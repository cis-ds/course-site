---
title: "Practice transforming college education (data)"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/datawrangle_transform_college.html"]
categories: ["datawrangle"]

menu:
  notes:
    parent: Data wrangling
    weight: 3
---




```r
library(tidyverse)
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/data-transformation")
```

{{% /callout %}}

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2018-19 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub. To install the package, run the command `devtools::install_github("uc-cfss/rcfss")` in the console.

{{% callout warning %}}

If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages("devtools")`, then run `devtools::install_github("uc-cfss/rcfss")`.

{{% /callout %}}


```r
library(rcfss)
data("scorecard")
glimpse(scorecard)
```

```
## Rows: 1,753
## Columns: 15
## $ unitid    <int> 420325, 430485, 100654, 102234, 100724, 106467, 106704, 109…
## $ name      <chr> "Yeshiva D'monsey Rabbinical College", "The Creative Center…
## $ state     <chr> "NY", "NE", "AL", "AL", "AL", "AR", "AR", "CA", "CA", "CA",…
## $ type      <fct> "Private, nonprofit", "Private, for-profit", "Public", "Pri…
## $ admrate   <dbl> 0.5313, 0.6667, 0.8986, 0.6577, 0.9774, 0.9024, 0.9110, 0.6…
## $ satavg    <dbl> NA, NA, 957, 1130, 972, NA, 1186, NA, 1566, NA, NA, 1053, 1…
## $ cost      <int> 14874, 41627, 22489, 51969, 21476, 18627, 21350, 64097, 689…
## $ netcost   <dbl> 4018, 39020, 14444, 19718, 13043, 12362, 14723, 43010, 2382…
## $ avgfacsal <dbl> 26253, 54000, 63909, 60048, 69786, 61497, 63360, 69984, 179…
## $ pctpell   <dbl> 0.9583, 0.5294, 0.7067, 0.3420, 0.7448, 0.3955, 0.4298, 0.3…
## $ comprate  <dbl> 0.6667, 0.6667, 0.2685, 0.5864, 0.3001, 0.4069, 0.4113, 0.7…
## $ firstgen  <dbl> NA, NA, 0.3658281, 0.2516340, 0.3434343, 0.4574780, 0.34595…
## $ debt      <dbl> NA, 12000, 15500, 18270, 18679, 12000, 13100, 27811, 8013, …
## $ locale    <fct> Suburb, City, City, City, City, Town, City, City, City, Cit…
## $ openadmp  <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, No,…
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
## # A tibble: 352 x 15
##    unitid name  state type  admrate satavg  cost netcost avgfacsal pctpell
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>   <dbl>     <dbl>   <dbl>
##  1 106467 Arka… AR    Publ…   0.902     NA 18627   12362     61497   0.396
##  2 422695 Paci… CA    Priv…   0.6       NA    NA   23451     33750   0.258
##  3 243665 Univ… VI    Publ…   0.978     NA 17349   11714     63900   0.552
##  4 242972 Nati… PR    Priv…   0.574     NA 12941    7268     27216   0.804
##  5 237358 Davi… WV    Priv…   0.370   1005 40551   17405     51120   0.450
##  6 243832 EDP … PR    Priv…   0.858     NA 13880    7326     22131   0.577
##  7 169327 Clea… MI    Priv…   0.580   1039 30418   18299     45666   0.366
##  8 167251 Newb… MA    Priv…   0.768     NA 50096   23324     62973   0.580
##  9 176044 Miss… MS    Publ…   0.863    945 20073   15874     52182   0.692
## 10 177214 Drur… MO    Priv…   0.682   1227 38330   18595     59661   0.295
## # … with 342 more rows, and 5 more variables: comprate <dbl>, firstgen <dbl>,
## #   debt <dbl>, locale <fct>, openadmp <fct>
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
## # A tibble: 10 x 15
##    unitid name  state type  admrate satavg  cost netcost avgfacsal pctpell
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>   <dbl>     <dbl>   <dbl>
##  1 192040 Jewi… NY    Priv…   0.468   1444 74504   50794     99369  0.0443
##  2 136774 Ring… FL    Priv…   0.669     NA 64554   49515     77022  0.282 
##  3 166489 Long… MA    Priv…   0.906     NA 55170   49433     44946  0.130 
##  4 164748 Berk… MA    Priv…   0.476     NA 63027   48425     88200  0.170 
##  5 111081 Cali… CA    Priv…   0.230     NA 69015   47921     79425  0.262 
##  6 449384 Gnom… CA    Priv…   0.368     NA 50766   47473     81000  0.169 
##  7 192712 Manh… NY    Priv…   0.378     NA 67051   45952     72747  0.127 
##  8 194578 Prat… NY    Priv…   0.507   1213 65249   45559     96525  0.218 
##  9 122454 San … CA    Priv…   0.949     NA 69525   45203     62352  0.308 
## 10 197151 Scho… NY    Priv…   0.7     1202 58397   44473     28476  0.210 
## # … with 5 more variables: comprate <dbl>, firstgen <dbl>, debt <dbl>,
## #   locale <fct>, openadmp <fct>
```

We can also use the `slice_max()` function in `dplyr` to accomplish the same thing in one line of code.


```r
slice_max(.data = scorecard, n = 10, netcost)
```

```
## # A tibble: 10 x 15
##    unitid name  state type  admrate satavg  cost netcost avgfacsal pctpell
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>   <dbl>     <dbl>   <dbl>
##  1 192040 Jewi… NY    Priv…   0.468   1444 74504   50794     99369  0.0443
##  2 136774 Ring… FL    Priv…   0.669     NA 64554   49515     77022  0.282 
##  3 166489 Long… MA    Priv…   0.906     NA 55170   49433     44946  0.130 
##  4 164748 Berk… MA    Priv…   0.476     NA 63027   48425     88200  0.170 
##  5 111081 Cali… CA    Priv…   0.230     NA 69015   47921     79425  0.262 
##  6 449384 Gnom… CA    Priv…   0.368     NA 50766   47473     81000  0.169 
##  7 192712 Manh… NY    Priv…   0.378     NA 67051   45952     72747  0.127 
##  8 194578 Prat… NY    Priv…   0.507   1213 65249   45559     96525  0.218 
##  9 122454 San … CA    Priv…   0.949     NA 69525   45203     62352  0.308 
## 10 197151 Scho… NY    Priv…   0.7     1202 58397   44473     28476  0.210 
## # … with 5 more variables: comprate <dbl>, firstgen <dbl>, debt <dbl>,
## #   locale <fct>, openadmp <fct>
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
## `summarise()` ungrouping output (override with `.groups` argument)
```

```
## # A tibble: 3 x 2
##   type                mean_sat
##   <fct>                  <dbl>
## 1 Public                 1129.
## 2 Private, nonprofit     1153.
## 3 Private, for-profit    1068.
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
## # A tibble: 1,753 x 2
##    name                                ratio
##    <chr>                               <dbl>
##  1 Yeshiva D'monsey Rabbinical College  6.53
##  2 The Creative Center                  1.38
##  3 Alabama A & M University             4.42
##  4 Spring Hill College                  3.05
##  5 Alabama State University             5.35
##  6 Arkansas Tech University             4.97
##  7 University of Central Arkansas       4.30
##  8 Art Center College of Design         1.63
##  9 California Institute of Technology   7.55
## 10 Cogswell College                     2.11
## # … with 1,743 more rows
```

{{< /spoiler >}}

## Calculate how many private, nonprofit schools have a smaller net cost than the University of Chicago

Hint: the result should be a data frame with one row for the University of Chicago, and a column containing the requested value.

### Report the number as the total number of schools

{{< spoiler text="Click for the solution" >}}


```r
scorecard %>%
  filter(type == "Private, nonprofit") %>%
  arrange(netcost) %>%
  # use row_number() but subtract 1 since UChicago is not cheaper than itself
  mutate(school_cheaper = row_number() - 1) %>%
  filter(name == "University of Chicago") %>%
  glimpse()
```

```
## Rows: 1
## Columns: 16
## $ unitid         <int> 144050
## $ name           <chr> "University of Chicago"
## $ state          <chr> "IL"
## $ type           <fct> "Private, nonprofit"
## $ admrate        <dbl> 0.0726
## $ satavg         <dbl> 1520
## $ cost           <int> 75735
## $ netcost        <dbl> 26160
## $ avgfacsal      <dbl> 166221
## $ pctpell        <dbl> 0.1089
## $ comprate       <dbl> 0.9423
## $ firstgen       <dbl> 0.2024353
## $ debt           <dbl> 15000
## $ locale         <fct> City
## $ openadmp       <fct> No
## $ school_cheaper <dbl> 777
```

{{< /spoiler >}}

### Report the number as the percentage of schools

{{< spoiler text="Click for the solution" >}}


```r
scorecard %>%
  filter(type == "Private, nonprofit") %>%
  mutate(netcost_rank = percent_rank(netcost)) %>%
  filter(name == "University of Chicago") %>%
  glimpse()
```

```
## Rows: 1
## Columns: 16
## $ unitid       <int> 144050
## $ name         <chr> "University of Chicago"
## $ state        <chr> "IL"
## $ type         <fct> "Private, nonprofit"
## $ admrate      <dbl> 0.0726
## $ satavg       <dbl> 1520
## $ cost         <int> 75735
## $ netcost      <dbl> 26160
## $ avgfacsal    <dbl> 166221
## $ pctpell      <dbl> 0.1089
## $ comprate     <dbl> 0.9423
## $ firstgen     <dbl> 0.2024353
## $ debt         <dbl> 15000
## $ locale       <fct> City
## $ openadmp     <fct> No
## $ netcost_rank <dbl> 0.7141544
```

{{< /spoiler >}}

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.3 (2020-10-10)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-01-21                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source                              
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports     1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown      1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown      0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom         0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  cli           2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace    2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr        2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr       * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics      0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2     * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools     0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate     1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  pillar        1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx      3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps            1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  Rcpp          1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr       * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes       2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown     2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest         0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat      3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble      * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr       * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis       2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun          0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
