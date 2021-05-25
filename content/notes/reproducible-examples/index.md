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



{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/reproducible-examples-and-git")
```

{{% /callout %}}

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

{{< figure src="reprex-output.png" caption="Output of `reprex()`" >}}

The relevant bit of GitHub-flavored Markdown is ready to be pasted from your clipboard:


````
``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Must group by variables found in `.data`.
#> * Column `colour` is not found.
```

<sup>Created on 2020-12-15 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>
````

Here's what that Markdown would look like rendered in a GitHub issue:


``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Must group by variables found in `.data`.
#> * Column `colour` is not found.
```

<sup>Created on 2020-12-15 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>

Anyone else can copy, paste, and run this immediately. The nice thing is that if your script also produces images or graphs (probably using `ggplot()`) these images are automatically uploaded and included in the issue.

{{% callout note %}}

To ensure your example is a reproducible example, you need to make sure to load all necessary packages and data objects at the top of your copied code. This may involve opening a new tab in the editor panel and writing a short version of the script that only includes the essentials, then copying that script to the clipboard and `reprex()` it.

{{% /callout %}}



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

{{< figure src="allison_horst_art/reprex.png" caption="Artwork by @allison_horst" >}}

## Acknowledgments

* ["How do I ask a good question?" StackOverflow.com](http://stackoverflow.com/help/how-to-ask)
* [`reprex`](https://reprex.tidyverse.org/index.html)
* Artwork by [@allison_horst](https://github.com/allisonhorst/stats-illustrations)

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.4 (2021-02-15)
##  os       macOS Big Sur 10.16         
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-05-25                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  blogdown      1.3     2021-04-14 [1] CRAN (R 4.0.2)
##  bookdown      0.22    2021-04-22 [1] CRAN (R 4.0.2)
##  bslib         0.2.5   2021-05-12 [1] CRAN (R 4.0.4)
##  cachem        1.0.5   2021-05-15 [1] CRAN (R 4.0.2)
##  callr         3.7.0   2021-04-20 [1] CRAN (R 4.0.2)
##  cli           2.5.0   2021-04-26 [1] CRAN (R 4.0.2)
##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.2)
##  desc          1.3.0   2021-03-05 [1] CRAN (R 4.0.2)
##  devtools      2.4.1   2021-05-05 [1] CRAN (R 4.0.2)
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
##  ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.0.2)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.0.2)
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)
##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)
##  jquerylib     0.1.4   2021-04-26 [1] CRAN (R 4.0.2)
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)
##  knitr         1.33    2021-04-24 [1] CRAN (R 4.0.2)
##  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.0.2)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
##  memoise       2.0.0   2021-01-26 [1] CRAN (R 4.0.2)
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)
##  pkgload       1.2.1   2021-04-06 [1] CRAN (R 4.0.2)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.5.2   2021-04-30 [1] CRAN (R 4.0.2)
##  ps            1.6.0   2021-02-28 [1] CRAN (R 4.0.2)
##  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)
##  remotes       2.3.0   2021-04-01 [1] CRAN (R 4.0.2)
##  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.0.2)
##  rmarkdown     2.8     2021-05-07 [1] CRAN (R 4.0.2)
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)
##  sass          0.4.0   2021-05-12 [1] CRAN (R 4.0.2)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.6.1   2021-05-10 [1] CRAN (R 4.0.2)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      3.0.2   2021-02-14 [1] CRAN (R 4.0.2)
##  usethis       2.0.1   2021-02-10 [1] CRAN (R 4.0.2)
##  withr         2.4.2   2021-04-18 [1] CRAN (R 4.0.2)
##  xfun          0.23    2021-05-15 [1] CRAN (R 4.0.2)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
