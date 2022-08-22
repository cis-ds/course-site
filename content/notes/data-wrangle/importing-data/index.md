---
title: "Importing data into R"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/datawrangle_import_functions.html", "/notes/importing-data"]
categories: ["datawrangle"]

weight: 36
---




```r
library(tidyverse)
library(here)
theme_set(theme_minimal())

# set seed for reproducibility
set.seed(1234)
```

## `readr` vs. base R



One of the main advantages of `readr` functions over base R functions is that [they are typically much faster](http://r4ds.had.co.nz/data-import.html#compared-to-base-r). For example, let's import a randomly generated CSV file with 5,000 rows and 4 columns. How long does it take `read.csv()` to import this file vs. `readr::read_csv()`? To assess the differences, we use the [`microbenchmark`](https://cran.r-project.org/web/packages/microbenchmark/) to run each function 100 times and compare the distributions of the time it takes to complete the data import:


```r
library(microbenchmark)

results_small <- microbenchmark(
  read.csv = read.csv(file = here("static", "data", "sim-data-small.csv")),
  read_csv = read_csv(file = here("static", "data", "sim-data-small.csv"))
)
```

```
## Warning in microbenchmark(read.csv = read.csv(file = here("static", "data", :
## less accurate nanosecond times to avoid potential integer overflows
```


```r
autoplot(object = results_small) +
  scale_y_log10() +
  labs(y = "Time [milliseconds], logged")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/compare-speed-small-plot-1.png" width="672" />

`read_csv()` is over 5 times faster than `read.csv()`. Of course with relatively small data files, this isn't a large difference in absolute terms (a difference of 100 milliseconds is only .1 second). However, as the data file increases in size the performance savings will be much larger. Consider the same test with a CSV file with 500,000 rows:


```r
library(microbenchmark)

results_large <- microbenchmark(
  read.csv = read.csv(file = here("static", "data", "sim-data-large.csv")),
  read_csv = read_csv(file = here("static", "data", "sim-data-large.csv"))
)
```


```r
autoplot(object = results_large) +
  scale_y_log10() +
  labs(y = "Time [milliseconds], logged")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/compare-speed-large-plot-1.png" width="672" />

Here `read_csv()` is far superior to `read.csv()`.

## `vroom`

[`vroom`](https://vroom.r-lib.org/) is a recently developed package designed specifically for **speed**. It contains one of the fastest functions to import plain-text data files. Its syntax is similar to `readr::read_*()` functions, but works much more quickly.


```r
results_vroom <- microbenchmark(
  read.csv = read.csv(file = here("static", "data", "sim-data-large.csv")),
  read_csv = read_csv(file = here("static", "data", "sim-data-large.csv")),
  vroom = vroom::vroom(file = here("static", "data", "sim-data-large.csv"))
)
```


```r
autoplot(object = results_vroom) +
  scale_y_log10() +
  labs(y = "Time [milliseconds], logged")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/vroom-compare-speed-large-plot-1.png" width="672" />

## Alternative file formats

CSV files, while common, are not the only type of data storage format you will encounter in the wild. Here is a quick primer on other file formats you may encounter and how to import/export them using R. We'll use the `challenge` dataset in `readr` to demonstrate some of these formats.


```r
challenge <- read_csv(
  readr_example(file = "challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

challenge
```

```
## # A tibble: 2,000 × 2
##        x y     
##    <dbl> <date>
##  1   404 NA    
##  2  4172 NA    
##  3  3004 NA    
##  4   787 NA    
##  5    37 NA    
##  6  2332 NA    
##  7  2489 NA    
##  8  1449 NA    
##  9  3665 NA    
## 10  3863 NA    
## # … with 1,990 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

## RDS

**RDS** is a custom binary format used exclusively by R to store data objects.


```r
# write to csv
write_csv(x = challenge, file = here("static", "data", "challenge.csv"))

# write to/read from rds
write_rds(x = challenge, file = here("static", "data", "challenge.csv"))
read_rds(file = here("static", "data", "challenge.csv"))
```

```
## # A tibble: 2,000 × 2
##        x y     
##    <dbl> <date>
##  1   404 NA    
##  2  4172 NA    
##  3  3004 NA    
##  4   787 NA    
##  5    37 NA    
##  6  2332 NA    
##  7  2489 NA    
##  8  1449 NA    
##  9  3665 NA    
## 10  3863 NA    
## # … with 1,990 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

```r
# compare file size
file.info(here("static", "data", "challenge.rds"))$size %>%
  utils:::format.object_size("auto")
```

```
## [1] "11.6 Kb"
```

```r
file.info(here("static", "data", "challenge.csv"))$size %>%
  utils:::format.object_size("auto")
```

```
## [1] "32 Kb"
```

```r
# compare read speeds
microbenchmark(
  read_csv = read_csv(
    file = readr_example("challenge.csv"),
    col_types = cols(
      x = col_double(),
      y = col_date()
    )
  ),
  read_rds = read_rds(file = here("static", "data", "challenge.rds"))
) %>%
  autoplot() +
  labs(y = "Time [microseconds], logged")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/rds-1.png" width="672" />

By default, `write_rds()` does not compress the `.rds` file; use the `compress` argument to implement one of several different compression algorithms. `read_rds()` is noticably faster than `read_csv()`, and also has the benefit of [preserving column types](http://r4ds.had.co.nz/data-import.html#writing-to-a-file). The downside is that RDS is only implemented by R; it is not used by any other program so if you need to import/export data files into other languages like Python (or open in Excel), RDS is not a good storage format.

## `arrow`

The `arrow` package implements a binary file format called `feather` that is cross-compatible with many different programming languages:


```r
library(arrow)

write_feather(x = challenge, sink = here("static", "data", "challenge.feather"))
read_feather(file = here("static", "data", "challenge.feather"))
```

```
## # A tibble: 2,000 × 2
##        x y     
##  * <dbl> <date>
##  1   404 NA    
##  2  4172 NA    
##  3  3004 NA    
##  4   787 NA    
##  5    37 NA    
##  6  2332 NA    
##  7  2489 NA    
##  8  1449 NA    
##  9  3665 NA    
## 10  3863 NA    
## # … with 1,990 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

```r
# compare read speeds
microbenchmark(
  read_csv = read_csv(
    file = readr_example("challenge.csv"),
    col_types = cols(
      x = col_double(),
      y = col_date()
    )
  ),
  read_rds = read_rds(file = here("static", "data", "challenge.rds")),
  read_feather = read_feather(file = here("static", "data", "challenge.feather"))
) %>%
  autoplot() +
  scale_y_continuous(labels = scales::comma) +
  labs(y = "Time [microseconds], logged")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/feather-1.png" width="672" />

`read_feather()` is generally faster than RDS and `read_csv()`.^[Notice that the x-axis is logarithmically scaled.] Furthermore, [it has native support for Python, R, and Julia.](http://arrow.apache.org/blog/2019/08/08/r-package-on-cran/), so if you develop an analytics pipeline that switches between R and Python, you can import/export data files in `.feather` without any loss of information.

## `readxl`

[`readxl`](http://readxl.tidyverse.org/) enables you to read (but not write) Excel files (`.xls` and `xlsx`).^[If you need to export data into Excel, use `readr::write_csv_excel()`.]


```r
library(readxl)

xlsx_example <- readxl_example(path = "datasets.xlsx")
read_excel(xlsx_example)
```

```
## # A tibble: 150 × 5
##    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
##           <dbl>       <dbl>        <dbl>       <dbl> <chr>  
##  1          5.1         3.5          1.4         0.2 setosa 
##  2          4.9         3            1.4         0.2 setosa 
##  3          4.7         3.2          1.3         0.2 setosa 
##  4          4.6         3.1          1.5         0.2 setosa 
##  5          5           3.6          1.4         0.2 setosa 
##  6          5.4         3.9          1.7         0.4 setosa 
##  7          4.6         3.4          1.4         0.3 setosa 
##  8          5           3.4          1.5         0.2 setosa 
##  9          4.4         2.9          1.4         0.2 setosa 
## 10          4.9         3.1          1.5         0.1 setosa 
## # … with 140 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

The nice thing about `readxl` is that you can access multiple sheets from the workbook. List the sheet names with `excel_sheets()`:


```r
excel_sheets(path = xlsx_example)
```

```
## [1] "iris"     "mtcars"   "chickwts" "quakes"
```

Then specify which worksheet you want by name or number:


```r
read_excel(path = xlsx_example, sheet = "chickwts")
```

```
## # A tibble: 71 × 2
##    weight feed     
##     <dbl> <chr>    
##  1    179 horsebean
##  2    160 horsebean
##  3    136 horsebean
##  4    227 horsebean
##  5    217 horsebean
##  6    168 horsebean
##  7    108 horsebean
##  8    124 horsebean
##  9    143 horsebean
## 10    140 horsebean
## # … with 61 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

```r
read_excel(path = xlsx_example, sheet = 2)
```

```
## # A tibble: 32 × 11
##      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
##  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
##  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
##  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
##  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
##  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
##  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
##  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
##  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
##  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
## 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
## # … with 22 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

## `haven`

[`haven`](http://haven.tidyverse.org/) allows you to read and write data from other statistical packages such as SAS (`.sas7bdat` + `.sas7bcat`), SPSS (`.sav` + `.por`), and Stata (`.dta`).


```r
library(haven)
library(palmerpenguins)

# SAS
read_sas(data_file = system.file("examples", "iris.sas7bdat", package = "haven"))
```

```
## # A tibble: 150 × 5
##    Sepal_Length Sepal_Width Petal_Length Petal_Width Species
##           <dbl>       <dbl>        <dbl>       <dbl> <chr>  
##  1          5.1         3.5          1.4         0.2 setosa 
##  2          4.9         3            1.4         0.2 setosa 
##  3          4.7         3.2          1.3         0.2 setosa 
##  4          4.6         3.1          1.5         0.2 setosa 
##  5          5           3.6          1.4         0.2 setosa 
##  6          5.4         3.9          1.7         0.4 setosa 
##  7          4.6         3.4          1.4         0.3 setosa 
##  8          5           3.4          1.5         0.2 setosa 
##  9          4.4         2.9          1.4         0.2 setosa 
## 10          4.9         3.1          1.5         0.1 setosa 
## # … with 140 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

```r
write_sas(data = penguins, path = here("static", "data", "penguins.sas7bdat"))

# SPSS
read_sav(file = system.file("examples", "iris.sav", package = "haven"))
```

```
## # A tibble: 150 × 5
##    Sepal.Length Sepal.Width Petal.Length Petal.Width    Species
##           <dbl>       <dbl>        <dbl>       <dbl>  <dbl+lbl>
##  1          5.1         3.5          1.4         0.2 1 [setosa]
##  2          4.9         3            1.4         0.2 1 [setosa]
##  3          4.7         3.2          1.3         0.2 1 [setosa]
##  4          4.6         3.1          1.5         0.2 1 [setosa]
##  5          5           3.6          1.4         0.2 1 [setosa]
##  6          5.4         3.9          1.7         0.4 1 [setosa]
##  7          4.6         3.4          1.4         0.3 1 [setosa]
##  8          5           3.4          1.5         0.2 1 [setosa]
##  9          4.4         2.9          1.4         0.2 1 [setosa]
## 10          4.9         3.1          1.5         0.1 1 [setosa]
## # … with 140 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

```r
write_sav(data = penguins, path = here("static", "data", "penguins.sav"))

# Stata
read_dta(file = system.file("examples", "iris.dta", package = "haven"))
```

```
## # A tibble: 150 × 5
##    sepallength sepalwidth petallength petalwidth species
##          <dbl>      <dbl>       <dbl>      <dbl> <chr>  
##  1        5.10       3.5         1.40      0.200 setosa 
##  2        4.90       3           1.40      0.200 setosa 
##  3        4.70       3.20        1.30      0.200 setosa 
##  4        4.60       3.10        1.5       0.200 setosa 
##  5        5          3.60        1.40      0.200 setosa 
##  6        5.40       3.90        1.70      0.400 setosa 
##  7        4.60       3.40        1.40      0.300 setosa 
##  8        5          3.40        1.5       0.200 setosa 
##  9        4.40       2.90        1.40      0.200 setosa 
## 10        4.90       3.10        1.5       0.100 setosa 
## # … with 140 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

```r
write_dta(data = penguins, path = here("static", "data", "penguins.dta"))
```

That said, if you can obtain your data file in a plain `.csv` or `.tsv` file format, **I strongly recommend it**. SAS, SPSS, and Stata files represent labeled data and missing values differently from R. `haven` attempts to bridge the gap and preserve as much information as possible, but I frequently find myself stripping out all the label information and rebuilding it using `dplyr` functions and the codebook for the data file.

{{% callout note %}}

Need to import a SAS, SPSS, or Stata data file? Read [the documentation](http://haven.tidyverse.org/articles/semantics.html) to learn how to best handle value labels and missing values.

{{% /callout %}}

## Session Info



```r
sessioninfo::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.2.1 (2022-06-23)
##  os       macOS Monterey 12.3
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/New_York
##  date     2022-08-22
##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  assertthat      0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown        1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  cli             3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs              1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2       * 3.3.6      2022-05-03 [2] CRAN (R 4.2.0)
##  glue            1.6.2      2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive     2.0.0      2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4   1.0.0      2021-07-21 [2] CRAN (R 4.2.0)
##  gtable          0.3.0      2019-03-25 [2] CRAN (R 4.2.0)
##  haven           2.5.0      2022-04-15 [2] CRAN (R 4.2.0)
##  here          * 1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  hms             1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools       0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr            1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr           1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate       1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr          0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6              2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  readr         * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl          1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex          2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  rlang           1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown       2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest           1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo     1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  stringi         1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  utf8            1.2.2      2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs           0.4.1      2022-04-13 [2] CRAN (R 4.2.0)
##  withr           2.5.0      2022-03-03 [2] CRAN (R 4.2.0)
##  xfun            0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2            1.3.3      2021-11-30 [2] CRAN (R 4.2.0)
##  yaml            2.3.5      2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```
