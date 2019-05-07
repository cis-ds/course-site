---
title: "Pipes in R"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/program_pipes.html"]
categories: ["programming"]

menu:
  notes:
    parent: Programming elements
    weight: 1
---



Pipes are an extremely useful tool from the `magrittr` package^[The basic `%>%` pipe is automatically imported as part of the `tidyverse` library. If you wish to use any of the [extra tools from `magrittr` as demonstrated in R for Data Science](http://r4ds.had.co.nz/pipes.html#other-tools-from-magrittr), you need to explicitly load `magrittr`.] that allow you to express a sequence of multiple operations. They can greatly simplify your code and make your operations more intuitive. However they are not the only way to write your code and combine multiple operations. In fact, for many years the pipe did not exist in R. How else did people write their code?

Suppose we have the following assignment:

> Using the `diamonds` dataset, calculate the average price for each cut of "I" colored diamonds.

Okay, first let's load our libraries and check out the data frame.


```r
library(tidyverse)
diamonds
```

```
## # A tibble: 53,940 x 10
##    carat cut       color clarity depth table price     x     y     z
##    <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
##  1 0.23  Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
##  2 0.21  Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
##  3 0.23  Good      E     VS1      56.9    65   327  4.05  4.07  2.31
##  4 0.290 Premium   I     VS2      62.4    58   334  4.2   4.23  2.63
##  5 0.31  Good      J     SI2      63.3    58   335  4.34  4.35  2.75
##  6 0.24  Very Good J     VVS2     62.8    57   336  3.94  3.96  2.48
##  7 0.24  Very Good I     VVS1     62.3    57   336  3.95  3.98  2.47
##  8 0.26  Very Good H     SI1      61.9    55   337  4.07  4.11  2.53
##  9 0.22  Fair      E     VS2      65.1    61   337  3.87  3.78  2.49
## 10 0.23  Very Good H     VS1      59.4    61   338  4     4.05  2.39
## # … with 53,930 more rows
```

We can [decompose the problem](/notes/problem-solving/) into a series of discrete steps:

1. Filter `diamonds` to only keep observations where the color is rated as "I"
1. Group the filtered `diamonds` data frame by cut
1. Summarize the grouped and filtered `diamonds` data frame by calculating the average price

But how do we implement the code?

## Intermediate steps

One option is to save each step as a new object:


```r
diamonds_1 <- filter(diamonds, color == "I")
diamonds_2 <- group_by(diamonds_1, cut)
(diamonds_3 <- summarize(diamonds_2, price = mean(price)))
```

```
## # A tibble: 5 x 2
##   cut       price
##   <ord>     <dbl>
## 1 Fair      4685.
## 2 Good      5079.
## 3 Very Good 5256.
## 4 Premium   5946.
## 5 Ideal     4452.
```

Why do we not like doing this? **We have to name each intermediate object**. Here I just append a number to the end, but this is not good self-documentation. What should we expect to find in `diamond_2`? It would be nicer to have an informative name, but there isn't a natural one. Then we have to remember how the data exists in each intermediate step and remember to reference the correct one. What happens if we misidentify the data frame?


```r
diamonds_1 <- filter(diamonds, color == "I")
diamonds_2 <- group_by(diamonds_1, cut)
(diamonds_3 <- summarize(diamonds_1, price = mean(price)))
```

```
## # A tibble: 1 x 1
##   price
##   <dbl>
## 1 5092.
```

We don't get the correct answer. Worse, we don't get an explicit error message because the code, as written, works. R can execute this command for us and doesn't know to warn us that we used `diamonds_1` instead of `diamonds_2`.

## Overwrite the original

Instead of creating intermediate objects, let's just replace the original data frame with the modified form.


```r
# copy diamonds to diamonds_t just for demonstration purposes
diamonds_t <- diamonds

diamonds_t <- filter(diamonds_t, color == "I")
diamonds_t <- group_by(diamonds_t, cut)
(diamonds_t <- summarize(diamonds_t, price = mean(price)))
```

```
## # A tibble: 5 x 2
##   cut       price
##   <ord>     <dbl>
## 1 Fair      4685.
## 2 Good      5079.
## 3 Very Good 5256.
## 4 Premium   5946.
## 5 Ideal     4452.
```

This works, but still has a couple of problems. What happens if I make an error in the middle of the operation? I need to rerun the entire operation from the beginning. With your own data sources, this means having to read in the `.csv` file all over again to restore a fresh copy.

## Function composition

We could string all the function calls together into a single object and forget assigning it anywhere.


```r
summarize(
  group_by(
    filter(diamonds, color == "I"),
    cut
  ),
  price = mean(price)
)
```

```
## # A tibble: 5 x 2
##   cut       price
##   <ord>     <dbl>
## 1 Fair      4685.
## 2 Good      5079.
## 3 Very Good 5256.
## 4 Premium   5946.
## 5 Ideal     4452.
```

But now we have to read the function from the inside out. Even worse, what happens if we cram it all into a single line?


```r
summarize(group_by(filter(diamonds, color == "I"), cut), price = mean(price))
```

```
## # A tibble: 5 x 2
##   cut       price
##   <ord>     <dbl>
## 1 Fair      4685.
## 2 Good      5079.
## 3 Very Good 5256.
## 4 Premium   5946.
## 5 Ideal     4452.
```

**This is not intuitive for humans**. Again, the computer will handle it just fine, but if you make a mistake debugging it will be a pain.

## Back to the pipe


```r
diamonds %>%
  filter(color == "I") %>%
  group_by(cut) %>%
  summarize(price = mean(price))
```

```
## # A tibble: 5 x 2
##   cut       price
##   <ord>     <dbl>
## 1 Fair      4685.
## 2 Good      5079.
## 3 Very Good 5256.
## 4 Premium   5946.
## 5 Ideal     4452.
```

Piping is the clearest syntax to implement, as it focuses on actions, not objects. Or as [Hadley would say](http://r4ds.had.co.nz/pipes.html#use-the-pipe):

> [I]t focuses on verbs, not nouns.

`magrittr` automatically passes the output from the first line into the next line as the input. This is why `tidyverse` functions always accept a data frame as the first argument.

## Important tips for piping

* Remember though that you don't assign anything within the pipes - that is, you should not use `<-` inside the piped operation. Only use this at the beginning if you want to save the output
* Remember to add the pipe `%>%` at the end of each line involved in the piped operation. A good rule of thumb: RStudio will automatically indent lines of code that are part of a piped operation. If the line isn't indented, it probably hasn't been added to the pipe. **If you have an error in a piped operation, always check to make sure the pipe is connected as you expect**.

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
##  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
##  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.1   2018-10-26 [1] CRAN (R 3.5.1)
##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  fs            1.2.7   2019-03-19 [1] CRAN (R 3.5.3)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.5.3)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
##  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.0   2019-03-10 [2] CRAN (R 3.5.2)
##  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  remotes       2.0.2   2018-10-30 [1] CRAN (R 3.5.0)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.0.1   2018-10-13 [2] CRAN (R 3.5.0)
##  usethis       1.4.0   2018-08-14 [1] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
