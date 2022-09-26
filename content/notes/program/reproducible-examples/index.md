---
title: "Generating reproducible examples"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/notes/reproducible-examples/"]
categories: ["programming"]

weight: 88
---



{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("cis-ds/reproducible-examples")
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


```
Warning: The `show` argument of `reprex()` is deprecated as of reprex 1.0.0.
Please use the `html_preview` argument instead.
This warning is displayed once every 8 hours.
Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.
```

````
``` r
library(tidyverse)
count(diamonds, colour)
#> Error in `group_by()`:
#> ! Must group by variables found in `.data`.
#> ✖ Column `colour` is not found.

#> Backtrace:
#>     ▆
#>  1. ├─dplyr::count(diamonds, colour)
#>  2. └─dplyr:::count.data.frame(diamonds, colour)
#>  3.   ├─dplyr::group_by(x, ..., .add = TRUE, .drop = .drop)
#>  4.   └─dplyr:::group_by.data.frame(x, ..., .add = TRUE, .drop = .drop)
#>  5.     └─dplyr::group_by_prepare(.data, ..., .add = .add, caller_env = caller_env())
#>  6.       └─rlang::abort(bullets, call = error_call)
```

<sup>Created on 2022-08-22 by the [reprex package](https://reprex.tidyverse.org) (v2.0.1.9000)</sup>
````

Here's what that Markdown would look like rendered in a GitHub issue:


``` r
library(tidyverse)
count(diamonds, colour)
#> Error in `group_by()`:
#> ! Must group by variables found in `.data`.
#> ✖ Column `colour` is not found.

#> Backtrace:
#>     ▆
#>  1. ├─dplyr::count(diamonds, colour)
#>  2. └─dplyr:::count.data.frame(diamonds, colour)
#>  3.   ├─dplyr::group_by(x, ..., .add = TRUE, .drop = .drop)
#>  4.   └─dplyr:::group_by.data.frame(x, ..., .add = TRUE, .drop = .drop)
#>  5.     └─dplyr::group_by_prepare(.data, ..., .add = .add, caller_env = caller_env())
#>  6.       └─rlang::abort(bullets, call = error_call)
```

<sup>Created on 2022-08-22 by the [reprex package](https://reprex.tidyverse.org) (v2.0.1.9000)</sup>

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
##  date     2022-09-26
##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date (UTC) lib source
##  blogdown      1.10    2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown      0.27    2022-06-14 [2] CRAN (R 4.2.0)
##  bslib         0.4.0   2022-07-16 [2] CRAN (R 4.2.0)
##  cachem        1.0.6   2021-08-19 [2] CRAN (R 4.2.0)
##  cli           3.4.0   2022-09-08 [1] CRAN (R 4.2.0)
##  digest        0.6.29  2021-12-01 [2] CRAN (R 4.2.0)
##  evaluate      0.16    2022-08-09 [1] CRAN (R 4.2.1)
##  fastmap       1.1.0   2021-01-25 [2] CRAN (R 4.2.0)
##  here          1.0.1   2020-12-13 [2] CRAN (R 4.2.0)
##  htmltools     0.5.3   2022-07-18 [2] CRAN (R 4.2.0)
##  jquerylib     0.1.4   2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite      1.8.0   2022-02-22 [2] CRAN (R 4.2.0)
##  knitr         1.39    2022-04-26 [2] CRAN (R 4.2.0)
##  magrittr      2.0.3   2022-03-30 [2] CRAN (R 4.2.0)
##  R6            2.5.1   2021-08-19 [2] CRAN (R 4.2.0)
##  rlang         1.0.5   2022-08-31 [1] CRAN (R 4.2.0)
##  rmarkdown     2.14    2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot     2.0.3   2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi    0.13    2020-11-12 [2] CRAN (R 4.2.0)
##  sass          0.4.2   2022-07-16 [2] CRAN (R 4.2.0)
##  sessioninfo   1.2.2   2021-12-06 [2] CRAN (R 4.2.0)
##  stringi       1.7.8   2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       1.4.0   2019-02-10 [2] CRAN (R 4.2.0)
##  xfun          0.31    2022-05-10 [1] CRAN (R 4.2.0)
##  yaml          2.3.5   2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```
