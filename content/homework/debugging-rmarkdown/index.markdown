---
title: "HW05: Debugging and generating R Markdown documents"
date: 2019-04-25T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post

summary: "Resolve code errors and generate reproducible R Markdown documents."
url_code: "https://github.com/cfss-win21/hw05"
---



# Overview

Due by 9:40am (Chicago) on February 16th.

# Fork the `hw05` repository

Go [here](https://github.com/cfss-win21/hw05) to fork the repo for homework 05.

# Debugging code

The repository contains an R script called `babynames.R`. This script includes code to conduct analysis of baby name popularity in the United States using the [`babynames`](http://hadley.github.io/babynames/) package. Alas its author made some mistakes and the script currently does not work. Fix the errors/warnings in the script to generate the desired output.

# Working with R Markdown documents

The homework repository contains a file called `hiv-profile.Rmd`.

1. The file has some problems. Fix the problems so you can successfully knit the document in its existing form.
1. Create a [parameterized report](https://r4ds.had.co.nz/r-markdown.html#parameters) that allows you generate `hiv-profile.Rmd` for any country in the dataset. Use this parameterized R Markdown document to generate a separate report for each country and save them as HTML documents to a folder called `reports`.

{{% callout note %}}

Each file should be named after the country's iso3 code. For example, the report for the United States should be called `USA.html`.

{{% /callout %}}

# Submit the assignment

Your assignment should be submitted as several files:

1. The revised `babynames.R`.
1. The revised `hiv-profile.Rmd` and the successfully rendered `hiv-profile.md` with associated output files (e.g. images).
1. An R script that renders all the individual country HIV profiles, as well as rendered HTML files.

Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Needs improvement: The R script has not been successfully fixed. The broken R Markdown document still does not knit. You manually generated each country's report.

Satisfactory: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Excellent: Repository contains a detailed `README.md` explaining how the files in the repo should be executed. Broken R Markdown document successfully knits. Used iterative operations to generate each country's HIV profile.
