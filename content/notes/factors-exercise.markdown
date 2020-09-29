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
```

{{% alert note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/data-wrangling-relational-data-and-factors")
```

{{% /alert %}}


```r
# load the data
data("gun_deaths")
gun_deaths
```

```
## # A tibble: 100,798 x 10
##       id  year month intent   police sex     age race         place    education
##    <dbl> <dbl> <chr> <chr>     <dbl> <chr> <dbl> <chr>        <chr>    <fct>    
##  1     1  2012 Jan   Suicide       0 M        34 Asian/Pacif… Home     BA+      
##  2     2  2012 Jan   Suicide       0 F        21 White        Street   Some col…
##  3     3  2012 Jan   Suicide       0 M        60 White        Other s… BA+      
##  4     4  2012 Feb   Suicide       0 M        64 White        Home     BA+      
##  5     5  2012 Feb   Suicide       0 M        31 White        Other s… HS/GED   
##  6     6  2012 Feb   Suicide       0 M        17 Native Amer… Home     Less tha…
##  7     7  2012 Feb   Undeter…      0 M        48 White        Home     HS/GED   
##  8     8  2012 Mar   Suicide       0 M        41 Native Amer… Home     HS/GED   
##  9     9  2012 Feb   Acciden…      0 M        50 White        Other s… Some col…
## 10    10  2012 Feb   Suicide       0 M        NA Black        Home     <NA>     
## # … with 100,788 more rows
```

## Convert `month` into a factor column

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
# create a character vector with all month values
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# or use the built-in constant
month.abb
```

```
##  [1] "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"
```

```r
# use mutate() and factor() to convert the column and store the result
(gun_deaths <- gun_deaths %>%
  mutate(month = factor(month,
                        levels = month_levels)))
```

```
## # A tibble: 100,798 x 10
##       id  year month intent   police sex     age race         place    education
##    <dbl> <dbl> <fct> <chr>     <dbl> <chr> <dbl> <chr>        <chr>    <fct>    
##  1     1  2012 Jan   Suicide       0 M        34 Asian/Pacif… Home     BA+      
##  2     2  2012 Jan   Suicide       0 F        21 White        Street   Some col…
##  3     3  2012 Jan   Suicide       0 M        60 White        Other s… BA+      
##  4     4  2012 Feb   Suicide       0 M        64 White        Home     BA+      
##  5     5  2012 Feb   Suicide       0 M        31 White        Other s… HS/GED   
##  6     6  2012 Feb   Suicide       0 M        17 Native Amer… Home     Less tha…
##  7     7  2012 Feb   Undeter…      0 M        48 White        Home     HS/GED   
##  8     8  2012 Mar   Suicide       0 M        41 Native Amer… Home     HS/GED   
##  9     9  2012 Feb   Acciden…      0 M        50 White        Other s… Some col…
## 10    10  2012 Feb   Suicide       0 M        NA Black        Home     <NA>     
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
# identify all possible types of intent
intent_levels <- c("Accidental", "Homicide", "Suicide", "Undetermined")

gun_deaths %>%
  # remove rows with missing intent values
  drop_na(intent) %>%
  # parse_factor() is a tidyverse friendly form of factor()
  mutate(intent = parse_factor(intent, levels = intent_levels)) %>%
  ggplot(mapping = aes(x = fct_infreq(intent))) +
  geom_bar() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Intent of death",
       y = "Number of gun deaths")
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
  # use fct_collapse() to condense into 4 categories
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
##  rcfss       * 0.2.0   2020-09-05 [1] local         
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
