---
title: "Practice the pipe"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/program_pipes_exercise.html"]
categories: ["programming"]

menu:
  notes:
    parent: Programming elements
    weight: 2
---




```r
library(tidyverse)
library(rcfss)
```

Using `gun_deaths` from the `rcfss` library, answer the following question:

> For each education category, how many white males where killed in 2012?

Write your code using all four methods:

* Intermediate steps
* Overwrite the original
* Function composition
* Piping


```r
data("gun_deaths")
gun_deaths
```

```
## # A tibble: 100,798 x 10
##       id  year month intent  police sex     age race      place   education
##    <int> <int> <dbl> <chr>    <int> <chr> <int> <chr>     <chr>   <fct>    
##  1     1  2012     1 Suicide      0 M        34 Asian/Pa… Home    BA+      
##  2     2  2012     1 Suicide      0 F        21 White     Street  Some col…
##  3     3  2012     1 Suicide      0 M        60 White     Other … BA+      
##  4     4  2012     2 Suicide      0 M        64 White     Home    BA+      
##  5     5  2012     2 Suicide      0 M        31 White     Other … HS/GED   
##  6     6  2012     2 Suicide      0 M        17 Native A… Home    Less tha…
##  7     7  2012     2 Undete…      0 M        48 White     Home    HS/GED   
##  8     8  2012     3 Suicide      0 M        41 Native A… Home    HS/GED   
##  9     9  2012     2 Accide…      0 M        50 White     Other … Some col…
## 10    10  2012     2 Suicide      0 M        NA Black     Home    <NA>     
## # … with 100,788 more rows
```

## Intermediate steps

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
gun_deaths1 <- filter(gun_deaths, sex == "M", race == "White", year == 2012)
gun_deaths2 <- group_by(gun_deaths1, education)
```

```
## Warning: Factor `education` contains implicit NA, consider using
## `forcats::fct_explicit_na`
```

```r
(gun_deaths3 <- summarize(gun_deaths2, n = n()))
```

```
## # A tibble: 5 x 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

  </p>
</details>

## Overwrite the original

Hint: make sure to save a copy of `gun_deaths` as `gun_deaths2` for this code chunk.

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
gun_deaths2 <- gun_deaths       # copy for demonstration purposes

gun_deaths2 <- filter(gun_deaths2, sex == "M", race == "White", year == 2012)
gun_deaths2 <- group_by(gun_deaths2, education)
```

```
## Warning: Factor `education` contains implicit NA, consider using
## `forcats::fct_explicit_na`
```

```r
(gun_deaths2 <- summarize(gun_deaths2, n = n()))
```

```
## # A tibble: 5 x 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

  </p>
</details>

## Function composition

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
summarize(
  group_by(
    filter(gun_deaths, sex == "M", race == "White", year == 2012),
    education),
  n = n()
)
```

```
## Warning: Factor `education` contains implicit NA, consider using
## `forcats::fct_explicit_na`
```

```
## # A tibble: 5 x 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

  </p>
</details>

## Piped operation

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
gun_deaths %>%
  filter(sex == "M", race == "White", year == 2012) %>%
  group_by(education) %>%
  summarize(n = n())
```

```
## Warning: Factor `education` contains implicit NA, consider using
## `forcats::fct_explicit_na`
```

```
## # A tibble: 5 x 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

```r
# alternative using count()
gun_deaths %>%
  filter(sex == "M", race == "White", year == 2012) %>%
  count(education)
```

```
## Warning: Factor `education` contains implicit NA, consider using
## `forcats::fct_explicit_na`
```

```
## # A tibble: 5 x 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

Note that all methods produce the same answer. But which did you find easiest to implement?

  </p>
</details>

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-09-15                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  rcfss       * 0.1.8   2019-08-27 [1] local         
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
