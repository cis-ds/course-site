---
title: "Practice the pipe"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/program_pipes_exercise.html", "/notes/pipes-exercise/"]
categories: ["programming"]

weight: 82
---




```r
library(tidyverse)
library(rcis)
```

Using `gun_deaths` from the `rcis` library, answer the following question:

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

## Intermediate steps

{{< spoiler text="Click for the solution" >}}


```r
gun_deaths1 <- filter(gun_deaths, sex == "M", race == "White", year == 2012)
gun_deaths2 <- group_by(gun_deaths1, education)
(gun_deaths3 <- summarize(gun_deaths2, n = n()))
```

```
## # A tibble: 5 × 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

{{< /spoiler >}}

## Overwrite the original

Hint: make sure to save a copy of `gun_deaths` as `gun_deaths2` for this code chunk.

{{< spoiler text="Click for the solution" >}}


```r
gun_deaths2 <- gun_deaths # copy for demonstration purposes

gun_deaths2 <- filter(gun_deaths2, sex == "M", race == "White", year == 2012)
gun_deaths2 <- group_by(gun_deaths2, education)
(gun_deaths2 <- summarize(gun_deaths2, n = n()))
```

```
## # A tibble: 5 × 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

{{< /spoiler >}}

## Function composition

{{< spoiler text="Click for the solution" >}}


```r
summarize(
  group_by(
    filter(gun_deaths, sex == "M", race == "White", year == 2012),
    education
  ),
  n = n()
)
```

```
## # A tibble: 5 × 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

{{< /spoiler >}}

## Piped operation

{{< spoiler text="Click for the solution" >}}


```r
gun_deaths %>%
  filter(sex == "M", race == "White", year == 2012) %>%
  group_by(education) %>%
  summarize(n = n())
```

```
## # A tibble: 5 × 2
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
## # A tibble: 5 × 2
##   education        n
##   <fct>        <int>
## 1 Less than HS  2858
## 2 HS/GED        7912
## 3 Some college  4258
## 4 BA+           3029
## 5 <NA>           285
```

Note that all methods produce the same answer. But which did you find easiest to implement?


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
