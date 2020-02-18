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
#> Error: Column `colour` is unknown
```

<sup>Created on 2019-11-07 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>
````

Here's what that Markdown would look like rendered in a GitHub issue:


``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Column `colour` is unknown
```

<sup>Created on 2019-11-07 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>

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

## Exercise: generate a simple reproducible example

Consider the following code example:


```r
library(dplyr)
library(ggplot2)

# get data from rcfss package
# install latest version if not already installed
# devtools::install_github("uc-cfss/rcfss")
library(rcfss)

# load the data
data("mass_shootings")
mass_shootings
```

```
## # A tibble: 114 x 14
##    case   year month   day location summary fatalities injured
##    <chr> <dbl> <chr> <int> <chr>    <chr>        <dbl>   <dbl>
##  1 Dayt…  2019 Aug       4 Dayton,… PENDING          9      27
##  2 El P…  2019 Aug       3 El Paso… PENDING         20      26
##  3 Gilr…  2019 Jul      28 Gilroy,… "Santi…          3      12
##  4 Virg…  2019 May      31 Virgini… "DeWay…         12       4
##  5 Harr…  2019 Feb      15 Aurora,… Gary M…          5       6
##  6 Penn…  2019 Jan      24 State C… Jordan…          3       1
##  7 SunT…  2019 Jan      23 Sebring… "Zephe…          5       0
##  8 Merc…  2018 Nov      19 Chicago… Juan L…          3       0
##  9 Thou…  2018 Nov       7 Thousan… Ian Da…         12      22
## 10 Tree…  2018 Oct      27 Pittsbu… "Rober…         11       6
## # … with 104 more rows, and 6 more variables: total_victims <dbl>,
## #   location_type <chr>, male <lgl>, age_of_shooter <dbl>, race <chr>,
## #   prior_mental_illness <chr>
```

```r
# Generate a bar chart that identifies the number of mass shooters
# associated with each race category. The bars should be sorted
# from highest to lowest.

# using reorder() and aggregating the data before plotting
mass_shootings %>%
  count(race) %>%
  drop_na(race) %>%
  ggplot(mapping = aes(x = reorder(race, -n), y = n)) +
  geom_col() +
  labs(
    title = "Mass shootings in the United States (1982-2019)",
    x = "Race of perpetrator",
    y = "Number of incidents"
  )
```

```
## Error in drop_na(., race): could not find function "drop_na"
```

It does not work properly. Generate a simple reproducible example using `reprex()` and post it as a new issue in [this repository](https://github.com/uc-cfss/Discussion).

## Exercise: generate a simple reproducible example with graphs

Consider the following code example:


```r
library(tidyverse)

# get data from rcfss package
# install latest version if not already installed
# devtools::install_github("uc-cfss/rcfss")
library(rcfss)

# load the data
data("mass_shootings")
mass_shootings
```

```
## # A tibble: 114 x 14
##    case   year month   day location summary fatalities injured
##    <chr> <dbl> <chr> <int> <chr>    <chr>        <dbl>   <dbl>
##  1 Dayt…  2019 Aug       4 Dayton,… PENDING          9      27
##  2 El P…  2019 Aug       3 El Paso… PENDING         20      26
##  3 Gilr…  2019 Jul      28 Gilroy,… "Santi…          3      12
##  4 Virg…  2019 May      31 Virgini… "DeWay…         12       4
##  5 Harr…  2019 Feb      15 Aurora,… Gary M…          5       6
##  6 Penn…  2019 Jan      24 State C… Jordan…          3       1
##  7 SunT…  2019 Jan      23 Sebring… "Zephe…          5       0
##  8 Merc…  2018 Nov      19 Chicago… Juan L…          3       0
##  9 Thou…  2018 Nov       7 Thousan… Ian Da…         12      22
## 10 Tree…  2018 Oct      27 Pittsbu… "Rober…         11       6
## # … with 104 more rows, and 6 more variables: total_victims <dbl>,
## #   location_type <chr>, male <lgl>, age_of_shooter <dbl>, race <chr>,
## #   prior_mental_illness <chr>
```

```r
# Generate a bar chart that identifies the number of mass shooters
# associated with each race category. The bars should be sorted
# from highest to lowest.

# using forcats::fct_infreq() and using the raw data for plotting
mass_shootings %>%
  drop_na(race) %>%
  ggplot(mapping = aes(x = fct_infreq(race))) +
  geom_bar() +
  coord_flip() +
  labs(
    title = "Mass shootings in the United States (1982-2019)",
    x = "Race of perpetrator",
    y = "Number of incidents"
  )
```

<img src="/notes/reproducible-examples_files/figure-html/bad-graph-1.png" width="672" />

The code runs, but I want the graph sorted with the most frequent category at the top and the least frequent category at the bottom. How do I do this? Prepare a reproducible example and post it as a new issue on [this repository](https://github.com/uc-cfss/Discussion).

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
##  version  R version 3.6.1 (2019-07-05)
##  os       macOS Catalina 10.15.3      
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-02-18                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.5   2019-10-02 [1] CRAN (R 3.6.0)
##  blogdown      0.17.1  2020-02-13 [1] local         
##  bookdown      0.17    2020-01-11 [1] CRAN (R 3.6.0)
##  callr         3.4.2   2020-02-12 [1] CRAN (R 3.6.1)
##  cli           2.0.1   2020-01-08 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.2.1   2019-09-24 [1] CRAN (R 3.6.0)
##  digest        0.6.23  2019-11-23 [1] CRAN (R 3.6.0)
##  ellipsis      0.3.0   2019-09-20 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
##  knitr         1.28    2020-02-06 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.6   2019-10-09 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.3   2019-11-08 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.4   2020-01-28 [1] CRAN (R 3.6.0)
##  rmarkdown     2.1     2020-01-20 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.5   2020-01-11 [1] CRAN (R 3.6.0)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.3.1   2019-12-01 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.12    2020-01-13 [1] CRAN (R 3.6.0)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
