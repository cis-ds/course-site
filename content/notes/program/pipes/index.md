---
title: "Pipes in R"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/program_pipes.html"]
categories: ["programming"]

weight: 81
---



Pipes are an extremely useful tool from the `magrittr` package^[The basic `%>%` pipe is automatically imported as part of the `tidyverse` library. If you wish to use any of the [extra tools from `magrittr` as demonstrated in R for Data Science](http://r4ds.had.co.nz/pipes.html#other-tools-from-magrittr), you need to explicitly load `magrittr`.] that allow you to express a sequence of multiple operations. They can greatly simplify your code and make your operations more intuitive. However they are not the only way to write your code and combine multiple operations. In fact, for many years the pipe did not exist in R. How else did people write their code?

Suppose we have the following assignment:

> Using the [`penguins`](https://github.com/allisonhorst/palmerpenguins) dataset, calculate the average body mass for Adelie penguins on different islands.

Okay, first let's load our libraries and check out the data frame.


```r
library(tidyverse)
library(palmerpenguins)
penguins
```

```
## # A tibble: 344 × 8
##    species island    bill_length_mm bill_depth_mm flipper_…¹ body_…² sex    year
##    <fct>   <fct>              <dbl>         <dbl>      <int>   <int> <fct> <int>
##  1 Adelie  Torgersen           39.1          18.7        181    3750 male   2007
##  2 Adelie  Torgersen           39.5          17.4        186    3800 fema…  2007
##  3 Adelie  Torgersen           40.3          18          195    3250 fema…  2007
##  4 Adelie  Torgersen           NA            NA           NA      NA <NA>   2007
##  5 Adelie  Torgersen           36.7          19.3        193    3450 fema…  2007
##  6 Adelie  Torgersen           39.3          20.6        190    3650 male   2007
##  7 Adelie  Torgersen           38.9          17.8        181    3625 fema…  2007
##  8 Adelie  Torgersen           39.2          19.6        195    4675 male   2007
##  9 Adelie  Torgersen           34.1          18.1        193    3475 <NA>   2007
## 10 Adelie  Torgersen           42            20.2        190    4250 <NA>   2007
## # … with 334 more rows, and abbreviated variable names ¹​flipper_length_mm,
## #   ²​body_mass_g
## # ℹ Use `print(n = ...)` to see more rows
```

We can [decompose the problem](/notes/problem-solving/) into a series of discrete steps:

1. Filter `penguins` to only keep observations where the species is  "Adelie"
1. Group the filtered `penguins` data frame by island
1. Summarize the grouped and filtered `penguins` data frame by calculating the average body mass

But how do we implement the code?

## Intermediate steps

One option is to save each step as a new object:


```r
penguins_1 <- filter(penguins, species == "Adelie")
penguins_2 <- group_by(penguins_1, island)
(penguins_3 <- summarize(penguins_2, body_mass = mean(body_mass_g, na.rm = TRUE)))
```

```
## # A tibble: 3 × 2
##   island    body_mass
##   <fct>         <dbl>
## 1 Biscoe        3710.
## 2 Dream         3688.
## 3 Torgersen     3706.
```

Why do we not like doing this? **We have to name each intermediate object**. Here I just append a number to the end, but this is not good self-documentation. What should we expect to find in `penguins_2`? It would be nicer to have an informative name, but there isn't a natural one. Then we have to remember how the data exists in each intermediate step and remember to reference the correct one. What happens if we misidentify the data frame?


```r
penguins_1 <- filter(penguins, species == "Adelie")
penguins_2 <- group_by(penguins_1, island)
(penguins_3 <- summarize(penguins_1, body_mass = mean(body_mass_g, na.rm = TRUE)))
```

```
## # A tibble: 1 × 1
##   body_mass
##       <dbl>
## 1     3701.
```

We don't get the correct answer. Worse, we don't get an explicit error message because the code, as written, works. R can execute this command for us and doesn't know to warn us that we used `penguins_1` instead of `penguins_2`.

## Overwrite the original

Instead of creating intermediate objects, let's just replace the original data frame with the modified form.


```r
penguins <- filter(penguins, species == "Adelie")
penguins <- group_by(penguins, island)
(penguins <- summarize(penguins, body_mass = mean(body_mass_g, na.rm = TRUE)))
```

```
## # A tibble: 3 × 2
##   island    body_mass
##   <fct>         <dbl>
## 1 Biscoe        3710.
## 2 Dream         3688.
## 3 Torgersen     3706.
```

This works, but still has a couple of problems. What happens if I make an error in the middle of the operation? I need to rerun the entire operation from the beginning. With your own data sources, this means having to read in the `.csv` file all over again to restore a fresh copy.

## Function composition

We could string all the function calls together into a single object and forget assigning it anywhere.




```r
summarize(
  group_by(
    filter(
      penguins,
      species == "Adelie"
    ),
    island
  ),
  body_mass = mean(body_mass_g, na.rm = TRUE)
)
```

```
## # A tibble: 3 × 2
##   island    body_mass
##   <fct>         <dbl>
## 1 Biscoe        3710.
## 2 Dream         3688.
## 3 Torgersen     3706.
```

But now we have to read the function from the inside out. Even worse, what happens if we cram it all into a single line?


```r
summarize(group_by(filter(penguins, species == "Adelie"), island), body_mass = mean(body_mass_g, na.rm = TRUE))
```

```
## # A tibble: 3 × 2
##   island    body_mass
##   <fct>         <dbl>
## 1 Biscoe        3710.
## 2 Dream         3688.
## 3 Torgersen     3706.
```

**This is not intuitive for humans**. Again, the computer will handle it just fine, but if you make a mistake debugging it will be a pain.

## Back to the pipe


```r
penguins %>%
  filter(species == "Adelie") %>%
  group_by(island) %>%
  summarize(body_mass = mean(body_mass_g, na.rm = TRUE))
```

```
## # A tibble: 3 × 2
##   island    body_mass
##   <fct>         <dbl>
## 1 Biscoe        3710.
## 2 Dream         3688.
## 3 Torgersen     3706.
```

Piping is the clearest syntax to implement, as it focuses on actions, not objects. Or as [Hadley would say](http://r4ds.had.co.nz/pipes.html#use-the-pipe):

> [I]t focuses on verbs, not nouns.

`magrittr` automatically passes the output from the first line into the next line as the input.

{{< tweet 1172576445794803713 >}}

This is why `tidyverse` functions always accept a data frame as the first argument.

## Important tips for piping

* Remember though that you don't assign anything within the pipes - that is, you should not use `<-` inside the piped operation. Only use this at the beginning if you want to save the output
* Remember to add the pipe `%>%` at the end of each line involved in the piped operation. A good rule of thumb: RStudio will automatically indent lines of code that are part of a piped operation. If the line isn't indented, it probably hasn't been added to the pipe. **If you have an error in a piped operation, always check to make sure the pipe is connected as you expect**.

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
##  codetools        0.2-18     2020-11-04 [2] CRAN (R 4.2.1)
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
