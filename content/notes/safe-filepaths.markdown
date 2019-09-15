---
title: "Use safe filepaths"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["project-management"]

menu:
  notes:
    parent: Project management
    weight: 3
---




```r
library(tidyverse)

set.seed(1234)
theme_set(theme_minimal())
```

How can you avoid `setwd()` at the top of every script?

* Organize each logical project into a folder on your computer.
* Make sure the top-level folder advertises itself as such. This can be as simple as having an empty file named `.here`. Or, if you use RStudio and/or Git, those both leave characteristic files behind that will get the job done.
* Use the `here()` function from the [`here` package](https://CRAN.R-project.org/package=here) to build the path when you read or write a file. Create paths relative to the top-level directory.
* Whenever you work on this project, launch the R process from the project's top-level directory.
  
## How to use the `here` package

1. Install [`here`](https://cran.r-project.org/web/packages/here/index.html).

    ```r
    install.packages("here")
    ```

2. Use it.

    ```r
    library(here)
    here("data", "file_i_want.csv")
    ```

## Actual demonstration of `here::here()`

What does `here` think the top-level of current project is? The package displays this on load or, at any time, you can just call `here()`.


```r
library(here)
```

```
## here() starts at /Users/soltoffbc/Projects/Computing for Social Sciences/course-site
```

```r
here()
```

```
## [1] "/Users/soltoffbc/Projects/Computing for Social Sciences/course-site"
```

Build a path to something in a subdirectory and use it.


```r
here("static", "extras", "awesome.txt")
```

```
## [1] "/Users/soltoffbc/Projects/Computing for Social Sciences/course-site/static/extras/awesome.txt"
```

```r
cat(readLines(here("static", "extras", "awesome.txt")))
```

```
## OMG this is so awesome!
```

Don't try this at home, folks! But let me set working directory to a subdirectory and prove to you that the same code as above, for getting the path to `awesome.txt`, still works.


```r
setwd(here("static"))
getwd()
```

```
## [1] "/Users/soltoffbc/Projects/Computing for Social Sciences/course-site/static"
```

```r
cat(readLines(here("static", "extras", "awesome.txt")))
```

```
## OMG this is so awesome!
```

## The fine print

`here::here()` figures out the top-level of your current project using some sane heuristics. It looks at working directory, checks a criterion and, if not satisfied, moves up to parent directory and checks again. Lather, rinse, repeat.

Here are the criteria. The order doesn't really matter because all of them are checked for each directory before moving up to the parent directory:

* Is a file named `.here` present?
* Is this an RStudio Project? Literally, can I find a file named something like `foo.Rproj`?
* Is this a checkout from a version control system? Does it have a directory named `.git` or `.svn`? Currently, only Git and Subversion are supported.

## Filepaths and R Markdown documents

`here::here()` is particularly useful within R Markdown documents. Unlike `.R` scripts, R Markdown documents always knit assuming the location of the `.Rmd` file is the working directory. In an R Project, this is fine as long as the `.Rmd` is in the top-level directory. But if an R Markdown file is saved in a sub-directory, a user can quickly become confused when writing code. Say the structure is something like this:

```
data/
  scotus.csv
analysis/
  exploratory-analysis.Rmd
final-report.Rmd
scotus.Rproj
```

If you attempt to run `read_csv("data/scotus.csv")` inside of `final-report.Rmd`, it will work correctly. If you attempt to run `read_csv("data/scotus.csv")` inside of `exploratory-analysis.Rmd`, your code will fail because `data` is not a folder within `analysis`.

However, `read_csv(here("data", "scotus.csv"))` will work correctly from either `.Rmd` file because `here()` will use `scotus.Rproj` to identify the correct working directory.

## Acknowledgments

* Substantial material drawn from [What They Forgot To Teach You About R](https://whattheyforgot.org/) by Jenny Bryan and Jim Hester. Licensed under the licensed under the [CC BY-SA 4.0 Creative Commons License](https://creativecommons.org/licenses/by-sa/4.0/).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-09-15                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
