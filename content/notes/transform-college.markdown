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

{{% alert note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/data-transformation")
```

{{% /alert %}}

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2013 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub. To install the package, run the command `devtools::install_github("uc-cfss/rcfss")` in the console.

{{% alert warning %}}

If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages("devtools")`, then run `devtools::install_github("uc-cfss/rcfss")`.

{{% /alert %}}


```r
library(rcfss)
data("scorecard")
glimpse(scorecard)
```

```
## Rows: 1,733
## Columns: 14
## $ unitid    <int> 147244, 147341, 145691, 148131, 146667, 150774, 150941, 148…
## $ name      <chr> "Millikin University", "Monmouth College", "Illinois Colleg…
## $ state     <chr> "IL", "IL", "IL", "IL", "IL", "IN", "IN", "IL", "IL", "IN",…
## $ type      <fct> "Private, nonprofit", "Private, nonprofit", "Private, nonpr…
## $ admrate   <dbl> 0.6380, 0.5206, 0.5403, 0.6623, 0.5288, 0.9101, 0.8921, 0.4…
## $ satavg    <dbl> 1047, 1045, NA, 991, 1007, 1053, 1019, 1068, 1009, 1025, 10…
## $ cost      <int> 43149, 45005, 41869, 39686, 25542, 39437, 36227, 39175, 382…
## $ avgfacsal <dbl> 55197, 61101, 63765, 50166, 52713, 47367, 58563, 70425, 656…
## $ pctpell   <dbl> 0.4054, 0.4127, 0.4191, 0.3789, 0.4640, 0.2857, 0.3502, 0.3…
## $ comprate  <dbl> 0.6004, 0.5577, 0.6800, 0.5110, 0.6132, 0.4069, 0.6540, 0.6…
## $ firstgen  <dbl> 0.3184783, 0.3224401, 0.3109756, 0.3300493, 0.3122172, 0.28…
## $ debt      <dbl> 20375.0, 20000.0, 22300.0, 13000.0, 17500.0, 11000.0, 22500…
## $ locale    <fct> City, Town, Town, Town, Town, Suburb, Town, Suburb, City, C…
## $ openadmp  <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, No,…
```

{{% alert note %}}

`glimpse()` is part of the `tibble` package and is a transposed version of `print()`: columns run down the page, and data runs across. With a data frame with multiple columns, sometimes there is not enough horizontal space on the screen to print each column. By transposing the data frame, we can see all the columns and the values recorded for the initial rows.

{{% /alert %}}

Type `?scorecard` in the console to open up the help file for this data set. This includes the documentation for all the variables. Use your knowledge of the `dplyr` functions to perform the following tasks.

## Generate a data frame of schools with a greater than 40% share of first-generation students

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
filter(.data = scorecard, firstgen > .40)
```

```
## # A tibble: 356 x 14
##    unitid name  state type  admrate satavg  cost avgfacsal pctpell comprate
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>     <dbl>   <dbl>    <dbl>
##  1 148584 Univ… IL    Priv…   0.492   1068 39175     70425   0.382    0.629
##  2 148627 Sain… IL    Priv…   0.752   1009 38260     65619   0.533    0.510
##  3 165264 Labo… MA    Priv…   0.267     NA 37535     48357   0.428    0.167
##  4 167251 Newb… MA    Priv…   0.827     NA 43808     62973   0.577    0.419
##  5 169327 Clea… MI    Priv…   0.468    990 23983     45666   0.332    0.176
##  6 176044 Miss… MS    Publ…   0.844    825 20347     52182   0.717    0.312
##  7 176947 Cent… MO    Priv…   0.610   1023 35660     56907   0.398    0.465
##  8 178341 Miss… MO    Publ…   0.943    990 14419     52713   0.478    0.299
##  9 177214 Drur… MO    Priv…   0.700   1142 35054     59661   0.517    0.575
## 10 182281 Univ… NV    Publ…   0.828   1012 17131     97002   0.364    0.406
## # … with 346 more rows, and 4 more variables: firstgen <dbl>, debt <dbl>,
## #   locale <fct>, openadmp <fct>
```

  </p>
</details>

## Generate a data frame with the 10 most expensive colleges in 2013

<details> 
  <summary>Click for the solution</summary>
  <p>
  
  We could use a combination of `arrange()` and `slice()` to sort the data frame from most to least expensive, then keep the first 10 rows:
  

```r
arrange(.data = scorecard, desc(cost)) %>%
  slice(1:10)
```

```
## # A tibble: 10 x 14
##    unitid name  state type  admrate satavg  cost avgfacsal pctpell comprate
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>     <dbl>   <dbl>    <dbl>
##  1 144050 Univ… IL    Priv…  0.0794   1508 70100    166221  0.109     0.942
##  2 115409 Harv… CA    Priv…  0.129    1496 69355    123039  0.12      0.933
##  3 190150 Colu… NY    Priv…  0.0683   1496 69021    168867  0.224     0.941
##  4 147767 Nort… IL    Priv…  0.107    1470 67887    154701  0.142     0.935
##  5 212054 Drex… PA    Priv…  0.746    1204 67821     99576  0.220     0.698
##  6 179867 Wash… MO    Priv…  0.165    1472 67751    134640  0.0833    0.940
##  7 193900 New … NY    Priv…  0.319    1371 67637    126504  0.211     0.846
##  8 123961 Univ… CA    Priv…  0.166    1395 67064    132408  0.217     0.920
##  9 120254 Occi… CA    Priv…  0.458    1315 67046    101637  0.202     0.808
## 10 182670 Dart… NH    Priv…  0.106    1441 67044    137502  0.142     0.966
## # … with 4 more variables: firstgen <dbl>, debt <dbl>, locale <fct>,
## #   openadmp <fct>
```

 We can also use the `top_n()` function in `dplyr` to accomplish the same thing in one line of code.


```r
top_n(x = scorecard, n = 10, wt = cost)
```

```
## # A tibble: 10 x 14
##    unitid name  state type  admrate satavg  cost avgfacsal pctpell comprate
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>     <dbl>   <dbl>    <dbl>
##  1 179867 Wash… MO    Priv…  0.165    1472 67751    134640  0.0833    0.940
##  2 123961 Univ… CA    Priv…  0.166    1395 67064    132408  0.217     0.920
##  3 147767 Nort… IL    Priv…  0.107    1470 67887    154701  0.142     0.935
##  4 120254 Occi… CA    Priv…  0.458    1315 67046    101637  0.202     0.808
##  5 212054 Drex… PA    Priv…  0.746    1204 67821     99576  0.220     0.698
##  6 190150 Colu… NY    Priv…  0.0683   1496 69021    168867  0.224     0.941
##  7 115409 Harv… CA    Priv…  0.129    1496 69355    123039  0.12      0.933
##  8 182670 Dart… NH    Priv…  0.106    1441 67044    137502  0.142     0.966
##  9 144050 Univ… IL    Priv…  0.0794   1508 70100    166221  0.109     0.942
## 10 193900 New … NY    Priv…  0.319    1371 67637    126504  0.211     0.846
## # … with 4 more variables: firstgen <dbl>, debt <dbl>, locale <fct>,
## #   openadmp <fct>
```

  Notice that the resulting data frame is not sorted in order from most to least expensive - instead it is sorted in the original order from the data frame, but still only contains the 10 most expensive schools based on cost.
  
  </p>
</details>

## Generate a data frame with the average SAT score for each type of college

<details> 
  <summary>Click for the solution</summary>
  <p>
  

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
## 1 Public                 1049.
## 2 Private, nonprofit     1076.
## 3 Private, for-profit     980
```

  </p>
</details>

## Calculate for each school how many students it takes to pay the average faculty member's salary and generate a data frame with the school's name and the calculated value

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
scorecard %>%
  mutate(ratio = avgfacsal / cost) %>%
  select(name, ratio)
```

```
## # A tibble: 1,733 x 2
##    name                                              ratio
##    <chr>                                             <dbl>
##  1 Millikin University                                1.28
##  2 Monmouth College                                   1.36
##  3 Illinois College                                   1.52
##  4 Quincy University                                  1.26
##  5 Lincoln Christian University                       2.06
##  6 Holy Cross College                                 1.20
##  7 Huntington University                              1.62
##  8 University of St Francis                           1.80
##  9 Saint Xavier University                            1.72
## 10 Indiana University-Purdue University-Indianapolis  3.75
## # … with 1,723 more rows
```

  </p>
</details>

## Calculate how many private, nonprofit schools have a smaller cost than the University of Chicago

Hint: the result should be a data frame with one row for the University of Chicago, and a column containing the requested value.

### Report the number as the total number of schools

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
scorecard %>%
  filter(type == "Private, nonprofit") %>%
  arrange(cost) %>%
  # use row_number() but subtract 1 since UChicago is not cheaper than itself
  mutate(school_cheaper = row_number() - 1) %>%
  filter(name == "University of Chicago") %>%
  glimpse()
```

```
## Rows: 1
## Columns: 15
## $ unitid         <int> 144050
## $ name           <chr> "University of Chicago"
## $ state          <chr> "IL"
## $ type           <fct> "Private, nonprofit"
## $ admrate        <dbl> 0.0794
## $ satavg         <dbl> 1508
## $ cost           <int> 70100
## $ avgfacsal      <dbl> 166221
## $ pctpell        <dbl> 0.109
## $ comprate       <dbl> 0.9422
## $ firstgen       <dbl> 0.2024353
## $ debt           <dbl> 14853
## $ locale         <fct> City
## $ openadmp       <fct> No
## $ school_cheaper <dbl> 1066
```

  </p>
</details>

### Report the number as the percentage of schools

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
scorecard %>%
  filter(type == "Private, nonprofit") %>%
  mutate(cost_rank = percent_rank(cost)) %>%
  filter(name == "University of Chicago") %>%
  glimpse()
```

```
## Rows: 1
## Columns: 15
## $ unitid    <int> 144050
## $ name      <chr> "University of Chicago"
## $ state     <chr> "IL"
## $ type      <fct> "Private, nonprofit"
## $ admrate   <dbl> 0.0794
## $ satavg    <dbl> 1508
## $ cost      <int> 70100
## $ avgfacsal <dbl> 166221
## $ pctpell   <dbl> 0.109
## $ comprate  <dbl> 0.9422
## $ firstgen  <dbl> 0.2024353
## $ debt      <dbl> 14853
## $ locale    <fct> City
## $ openadmp  <fct> No
## $ cost_rank <dbl> 1
```

  </p>
</details>

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.2 (2020-06-22)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-09-29                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports     1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
##  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
##  blogdown      0.20.1  2020-07-02 [1] local         
##  bookdown      0.20    2020-06-23 [1] CRAN (R 4.0.2)
##  broom         0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
##  callr         3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools      2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
##  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr       * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
##  fs            1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
##  ggplot2     * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
##  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
##  here          0.1     2017-05-28 [1] CRAN (R 4.0.0)
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
##  jsonlite      1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
##  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.1)
##  lattice       0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
##  lubridate     1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  nlme          3.1-148 2020-05-24 [1] CRAN (R 4.0.2)
##  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
##  pkgbuild      1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
##  ps            1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
##  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes       2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
##  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
##  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
##  rstudioapi    0.11    2020-02-07 [1] CRAN (R 4.0.0)
##  rvest         0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
##  tibble      * 3.0.3   2020-07-10 [1] CRAN (R 4.0.1)
##  tidyr       * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
##  usethis       1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
##  vctrs         0.3.1   2020-06-05 [1] CRAN (R 4.0.1)
##  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
##  xfun          0.15    2020-06-21 [1] CRAN (R 4.0.1)
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
