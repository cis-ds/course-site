---
title: "HW05: Generating reproducible research"
date: 2019-04-29T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: true
type: post
aliases: ["/hw05-reproducible-research.html"]

summary: "Synthesize everything we have learned thus far."
url_code: "https://github.com/uc-cfss/hw05"
---



# Overview

Due before class May 6th.

# Fork the `hw05` repository

Go [here](https://github.com/uc-cfss/hw05) to fork the repo for homework 05.

# What is my objective?

At this half-way point in the term, I want to check and make sure everyone is up to speed on the major skills learned so far:

* Importing and tidying data
* Transforming, visualizing, and exploring data
* Communicating results
* Basic programming principles
* Debugging and defensive programming

I also want to demonstrate the value of these skills for research **that interests you**. Therefore in this assignment, I want you to write a short report on a research question of your own interest. Frame it as you would if you were submitting it for a substantive seminar in your research field, though much shorter and comprehensive then a term paper. It should be approximately 750-1000 words in length and showcase the major skills identified above. It does not need to be an advanced statistical analysis involving complex statistical modeling and skills we have not yet learned. The actual analysis can be relative simple - again, think exploratory. Analyzing the distribution of variables and how they are related to one another at a bivariate level is more than adequate.

# What data should I use?

Whatever you want! The important thing is that the entire analysis is **reproducible**. That is, I will clone your repository on my computer and attempt to reproduce your results. This means you should provide an informative `README.md` file that:

* Explains the purpose of the repository
* Identifies how to execute the scripts/R Markdown documents to produce the same results as you
* Lists any additional packages a user should be expected to install prior to executing the files (you don't need to specify basic packages like `dplyr`, `tidyverse`, `rmarkdown`, etc.)

# I'm not creative and I can't think of anything to analyze!

Okay, then analyze one of the datasets we've used before.

* `gapminder` in `library(gapminder)`
* `gun_deaths`
    * In `library(rcfss)`
    * [Raw data for `gun_deaths` from FiveThirtyEight](https://github.com/fivethirtyeight/guns-data)
* `scorecard`
    * In `library(rcfss)`
    * Use the [`rscorecard`](https://github.com/btskinner/rscorecard) library to download your own subset of the Department of Education's College Scorecard data

## How can I automatically download the data

There are functions in R and programs for the [shell](/setup/shell/) that allow you to do this. For example, if I wanted to download `gapminder` from the [original GitHub repo](https://github.com/jennybc/gapminder):

+ Option 1: via an R script using [downloader::download](https://cran.r-project.org/web/packages/downloader/downloader.pdf) or [RCurl::getURL](http://www.omegahat.net/RCurl/installed/RCurl/html/getURL.html).

    ```r
    downloader::download("https://raw.githubusercontent.com/jennybc/gapminder/master/inst/gapminder.tsv")
    cat(file = "gapminder.tsv",
      RCurl::getURL("https://raw.githubusercontent.com/jennybc/gapminder/master/inst/gapminder.tsv"))
    ```

+ Option 2: in a [shell](/setup/shell/) script using `curl` or `wget`.

    ```bash
    curl -O https://raw.githubusercontent.com/jennybc/gapminder/master/inst/gapminder.tsv
    wget https://raw.githubusercontent.com/jennybc/gapminder/master/inst/gapminder.tsv
    ```

+ Option 3: manually download and save a copy of the data file(s) in your repo. **Make sure to commit and push them to GitHub**.

### What if my data file is large?

Because of how Git tracks changes in files, GitHub will not allow you to commit and push a file larger than 100mb. If you try to do so, you will get an error message and the commit will not push. Worse yet, you know have to find a way to strip all trace of the data file from the Git repo (including previous commits) before you can sync up your fork. This is a pain in the ass. Avoid it as much as possible. If you follow option 1 and 2, then you do not need to store the data file in the repo because it is automatically downloaded by your script/R Markdown document.

If you have to store a large data file in your repo, use [**Git Large File Storage**](https://git-lfs.github.com/). It is a separate program you need to install via the shell, but the instructions are straight-forward. It integrates smoothly into GitHub, and makes version tracking of large files far easier. If you include it in a course-related repo (i.e. a fork of the homework repos), then there is no cost. If you want to use Git LFS for your own work, [there are separate fees charged by GitHub for storage and bandwidth usage.](https://help.github.com/articles/about-storage-and-bandwidth-usage/)

## Perform exploratory analysis

* Import the data
* Tidy it as necessary to get it into a tidy data structure
* Generate some descriptive plots of the data
* Summarize the relationships you discover with a written summary. Conjecture as to why they occur and/or why they may be [spurious](https://en.wikipedia.org/wiki/Spurious_relationship).

The final output should be a `github_document`, but feel free to use R scripts in your initial work or create a [pipeline](https://github.com/uc-cfss/pipeline-example) that executes and renders all your scripts/R Markdown files at once.

# Aim higher!

* Use a completely unique dataset - preferably something related to your own research interests
    * You will probably need to spend time data cleaning and tidying. Could be done in the main R Markdown document or in a separate R script. If done in the R Markdown document, consider whether it is necessary to include the code and output in the final document.
* Render an R Markdown document with your final analysis.
    * You do not need to stuff everything into the final document. Think of this like a traditional report. You might describe how you obtained and prepared the data, but you won't include all the code and output from that process in the final document. But because it is stored in a separate R script and is part of the repo, everything is still completely reproducible.
    * To emulate RStudio's "Knit" button from a [shell](/setup/shell/):
        `Rscript -e "rmarkdown::render('myAwesomeAnalysis.Rmd')"`
    * To emulate RStudio's "Knit" button within an R script:
        `rmarkdown::render('myAwesomeAnalysis.Rmd)`
* Experiment with running R code saved in a script from within R Markdown. Here's some official documentation on [code externalization](http://yihui.name/knitr/demo/externalization/).
* Embed pre-existing figures in an R Markdown document, i.e. an R script creates the figures, then the report incorporates them.
* Make use of code chunk and YAML options to customize the appearance of your final document
* Writing your own functions? Implement [defensive](/notes/style-guide/) [programming](/notes/condition-handling/) to minimize errors (or at least provide informative error messages).
* Use a consistent style when writing your code

# Submit the assignment

Your assignment should be submitted as a set of R scripts, R Markdown documents, data files, figures, etc. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

## SPECIAL NOTE

In your reflection, make special note of any significant problems that required debugging. Try to be specific about your process. Did you receive any helpful error or warning message? Did you use `traceback()` to hunt down the source of the bug? How did you resolve it? You don't need to do this for every bug, but keep track of at least one or two major errors you had to resolve.

# Rubric

Check minus: Cannot reproduce your results. Scripts require interactive coding to fix. Markdown documents are not generated. Graphs and tables don't have appropriate labels or formatting. There is no consistency to your code's style.

Check: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Check plus: Repository contains a detailed `README.md` explaining how the files in the repo should be executed. Displays innovative data analysis or coding skills. Graphs and tables are well labeled. Excellent implementation of a consistent style guide. Analysis is insightful. I walk away feeling I learned something.

### Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
