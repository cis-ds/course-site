---
title: "A deep dive into R Markdown"
date: 2019-05-01T13:30:00
publishDate: 2019-03-01T13:30:00
draft: false
type: "talk"

alias: ["/cm010.html"]

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
time_start: 2019-05-01T13:30:00
time_end: 2019-05-01T14:50:00
all_day: false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: []

# Abstract and optional shortened version.
abstract: ""
summary: "All things related to R Markdown, plus a review of R scripts and Git troubleshooting."

# Location of event.
location: "Room 247, Saieh Hall for Economics, Chicago, IL"

# Is this a selected talk? (true/false)
selected: false

# Tags (optional).
#   Set `tags: []` for no tags, or use the form `tags: ["A Tag", "Another Tag"]` for one or more tags.
tags: []

# Links (optional).
url_pdf: ""
url_slides: ""
url_video: ""
url_code: ""

# Does the content use math formatting?
math: false
---



## Overview

* Review the importance of reproducibility in scientific research
* Identify the major components of R Markdown
* Implement chunk options to customize output
* Incorporate in-line R code in R Markdown documents
* Introduce the different R Markdown formats
* Identify common problems with Git and explain how to resolve these problems

## Before class

* Read chapters 27-29 in [R for Data Science](http://r4ds.had.co.nz) for more on R Markdown and document formats
* Review [chapter 6](http://r4ds.had.co.nz/workflow-scripts.html) in *R for Data Science* for more info on scripts
* Read [Recovering from Git Predicaments](/notes/common-git-problems/) - some important tips for fixing problems related to Git

## Slides and links

* [Slides](extras/cm010_slides.html)
* [A dive into R Markdown](/notes/r-markdown/)

* [R Markdown](http://rmarkdown.rstudio.com/) - the official site for R Markdown. Lots of great explanations of the different formats and options available for each one.
* [`flexdashboard`](https://rmarkdown.rstudio.com/flexdashboard/) - documentation for `flexdashboard` to create information dashboards using R Markdown
* [`pipeline-example`](https://github.com/uc-cfss/pipeline-example) - a repo demonstrating how to combine and use R scripts and R Markdown documents. I recommend you fork/clone the repo to your computer, then explore and execute the different files to see how everything works together.

## What you need to do

* [Start homework 5](/homework/reproducible-research/)
* Install the `titanic` package using the command `install.packages("titanic")`. We will be using this package in-class next time
