---
title: "Generating reproducible examples"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["programming"]

menu:
  notes:
    parent: Programming elements
    weight: 8
---



{{% alert note %}}

Run the below code in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/reproducible-examples-and-git")
```

{{% /alert %}}

## Include a reproducible example

Including a [minimal, complete, and verifiable example](http://stackoverflow.com/help/mcve) of the code you are using greatly helps people resolve your problem in your code. Key elements of a MCV example include:

* Minimal - use as little code as possible that still produces the same problem
* Complete - provide all parts someone else needs to reproduce your problem
* Reproducible - test the code to ensure it reproduces the problem

Preparing reproducible examples is difficult. However the better prepared your example, the easier it is for others to help you debug and resolve the problem. So there is substantial value in writing reproducible examples. Fortunately, there are packages available that help you to generate a reproducible example for easy publishing.

## Format your code snippets with `reprex`

The [`reprex`](http://reprex.tidyverse.org/) package allows you to quickly generate reproducible examples that are easily shared on GitHub with all the proper formatting and syntax. Install it by running the following command from the console:

```r
install.packages("reprex")
```

To use it, copy your code onto your clipboard (e.g. select the code and **Ctrl + C** or **⌘ + C**). For example, copy this demonstration code to your clipboard:






```
library(tidyverse)
count(diamonds, colour)
```

Then run `reprex()` from the console, where the default target venue is GitHub:


```r
reprex()
```

A nicely rendered HTML preview will display in RStudio's Viewer (if you're in RStudio) or your default browser otherwise.

![Output of `reprex()`](/img/reprex-output.png)

The relevant bit of GitHub-flavored Markdown is ready to be pasted from your clipboard:


````
``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Must group by variables found in `.data`.
#> * Column `colour` is not found.
```

<sup>Created on 2020-09-21 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>

<details>

<summary>Session info</summary>

``` r
devtools::session_info()
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 4.0.2 (2020-06-22)
#>  os       macOS Catalina 10.15.6      
#>  system   x86_64, darwin17.0          
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  ctype    en_US.UTF-8                 
#>  tz       America/Chicago             
#>  date     2020-09-21                  
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package     * version date       lib source        
#>  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
#>  backports     1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
#>  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
#>  broom         0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
#>  callr         3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
#>  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
#>  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
#>  colorspace    1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
#>  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
#>  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
#>  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
#>  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
#>  devtools      2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
#>  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
#>  dplyr       * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
#>  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
#>  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
#>  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
#>  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
#>  fs            1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
#>  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
#>  ggplot2     * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
#>  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
#>  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
#>  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
#>  highr         0.8     2019-03-20 [1] CRAN (R 4.0.0)
#>  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
#>  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
#>  httr          1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
#>  jsonlite      1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
#>  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.1)
#>  lattice       0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
#>  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
#>  lubridate     1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
#>  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
#>  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
#>  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
#>  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
#>  nlme          3.1-148 2020-05-24 [1] CRAN (R 4.0.2)
#>  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
#>  pkgbuild      1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
#>  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
#>  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
#>  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
#>  processx      3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
#>  ps            1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
#>  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
#>  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
#>  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
#>  readr       * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
#>  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
#>  remotes       2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
#>  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
#>  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
#>  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
#>  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
#>  rvest         0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
#>  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
#>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
#>  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
#>  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
#>  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
#>  tibble      * 3.0.3   2020-07-10 [1] CRAN (R 4.0.1)
#>  tidyr       * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
#>  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
#>  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
#>  usethis       1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
#>  vctrs         0.3.1   2020-06-05 [1] CRAN (R 4.0.1)
#>  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
#>  xfun          0.15    2020-06-21 [1] CRAN (R 4.0.1)
#>  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
#>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
#> 
#> [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

</details>
````

Here's what that Markdown would look like rendered in a GitHub issue:


``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Must group by variables found in `.data`.
#> * Column `colour` is not found.
```

<sup>Created on 2020-09-21 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>

<details>

<summary>Session info</summary>

``` r
devtools::session_info()
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 4.0.2 (2020-06-22)
#>  os       macOS Catalina 10.15.6      
#>  system   x86_64, darwin17.0          
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  ctype    en_US.UTF-8                 
#>  tz       America/Chicago             
#>  date     2020-09-21                  
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package     * version date       lib source        
#>  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
#>  backports     1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
#>  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
#>  broom         0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
#>  callr         3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
#>  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
#>  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
#>  colorspace    1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
#>  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
#>  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
#>  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
#>  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
#>  devtools      2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
#>  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
#>  dplyr       * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
#>  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
#>  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
#>  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
#>  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
#>  fs            1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
#>  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
#>  ggplot2     * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
#>  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
#>  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
#>  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
#>  highr         0.8     2019-03-20 [1] CRAN (R 4.0.0)
#>  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
#>  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
#>  httr          1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
#>  jsonlite      1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
#>  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.1)
#>  lattice       0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
#>  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
#>  lubridate     1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
#>  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
#>  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
#>  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
#>  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
#>  nlme          3.1-148 2020-05-24 [1] CRAN (R 4.0.2)
#>  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
#>  pkgbuild      1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
#>  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
#>  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
#>  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
#>  processx      3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
#>  ps            1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
#>  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
#>  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
#>  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
#>  readr       * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
#>  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
#>  remotes       2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
#>  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
#>  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
#>  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
#>  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
#>  rvest         0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
#>  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
#>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
#>  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
#>  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
#>  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
#>  tibble      * 3.0.3   2020-07-10 [1] CRAN (R 4.0.1)
#>  tidyr       * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
#>  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
#>  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
#>  usethis       1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
#>  vctrs         0.3.1   2020-06-05 [1] CRAN (R 4.0.1)
#>  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
#>  xfun          0.15    2020-06-21 [1] CRAN (R 4.0.1)
#>  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
#>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
#> 
#> [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

</details>

Anyone else can copy, paste, and run this immediately. The nice thing is that if your script also produces images or graphs (probably using `ggplot()`) these images are automatically uploaded and included in the issue.

{{% alert note %}}

To ensure your example is a reproducible example, you need to make sure to load all necessary packages and data objects at the top of your copied code. This may involve opening a new tab in the editor panel and writing a short version of the script that only includes the essentials, then copying that script to the clipboard and `reprex()` it.

{{% /alert %}}



## Reprex do's and don'ts

* Use the smallest, simplest, most built-in data possible
    * Your example does not have to use a custom data file if you can reproduce it using something that already exists built-in to R or a common R package. This avoids requiring to share data files as part of the reproducible example
* Include commands on a strict "need to run" basis
    * You don't typically need to run the entire script or R Markdown document to reproduce the error. Instead, strip out any code that is unrelated to the specific matter at hand.
    * Do include every single command that is required (e.g. loading specific packages, creating/modifying data frames)
* Consider including "session info"
    * Session information provides important details such as your operating system, version of R, version of add-on packages. Often this information is useful in identifying and fixing problems in your code.
    * Use `reprex(..., si = TRUE)` to automatically append this information at the end of your reproducible example.
* Use good coding style to ensure the readability of your code by other human beings
    * Use `reprex(..., style = TRUE)` to request automatic styling of your code. Relies on the [`styler` package](/notes/style-guide/#styler).
* Ensure portability of the code
    * Don't use [`rm(list = ls())`](/notes/saving-source/#what-s-wrong-with-rm-list-ls) or [`setwd()`](/notes/project-oriented-workflow/#we-need-to-talk-about-setwd-path-that-only-works-on-my-machine).

## Acknowledgments

* ["How do I ask a good question?" StackOverflow.com](http://stackoverflow.com/help/how-to-ask)
* [`reprex`](https://reprex.tidyverse.org/index.html)

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.2 (2020-06-22)
##  os       macOS Catalina 10.15.6      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-09-21                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports     1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
##  blogdown      0.20.1  2020-07-02 [1] local         
##  bookdown      0.20    2020-06-23 [1] CRAN (R 4.0.2)
##  callr         3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
##  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
##  clipr         0.7.0   2019-07-23 [1] CRAN (R 4.0.0)
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 4.0.2)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools      2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
##  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  fs            1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
##  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
##  here          0.1     2017-05-28 [1] CRAN (R 4.0.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
##  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.1)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  pkgbuild      1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
##  ps            1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
##  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
##  remotes       2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
##  reprex      * 0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
##  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
##  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
##  usethis       1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
##  whisker       0.4     2019-08-28 [1] CRAN (R 4.0.0)
##  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
##  xfun          0.15    2020-06-21 [1] CRAN (R 4.0.1)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
