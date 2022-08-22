---
title: "Computer programming as a form of problem solving"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/datawrangle_problem_solve.html", "/notes/problem-solving/"]
categories: ["datawrangle"]

weight: 31
---




```r
library(tidyverse)
library(palmerpenguins)
```

{{< figure src="xmen_xavier.jpg" caption="Professor X from *X-Men* (the Patrick Stewart version, not James Mcavoy)" >}}

{{< figure src="xkcd_computer_problems.png" caption="[*Computer Problems*. XKCD.](https://xkcd.com/722/)" >}}

Computers are not mind-reading machines. They are very efficient at certain tasks, and can perform calculations thousands of times faster than any human. But they are also very dumb: they can only do what you tell them to do. If you are not explicit about what you want the computer to do, or you misspeak and tell the computer to do the wrong thing, it will not correct you.

In order to translate your goal for the program into clear instructions for the computer, you need to break the problem down into a set of smaller, discrete chunks that can be followed by the computer (and also by yourself/other humans).

## Decomposing problems using `penguins`

{{< figure src="lter_penguins.png" caption="Meet the Palmer penguins" >}}


```r
library(tidyverse)
library(palmerpenguins)
glimpse(x = penguins)
```

```
## Rows: 344
## Columns: 8
## $ species           <fct> Adelie, Adelie, Adelie, Adelie, Adelie, Adelie, Adel…
## $ island            <fct> Torgersen, Torgersen, Torgersen, Torgersen, Torgerse…
## $ bill_length_mm    <dbl> 39.1, 39.5, 40.3, NA, 36.7, 39.3, 38.9, 39.2, 34.1, …
## $ bill_depth_mm     <dbl> 18.7, 17.4, 18.0, NA, 19.3, 20.6, 17.8, 19.6, 18.1, …
## $ flipper_length_mm <int> 181, 186, 195, NA, 193, 190, 181, 195, 193, 190, 186…
## $ body_mass_g       <int> 3750, 3800, 3250, NA, 3450, 3650, 3625, 4675, 3475, …
## $ sex               <fct> male, female, female, NA, female, male, female, male…
## $ year              <int> 2007, 2007, 2007, 2007, 2007, 2007, 2007, 2007, 2007…
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
## # A tibble: 1 × 1
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
## # A tibble: 3 × 2
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
## # A tibble: 3 × 3
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
##  package        * version    date (UTC) lib source
##  assertthat       0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports        1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown         1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown         0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom            1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib            0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem           1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger       1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  cli              3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  colorspace       2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon           1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI              1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr           2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest           0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr          * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis         0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate         0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi            1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap          1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats        * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs               1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle           1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics         0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2        * 3.3.6      2022-05-03 [2] CRAN (R 4.2.0)
##  glue             1.6.2      2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive      2.0.0      2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4    1.0.0      2021-07-21 [2] CRAN (R 4.2.0)
##  gtable           0.3.0      2019-03-25 [2] CRAN (R 4.2.0)
##  haven            2.5.0      2022-04-15 [2] CRAN (R 4.2.0)
##  here             1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  hms              1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools        0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr             1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib        0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite         1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr            1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  lifecycle        1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate        1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr         2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr           0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell          0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  palmerpenguins * 0.1.0      2020-07-23 [2] CRAN (R 4.2.0)
##  pillar           1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig        2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  purrr          * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6               2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  readr          * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl           1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex           2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  rlang            1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown        2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot        2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi       0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest            1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass             0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales           1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo      1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  stringi          1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr        * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble         * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr          * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect       1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse      * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb             0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  utf8             1.2.2      2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs            0.4.1      2022-04-13 [2] CRAN (R 4.2.0)
##  withr            2.5.0      2022-03-03 [2] CRAN (R 4.2.0)
##  xfun             0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2             1.3.3      2021-11-30 [2] CRAN (R 4.2.0)
##  yaml             2.3.5      2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```
