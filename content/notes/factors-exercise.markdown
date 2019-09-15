---
title: "Practice transforming and visualizing factors"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/datawrangle_factors_exercise.html"]
categories: ["datawrangle"]

menu:
  notes:
    parent: Data wrangling
    weight: 6
---




```r
library(tidyverse)
library(rcfss)
theme_set(theme_minimal())

# load the data
data("gun_deaths")
gun_deaths
```

```
## # A tibble: 100,798 x 10
##       id  year month intent   police sex     age race      place  education
##    <dbl> <dbl> <chr> <chr>     <dbl> <chr> <dbl> <chr>     <chr>  <fct>    
##  1     1  2012 Jan   Suicide       0 M        34 Asian/Pa… Home   <NA>     
##  2     2  2012 Jan   Suicide       0 F        21 White     Street <NA>     
##  3     3  2012 Jan   Suicide       0 M        60 White     Other… <NA>     
##  4     4  2012 Feb   Suicide       0 M        64 White     Home   <NA>     
##  5     5  2012 Feb   Suicide       0 M        31 White     Other… <NA>     
##  6     6  2012 Feb   Suicide       0 M        17 Native A… Home   <NA>     
##  7     7  2012 Feb   Undeter…      0 M        48 White     Home   <NA>     
##  8     8  2012 Mar   Suicide       0 M        41 Native A… Home   <NA>     
##  9     9  2012 Feb   Acciden…      0 M        50 White     Other… <NA>     
## 10    10  2012 Feb   Suicide       0 M        NA Black     Home   <NA>     
## # … with 100,788 more rows
```

## Convert `month` into a factor column

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# or use the built-in constant
month.abb
```

```
##  [1] "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov"
## [12] "Dec"
```

```r
(gun_deaths <- gun_deaths %>%
  mutate(month = factor(month,
                        levels = month_levels)))
```

```
## # A tibble: 100,798 x 10
##       id  year month intent   police sex     age race      place  education
##    <dbl> <dbl> <fct> <chr>     <dbl> <chr> <dbl> <chr>     <chr>  <fct>    
##  1     1  2012 Jan   Suicide       0 M        34 Asian/Pa… Home   <NA>     
##  2     2  2012 Jan   Suicide       0 F        21 White     Street <NA>     
##  3     3  2012 Jan   Suicide       0 M        60 White     Other… <NA>     
##  4     4  2012 Feb   Suicide       0 M        64 White     Home   <NA>     
##  5     5  2012 Feb   Suicide       0 M        31 White     Other… <NA>     
##  6     6  2012 Feb   Suicide       0 M        17 Native A… Home   <NA>     
##  7     7  2012 Feb   Undeter…      0 M        48 White     Home   <NA>     
##  8     8  2012 Mar   Suicide       0 M        41 Native A… Home   <NA>     
##  9     9  2012 Feb   Acciden…      0 M        50 White     Other… <NA>     
## 10    10  2012 Feb   Suicide       0 M        NA Black     Home   <NA>     
## # … with 100,788 more rows
```

  </p>
</details>

## Visualize the total gun deaths per month, in chronological order

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gun_deaths,
       mapping = aes(x = month)) +
  geom_bar() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Month",
       y = "Number of gun deaths")
```

<img src="/notes/factors-exercise_files/figure-html/month-deaths-1.png" width="672" />

  </p>
</details>

## Visualize the total gun deaths per month, sorted from lowest to highest

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
# with geom_col() and fct_reorder()
gun_deaths %>%
  count(month) %>%
  ggplot(mapping = aes(x = fct_reorder(.f = month, .x = n), y = n)) +
  geom_col() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Month",
       y = "Number of gun deaths")
```

<img src="/notes/factors-exercise_files/figure-html/month-deaths-sort-1.png" width="672" />

```r
# with geom_bar() and fct_infreq()
ggplot(data = gun_deaths,
       mapping = aes(x = month %>%
                       fct_infreq() %>%
                       fct_rev())) +
  geom_bar() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Month",
       y = "Number of gun deaths")
```

<img src="/notes/factors-exercise_files/figure-html/month-deaths-sort-2.png" width="672" />

  </p>
</details>

## Visualize the frequency of intent of gun deaths using a bar chart, sorted from most to least frequent

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
intent_levels <- c("Accidental", "Homicide", "Suicide", "Undetermined")

gun_deaths %>%
  drop_na(intent) %>%
  mutate(intent = parse_factor(intent, levels = intent_levels)) %>%
  ggplot(mapping = aes(x = intent %>%
                         fct_infreq() %>%
                         fct_rev())) +
  geom_bar() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Intent of death",
       y = "Number of gun deaths") +
  coord_flip()
```

<img src="/notes/factors-exercise_files/figure-html/intent-1.png" width="672" />

  </p>
</details>

## Visualize total gun deaths by season of the year using a bar chart.

Hint: do not use `cut()` to create the `season` column.

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
gun_deaths %>%
  mutate(season = fct_collapse(month,
                               "Winter" = c("Jan", "Feb", "Mar"),
                               "Spring" = c("Apr", "May", "Jun"),
                               "Summer" = c("Jul", "Aug", "Sep"),
                               "Fall" = c("Oct", "Nov", "Dec"))) %>%
  ggplot(mapping = aes(x = season)) +
  geom_bar() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Season",
       y = "Number of gun deaths")
```

<img src="/notes/factors-exercise_files/figure-html/season-1.png" width="672" />

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
##  fansi         0.4.0   2018-10-05 [1] CRAN (R 3.6.0)
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
##  utf8          1.1.4   2018-05-24 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
