---
title: "Project-oriented workflow"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["project-management"]

menu:
  notes:
    parent: Project management
    weight: 2
---




```r
library(tidyverse)
library(here)

set.seed(1234)
theme_set(theme_minimal())
```

In [saving the source and blank slates](/notes/saving-the-source-and-blank-slates/), we discouraged the habit of starting R scripts with `rm(list = ls())`, because it doesn't actually achieve the intended goal: to reset things. Restarting R is a better way to power-cycle.

But what if you want to shift focus from project A to project B? Restarting R, alone, is not enough. It doesn't change R's working directory, which is needed if projects A and B live in different directories, which they should. Also, what if you want to have project A and B available for work at the same time?

My strong recommendation is to use a development tool with first-class support for projects. But first ...

## We need to talk about `setwd("path/that/only/works/on/my/machine")`

A common response to the working directory problem is to set the working directory at the beginning of each script via `setwd()`. For example:

```r
library(ggplot2)
setwd("/Users/bensoltoff/cuddly_broccoli/verbose_funicular/foofy/data")
df <- read.delim("raw_foofy_data.csv")
p <- ggplot(df, aes(x, y)) + geom_point()
ggsave("../figs/foofy_scatterplot.png")
```

The chance of the `setwd()` command having the desired effect -- making the file paths work -- for anyone besides its author is 0%. It's also unlikely to work for the author one or two years or computers from now. To recreate and perhaps extend this plot, the lucky recipient will need to hand edit one or more paths to reflect where the project has landed on their machine.

Hard-wired, absolute paths, especially when sprinkled throughout the code, make a project brittle. Such code does not travel well across time or space.

## Dilemma and a solution

Problem statement:

* We want to work on project A with R's working directory set to `path/to/projectA` and on project B with R's working directory set to `path/to/projectB`.
* But we also want to keep code like `setwd("path/to/projectA")` out of our `.R` scripts.

The solution is to use a **project-based workflow**.

## Organize work into projects (colloquial definition)

Here's what I mean by "project-based workflow":

* File system discipline: put all the files related to a single project in a designated folder.
    * This applies to data, code, figures, notes, etc.
    * Depending on project complexity, you might enforce further organization into subfolders.
* Working directory intentionality: when working on project A, make sure working directory is set to project A's folder.
    * Ideally, this is achieved via the development workflow and tooling, not by baking absolute paths into the code.
* File path discipline: all paths are relative and, by default, relative to the project's folder.

These habits are synergistic: you'll get the biggest payoff if you practice all of them together.

These habits guarantee that the project can be moved around on your computer or onto other computers and will still "just work". I argue that this is the only practical convention that creates reliable, polite behavior across different computers or users and over time. This convention is neither new, nor unique to R.

It's like agreeing that we will all drive on the left or the right. A hallmark of civilization is following conventions that constrain your behavior a little, in the name of public safety.

## RStudio Projects

The RStudio IDE has a notion of a (capital "P") [Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects), which is a very effective implementation of the (small "p") projects described above. 

You can designate a new or existing folder as a Project. All this means is that RStudio leaves a file, e.g., `foofy.Rproj`, in the folder, which is used to store settings specific to that project. Use *File > New Project ...* to get started.

Double-click on a `.Rproj` file to open a fresh instance of RStudio, with the working directory and file browser pointed at the project folder.

Once RStudio is running, you can open an existing Project, switch to another Project, launch a second instance of RStudio in a new or existing Project, and much more, via various menus and keyboard shortcuts (more below).

Here's a screenshot of the Mac OS app switcher invoked via Command+Tab, showing multiple simultaneous instances of RStudio.

![](/img/multiple-rstudio-projects.png)

This allows rapid context switching across several projects, such as an R package, teaching material, and a data analysis. There is no danger of crosstalk between the projects: each has its own R process, global workspace, and working directory.

## Tricks for opening Projects

Once you decide "I want to do some work in Project K", there are various ways to accelerate the startup process. I'll review a few going from general and low-tech to more specific.

**Have a dedicated folder for your Projects.** I keep the vast majority of my R work in RStudio Projects in the folder `~/Projects/`. What I call this folder and where I keep it is not important. The main point is if you have One Main Place for Projects, then you can go there in Finder or File Explorer and drill down to the `.Rproj` file needed to launch any specific project.

**RStudio knows about recently used Projects.** Once you are in RStudio, there are several ways to access other Projects you've recently worked in. In the upper right corner is a drop-down menu with various Project- and session-related goodies in it.

![](/img/rstudio-project-switching.png)

Use the "arrow and paper" icon to open a Project in a separate RStudio instance, while also leaving the Project you're launching it from open. Click on a Project's name to switch the current RStudio instance from one Project to another. The *File* menu also offers ways to switch project or open new, additional instances.

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
