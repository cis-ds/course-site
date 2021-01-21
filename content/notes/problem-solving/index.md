---
title: "Computer programming as a form of problem solving"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/datawrangle_problem_solve.html"]
categories: ["datawrangle"]

menu:
  notes:
    parent: Data wrangling
    weight: 1
---




```r
library(tidyverse)
library(palmerpenguins)
```

![Professor X from *X-Men* (the Patrick Stewart version, not James Mcavoy)](/img/xmen_xavier.jpg)

[![*Computer Problems*. XKCD.](/img/xkcd_computer_problems.png)](https://xkcd.com/722/)

Computers are not mind-reading machines. They are very efficient at certain tasks, and can perform calculations thousands of times faster than any human. But they are also very dumb: they can only do what you tell them to do. If you are not explicit about what you want the computer to do, or you misspeak and tell the computer to do the wrong thing, it will not correct you.

In order to translate your goal for the program into clear instructions for the computer, you need to break the problem down into a set of smaller, discrete chunks that can be followed by the computer (and also by yourself/other humans).

## Decomposing problems using `penguins`

![Meet the Palmer penguins](/img/lter_penguins.png)


```r
library(tidyverse)
library(palmerpenguins)
glimpse(x = penguins)
```

```
## Rows: 344
## Columns: 8
## $ species           <fct> Adelie, Adelie, Adelie, Adelie, Adelie, Adelie, Ade…
## $ island            <fct> Torgersen, Torgersen, Torgersen, Torgersen, Torgers…
## $ bill_length_mm    <dbl> 39.1, 39.5, 40.3, NA, 36.7, 39.3, 38.9, 39.2, 34.1,…
## $ bill_depth_mm     <dbl> 18.7, 17.4, 18.0, NA, 19.3, 20.6, 17.8, 19.6, 18.1,…
## $ flipper_length_mm <int> 181, 186, 195, NA, 193, 190, 181, 195, 193, 190, 18…
## $ body_mass_g       <int> 3750, 3800, 3250, NA, 3450, 3650, 3625, 4675, 3475,…
## $ sex               <fct> male, female, female, NA, female, male, female, mal…
## $ year              <int> 2007, 2007, 2007, 2007, 2007, 2007, 2007, 2007, 200…
```

The [`penguins`](https://github.com/allisonhorst/palmerpenguins) dataset includes measurements for penguin species from islands in the Palmer Archipelago. Let's answer the following questions by **decomposing** the problem into a series of discrete steps we can tell R to follow.

## What is the average body mass of an Adelie penguin?

Think about what we need to have the computer do to answer this question:

1. First we need to identify the **input**, or the data we're going to analyze.
1. Next we need to **select** only the observations which are Adelie penguins.
1. Finally we need to calculate the average value, or **mean**, of `body_mass_g`.

Here's how we tell the computer to do this:


```r
data("penguins")
penguins_adelie <- filter(.data = penguins, species == "Adelie")
summarize(.data = penguins_adelie, avg_mass = mean(body_mass_g, na.rm = TRUE))
```

```
## # A tibble: 1 x 1
##   avg_mass
##      <dbl>
## 1    3701.
```

The first line of code copies the `penguins` data frame from the hard drive into memory so we can actively work with it. The second line create a new data frame called `penguins_adelie` that only contains the observations in `penguins` which are Adelie penguins. The third line summarizes the new data frame and calculates the mean value for the `body_mass_g` variable.

## What is the average body mass of a penguin for each species?

**Exercise: decompose the question into a discrete set of tasks to complete using R.**

{{< spoiler text="Click for the solution" >}}

1. First we need to identify the **input**, or the data we're going to analyze.
1. Next we need to **group** the observations together by their value for `species`, so we can make separate calculations for each category.
1. Finally we need to calculate the average value, or **mean**, of body mass for penguins of each species.

Here's how we tell the computer to do this:


```r
data("penguins")
penguins_species <- group_by(.data = penguins, species)
summarize(.data = penguins_species, avg_mass = mean(body_mass_g, na.rm = TRUE))
```

```
## `summarise()` ungrouping output (override with `.groups` argument)
```

```
## # A tibble: 3 x 2
##   species   avg_mass
##   <fct>        <dbl>
## 1 Adelie       3701.
## 2 Chinstrap    3733.
## 3 Gentoo       5076.
```

{{< /spoiler >}}

## What is the average bill length and body mass for each Adelie penguin by sex?

**Exercise: decompose the question into a discrete set of tasks to complete using R.**

{{< spoiler text="Click for the solution" >}}

1. Use `penguins` as the input
1. Filter `penguins` to only keep observations where the species is "Adelie".
1. Group the filtered `penguins` data frame by sex.
1. Summarize the grouped and filtered `penguins` data frame by calculating the average bill length and body mass.


```r
data("penguins")
penguins_adelie <- filter(.data = penguins, species == "Adelie")
penguins_adelie_sex <- group_by(.data = penguins_adelie, sex)
summarize(
  .data = penguins_adelie_sex,
  bill = mean(bill_length_mm, na.rm = TRUE),
  avg_mass = mean(body_mass_g, na.rm = TRUE)
)
```

```
## `summarise()` ungrouping output (override with `.groups` argument)
```

```
## # A tibble: 3 x 3
##   sex     bill avg_mass
##   <fct>  <dbl>    <dbl>
## 1 female  37.3    3369.
## 2 male    40.4    4043.
## 3 <NA>    37.8    3540
```

{{< /spoiler >}}

## References

* Artwork by [Allison Horst](https://github.com/allisonhorst/palmerpenguins)

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
##  package        * version date       lib source                              
##  assertthat       0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports        1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown         1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown         0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom            0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr            3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger       1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  cli              2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace       2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon           1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI              1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr           2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc             1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools         2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest           0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr          * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis         0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate         0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi            0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats        * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  fs               1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics         0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2        * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue             1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable           0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven            2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here             1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms              0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools        0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr             1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite         1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr            1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lifecycle        0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate        1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr         2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  memoise          1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr           0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell          0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  palmerpenguins * 0.1.0   2020-07-23 [1] CRAN (R 4.0.2)                      
##  pillar           1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild         1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig        2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload          1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  prettyunits      1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx         3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps               1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr          * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6               2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  Rcpp             1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr          * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl           1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes          2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex           0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  rlang            0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown        2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot        2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi       0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest            0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales           1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo      1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi          1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr        * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat         3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble         * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr          * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect       1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse      * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis          2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs            0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr            2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun             0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2             1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml             2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
