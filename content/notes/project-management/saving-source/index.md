---
title: "Saving the source and blank slates"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/notes/saving-source/"]
categories: ["project-management"]

weight: 91
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

{{< figure src="if-you-liked-it-you-should-have-saved-the-source-for-it.jpg" caption="" >}}

All important objects or figures should be explicitly saved to file, in a granular way. This is in contrast to storing them implicitly or explicitly, as part of an entire workspace, or saving them via the mouse. These recommendations make useful objects readily available for use in other scripts or documents, with the additional assurance that they can be regenerated on-demand.

Saving code -- not workspaces -- is incredibly important because it is an absolute requirement for reproducibility. Renouncing `.Rdata` and restarting R often are not intrinsically important or morally superior behaviours. They are important because they provide constant pressure for you to do the right thing: save the source code needed to create all important artifacts of your analysis.

## Always save commands

When working with R, save your commands in a `.R` file, a.k.a. a script, or in `.Rmd`, a.k.a. an R Markdown document. It doesn't have to be polished. Just save it!

## Always start R with a blank slate

When you quit R, do not save the workspace to an `.Rdata` file. When you launch, do not reload the workspace from an `.Rdata` file.

In RStudio, set this via *Tools > Global Options*.

{{< figure src="rstudio-workspace.png" caption="" >}}

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

This indicates it's time for a modular approach that breaks the analysis into natural phases, each with an associated script and outputs. Isolate each computationally demanding step in its own script and write the precious object to file with `readr::save_rds(my_precious,
here("results", "my_precious.rds"))`. Now you can develop scripts to do
downstream work that reload the precious object via `my_precious <-
readr::read_rds(here("results", "my_precious.rds"))`. Breaking an analysis into logical steps, with clear inputs and outputs, is a good idea anyway.

## Acknowledgments

* Substantial material drawn from [What They Forgot To Teach You About R](https://whattheyforgot.org/) by Jenny Bryan and Jim Hester. Licensed under the licensed under the [CC BY-SA 4.0 Creative Commons License](https://creativecommons.org/licenses/by-sa/4.0/).

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
##  package       * version    date (UTC) lib source
##  assertthat      0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown        1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  cli             3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs              1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2       * 3.3.6      2022-05-03 [2] CRAN (R 4.2.0)
##  glue            1.6.2      2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive     2.0.0      2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4   1.0.0      2021-07-21 [2] CRAN (R 4.2.0)
##  gtable          0.3.0      2019-03-25 [2] CRAN (R 4.2.0)
##  haven           2.5.0      2022-04-15 [2] CRAN (R 4.2.0)
##  here          * 1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  hms             1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools       0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr            1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr           1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate       1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr          0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6              2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  readr         * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl          1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex          2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  rlang           1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown       2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest           1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo     1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  stringi         1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  utf8            1.2.2      2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs           0.4.1      2022-04-13 [2] CRAN (R 4.2.0)
##  withr           2.5.0      2022-03-03 [2] CRAN (R 4.2.0)
##  xfun            0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2            1.3.3      2021-11-30 [2] CRAN (R 4.2.0)
##  yaml            2.3.5      2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```
