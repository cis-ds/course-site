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

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2013 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub. To install the package, run the command `devtools::install_github("uc-cfss/rcfss")` in the console.

> If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages("devtools")`, then run `devtools::install_github("uc-cfss/rcfss")`.


```r
library(rcfss)
data("scorecard")
glimpse(scorecard)
```

```
## Observations: 1,849
## Variables: 12
## $ unitid    <int> 450234, 448479, 456427, 459596, 459851, 482477, 482547…
## $ name      <chr> "ITT Technical Institute-Wichita", "ITT Technical Inst…
## $ state     <chr> "KS", "MI", "CA", "FL", "WI", "IL", "NV", "OR", "TN", …
## $ type      <chr> "Private, for-profit", "Private, for-profit", "Private…
## $ cost      <int> 28306, 26994, 26353, 28894, 23928, 25625, 24265, NA, 2…
## $ admrate   <dbl> 81.31, 98.31, 89.26, 58.37, 68.75, 70.40, 80.00, 50.00…
## $ satavg    <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ avgfacsal <dbl> 45054, 52857, NA, 47196, 55089, 62793, 47556, 60003, 5…
## $ pctpell   <dbl> 0.8030, 0.7735, 0.7038, 0.7781, 0.6098, 0.6411, 0.6356…
## $ comprate  <dbl> 0.6000, 0.3359, NA, NA, NA, 0.2939, 0.6364, 0.0000, 0.…
## $ firstgen  <dbl> 0.5057590, 0.5057590, 0.5057590, 0.5057590, 0.5171601,…
## $ debt      <dbl> 13000, 13000, 13000, 13000, 9500, 14250, 14250, 14250,…
```

> `glimpse()` is part of the `tibble` package and is a transposed version of `print()`: columns run down the page, and data runs across. With a data frame with multiple columns, sometimes there is not enough horizontal space on the screen to print each column. By transposing the data frame, we can see all the columns and the values recorded for the initial rows.

Type `?scorecard` in the console to open up the help file for this data set. This includes the documentation for all the variables. Use your knowledge of the `dplyr` functions to perform the following tasks.

## Generate a data frame of schools with a greater than 40% share of first-generation students

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
filter(.data = scorecard, firstgen > .40)
```

```
## # A tibble: 578 x 12
##    unitid name  state type   cost admrate satavg avgfacsal pctpell comprate
##     <int> <chr> <chr> <chr> <int>   <dbl>  <dbl>     <dbl>   <dbl>    <dbl>
##  1 450234 ITT … KS    Priv… 28306    81.3     NA     45054   0.803    0.6  
##  2 448479 ITT … MI    Priv… 26994    98.3     NA     52857   0.774    0.336
##  3 456427 ITT … CA    Priv… 26353    89.3     NA        NA   0.704   NA    
##  4 459596 ITT … FL    Priv… 28894    58.4     NA     47196   0.778   NA    
##  5 459851 Herz… WI    Priv… 23928    68.8     NA     55089   0.610   NA    
##  6 482477 DeVr… IL    Priv… 25625    70.4     NA     62793   0.641    0.294
##  7 482547 DeVr… NV    Priv… 24265    80       NA     47556   0.636    0.636
##  8 482592 DeVr… OR    Priv…    NA    50       NA     60003   0.671    0    
##  9 482617 DeVr… TN    Priv… 20983    66.7     NA     51660   0.720    0    
## 10 482662 DeVr… WA    Priv… 21999    77.8     NA     56160   0.586    0.290
## # … with 568 more rows, and 2 more variables: firstgen <dbl>, debt <dbl>
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
## # A tibble: 10 x 12
##    unitid name  state type   cost admrate satavg avgfacsal pctpell comprate
##     <int> <chr> <chr> <chr> <int>   <dbl>  <dbl>     <dbl>   <dbl>    <dbl>
##  1 195304 Sara… NY    Priv… 62636   61.7      NA     87309  0.194     0.692
##  2 179867 Wash… MO    Priv… 62594   15.6    1474    123579  0.0616    0.940
##  3 144050 Univ… IL    Priv… 62425    8.81   1504    153738  0.142     0.927
##  4 190150 Colu… NY    Priv… 61540    7.42   1471    151479  0.215     0.933
##  5 182670 Dart… NH    Priv… 61398    9.78   1446    120114  0.136     0.947
##  6 130697 Wesl… CT    Priv… 61167   20.9    1387    103437  0.184     0.915
##  7 147767 Nort… IL    Priv… 60729   15.3    1458    135396  0.142     0.942
##  8 120254 Occi… CA    Priv… 60655   42.4    1303     95391  0.215     0.878
##  9 115409 Harv… CA    Priv… 60613   18.2    1483    114885  0.131     0.908
## 10 230816 Benn… VT    Priv… 60556   64.9      NA     82017  0.215     0.672
## # … with 2 more variables: firstgen <dbl>, debt <dbl>
```

 We can also use the `top_n()` function in `dplyr` to accomplish the same thing in one line of code.


```r
top_n(x = scorecard, n = 10, wt = cost)
```

```
## # A tibble: 10 x 12
##    unitid name  state type   cost admrate satavg avgfacsal pctpell comprate
##     <int> <chr> <chr> <chr> <int>   <dbl>  <dbl>     <dbl>   <dbl>    <dbl>
##  1 120254 Occi… CA    Priv… 60655   42.4    1303     95391  0.215     0.878
##  2 195304 Sara… NY    Priv… 62636   61.7      NA     87309  0.194     0.692
##  3 115409 Harv… CA    Priv… 60613   18.2    1483    114885  0.131     0.908
##  4 130697 Wesl… CT    Priv… 61167   20.9    1387    103437  0.184     0.915
##  5 147767 Nort… IL    Priv… 60729   15.3    1458    135396  0.142     0.942
##  6 144050 Univ… IL    Priv… 62425    8.81   1504    153738  0.142     0.927
##  7 230816 Benn… VT    Priv… 60556   64.9      NA     82017  0.215     0.672
##  8 182670 Dart… NH    Priv… 61398    9.78   1446    120114  0.136     0.947
##  9 179867 Wash… MO    Priv… 62594   15.6    1474    123579  0.0616    0.940
## 10 190150 Colu… NY    Priv… 61540    7.42   1471    151479  0.215     0.933
## # … with 2 more variables: firstgen <dbl>, debt <dbl>
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
## # A tibble: 3 x 2
##   type                mean_sat
##   <chr>                  <dbl>
## 1 Private, for-profit    1002.
## 2 Private, nonprofit     1075.
## 3 Public                 1037.
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
## # A tibble: 1,849 x 2
##    name                                 ratio
##    <chr>                                <dbl>
##  1 ITT Technical Institute-Wichita       1.59
##  2 ITT Technical Institute-Swartz Creek  1.96
##  3 ITT Technical Institute-Concord      NA   
##  4 ITT Technical Institute-Tallahassee   1.63
##  5 Herzing University-Brookfield         2.30
##  6 DeVry University-Illinois             2.45
##  7 DeVry University-Nevada               1.96
##  8 DeVry University-Oregon              NA   
##  9 DeVry University-Tennessee            2.46
## 10 DeVry University-Washington           2.55
## # … with 1,839 more rows
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
## Observations: 1
## Variables: 13
## $ unitid         <int> 144050
## $ name           <chr> "University of Chicago"
## $ state          <chr> "IL"
## $ type           <chr> "Private, nonprofit"
## $ cost           <int> 62425
## $ admrate        <dbl> 8.81
## $ satavg         <dbl> 1504
## $ avgfacsal      <dbl> 153738
## $ pctpell        <dbl> 0.1419
## $ comprate       <dbl> 0.9268
## $ firstgen       <dbl> 0.1185808
## $ debt           <dbl> 16350
## $ school_cheaper <dbl> 1077
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
## Observations: 1
## Variables: 13
## $ unitid    <int> 144050
## $ name      <chr> "University of Chicago"
## $ state     <chr> "IL"
## $ type      <chr> "Private, nonprofit"
## $ cost      <int> 62425
## $ admrate   <dbl> 8.81
## $ satavg    <dbl> 1504
## $ avgfacsal <dbl> 153738
## $ pctpell   <dbl> 0.1419
## $ comprate  <dbl> 0.9268
## $ firstgen  <dbl> 0.1185808
## $ debt      <dbl> 16350
## $ cost_rank <dbl> 0.9981464
```

  </p>
</details>

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.5.3 (2019-03-11)
##  os       macOS Mojave 10.14.3        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-05-07                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.3   2018-12-14 [2] CRAN (R 3.5.0)
##  blogdown      0.11    2019-03-11 [1] CRAN (R 3.5.2)
##  bookdown      0.9     2018-12-21 [1] CRAN (R 3.5.0)
##  broom         0.5.1   2018-12-05 [2] CRAN (R 3.5.0)
##  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
##  cellranger    1.1.0   2016-07-27 [2] CRAN (R 3.5.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
##  colorspace    1.4-1   2019-03-18 [2] CRAN (R 3.5.2)
##  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.1   2018-10-26 [1] CRAN (R 3.5.1)
##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr       * 0.8.0.1 2019-02-15 [1] CRAN (R 3.5.2)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  forcats     * 0.4.0   2019-02-17 [2] CRAN (R 3.5.2)
##  fs            1.2.7   2019-03-19 [1] CRAN (R 3.5.3)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2     * 3.1.0   2018-10-25 [1] CRAN (R 3.5.0)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  gtable        0.2.0   2016-02-26 [2] CRAN (R 3.5.0)
##  haven         2.1.0   2019-02-19 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite      1.6     2018-12-07 [2] CRAN (R 3.5.0)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  lattice       0.20-38 2018-11-04 [2] CRAN (R 3.5.3)
##  lazyeval      0.2.2   2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate     1.7.4   2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  modelr        0.1.4   2019-02-18 [2] CRAN (R 3.5.2)
##  munsell       0.5.0   2018-06-12 [2] CRAN (R 3.5.0)
##  nlme          3.1-137 2018-04-07 [2] CRAN (R 3.5.3)
##  pillar        1.3.1   2018-12-15 [2] CRAN (R 3.5.0)
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.5.3)
##  pkgconfig     2.0.2   2018-08-16 [2] CRAN (R 3.5.1)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
##  plyr          1.8.4   2016-06-08 [2] CRAN (R 3.5.0)
##  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.0   2019-03-10 [2] CRAN (R 3.5.2)
##  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
##  purrr       * 0.3.2   2019-03-15 [2] CRAN (R 3.5.2)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  readr       * 1.3.1   2018-12-21 [2] CRAN (R 3.5.0)
##  readxl        1.3.1   2019-03-13 [2] CRAN (R 3.5.2)
##  remotes       2.0.2   2018-10-30 [1] CRAN (R 3.5.0)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.5.3)
##  rvest         0.3.2   2016-06-17 [2] CRAN (R 3.5.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.5.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.0.1   2018-10-13 [2] CRAN (R 3.5.0)
##  tibble      * 2.1.1   2019-03-16 [2] CRAN (R 3.5.2)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.5.0)
##  tidyverse   * 1.2.1   2017-11-14 [2] CRAN (R 3.5.0)
##  usethis       1.4.0   2018-08-14 [1] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
