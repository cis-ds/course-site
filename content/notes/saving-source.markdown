---
title: "Saving the source and blank slates"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["project-management"]

menu:
  notes:
    parent: Project management
    weight: 1
---




```r
library(tidyverse)
library(here)

set.seed(1234)
theme_set(theme_minimal())
```

## Save source, not the workspace

Your **workspace** in R is the current working environment. It includes any libraries you have loaded using `library()`, any user-defined objects (e.g. data frames, lists, functions). At the end of an R session, you can save an image of the current workspace that is automatically reloaded the next time R is started.

**This is not good practice.** I recommend you cultivate a workflow in which you treat R processes (a.k.a. "sessions") as disposable. Any individual R process and the associated workspace is disposable. Why might this be unappealing? This sounds terrible if your workspace is a pet, i.e. it holds precious objects and you aren't 100% sure you can reproduce them. This fear is worth designing away, because attachment to your workspace indicates you have a non-reproducible workflow. This is guaranteed to lead to heartache.

Everything that really matters should be achieved through code that you save.

![](/img/if-you-liked-it-you-should-have-saved-the-source-for-it.jpg)

All important objects or figures should be explicitly saved to file, in a granular way. This is in contrast to storing them implicitly or explicitly, as part of an entire workspace, or saving them via the mouse. These recommendations make useful objects readily available for use in other scripts or documents, with the additional assurance that they can be regenerated on-demand.

Saving code -- not workspaces -- is incredibly important because it is an absolute requirement for reproducibility. Renouncing `.Rdata` and restarting R often are not intrinsically important or morally superior behaviours. They are important because they provide constant pressure for you to do the right thing: save the source code needed to create all important artifacts of your analysis.

## Always save commands

When working with R, save your commands in a `.R` file, a.k.a. a script, or in `.Rmd`, a.k.a. an R Markdown document. It doesn't have to be polished. Just save it!

## Always start R with a blank slate

When you quit R, do not save the workspace to an `.Rdata` file. When you launch, do not reload the workspace from an `.Rdata` file.

In RStudio, set this via *Tools > Global Options*.

![](/img/rstudio-workspace.png)

## Restart R often during development

> Have you tried turning it off and then on again?
>
> -- timeless troubleshooting wisdom, applies to everything

If you use RStudio, use the menu item *Session > Restart R* or the associated keyboard shortcut Ctrl+Shift+F10 (Windows and Linux) or Command+Shift+F10 (Mac OS). Additional keyboard shortcuts make it easy to restart development where you left off, i.e. to say "re-run all the code up to HERE":

* In an R script, use Ctrl+Alt+B (Windows and Linux) or Command+Option+B (Mac OS)
* In R markdown, use Ctrl+Alt+P (Windows and Linux) or Command+Option+P (Mac OS)

## What's wrong with `rm(list = ls())`?

{{< youtube GiPe1OiKQuk >}}

It's fairly common to see data analysis scripts that begin with this object-nuking command:

```r
rm(list = ls())
```

This is highly suggestive of a non-reproducible workflow.

This line is meant to reset things, either to power-cycle the current analysis or to switch from one project to another. But there are better ways to do both:

* To power-cycle the current analysis, restart R! See above.
* To switch from one project to another, either restart R or, even better, use an IDE with proper support for projects, where each project gets its own R process (i.e. RStudio).

**The problem with `rm(list = ls())` is that, given the intent, it does not go far enough.** All it does is delete user-created objects from the global workspace. Many other changes to the R landscape persist invisibly and can have profound effects on subsequent development. Any packages that have ever been attached via `library()` are still available. Any options that have been set to non-default values remain that way. Working directory is not affected (which is, of course, why we see `setwd()` so often here too!).

Why does this matter? It makes your script vulnerable to hidden dependencies on things you ran in this R process before you executed `rm(list = ls())`.

* You might use functions from a package without including the necessary `library()` call. Your collaborator won't be able to run this script.
* You might code up an analysis assuming that `stringsAsFactors = FALSE` but next week, when you have restarted R, everything will inexplicably be broken.
* You might write paths relative to some random working directory, then be puzzled next month when nothing can be found or results don't appear where you expect.

The solution is to write every script assuming it will be run in a fresh R process. The best way to do that is ... develop scripts in a fresh R process! 

There is nothing inherently evil about `rm(list = ls())`. It's a red flag, because it is indicative of a non-reproducible workflow. Since it appears to "work" ~90% of the time, it's very easy to deceive yourself into thinking your script is self-contained, when it is not.

## Objects that take a long time to create

Power-cycling your analysis regularly can be very painful if there are parts that take a long time to execute.

This indicates it's time for a modular approach that breaks the analysis into natural phases, each with an associated script and outputs. Isolate each computationally demanding step in its own script and write the precious object to file with `saveRDS(my_precious,
here("results", "my_precious.rds"))`. Now you can develop scripts to do
downstream work that reload the precious object via `my_precious <-
readRDS(here("results", "my_precious.rds"))`. Breaking an analysis into logical steps, with clear inputs and outputs, is a good idea anyway.

## Acknowledgments

* Substantial material drawn from [What They Forgot To Teach You About R](https://whattheyforgot.org/) by Jenny Bryan and Jim Hester. Licensed under the licensed under the [CC BY-SA 4.0 Creative Commons License](https://creativecommons.org/licenses/by-sa/4.0/).

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
##  here        * 0.1     2017-05-28 [2] CRAN (R 3.5.0)
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
