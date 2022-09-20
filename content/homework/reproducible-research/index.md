---
title: "HW06: Generating reproducible analysis"
date: 2022-10-17T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post
aliases: ["/hw05-reproducible-research.html"]

summary: "Synthesize everything we have learned thus far."
---



# Overview

Due by 11:59pm on October 18th.

# Accessing the `hw06` repository

Go [here](https://github.coecis.cornell.edu/cis-fa22) and find your copy of the `hw06` repository. It follows the naming convention `hw06-<USERNAME>`. Clone the repository to your computer.

# What is my objective?

At this mid-way point in the term, I want to check and make sure everyone is up to speed on the major skills learned so far:

- Importing and tidying data
- Transforming, visualizing, and exploring data
- Communicating results
- Basic programming principles
- Debugging and defensive programming
- Reproducible workflows
- Quarto documents and extended publication formats

I also want to demonstrate the value of these skills for analysis **that interests you**. Therefore in this assignment, I want you to complete a data analytic report on a topic of your own interest. Frame it as you would if you were sharing this analysis in an extended blog post online. It should be approximately 1000-1200 words in length and showcase the major skills identified above. It does not need to be an advanced statistical analysis involving complex statistical modeling and skills we have not yet learned. The actual analysis can be relative simple - again, think exploratory. Analyzing the distribution of variables and how they are related to one another at a bivariate level is more than adequate.

You will disseminate your analysis as a [**website** constructed using Quarto](https://quarto.org/docs/websites/) and published using GitHub Pages. I will make sure your repository is configured to use GitHub Pages for publication. You need to make sure to [follow the instructions to render the site within RStudio to the `docs` directory.](https://quarto.org/docs/publishing/github-pages.html). At minimum, your site should be a single page. However you can expand it to include multiple pages if you desire and want to stretch your abilities.

# What data should I use?

Whatever you want! The important thing is that the entire analysis is **reproducible**. That is, I will clone your repository on my computer and attempt to reproduce your results. This means you should provide an informative `README.md` file that:

* Explains the purpose of the repository
* Identifies how to execute the scripts/Quarto documents to produce the same results as you
* Lists any additional packages a user should be expected to install prior to executing the files (you don't need to specify basic packages like `dplyr`, `tidyverse`, `rmarkdown`, etc.)

# I'm not creative and I can't think of anything to analyze!

Okay, then analyze one of the datasets we've used before.

* `gapminder` in `library(gapminder)`
* `gun_deaths`
    * In `library(rcis)`
    * [Raw data for `gun_deaths` from FiveThirtyEight](https://github.com/fivethirtyeight/guns-data)
* `scorecard`
    * In `library(rcis)`
    * Use the [`rscorecard`](https://github.com/btskinner/rscorecard) library to download your own subset of the Department of Education's College Scorecard data
* Check out [this archive of datasets](https://docs.google.com/spreadsheets/d/1wZhPLMCHKJvwOkP4juclhjFgqIY8fQFMemwKL2c64vk/edit#gid=0) from the Data Is Plural Newsletter
* Likewise, #TidyTuesday is a weekly data analysis challenge for individuals to practice and develop their data analysis skills in R. They post a new challenge every Tuesday, and publish [a complete archive of all of their past challenges and source data](https://github.com/rfordatascience/tidytuesday).

## How can I automatically download the data

There are functions in R and programs for the [shell](/setup/shell/) that allow you to do this. For example, if I wanted to download `gapminder` from the [original GitHub repo](https://github.com/jennybc/gapminder):

+ Option 1: via an R script using [downloader::download](https://cran.r-project.org/web/packages/downloader/downloader.pdf) or [RCurl::getURL](http://www.omegahat.net/RCurl/installed/RCurl/html/getURL.html).

    ```r
    downloader::download("https://raw.githubusercontent.com/fivethirtyeight/guns-data/master/full_data.csv", "gun_deaths.csv")
    cat(file = "gun_deaths.csv",
    RCurl::getURL("https://raw.githubusercontent.com/fivethirtyeight/guns-data/master/full_data.csv"))
    ```

+ Option 2: in a [shell](/setup/shell/) script using `curl` or `wget`.

    ```bash
    curl -O https://raw.githubusercontent.com/fivethirtyeight/guns-data/master/full_data.csv
    wget https://raw.githubusercontent.com/fivethirtyeight/guns-data/master/full_data.csv
    ```

+ Option 3: manually download and save a copy of the data file(s) in your repo. **Make sure to commit and push them to GitHub**.

### What if my data file is large?

Because of how Git tracks changes in files, GitHub will not allow you to commit and push a file larger than 100mb. If you try to do so, you will get an error message and the commit will not push. Worse yet, you know have to find a way to strip all trace of the data file from the Git repo (including previous commits) before you can sync up your fork. This is a pain in the ass. Avoid it as much as possible. If you follow option 1 and 2, then you do not need to store the data file in the repo because it is automatically downloaded by your script/Quarto document.

If you have to store a large data file in your repo, use [**Git Large File Storage**](https://git-lfs.github.com/). It is a separate program you need to install via the shell, but the instructions are straight-forward. It integrates smoothly into GitHub, and makes version tracking of large files far easier. If you include it in a course-related repo (i.e. a fork of the homework repos), then there is no cost. If you want to use Git LFS for your own work, [there are separate fees charged by GitHub for storage and bandwidth usage.](https://help.github.com/articles/about-storage-and-bandwidth-usage/)

## Perform exploratory analysis

* Import the data
* Tidy it as necessary to get it into a tidy data structure
* Generate some descriptive plots of the data
* Summarize the relationships you discover with a written summary. Conjecture as to why they occur and/or why they may be [spurious](https://en.wikipedia.org/wiki/Spurious_relationship).

The final output should be a Quarto website (hence the output file(s) will be HTML). It is okay to have additional standalone R scripts if they are used as part of the data analysis workflow.

# Aim higher!

* Use a completely unique dataset - preferably something related to your own research interests
    * You will probably need to spend time data cleaning and tidying. This could be done in the main Quarto document or in a separate R script. If done in the Quarto document, consider whether it is necessary to include the code and output in the final document.
* Render a Quarto website with your final analysis.
    * You do not need to stuff everything into the website. For example, you might describe how you obtained and prepared the data, but you won't include all the code and output from that process in the final page. But because it is stored in a separate R script and is part of the repo, everything is still completely reproducible.
* Make use of code chunk and YAML options to customize the appearance of your final document
* Use your skills on [project management](/notes/saving-source/) to ensure reproducibility
* Writing your own functions? Implement [defensive](/notes/style-guide/) [programming](/notes/condition-handling/) to minimize errors (or at least provide informative error messages).
* Use a consistent style when writing your code

# Submit the assignment

Your assignment should be submitted as a set of R scripts, Quarto documents, data files, figures, etc. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow).

# Rubric

Needs improvement: Cannot reproduce your results. Scripts require interactive coding to fix. Markdown documents are not generated. Graphs and tables don't have appropriate labels or formatting. There is no consistency to your code's style.

Satisfactory: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Excellent: Repository contains a detailed `README.md` explaining how the files in the repo should be executed. Displays innovative data analysis or coding skills. Graphs and tables are well labeled. Excellent implementation of a consistent style guide. Analysis is insightful. I walk away feeling I learned something.

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
