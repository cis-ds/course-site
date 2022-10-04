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

I also want to demonstrate the value of these skills for analysis **that interests you**. Therefore in this assignment you will create a [**Quarto blog**](https://quarto.org/docs/websites/website-blog.html). The blog should contain:

- A home page
- An about page
- At least **three blog posts** which utilize R code and original data analysis. You are welcome to reuse analysis you wrote for previous homework assignments in this class, but at least **one** post must contain completely original analysis using new data. They do not need to be advanced statistical analyses involving complex statistical modeling and skills we have not yet learned. The actual analysis can be relative simple - again, think exploratory.

Some examples of appropriate blog post content include:

- [My personal blog](https://bensoltoff.com/blog/)
- [The MockUp](https://themockup.blog/)
- [Any number of posts shared as part of #TidyTuesday](https://twitter.com/search?q=%23tidytuesday)

You will publish your website using GitHub Pages. I will make sure your repository is configured to use GitHub Pages for publication. The publication URL will be `https://pages.github.coecis.cornell.edu/cis-fa22/hw06-<USERNAME>/`. You need to make sure to [follow the instructions to render the site within RStudio to the `docs` directory.](https://quarto.org/docs/publishing/github-pages.html).

# What data should I use?

Whatever you want! For two of the blog posts you can use analysis from previous homeworks, but for at least one post you should use new data. The important thing is that the entire website is **reproducible**. That is, I will clone your repository on my computer and attempt to reproduce your results (e.g. render the website from scratch). This means you should provide an informative `README.md` file that:

* Explains the purpose of the repository
* Identifies how to execute the scripts/Quarto documents to produce the same results as you
* Lists any additional packages a user should be expected to install prior to executing the files (you don't need to specify basic packages like `dplyr`, `tidyverse`, `rmarkdown`, etc.)

This also means all required data files should be included in the repository.

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

### What if my data files are large?

Because of how Git tracks changes in files, GitHub will not allow you to commit and push a file larger than 100mb. If you try to do so, you will get an error message and the commit will not push. Worse yet, you know have to find a way to strip all trace of the data file from the Git repo (including previous commits) before you can sync up your fork. This is a pain in the ass. Avoid it as much as possible. If you follow option 1 and 2, then you do not need to store the data file in the repo because it is automatically downloaded by your script/Quarto document.

If you have to store a large data file in your repo, use [**Git Large File Storage**](https://git-lfs.github.com/). It is a separate program you need to install via the shell, but the instructions are straight-forward. It integrates smoothly into GitHub, and makes version tracking of large files far easier. If you include it in a course-related repo (i.e. a fork of the homework repos), then there is no cost. If you want to use Git LFS for your own work, [there are separate fees charged by GitHub for storage and bandwidth usage.](https://help.github.com/articles/about-storage-and-bandwidth-usage/)

# Aim higher!

* Use completely unique datasets for all your blog posts - preferably something related to your own personal or professional interests
    * You will probably need to spend time data cleaning and tidying. This could be done in the main Quarto document or in a separate R script. If done in the Quarto document, consider whether it is necessary to include the code and output in the final document.
* Selectively determine what content to include on your pages
    * You do not need to stuff everything into the website. For example, you might describe how you obtained and prepared the data, but you won't include all the code and output from that process in the final page. To ensure it is reproducible, store that tidying code in a standalone R script within the repo **and document it with a `README.md` file**.
* Make use of `knitr` chunk options and YAML options to customize the appearance of your final website
* Use your skills on [project management](/notes/saving-source/) to ensure reproducibility
* Writing your own functions? Implement [defensive](/notes/style-guide/) [programming](/notes/condition-handling/) to minimize errors (or at least provide informative error messages).
* Use a consistent style when writing your code

# Submit the assignment

Your assignment should be submitted as a Quarto website with all the required source code files (e.g. `.qmd`, `*.yml`, `.R`). Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow).

# Rubric

Needs improvement: Cannot reproduce your results. Scripts require interactive coding to fix. HTML documents are not generated. Graphs and tables don't have appropriate labels or formatting. There is no consistency to your code's style.

Satisfactory: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Excellent: Repository contains a detailed `README.md` explaining how the files in the repo should be executed. Displays innovative data analysis or coding skills. Graphs and tables are well labeled. Excellent implementation of a consistent style guide. Analysis is insightful. I walk away feeling I learned something.

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
