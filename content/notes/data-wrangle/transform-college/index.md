---
title: "Practice transforming college education (data)"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/datawrangle_transform_college.html"]
categories: ["datawrangle"]

weight: 33
---




```r
library(tidyverse)
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("cis-ds/data-transformation")
```

{{% /callout %}}

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2018-19 in the [`rcis`](https://github.com/cis-ds/rcis) library from GitHub. To install the package, run the command `remotes::install_github("cis-ds/rcis")` in the console.

{{% callout warning %}}

If you don't already have the `remotes` library installed, you will get an error. Go back and install this first using `install.packages("remotes")`, then run `remotes::install_github("cis-ds/rcis")`.

{{% /callout %}}


```r
library(rcis)
```

```
## 
## Attaching package: 'rcis'
```

```
## The following objects are masked from 'package:rcfss':
## 
##     add_ci, bechdel, cfss_notes, cfss_slides, err.rate.rf,
##     err.rate.tree, logit2prob, mse, mse_vec, plot_ci, prob2logodds,
##     prob2odds, xaringan, xaringan_wide
```

```r
data("scorecard")
glimpse(scorecard)
```

```
## Rows: 1,732
## Columns: 14
## $ unitid    <dbl> 100654, 100663, 100706, 100724, 100751, 100830, 100858, 1009…
## $ name      <chr> "Alabama A & M University", "University of Alabama at Birmin…
## $ state     <chr> "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", …
## $ type      <fct> "Public", "Public", "Public", "Public", "Public", "Public", …
## $ admrate   <dbl> 0.9175, 0.7366, 0.8257, 0.9690, 0.8268, 0.9044, 0.8067, 0.53…
## $ satavg    <dbl> 939, 1234, 1319, 946, 1261, 1082, 1300, 1230, 1066, NA, 1076…
## $ cost      <dbl> 23053, 24495, 23917, 21866, 29872, 19849, 31590, 32095, 3431…
## $ netcost   <dbl> 14990, 16953, 15860, 13650, 22597, 13987, 24104, 22107, 2071…
## $ avgfacsal <dbl> 69381, 99441, 87192, 64989, 92619, 71343, 96642, 56646, 5400…
## $ pctpell   <dbl> 0.7019, 0.3512, 0.2536, 0.7627, 0.1772, 0.4644, 0.1455, 0.23…
## $ comprate  <dbl> 0.2974, 0.6340, 0.5768, 0.3276, 0.7110, 0.3401, 0.7911, 0.69…
## $ firstgen  <dbl> 0.3658281, 0.3412237, 0.3101322, 0.3434343, 0.2257127, 0.381…
## $ debt      <dbl> 15250, 15085, 14000, 17500, 17671, 12000, 17500, 16000, 1425…
## $ locale    <fct> City, City, City, City, City, City, City, City, City, Suburb…
```

{{% callout note %}}

`glimpse()` is part of the `tibble` package and is a transposed version of `print()`: columns run down the page, and data runs across. With a data frame with multiple columns, sometimes there is not enough horizontal space on the screen to print each column. By transposing the data frame, we can see all the columns and the values recorded for the initial rows.

{{% /callout %}}

Type `?scorecard` in the console to open up the help file for this data set. This includes the documentation for all the variables. Use your knowledge of the `dplyr` functions to perform the following tasks.

## Generate a data frame of schools with a greater than 40% share of first-generation students

{{< spoiler text="Click for the solution" >}}


```r
filter(.data = scorecard, firstgen > .40)
```

```
## # A tibble: 356 × 14
##    unitid name  state type  admrate satavg  cost netcost avgfa…¹ pctpell compr…²
##     <dbl> <chr> <chr> <fct>   <dbl>  <dbl> <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
##  1 101189 Faul… AL    Priv…   0.783   1066 34317   20715   54009   0.488   0.329
##  2 101365 Herz… AL    Priv…   0.783     NA 30119   26680   54684   0.706   0.28 
##  3 101541 Juds… AL    Priv…   0.372   1020 32691   16827   52020   0.545   0.364
##  4 101587 Univ… AL    Publ…   0.349   1041 21657   15514   58329   0.535   0.350
##  5 102270 Stil… AL    Priv…   0.330     NA 25413   18352   43605   0.709   0.272
##  6 104717 Gran… AZ    Priv…   0.769     NA 31213   21020   60741   0.454   0.408
##  7 106467 Arka… AR    Publ…   0.947     NA 18358   10772   61812   0.361   0.384
##  8 107983 Sout… AR    Publ…   0.651   1085 22579   14270   61650   0.487   0.436
##  9 110361 Cali… CA    Priv…   0.783   1096 46261   24707   88335   0.453   0.630
## 10 110486 Cali… CA    Publ…   0.807     NA 16660    5318   86760   0.619   0.430
## # … with 346 more rows, 3 more variables: firstgen <dbl>, debt <dbl>,
## #   locale <fct>, and abbreviated variable names ¹​avgfacsal, ²​comprate
## # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

{{< /spoiler >}}

## Generate a data frame with the 10 most expensive colleges in 2018-19 based on net cost of attendance

{{< spoiler text="Click for the solution" >}}

We could use a combination of `arrange()` and `slice()` to sort the data frame from most to least expensive, then keep the first 10 rows:


```r
arrange(.data = scorecard, desc(netcost)) %>%
  slice(1:10)
```

```
## # A tibble: 10 × 14
##    unitid name  state type  admrate satavg  cost netcost avgfa…¹ pctpell compr…²
##     <dbl> <chr> <chr> <fct>   <dbl>  <dbl> <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
##  1 192712 Manh… NY    Priv…   0.355     NA 68686   54902   73863   0.129   0.876
##  2 111081 Cali… CA    Priv…   0.253     NA 71382   50412   86760   0.248   0.614
##  3 136774 Ring… FL    Priv…   0.639     NA 67325   49649   78435   0.284   0.672
##  4 164748 Berk… MA    Priv…   0.514     NA 64436   49514   93870   0.166   0.652
##  5 247649 Land… VT    Priv…   0.470     NA 73821   47373   59373   0.219   0.416
##  6 109651 Art … CA    Priv…   0.708     NA 64316   47080   71523   0.283   0.685
##  7 135726 Univ… FL    Priv…   0.271   1371 67249   46949  115353   0.143   0.831
##  8 194578 Prat… NY    Priv…   0.555   1273 67703   45571  101079   0.198   0.704
##  9 165662 Emer… MA    Priv…   0.334   1318 68350   45365   90747   0.161   0.821
## 10 143048 Scho… IL    Priv…   0.570   1238 67058   44815   96102   0.192   0.699
## # … with 3 more variables: firstgen <dbl>, debt <dbl>, locale <fct>, and
## #   abbreviated variable names ¹​avgfacsal, ²​comprate
## # ℹ Use `colnames()` to see all variable names
```

We can also use the `slice_max()` function in `dplyr` to accomplish the same thing in one line of code.


```r
slice_max(.data = scorecard, order_by = netcost, n = 10)
```

```
## # A tibble: 10 × 14
##    unitid name  state type  admrate satavg  cost netcost avgfa…¹ pctpell compr…²
##     <dbl> <chr> <chr> <fct>   <dbl>  <dbl> <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
##  1 192712 Manh… NY    Priv…   0.355     NA 68686   54902   73863   0.129   0.876
##  2 111081 Cali… CA    Priv…   0.253     NA 71382   50412   86760   0.248   0.614
##  3 136774 Ring… FL    Priv…   0.639     NA 67325   49649   78435   0.284   0.672
##  4 164748 Berk… MA    Priv…   0.514     NA 64436   49514   93870   0.166   0.652
##  5 247649 Land… VT    Priv…   0.470     NA 73821   47373   59373   0.219   0.416
##  6 109651 Art … CA    Priv…   0.708     NA 64316   47080   71523   0.283   0.685
##  7 135726 Univ… FL    Priv…   0.271   1371 67249   46949  115353   0.143   0.831
##  8 194578 Prat… NY    Priv…   0.555   1273 67703   45571  101079   0.198   0.704
##  9 165662 Emer… MA    Priv…   0.334   1318 68350   45365   90747   0.161   0.821
## 10 143048 Scho… IL    Priv…   0.570   1238 67058   44815   96102   0.192   0.699
## # … with 3 more variables: firstgen <dbl>, debt <dbl>, locale <fct>, and
## #   abbreviated variable names ¹​avgfacsal, ²​comprate
## # ℹ Use `colnames()` to see all variable names
```

{{< /spoiler >}}

## Generate a data frame with the average SAT score for each type of college

{{< spoiler text="Click for the solution" >}}


```r
scorecard %>%
  group_by(type) %>%
  summarize(mean_sat = mean(satavg, na.rm = TRUE))
```

```
## # A tibble: 3 × 2
##   type                mean_sat
##   <fct>                  <dbl>
## 1 Public                 1126.
## 2 Private, nonprofit     1152.
## 3 Private, for-profit    1121.
```

{{< /spoiler >}}

## Calculate for each school how many students it takes to pay the average faculty member's salary and generate a data frame with the school's name and the calculated value

Note: use the net cost of attendance.

{{< spoiler text="Click for the solution" >}}


```r
scorecard %>%
  mutate(ratio = avgfacsal / netcost) %>%
  select(name, ratio)
```

```
## # A tibble: 1,732 × 2
##    name                                ratio
##    <chr>                               <dbl>
##  1 Alabama A & M University             4.63
##  2 University of Alabama at Birmingham  5.87
##  3 University of Alabama in Huntsville  5.50
##  4 Alabama State University             4.76
##  5 The University of Alabama            4.10
##  6 Auburn University at Montgomery      5.10
##  7 Auburn University                    4.01
##  8 Birmingham-Southern College          2.56
##  9 Faulkner University                  2.61
## 10 Herzing University-Birmingham        2.05
## # … with 1,722 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

{{< /spoiler >}}

## Calculate how many private, nonprofit schools have a smaller net cost than Cornell University

Hint: the result should be a data frame with one row for Cornell University, and a column containing the requested value.

### Report the number as the total number of schools

{{< spoiler text="Click for the solution" >}}


```r
scorecard %>%
  filter(type == "Private, nonprofit") %>%
  arrange(netcost) %>%
  # use row_number() but subtract 1 since Cornell is not cheaper than itself
  mutate(school_cheaper = row_number() - 1) %>%
  filter(name == "Cornell University") %>%
  glimpse()
```

```
## Rows: 1
## Columns: 15
## $ unitid         <dbl> 190415
## $ name           <chr> "Cornell University"
## $ state          <chr> "NY"
## $ type           <fct> "Private, nonprofit"
## $ admrate        <dbl> 0.1085
## $ satavg         <dbl> 1487
## $ cost           <dbl> 73879
## $ netcost        <dbl> 40126
## $ avgfacsal      <dbl> 140166
## $ pctpell        <dbl> 0.1683
## $ comprate       <dbl> 0.9453
## $ firstgen       <dbl> 0.154164
## $ debt           <dbl> 13108
## $ locale         <fct> City
## $ school_cheaper <dbl> 1043
```

{{< /spoiler >}}

### Report the number as the percentage of schools

{{< spoiler text="Click for the solution" >}}


```r
scorecard %>%
  filter(type == "Private, nonprofit") %>%
  mutate(netcost_rank = percent_rank(netcost)) %>%
  filter(name == "Cornell University") %>%
  glimpse()
```

```
## Rows: 1
## Columns: 15
## $ unitid       <dbl> 190415
## $ name         <chr> "Cornell University"
## $ state        <chr> "NY"
## $ type         <fct> "Private, nonprofit"
## $ admrate      <dbl> 0.1085
## $ satavg       <dbl> 1487
## $ cost         <dbl> 73879
## $ netcost      <dbl> 40126
## $ avgfacsal    <dbl> 140166
## $ pctpell      <dbl> 0.1683
## $ comprate     <dbl> 0.9453
## $ firstgen     <dbl> 0.154164
## $ debt         <dbl> 13108
## $ locale       <fct> City
## $ netcost_rank <dbl> 0.9702326
```

{{< /spoiler >}}

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
##  here            1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
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
