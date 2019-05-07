---
title: "Vectors"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/program_vectors.html"]
categories: ["programming"]

menu:
  notes:
    parent: Programming elements
    weight: 4
---




```r
library(tidyverse)
set.seed(1234)
```

So far the only type of data object in R you have encountered is a `data.frame` (or the `tidyverse` variant `tibble`). At its core though, the primary method of data storage in R is the **vector**. So far we have only encountered vectors as components of a **data frame**; data frames are built from vectors. There are a few different types of vectors: logical, numeric, and character. But now we want to understand more precisely how these data objects are structured and related to one another.

## Types of vectors

![Figure 20.1 from [*R for Data Science*](http://r4ds.had.co.nz/vectors.html)](https://r4ds.had.co.nz/diagrams/data-structures-overview.png)

There are two categories of vectors:

1. **Atomic vectors** - these are the types previously covered, including logical, integer, double, and character.
1. **Lists** - there are new and we will cover them later in this module. Lists are distinct from atomic vectors because lists can contain other lists.

Atomic vectors are **homogenous** - that is, all elements of the vector must be the same type. Lists can be **hetergenous** and contain multiple types of elements. `NULL` is the counterpart to `NA`. While `NA` represents the absence of a value, `NULL` represents the absence of a vector.

## Atomic vectors

## Logical vectors

**Logical vectors** take on one of three possible values:

* `TRUE`
* `FALSE`
* `NA` (missing value)


```r
parse_logical(c("TRUE", "TRUE", "FALSE", "TRUE", "NA"))
```

```
## [1]  TRUE  TRUE FALSE  TRUE    NA
```

> Whenever you filter a data frame, R is (in the background) creating a vector of `TRUE` and `FALSE` - whenever the condition is `TRUE`, keep the row, otherwise exclude it.

## Numeric vectors

**Numeric vectors** contain numbers (duh!). They can be stored as **integers** (whole numbers) or **doubles** (numbers with decimal points). In practice, you rarely need to concern yourself with this difference, but just know that they are different but related things.


```r
parse_integer(c("1", "5", "3", "4", "12423"))
```

```
## [1]     1     5     3     4 12423
```

```r
parse_double(c("4.2", "4", "6", "53.2"))
```

```
## [1]  4.2  4.0  6.0 53.2
```

> Doubles can store both whole numbers and numbers with decimal points.

## Character vectors

**Character vectors** contain **strings**, which are typically text but could also be dates or any other combination of characters.


```r
parse_character(c("Goodnight Moon", "Runaway Bunny", "Big Red Barn"))
```

```
## [1] "Goodnight Moon" "Runaway Bunny"  "Big Red Barn"
```

## Using atomic vectors

Be sure to read ["Using atomic vectors"](http://r4ds.had.co.nz/vectors.html#using-atomic-vectors) for more detail on how to use and interact with atomic vectors. I have no desire to rehash everything Hadley already wrote, but here are a couple things about atomic vectors I want to reemphasize.

## Scalars

**Scalars** are a single number; **vectors** are a set of multiple values. In R, scalars are merely a vector of length 1. So when you try to perform arithmetic or other types of functions on a vector, it will **recycle** the scalar value.


```r
(x <- sample(10))
```

```
##  [1]  2  6  5  8  9  4  1  7 10  3
```

```r
x + c(100, 100, 100, 100, 100, 100, 100, 100, 100, 100)
```

```
##  [1] 102 106 105 108 109 104 101 107 110 103
```

```r
x + 100
```

```
##  [1] 102 106 105 108 109 104 101 107 110 103
```

This is why [you don't need to write an iterative operation when performing these basic operations](/notes/functions#exercise:-calculate-the-sum-of-squares-of-two-variables) - R automatically converts it for you.

Sometimes this isn't so great, because R will also recycle vectors if the lengths are not equal:


```r
# create a sequence of numbers between 1 and 10
(x1 <- seq(from = 1, to = 2))
```

```
## [1] 1 2
```

```r
(x2 <- seq(from = 1, to = 10))
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```

```r
# add together two sequences of numbers
x1 + x2
```

```
##  [1]  2  4  4  6  6  8  8 10 10 12
```

Did you really mean to recycle `1:2` five times, or was this actually an error? `tidyverse` functions will only allow you to implicitly recycle scalars, otherwise it will throw an error and you'll have to manually recycle shorter vectors.

## Subsetting

To filter a vector, we cannot use `filter()` because that only works for filtering rows in a `tibble`. `[` is the subsetting function for vectors. It is used like `x[a]`.

### Subset with a numeric vector containing integers


```r
(x <- c("one", "two", "three", "four", "five"))
```

```
## [1] "one"   "two"   "three" "four"  "five"
```

Subset with positive integers keeps the corresponding elements:


```r
x[c(3, 2, 5)]
```

```
## [1] "three" "two"   "five"
```

Negative values drop the corresponding elements:


```r
x[c(-1, -3, -5)]
```

```
## [1] "two"  "four"
```

You cannot mix positive and negative values:


```r
x[c(-1, 1)]
```

```
## Error in x[c(-1, 1)]: only 0's may be mixed with negative subscripts
```

### Subset with a logical vector

Subsetting with a logical vector keeps all values corresponding to a `TRUE` value.


```r
(x <- c(10, 3, NA, 5, 8, 1, NA))
```

```
## [1] 10  3 NA  5  8  1 NA
```

```r
# All non-missing values of x
!is.na(x)
```

```
## [1]  TRUE  TRUE FALSE  TRUE  TRUE  TRUE FALSE
```

```r
x[!is.na(x)]
```

```
## [1] 10  3  5  8  1
```

```r
# All even (or missing!) values of x
x[x %% 2 == 0]
```

```
## [1] 10 NA  8 NA
```

## Exercise: subset the vector


```r
(x <- seq(from = 1, to = 10))
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```

Create the sequence above in your R session. Write commands to subset the vector in the following ways:

1. Keep the first through fourth elements, plus the seventh element.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    x[c(1, 2, 3, 4, 7)]
    ```
    
    ```
    ## [1] 1 2 3 4 7
    ```
    
    ```r
    # use a sequence shortcut
    x[c(seq(1, 4), 7)]
    ```
    
    ```
    ## [1] 1 2 3 4 7
    ```
    
      </p>
    </details>

1. Keep the first through eighth elements, plus the tenth element.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # long way
    x[c(1, 2, 3, 4, 5, 6, 7, 8, 10)]
    ```
    
    ```
    ## [1]  1  2  3  4  5  6  7  8 10
    ```
    
    ```r
    # sequence shortcut
    x[c(seq(1, 8), 10)]
    ```
    
    ```
    ## [1]  1  2  3  4  5  6  7  8 10
    ```
    
    ```r
    # negative indexing
    x[c(-9)]
    ```
    
    ```
    ## [1]  1  2  3  4  5  6  7  8 10
    ```
    
      </p>
    </details>

1. Keep all elements with values greater than five.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # get the index for which values in x are greater than 5
    x > 5
    ```
    
    ```
    ##  [1] FALSE FALSE FALSE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE
    ```
    
    ```r
    x[x > 5]
    ```
    
    ```
    ## [1]  6  7  8  9 10
    ```
    
      </p>
    </details>

1. Keep all elements evenly divisible by three.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    x[x %% 3 == 0]
    ```
    
    ```
    ## [1] 3 6 9
    ```
    
      </p>
    </details>

## Lists

**Lists** are an entirely different type of vector.


```r
x <- list(1, 2, 3)
x
```

```
## [[1]]
## [1] 1
## 
## [[2]]
## [1] 2
## 
## [[3]]
## [1] 3
```

Use `str()` to view the **structure** of the list.


```r
str(x)
```

```
## List of 3
##  $ : num 1
##  $ : num 2
##  $ : num 3
```

```r
x_named <- list(a = 1, b = 2, c = 3)
str(x_named)
```

```
## List of 3
##  $ a: num 1
##  $ b: num 2
##  $ c: num 3
```

> If you are running RStudio 1.1 or above, you can also use the [**object explorer**](https://blog.rstudio.com/2017/08/22/rstudio-v1-1-preview-object-explorer/) to interactively examine the structure of objects.

Unlike the other atomic vectors, lists are **recursive**. This means they can:

1. Store a mix of objects.

    
    ```r
    y <- list("a", 1L, 1.5, TRUE)
    str(y)
    ```
    
    ```
    ## List of 4
    ##  $ : chr "a"
    ##  $ : int 1
    ##  $ : num 1.5
    ##  $ : logi TRUE
    ```
    
1. Contain other lists.

    
    ```r
    z <- list(list(1, 2), list(3, 4))
    str(z)
    ```
    
    ```
    ## List of 2
    ##  $ :List of 2
    ##   ..$ : num 1
    ##   ..$ : num 2
    ##  $ :List of 2
    ##   ..$ : num 3
    ##   ..$ : num 4
    ```
    
    It isn't immediately apparent why you would want to do this, but in later units we will discover the value of lists as many packages for R store non-tidy data as lists.

You've already worked with lists without even knowing it. **Data frames and `tibble`s are a type of a list.** Notice that you can store a data frame with a mix of column types.


```r
str(diamonds)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	53940 obs. of  10 variables:
##  $ carat  : num  0.23 0.21 0.23 0.29 0.31 0.24 0.24 0.26 0.22 0.23 ...
##  $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 5 4 2 4 2 3 3 3 1 3 ...
##  $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 2 2 6 7 7 6 5 2 5 ...
##  $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 2 3 5 4 2 6 7 3 4 5 ...
##  $ depth  : num  61.5 59.8 56.9 62.4 63.3 62.8 62.3 61.9 65.1 59.4 ...
##  $ table  : num  55 61 65 58 58 57 57 55 61 61 ...
##  $ price  : int  326 326 327 334 335 336 336 337 337 338 ...
##  $ x      : num  3.95 3.89 4.05 4.2 4.34 3.94 3.95 4.07 3.87 4 ...
##  $ y      : num  3.98 3.84 4.07 4.23 4.35 3.96 3.98 4.11 3.78 4.05 ...
##  $ z      : num  2.43 2.31 2.31 2.63 2.75 2.48 2.47 2.53 2.49 2.39 ...
```

## How to subset lists

Sometimes lists (especially deeply-nested lists) can be confusing to view and manipulate. Take the example from [R for Data Science](http://r4ds.had.co.nz/vectors.html#subsetting-1):


```r
x <- list(a = c(1, 2, 3), b = "a string", c = pi, d = list(-1, -5))
str(x)
```

```
## List of 4
##  $ a: num [1:3] 1 2 3
##  $ b: chr "a string"
##  $ c: num 3.14
##  $ d:List of 2
##   ..$ : num -1
##   ..$ : num -5
```

* `[` extracts a sub-list. The result will always be a list.

    
    ```r
    str(x[c(1, 2)])
    ```
    
    ```
    ## List of 2
    ##  $ a: num [1:3] 1 2 3
    ##  $ b: chr "a string"
    ```
    
    ```r
    str(x[4])
    ```
    
    ```
    ## List of 1
    ##  $ d:List of 2
    ##   ..$ : num -1
    ##   ..$ : num -5
    ```
    
* `[[` extracts a single component from a list and removes a level of hierarchy.

    
    ```r
    str(x[[1]])
    ```
    
    ```
    ##  num [1:3] 1 2 3
    ```
    
    ```r
    str(x[[4]])
    ```
    
    ```
    ## List of 2
    ##  $ : num -1
    ##  $ : num -5
    ```

* `$` can be used to extract named elements of a list.

    
    ```r
    x$a
    ```
    
    ```
    ## [1] 1 2 3
    ```
    
    ```r
    x[['a']]
    ```
    
    ```
    ## [1] 1 2 3
    ```
    
    ```r
    x[["a"]]
    ```
    
    ```
    ## [1] 1 2 3
    ```

![Figure 20.2 from [R for Data Science](http://r4ds.had.co.nz/vectors.html#fig:lists-subsetting)](https://r4ds.had.co.nz/diagrams/lists-subsetting.png)

> Still confused about list subsetting? [Review the pepper shaker.](http://r4ds.had.co.nz/vectors.html#lists-of-condiments)

## Exercise: subset a list


```r
x <- list(a = c(1, 2, 3), b = "a string", c = pi, d = list(-1, -5))
str(x)
```

```
## List of 4
##  $ a: num [1:3] 1 2 3
##  $ b: chr "a string"
##  $ c: num 3.14
##  $ d:List of 2
##   ..$ : num -1
##   ..$ : num -5
```

Create the list above in your R session. Write commands to subset the list in the following ways:

1. Subset `a`. The result should be an atomic vector.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # use the index value
    x[[1]]
    ```
    
    ```
    ## [1] 1 2 3
    ```
    
    ```r
    # use the element name
    x$a
    ```
    
    ```
    ## [1] 1 2 3
    ```
    
    ```r
    x[["a"]]
    ```
    
    ```
    ## [1] 1 2 3
    ```
    
      </p>
    </details>

1. Subset `pi`. The results should be a new list.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # correct method
    str(x["c"])
    ```
    
    ```
    ## List of 1
    ##  $ c: num 3.14
    ```
    
    ```r
    # incorrect method to produce another list
    # the result is a scalar
    str(x$c)
    ```
    
    ```
    ##  num 3.14
    ```
    
      </p>
    </details>

1. Subset the first and third elements from `x`.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    x[c(1, 3)]
    ```
    
    ```
    ## $a
    ## [1] 1 2 3
    ## 
    ## $c
    ## [1] 3.141593
    ```
    
    ```r
    x[c("a", "c")]
    ```
    
    ```
    ## $a
    ## [1] 1 2 3
    ## 
    ## $c
    ## [1] 3.141593
    ```
    
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
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
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
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
