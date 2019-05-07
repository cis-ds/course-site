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
library(knitr)
library(rcfss)
theme_set(theme_minimal())

# load the data
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
                        levels = seq(from = 1, to = 12),
                        labels = month_levels)))
```

```
## # A tibble: 100,798 x 10
##       id  year month intent  police sex     age race      place   education
##    <int> <int> <fct> <chr>    <int> <chr> <int> <chr>     <chr>   <fct>    
##  1     1  2012 Jan   Suicide      0 M        34 Asian/Pa… Home    BA+      
##  2     2  2012 Jan   Suicide      0 F        21 White     Street  Some col…
##  3     3  2012 Jan   Suicide      0 M        60 White     Other … BA+      
##  4     4  2012 Feb   Suicide      0 M        64 White     Home    BA+      
##  5     5  2012 Feb   Suicide      0 M        31 White     Other … HS/GED   
##  6     6  2012 Feb   Suicide      0 M        17 Native A… Home    Less tha…
##  7     7  2012 Feb   Undete…      0 M        48 White     Home    HS/GED   
##  8     8  2012 Mar   Suicide      0 M        41 Native A… Home    HS/GED   
##  9     9  2012 Feb   Accide…      0 M        50 White     Other … Some col…
## 10    10  2012 Feb   Suicide      0 M        NA Black     Home    <NA>     
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
  filter(!is.na(intent)) %>%
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
##  fansi         0.4.0   2018-10-05 [2] CRAN (R 3.5.0)
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
##  knitr       * 1.22    2019-03-08 [2] CRAN (R 3.5.2)
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
##  rcfss       * 0.1.5   2019-04-17 [1] local         
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
##  utf8          1.1.4   2018-05-24 [2] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
