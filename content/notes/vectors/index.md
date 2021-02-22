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
library(rcfss)
set.seed(1234)
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/vectors-and-iteration")
```

{{% /callout %}}

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

{{% callout note %}}

Whenever you filter a data frame, R is (in the background) creating a vector of `TRUE` and `FALSE` - whenever the condition is `TRUE`, keep the row, otherwise exclude it.

{{% /callout %}}

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

{{% callout note %}}

Doubles can store both whole numbers and numbers with decimal points.

{{% /callout %}}

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
##  [1] 10  6  5  4  1  8  2  7  9  3
```

```r
x + c(100, 100, 100, 100, 100, 100, 100, 100, 100, 100)
```

```
##  [1] 110 106 105 104 101 108 102 107 109 103
```

```r
x + 100
```

```
##  [1] 110 106 105 104 101 108 102 107 109 103
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

    {{< spoiler text="Click for the solution" >}}


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

    {{< /spoiler >}}

1. Keep the first through eighth elements, plus the tenth element.

    {{< spoiler text="Click for the solution" >}}
    

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

    {{< /spoiler >}}

1. Keep all elements with values greater than five.

    {{< spoiler text="Click for the solution" >}}


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

    {{< /spoiler >}}

1. Keep all elements evenly divisible by three.

    {{< spoiler text="Click for the solution" >}}


```r
x[x %% 3 == 0]
```

```
## [1] 3 6 9
```

    {{< /spoiler >}}

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

{{% callout note %}}

If you are running RStudio 1.1 or above, you can also use the [**object explorer**](https://blog.rstudio.com/2017/08/22/rstudio-v1-1-preview-object-explorer/) to interactively examine the structure of objects.

{{% /callout %}}

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
str(gun_deaths)
```

```
## tibble [100,798 × 10] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
##  $ id       : num [1:100798] 1 2 3 4 5 6 7 8 9 10 ...
##  $ year     : num [1:100798] 2012 2012 2012 2012 2012 ...
##  $ month    : chr [1:100798] "Jan" "Jan" "Jan" "Feb" ...
##  $ intent   : chr [1:100798] "Suicide" "Suicide" "Suicide" "Suicide" ...
##  $ police   : num [1:100798] 0 0 0 0 0 0 0 0 0 0 ...
##  $ sex      : chr [1:100798] "M" "F" "M" "M" ...
##  $ age      : num [1:100798] 34 21 60 64 31 17 48 41 50 NA ...
##  $ race     : chr [1:100798] "Asian/Pacific Islander" "White" "White" "White" ...
##  $ place    : chr [1:100798] "Home" "Street" "Other specified" "Home" ...
##  $ education: Factor w/ 4 levels "Less than HS",..: 4 3 4 4 2 1 2 2 3 NA ...
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

{{% callout note %}}

Still confused about list subsetting? [Review the pepper shaker.](http://r4ds.had.co.nz/vectors.html#lists-of-condiments)

{{% /callout %}}

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

    {{< spoiler text="Click for the solution" >}}
    

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
    
    {{< /spoiler >}}

1. Subset `pi`. The results should be a new list.

    {{< spoiler text="Click for the solution" >}}


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

    {{< /spoiler >}}

1. Subset the first and third elements from `x`.

    {{< spoiler text="Click for the solution" >}}


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
