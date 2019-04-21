---
date: "2018-09-09T00:00:00-05:00"
draft: false
menu:
  faq:
    name: Overview
    weight: 1
title: "FAQ"
toc: true
type: docs
---

## Should I take this course?

This course is open to any graduate (or advanced undergraduate) at UChicago. I anticipate drawing students from a wide range of departments such as Sociology, Psychology, Political Science, Comparative Human Development, and MAPSS. Typically these students are looking to learn basic computational and analytical skills they can apply to master's theses or dissertation research.

If you have never programmed before or don't even know what the [shell](/setup/shell/) is, **prepare for a shock**. This class will prove to be immensely beneficial if you stick with it, but that will require you to commit for the full 10 weeks. I do not presume any prior programming experience, so everyone starts from the same knowledge level. I guarantee that the first few weeks and assignments will be rough - but the good news is that they will be rough for everyone! Your classmates are struggling with you and you can lean on one another to get through the worst part of the learning curve.

A highly selective sampling of feedback from past course evaluations:

> I think this class is really well-organized. The homework is craftily designed as a way to solidify the materials learned in class. Dr. Soltoff is wonderful and helpful! He came to class fully prepared and made the lectures enjoyable and productive. I suggest that all Ph.D. students in Political Science (at least in my field), who likes to conduct quantitative research, should choose this class in the first year, because this class can well set students up with a good understanding of programming techniques.

> It's a steep learning curve, but very rewarding.

> This class can set you up really nicely with conversant knowledge in R programming and a large amount of coding materials that are helpful for future research. And it also provides students with a first-hand experience of using some of the cutting edge methods and makes students have a taste of them.

> I'm so so so glad I ended up taking this course. I had a lot of doubts about my own (lack of) skills and my inability to to handle so many things in one quarter. I had a lot of apprehensions about this course but they all quickly disappeared. It's quite honestly been one of the most valuable courses I've taken at this University and I attribute all of that to your excellence as a lecturer. You and the TAs have always been extremely accessible to everyone and I can't appreciate that enough. In other classes, I would've been more hesitant to ask "dumb questions" but you all have made me comfortable doing so, and I have benefited immensely from it.

> It's really damn helpful if you want to do any sort of social science research. It's helpful to know how to do any sort of coding just going into the job market with any degree.

## What do I need for this course?

**You will need to bring a computer to class each day.** Class sessions are a mix of lecture, demonstration, and live coding. It is essential to have a computer so you can follow along and complete the exercises.

## Textbooks/Readings

* [R for Data Science](http://r4ds.had.co.nz/) -- Garrett Grolemund and Hadley Wickham
    * [Hardcover available for purchase online](https://www.amazon.com/R-Data-Science-Hadley-Wickham/dp/1491910399/ref=as_li_ss_tl?ie=UTF8&qid=1469550189&sr=8-1&keywords=R+for+data+science&linkCode=sl1&tag=devtools-20&linkId=6fe0069f9605cf847ed96c191f4e84dd)
    * Open-source online version is available for free

    > Completing the exercises in the book? No official solution manual exists, but several can be found online. I recommend [this version by Jeffrey B. Arnold](https://jrnold.github.io/r4ds-exercise-solutions/). Your exact solutions may vary, but these can be a good starting point.

### Additional resources

* [ggplot2: Elegant Graphics for Data Analysis, 2nd Edition](http://link.springer.com.proxy.uchicago.edu/book/10.1007/978-3-319-24277-4) -- Hadley Wickham
    * Excellent resource for the [`ggplot2`](https://cran.r-project.org/web/packages/ggplot2/index.html) graphics library.
* [Advanced R](http://adv-r.had.co.nz/) -- Hadley Wickham
    * Hardcover available online for around $55, but the online version is free
    * A deep dive into R as a programming language, not just a tool for data science. We will use some chapters in class, but most of this material is best covered on your own after completion of this course
* [An Introduction to Statistical Learning: with Applications in R](http://www-bcf.usc.edu/~gareth/ISL/) -- Gareth James, Daniela Witten, Trevor Hastie, and Robert Tibshirani
    * [Hardcover is available online for around $70](https://www.amazon.com/Introduction-Statistical-Learning-Applications-Statistics/dp/1461471370)
    * Authenticated UChicago students can purchase a [softcover black-and-white edition for $25](http://link.springer.com.proxy.uchicago.edu/book/10.1007%2F978-1-4614-7138-7)^[I don't recommend this since many of the figures rely on the use of color.] or download a PDF copy of the entire book for free
    * Non-UChicago students can find a free PDF of the entire book [from the authors' site](http://www-bcf.usc.edu/~gareth/ISL/ISLR%20Sixth%20Printing.pdf)
* [RStudio Cheatsheets](https://www.rstudio.com/resources/cheatsheets/)
    * Printable cheat sheets for common R tasks and features
    * [Data import](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/data-import-cheatsheet.pdf)
    * [Data transformation](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/data-transformation-cheatsheet.pdf)
    * [Data visualization](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/ggplot2-cheatsheet-2.1.pdf)
    * [RStudio IDE](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/rstudio-IDE-cheatsheet.pdf)
    * [And more!](https://www.rstudio.com/resources/cheatsheets/)

## Software

By the end of the first week (or even better, before the course starts), you should install the following software on your computer:

* [R](https://www.r-project.org/) - easiest approach is to select [a pre-compiled binary appropriate for your operating system](https://cran.rstudio.com/).
* [RStudio's IDE](https://www.rstudio.com/products/RStudio/) - this is a powerful user interface for programming in R. You could use base R, but you would regret it.
* [Git](https://git-scm.com/) - Git is a [version control system](https://en.wikipedia.org/wiki/Version_control) which is used to manage projects and track changes in computer files. Once installed, it can be integrated into RStudio to manage your course assignments and other projects.

Comprehensive instructions for downloading and setting up this software can be found [here](/setup/).

## How will I be evaluated?

Each week students will complete a series of programming assignments linked to lecture materials. These assignments will generally be due the following week prior to Monday's class. Weekly lab sessions will be held to assist students in completing these assignments. While students are encouraged to assist one another in debugging programs and solving problems in these assignments, it is imperative students also learn how to do this for themselves. That is, **students need to understand, write, and submit their own work.**

Each homework will be evaluated by either myself or the TA, as well as by **two peer reviewers**. Each of you is required to provide two peer reviews for each assignment; failure to complete these reviews will result in a deduction of your final grade.

* [General guidelines for submitting homework](/faq/homework-guidelines/)
* [Evaluation criteria for homework](/faq/homework-evaluations/)
* [How to perform peer review](/faq/peer-evaluations/)
* [How to properly ask for help](/faq/asking-questions/)

## Statement on Disabilities

If you need any special accommodations, please provide me (Dr. Soltoff) with a copy of your Accommodation Determination Letter (provided to you by the Student Disability Services office) as soon as possible so that you may discuss with me how your accommodations may be implemented in this course.
