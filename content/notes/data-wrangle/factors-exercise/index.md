---
title: "Practice transforming and visualizing factors"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/datawrangle_factors_exercise.html"]
categories: ["datawrangle"]

weight: 36
---




```r
library(tidyverse)
library(rcis)
theme_set(theme_minimal())
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("cis-ds/data-wrangling-relational-data-and-factors")
```

{{% /callout %}}


```r
# load the data
data("gun_deaths")
gun_deaths
```

```
## # A tibble: 100,798 × 10
##       id  year month intent       police sex     age race        place education
##    <dbl> <dbl> <chr> <chr>         <dbl> <chr> <dbl> <chr>       <chr> <fct>    
##  1     1  2012 Jan   Suicide           0 M        34 Asian/Paci… Home  BA+      
##  2     2  2012 Jan   Suicide           0 F        21 White       Stre… Some col…
##  3     3  2012 Jan   Suicide           0 M        60 White       Othe… BA+      
##  4     4  2012 Feb   Suicide           0 M        64 White       Home  BA+      
##  5     5  2012 Feb   Suicide           0 M        31 White       Othe… HS/GED   
##  6     6  2012 Feb   Suicide           0 M        17 Native Ame… Home  Less tha…
##  7     7  2012 Feb   Undetermined      0 M        48 White       Home  HS/GED   
##  8     8  2012 Mar   Suicide           0 M        41 Native Ame… Home  HS/GED   
##  9     9  2012 Feb   Accidental        0 M        50 White       Othe… Some col…
## 10    10  2012 Feb   Suicide           0 M        NA Black       Home  <NA>     
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
    levels = month_levels
  )))
```

```
## # A tibble: 100,798 × 10
##       id  year month intent       police sex     age race        place education
##    <dbl> <dbl> <fct> <chr>         <dbl> <chr> <dbl> <chr>       <chr> <fct>    
##  1     1  2012 Jan   Suicide           0 M        34 Asian/Paci… Home  BA+      
##  2     2  2012 Jan   Suicide           0 F        21 White       Stre… Some col…
##  3     3  2012 Jan   Suicide           0 M        60 White       Othe… BA+      
##  4     4  2012 Feb   Suicide           0 M        64 White       Home  BA+      
##  5     5  2012 Feb   Suicide           0 M        31 White       Othe… HS/GED   
##  6     6  2012 Feb   Suicide           0 M        17 Native Ame… Home  Less tha…
##  7     7  2012 Feb   Undetermined      0 M        48 White       Home  HS/GED   
##  8     8  2012 Mar   Suicide           0 M        41 Native Ame… Home  HS/GED   
##  9     9  2012 Feb   Accidental        0 M        50 White       Othe… Some col…
## 10    10  2012 Feb   Suicide           0 M        NA Black       Home  <NA>     
## # … with 100,788 more rows
```

{{< /spoiler >}}

## Visualize the total gun deaths per month, in chronological order

{{< spoiler text="Click for the solution" >}}


```r
ggplot(
  data = gun_deaths,
  mapping = aes(x = month)
) +
  geom_bar() +
  labs(
    title = "Gun Deaths in the United States (2012-2014)",
    x = "Month",
    y = "Number of gun deaths"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/month-deaths-1.png" width="672" />

{{< /spoiler >}}

## Visualize the total gun deaths per month, sorted from lowest to highest

{{< spoiler text="Click for the solution" >}}


```r
# with geom_col() and fct_reorder()
gun_deaths %>%
  count(month) %>%
  mutate(month = fct_reorder(.f = month, .x = n)) %>%
  ggplot(mapping = aes(x = month, y = n)) +
  geom_col() +
  labs(
    title = "Gun Deaths in the United States (2012-2014)",
    x = "Month",
    y = "Number of gun deaths"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/month-deaths-sort-1.png" width="672" />

```r
# with geom_bar() and fct_infreq()
gun_deaths %>%
  mutate(month = fct_infreq(f = month) %>%
    fct_rev()) %>%
  ggplot(mapping = aes(x = month)) +
  geom_bar() +
  labs(
    title = "Gun Deaths in the United States (2012-2014)",
    x = "Month",
    y = "Number of gun deaths"
  )
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
  # ensure values are properly ordered from highest to lowest frequency
  mutate(intent = parse_factor(intent, levels = intent_levels) %>%
    fct_infreq() %>%
    fct_rev()) %>%
  ggplot(mapping = aes(x = intent)) +
  geom_bar() +
  labs(
    title = "Gun Deaths in the United States (2012-2014)",
    x = "Intent of death",
    y = "Number of gun deaths"
  ) +
  coord_flip()
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
    "Fall" = c("Oct", "Nov", "Dec")
  )) %>%
  ggplot(mapping = aes(x = season)) +
  geom_bar() +
  labs(
    title = "Gun Deaths in the United States (2012-2014)",
    x = "Season",
    y = "Number of gun deaths"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/season-1.png" width="672" />

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
##  rcis          * 0.2.5      2022-08-08 [2] local
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
