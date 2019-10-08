---
title: "HW05: Debugging and generating R Markdown documents"
date: 2019-04-25T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post

summary: "Resolve code errors and generate reproducible R Markdown documents."
url_code: "https://github.com/cfss-fa19/hw05"
---



# Overview

Due before class November 5th.

# Fork the `hw05` repository

Go [here](https://github.com/cfss-fa19/hw05) to fork the repo for homework 05.

# Part 1: Debugging code

The homework repository contains a file called `country-profile.Rmd`. It has some problems. Fix the problems so you can successfully knit the document.

# Part 2: Prepare a presentation

So far this quarter you have [explored mass shootings](/homework/explore-data/), [wrangled and visualized decisions from the U.S. Supreme Court](/homework/wrangle-data/), and [analyzed economic indicators from the World Bank](/homework/programming/). And that's just on the homework assignments!

For this assignment, take a dataset we have previously used in this class (e.g. homework assignment, in-class exercises) and prepare a [lightning talk](https://en.wikipedia.org/wiki/Lightning_talk) presenting some portion of the data/results/answer to a question of interest. For this specific talk, the format is:

* 5 minutes to present
* You need to generate a slideshow for supporting material
* 10 slides
* Each slide will auto-advance after 30 seconds (you do not have to build this into your code - just assume it will happen)

You will not actually have the opportunity to present this talk in-class (alas, too many students and not enough time). Instead, you will be evaluated on two deliverables:

1. Slides generated using R Markdown, rendered into the format of your choice. Assume your audience does not have a computational background, so there should be no code visible in the rendered slides.
1. Supporting materials, specifically an R Markdown document containing a copy of all the code/output presented in the slides, as well as core talking points for each slide.

Each of these deliverables should be **reproducible**. That means someone should be able to clone your repository and re-knit the slides and supporting materials from the `.Rmd` files without any errors.

For this assignment, it is okay if your R Markdown documents render into a format that is not directly viewable on GitHub (i.e. HTML files). You can find a list of common R Markdown formats for documents and presentations [in the `rmarkdown` documentation](https://rmarkdown.rstudio.com/formats.html), as well as in [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/).

# Submit the assignment

Your assignment should be submitted as two R Markdown documents and the rendered output. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Check minus: Your slides and supporting materials cannot be reproduced. Code is visible in your slides. The broken R Markdown document still does not knit. Graphs and tables don't have appropriate labels or formatting. There is no consistency to your code's style.

Check: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Check plus: Repository contains a detailed `README.md` explaining how the files in the repo should be executed. Broken R Markdown document successfully knits. Displays innovative data analysis or coding skills. Slides are well-designed and visually intuitive. Graphs and tables are well labeled. Analysis is insightful. I walk away feeling I learned something.
