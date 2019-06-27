---
title: "A deep dive into R Markdown"
date: 2019-07-11T10:00:00
publishDate: 2019-03-01T13:30:00
draft: false
type: "talk"

aliases: ["/cm010.html"]

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
time_end: 2019-07-11T10:50:00
all_day: false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: []

# Abstract and optional shortened version.
abstract: ""
summary: "All things related to R Markdown, plus a review of R scripts and Git troubleshooting."

# Location of event.
location: "Room 315, Haskell Hall, Chicago, IL"

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
* Introduce the different R Markdown formats
* Distinguish between R scripts (`.R`) and R Markdown documents (`.Rmd`)
* Practice generating reproducible examples
* Identify common problems with Git and explain how to resolve these problems

## Before class

* Read chapters 27-29 in [R for Data Science](http://r4ds.had.co.nz) for more on R Markdown and document formats
* Review [chapter 6](http://r4ds.had.co.nz/workflow-scripts.html) in *R for Data Science* for more info on scripts

## Class materials

* [A dive into R Markdown](/notes/r-markdown/)
* [Reproducible examples and `reprex`](/faq/asking-questions/#include-a-reproducible-example)
* [Recovering from common Git predicaments](/notes/common-git-problems/)

## What you need to do

* Install the `titanic` package using the command `install.packages("titanic")`. We will be using this package in-class next time
