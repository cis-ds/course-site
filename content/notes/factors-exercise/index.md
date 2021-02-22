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

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/data-wrangling-relational-data-and-factors")
```

{{% /callout %}}


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

{{< spoiler text="Click for the solution" >}}


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

{{< /spoiler >}}

## Visualize the total gun deaths per month, in chronological order

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gun_deaths,
       mapping = aes(x = month)) +
  geom_bar() +
  labs(title = "Gun Deaths in the United States (2012-2014)",
       x = "Month",
       y = "Number of gun deaths")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/month-deaths-1.png" width="672" />

{{< /spoiler >}}

## Visualize the total gun deaths per month, sorted from lowest to highest

{{< spoiler text="Click for the solution" >}}


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

<img src="{{< blogdown/postref >}}index_files/figure-html/month-deaths-sort-1.png" width="672" />

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

<img src="{{< blogdown/postref >}}index_files/figure-html/month-deaths-sort-2.png" width="672" />

{{< /spoiler >}}

## Visualize the frequency of intent of gun deaths using a bar chart, sorted from most to least frequent

{{< spoiler text="Click for the solution" >}}


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

<img src="{{< blogdown/postref >}}index_files/figure-html/intent-1.png" width="672" />

{{< /spoiler >}}

## Visualize total gun deaths by season of the year using a bar chart.

Hint: do not use `cut()` to create the `season` column.

{{< spoiler text="Click for the solution" >}}


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

<img src="{{< blogdown/postref >}}index_files/figure-html/season-1.png" width="672" />

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
##  rcfss       * 0.2.1   2020-12-08 [1] local                               
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
