---
title: "HW05: Debugging and generating R Markdown documents"
date: 2019-04-25T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post

summary: "Resolve code errors and generate reproducible R Markdown documents."
url_code: "https://github.com/cfss-sp20/hw05"
---



# Overview

Due before class November 5th.

# Fork the `hw05` repository

Go [here](https://github.com/cfss-sp20/hw05) to fork the repo for homework 05.

# Debugging code

TBD.

# Working with R Markdown documents

The homework repository contains a file called `hiv-profile.Rmd`.

1. The file has some problems. Fix the problems so you can successfully knit the document in its existing form.
1. Create a [parameterized report](https://r4ds.had.co.nz/r-markdown.html#parameters) that allows you generate `hiv-profile.Rmd` for any country in the dataset. Specifically, you need to do the following:
    1. Copy the file that you have successfully debugged to `hiv-profile-params.Rmd`.
    1. Change the output format to `html_document`.
    1. Add a parameter called `my_iso3` to the YAML header which defines a country's iso3 code.
    1. Write an R script which generates a separate report for every country in `hiv_rates.csv` and saves it to a folder called `reports`. Each file should be named after the country's iso3 code. For example, the report for the United States should be called `USA.html`.

# Submit the assignment

Your assignment should be submitted as two R Markdown documents using the `github_document` format. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Check minus: Your slides and supporting materials cannot be reproduced. Code is visible in your slides. The broken R Markdown document still does not knit. Graphs and tables don't have appropriate labels or formatting. There is no consistency to your code's style.

Check: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Check plus: Repository contains a detailed `README.md` explaining how the files in the repo should be executed. Broken R Markdown document successfully knits. Displays innovative data analysis or coding skills. Slides are well-designed and visually intuitive. Graphs and tables are well labeled. Analysis is insightful. I walk away feeling I learned something.
