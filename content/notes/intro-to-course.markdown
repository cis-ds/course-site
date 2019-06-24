---
title: "Introduction to the course"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/intro.html"]
categories: []

menu:
  notes:
    parent: Overview
    weight: 1
---



## Who am I?

### Me (Dr. Benjamin Soltoff)

I am a lecturer in the [Masters in Computational Social Science](http://macss.uchicago.edu) program. I earned my PhD in political science from [Penn State University](http://polisci.la.psu.edu/) in 2015. [My research interests](https://www.bensoltoff.com) focus on judicial politics, state courts, and agenda-setting. Methodologically I am interested in statistical learning and text analysis. I was first drawn to programming in grad school, starting out in [Stata](http://www.stata.com/) and eventually making the transition to [R](https://www.r-project.org/) and [Python](https://www.python.org/). I learned these programming languages out of necessity - I needed to process, analyze, and code tens of thousands of judicial opinions and extract key information into a tabular format. I am not a computer scientist. I am a social scientist who uses programming and computational tools to answer my research questions.

### Teaching assistants

* Patrick Thelen

## Course objectives

**The goal of this course is to teach you basic computational skills and provide you with the means to learn what you need to know for your own research.** I start from the perspective that you want to analyze data, and *programming is a means to that end*. You will not become an expert programmer - that is a given. But you will learn the basic skills and techniques necessary to conduct computational social science, and gain the confidence necessary to learn new techniques as you encounter them in your research.

We will cover many different topics in this course, including:

* Elementary programming techniques (e.g. loops, conditional statements, functions)
* Writing reusable, interpretable code
* Problem-solving - debugging programs for errors
* Obtaining, importing, and munging data from a variety of sources
* Performing statistical analysis
* Visualizing information
* Creating interactive reports
* Generating reproducible research

## How we will do this

> Teach a (wo)man to fish

This is a hands-on class. You will learn by writing programs and analysis. Don't fear the word "program". A program can be as simple as:


```r
print("Hello world")
```

```
## [1] "Hello world"
```

> One line of code, and it performs a very specific task (print the phrase "Hello world" to the screen)

More typically, your programs will perform statistical and graphical analysis on data of a variety of forms. For example, here I analyze a dataset of automobiles to assess the relationship between engine displacement and highway mileage:


```r
# load packages
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
```

```
## ✔ ggplot2 3.1.0       ✔ purrr   0.3.2  
## ✔ tibble  2.1.1       ✔ dplyr   0.8.0.1
## ✔ tidyr   0.8.3       ✔ stringr 1.4.0  
## ✔ readr   1.3.1       ✔ forcats 0.4.0
```

```
## ── Conflicts ────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

```r
library(broom)

# estimate and print the linear model
lm(hwy ~ displ, data = mpg) %>%
  tidy() %>%
  mutate(term = c("Intercept", "Engine displacement (in liters)")) %>%
  knitr::kable(digits = 2,
               col.names = c("Variable", "Estimate", "Standard Error",
                             "T-statistic", "P-Value"))
```



|Variable                        | Estimate| Standard Error| T-statistic| P-Value|
|:-------------------------------|--------:|--------------:|-----------:|-------:|
|Intercept                       |    35.70|           0.72|       49.55|       0|
|Engine displacement (in liters) |    -3.53|           0.19|      -18.15|       0|

```r
# visualize the relationship
ggplot(data = mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) +
  geom_smooth(method = "lm", se = FALSE, color = "black", alpha = .25) +
  labs(x = "Engine displacement (in liters)",
       y = "Highway miles per gallon",
       color = "Car type") +
  theme_bw(base_size = 16)
```

<img src="/notes/intro-to-course_files/figure-html/auto-example-1.png" width="672" />

But we will start small to build our way up to there.

Class sessions will include a combination of lecture and live-coding. **You need to bring a laptop to class to follow along**, but all class materials (including slides and notes) will be made available before/after class for your review. The emphasis of the class is on application and learning how to implement different computational techniques. However we will sometimes read and discuss examples of interesting and relevant scholarly research that demonstrates the capabilities and range of computational social science.

Lab sessions will be held each Wednesday immediately following class. I strongly encourage you to attend these sessions. Myself or the TA will be available to assist you as you practice specific skills or encounter problems completing the homework assignments.

## Complete the readings

Each class will have assigned readings. **You need to complete these before coming to class.** I will assume you have done so and have at least a basic understanding of the material. My general structure for the class is to spend the first 15-30 minutes lecturing, then the remaining time practicing skills via live-coding and in-class exercises. If you do not come to class prepared, then there is no point in coming to class.

## 15 minute rule

{{< youtube ZS8QHRtzcPg >}}

You will fail in this class. You will stumble, you will get lost, confused, not understand how to perform a task, not understand why your code is generating an error. But as Alfred so helpfully points out to Bruce Wayne, do not fall to pieces when you fail. Instead, learn to pick yourself up, recover, and learn from the experience. Consider this a lesson not only for this class, but graduate school in general.

{{< tweet 764931533383749632 >}}

We will follow the **15 minute rule** in this class. If you encounter a problem in your assignments, spend 15 minutes troubleshooting the problem on your own. Make use of [Google](https://www.google.com) and [StackOverflow](http://stackoverflow.com/) to resolve the error. However, if after 15 minutes you still cannot solve the problem, **ask for help**. We will use [GitHub to ask and answer class-related questions](https://github.com/uc-cfss/Discussion).

> Check out [this guide on how to properly ask questions, including tips and details on what information you should include in your post](/faq/asking-questions/)

## Plagiarism

I am trying to balance two competing perspectives:

1. Collaboration is good - researchers usually collaborate with one another on projects. Developers work in teams to write programs. Why reinvent the wheel when it has already been done?
1. Collaboration is cheating - this is academia. You are expected to complete your own work. If you copy from someone else, how do I know you actually learned the material?

The point is that collaboration in this class is good - **to a point**. You are always, unless otherwise noted, expected to write and submit your own work. You should not blindly copy from your peers. You should not copy large chunks of code from the internet. That said, using the internet to debug programs is fine. Asking a classmate to help you debug your program is fine (the key phrase is *help you*, not do it for you).

> [As Computer Coding Classes Swell, So Does Cheating](https://www.nytimes.com/2017/05/29/us/computer-science-cheating.html)

*The bottom line* - if you don't understand what the program is doing and are not prepared to explain it in detail, you should not submit it.

## Evaluations

Each week you will complete a series of programming assignments linked to lecture materials. These assignments will generally be due the following week prior to Monday's class. Weekly lab sessions will be held to assist students in completing these assignments. Assignments will initially come with starter code, or an initial version of the program where you need to fill in the blanks to make it work. As the quarter moves on and your skills become more developed, I will provide less help upfront.

Each assignment will be evaluated by myself or the TA, as well as by *two peers*. Peer review is a crucial element to this course, in that by [eating each other's dog food](https://en.wikipedia.org/wiki/Eating_your_own_dog_food) you will learn to read, debug, and reproduce code and analysis. And while I and the TA are competent users in R, your classmates are not - so make sure your code is [well-documented](#documentation) so that others with basic knowledge of programming and R can follow along and reuse your code. Be sure to read the instructions for [peer review](/faq/peer-evaluations/) so you know how to provide useful feedback.

## The computational social science workflow

![Data science workflow. Source: [R for Data Science](http://r4ds.had.co.nz/) by Garrett Grolemund and Hadley Wickham.](/img/data-science.png)

Computationally driven research follows a specific workflow. This is the ideal - in this course, I want to illustrate and explain to you why each stage is important and how to do it.

### Import

First you need to get your data into whatever software package you will use to analyze it. Most of us are familiar with data stored in flat files (e.g. spreadsheets). However a lot of interesting data cannot be obtained in a single specific and simple format. Information you need could be stored in a database, or a web API, or even (god forbid) **printed books**. You need to know how to convert/extract information into your software package of choice.

### Tidy

Tidying your data means to store it in a standardized form that enables the use of a standard library of functions to analyze the data. When your data is tidy, each column is a variable, and each row is an observation. By storing data in a consistent structure, you can focus your efforts on questions about the data and not constantly wrangling the data into different forms. Contrary to what you might expect, much of a researcher's time is spent wrangling and cleaning data into a tidy format for analysis. While not glamorous, tidying is an important stage.

### Transform

Transforming data can take on different tasks. Typically these include subsetting the data to focus on one specific set of observations, creating new variables that are functions of existing variables, or calculating summary statistics for the data.

### Visualize

Humans love to visualize information, as it reduces the complexity of the data into an easily interpretable format. There are many different ways to visualize data - knowing how to create specific graphs is important, but even more so is the ability to determine what visualizations are appropriate given the variables you wish to analyze.

### Model

Models complement visualizations. While visualizations are intuitive, they do not scale well to complex relationships. Visualizing two (or even three) variables is a straightforward exercise, but once you are dealing with four or more variables visualizations become pointless. Models are fundamentally mathemetical, so they scale well to many variables. However all models make assumptions about the form of relationships, so if you choose an inappropriate functional form the model will not tell you that you are wrong.

### Communicate

All of the above work will be for naught if you fail to communicate your project to a larger audience. You need to not only understand your data, but also communicate your results to others so that the community can learn from your knowledge.

### Programming

Programming is the tool that encompasses all of the previous stages. You can use programming in all facets of your project. You do not need to be an expert programmer to be a computational social scientist, but learning to program will make your life **much easier**.

## Basic principles of programming

A **program** is a series of instructions that specifies how to perform a computation.^[[Downey, Allen. 2012. *Think Python*. 2nd ed.](http://proquestcombo.safaribooksonline.com.proxy.uchicago.edu/book/programming/python/9781491939406)]

Major components to programs are:

* **Input** - what is being manipulated/utilized. Typically these are data files from your hard drive or the internet.
* **Output** - display data or analysis on the computer, include in a paper/report, publish on the internet, etc.
* **Math** - basic or complex mathematical and statistical operations. This could be as simple as addition or subtraction, or more complicated like estimating a linear regression or statistical learning model.
* **Conditional execution** - check for certain conditions and only perform operations when conditions are met.
* **Repetition** - perform some action repeatedly, usually with some variation.

Virtually all programs are built using these fundamental components. Obviously the more components you implement, the more complex the program will become. The skill is in breaking up a problem into smaller parts until each part is simple enough to be computed using these basic instructions.

## GUI software

A **graphical user interface (GUI)** is a visual way of interacting with a computer using elements such as a mouse, icons, and menus.

![Windows 3.1](/img/windows_3.1.png)

![Mac OSX](/img/mac_os_x.png)

![Android operating system](/img/android_phones.jpg)

GUI software runs using all the basic programming elements, but the end user is not aware of any of this. Instructions in GUI software are **implicit** to the user, whereas programming requires the user to make instructions **explicit**.

![Programming in [the shell](/setup/shell/)](/img/shell.png)

## Benefits to programming vs. GUI software

Let's demonstrate why you should want to learn to program.^[Example drawn from [*Code and Data for the Social Sciences: A Practitioner's Guide*](https://people.stanford.edu/gentzkow/sites/default/files/codeanddata.pdf).] What are the advantages over GUI software, such as Stata?

![Stata](/img/stata14.png)

Here is a hypothetical assignment for a UChicago undergrad:

> Write a report analyzing the relationship between ice cream consumption and crime rates in Chicago.

Let's see how two students (Jane and Sally) would complete this. Jane will use strictly GUI software, whereas Sally will use programming and the data science workflow we outlined above.

#### Jane: Typical workflow of an undergraduate writing a research paper

1. Jane finds data files online with total annual ice cream sales in the 50 largest U.S. cities from 2001-2010 and total numbers of crimes (by type) for the 50 largest U.S. cities from 2001-2010. She gets them as spreadsheets and downloads them to her computer, saving them in her main `Downloads` folder which includes everything she's downloaded over the past three years. It probably looks something like this:

    ![](/img/downloads_folder.png)

1. Jane opens the files in Excel.
    * Ice cream sales - frozen yogurt is not ice cream. She deletes the column for frozen yogurt sales.
    * Crime data - Jane is only interested in violent crime. She deletes all rows pertaining to non-violent offenses.
    * Jane saves these modified spreadsheets in a new folder created for this paper.
1. Jane opens Stata.
    * First she imports the ice cream data file using the drop-down menu.
    * Next she merges this with the crime data using the drop-down menu. There are some settings she tweaks when she does this, but Jane doesn't bother to write them down anywhere.
    * Then she creates new variables for per capita ice cream sales and per capita crime rates.
    * After that, she estimates a linear regression model for the relationship between the two per capita variables.
    * Finally she creates a graph plotting the relationship between these two variables.
1. Jane writes her report in Google Docs
    * Huzzah! She finds a correlation between the two variables. Jane writes up her awesome findings and prepares for her A+.
    * The professor wants her results in the paper itself? Darn it. Okay, she copies and pastes her regression results and graph into the paper.
1. Jane prints her report and turns it in to the professor. Done!

#### Sally: Using a computational data science workflow

1. Sally creates a folder specifically for this project and divides it into subfolders (e.g. `data`, `graphics`, `output`)
1. Next she finds data files online with total annual ice cream sales in the 50 largest U.S. cities from 2001-2010 and total numbers of crimes (by type) for the 50 largest U.S. cities from 2001-2010. She writes a program to download these files to the `data` subfolder.
1. Then Sally writes a program in R that opens each data file and filters/cleans the data to get the necessary variables. She saves the cleaned data as new files in the `data` folder.
1. Sally writes a separate program which imports the cleaned data files, estimates a regression model, generates a graph, and saves the regression results and graph to the `output` subfolder.
1. Sally creates an [R Markdown](http://rmarkdown.rstudio.com) document for her report and analysis. Because R Markdown combines both code and text, the results from step 3 are automatically added into the final report.
1. Sally submits the report to the professor. Done!

## Automation

The professor is impressed with Jane and Sally's findings, but wants them to verify the results using new data files for ice cream **and frozen yogurt** sales and crime rates for 2011-2015 before he will determine their grade.

At this point, Jane is greatly hampered by her GUI workflow. She now has to repeat steps 1-5 all over again, but she forgot how she defined violent vs. non-violent crimes. She also no longer has the original frozen yogurt sales data and has to find the original file again somewhere on her computer or online. She has to remember precisely all the menus she entered and all the settings she changed in order to reproduce her findings.

Sally's computational workflow is much better suited to the professor's request because it is **automated**. All Sally needs to do is add the updated data files to the `data` subfolder, then rewrite her program in step 2 to combine the old and new data files. Next she can simply re-run the programs in steps 3 and 4 with no modifications. The analysis program accepts the new data files without issue and generates the updated regression model estimates and graph. The R Markdown document automatically includes these revised results without any need to modify the code in underlying document.

By automating her workflow, Sally can quickly update her results. Jane has to do all the same work again. Data cleaning alone is a non-trivial challenge for Jane. And the more data files in a project, the more work that has to be done. Sally's program makes cleaning the data files trivial - if she wants to clean the data again, she simply runs the program again.

## Reproducibility

Previously researchers focused on **replication** - can the results be duplicated in a new study with different data? In science it is difficult to replicate articles and research, in part because authors don't provide enough information to easily replicate experiments and studies. Institutional biases also exist against replication - no one wants to publish it, and authors don't like to have their results challenged.

**Reproducibility** is "the idea that data analyses, and more generally, scientific claims, are published with their data and software code so that others may verify the findings and build upon them."^[[Coursera: Reproducible Research](https://www.coursera.org/learn/reproducible-research)] Scholars who implement reproducibility in their projects can quickly and easily reproduce the original results and trace back to determine how they were derived. This easily enables verification and replication, and allows the researcher to precisely replicate his or her analysis. This is extremely important when writing a paper, submiting it to a journal, then coming back months later for a revise and resubmit because you won't remember how all the code/analysis works together when completing your revisions.

Because Jane forgot how she initially filtered the data files, she cannot replicate her original results, much less update them with the new data. There is no way to definitively prove how she got her initial results. And even if Jane does remember, she still has to do the work of cleaning the data all over again. Sally's work is reproducible because she still has all the original data files. Any changes to the files, as well as analysis, are created in the programs she wrote. To reproduce her results, all she needs to do is run the programs again. Anyone who wishes to verify her results can implement her code to reproduce them.

## Version control

Research projects involve lots of edits and revisions, and not just in the final paper. Researchers make lots of individual decisions when writing programs and conducting analysis. Why filter this set of rows and not this other set? Do I compute traditional or robust standard errors?

To keep track of all of these decisions and modifications, you could save multiple copies of the same file. But this is bad for two reasons.

1. When do you decide to create a new version of the file? What do we name this file?
1. Why did you create this new version? How can we include this information in a short file name?

Many of you are probably familiar with cloud storage systems like Dropbox or Google Drive. Why not use those to track files in research projects? For one, multiple authors cannot simultaneously edit these files - how do you combine the changes? There is also no record of who made what changes, and you cannot keep annotations describing the changes and why you made them.

**Version control software** (VCS) allows us to track all these changes in a detailed and comprehensive manner without resorting to 50 different copies of a file floating around. VCS works by creating a **repository** on a computer or server which contains all files relevant to a project. Any time you want to modify a file or directory, you check it out. When you are finished, you check it back in. The VCS tracks all changes, when the changes were made, and who made the changes.

If you make a change and realize you don't want to keep it, you can rollback to a previous version of the repository - or even an individual file - without hassle because the VCS already contains a log of every change. VCS can be implemented locally on a single computer:

![VCS on a local computer](https://git-scm.com/book/en/v2/book/01-introduction/images/local.png)

Or in conjunction with remote servers to store backups of your repository:

![VCS with a server](https://git-scm.com/book/en/v2/book/01-introduction/images/distributed.png)

If Jane wanted to rollback to an earlier implementation of her linear regression model, she'd have to remember exactly what her settings were. However all Sally needs to do is use VCS when she revises her programs. Then to rollback to an earlier model formulation she just needs to find the earlier version of her program which generates that model.

## Documentation

Programs include **comments** which are ignored by the computer but are intended for humans reading the code to understand what it does. So if you decide to ignore frozen yogurt sales, you can include this comment in your code to explain why the program drops that column from the data.

> Comments are the **what** - what is the program doing? Code is the **how** - how is the program going to do this?

Computer code should also be **self-documenting**. That is, the code should be comprehensible whenever possible. For example, if you are creating a scatterplot of the relationship between ice cream sales and crime, don't store it in your code as `graph`. Instead, give it an intelligible name that intuitively means something, such as `icecream_crime_scatterplot` or even `ic_crime_plot`. These records are included directly in the code and should be updated whenever the code is updated.

Comments are not just for other people reading your code, but also for yourself. The goal here is to future-proof your code. That is, future you should be able to open a program and understand what the code does. If you do not include comments and/or write the code in an interpretable way, you will forget how it works.

### Badly documented code

This is an example of badly documented code.


```r
library(tidyverse)
library(rtweet)
tmls <- get_timeline(c("MeCookieMonster", "Grover", "elmo", "CountVonCount"), 3000)
ts_plot(group_by(tmls, screen_name), "weeks")
```

* What does this program do?
* What are we using with the `ts_plot()` function?
* What does `3000` refer to?

This program, although it works, is entirely indecipherable unless you are the original author (and even then you may not fully understand it).

### Good code

This is a rewritten version of the previous program. Note that it does the exact same thing, but is much more comprehensible.


```r
# get_to_sesame_street.R
# Program to retrieve recent tweets from Sesame Street characters

# load packages for data management and Twitter API
library(tidyverse)
library(rtweet)

# retrieve most recent 3000 tweets of Sesame Street characters
tmls <- get_timeline(
  user = c("MeCookieMonster", "Grover", "elmo", "CountVonCount"),
  n = 3000
)

# group by character and plot weekly tweet frequency
tmls %>%
  group_by(screen_name) %>%
  ts_plot(by = "weeks")
```

<img src="/notes/intro-to-course_files/figure-html/sesame-good-1.png" width="672" />

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.5        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-06-24                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source                     
##  askpass       1.1     2019-01-13 [1] CRAN (R 3.6.0)             
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)             
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)             
##  blogdown      0.12    2019-05-01 [1] CRAN (R 3.6.0)             
##  bookdown      0.11    2019-05-28 [1] CRAN (R 3.6.0)             
##  broom       * 0.5.2   2019-04-07 [1] CRAN (R 3.6.0)             
##  callr         3.2.0   2019-03-15 [1] CRAN (R 3.6.0)             
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)             
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)             
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 3.6.0)             
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)             
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)             
##  curl          3.3     2019-01-10 [1] CRAN (R 3.6.0)             
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)             
##  devtools      2.0.2   2019-04-08 [1] CRAN (R 3.6.0)             
##  digest        0.6.19  2019-05-20 [1] CRAN (R 3.6.0)             
##  dplyr       * 0.8.1   2019-05-14 [1] CRAN (R 3.6.0)             
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)             
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)             
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)             
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)             
##  ggplot2     * 3.1.1   2019-04-07 [1] CRAN (R 3.6.0)             
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)             
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)             
##  haven         2.1.0   2019-02-19 [1] CRAN (R 3.6.0)             
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)             
##  hms           0.4.2   2018-03-10 [1] CRAN (R 3.6.0)             
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)             
##  httr          1.4.0   2018-12-11 [1] CRAN (R 3.6.0)             
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)             
##  knitr         1.23    2019-05-18 [1] CRAN (R 3.6.0)             
##  labeling      0.3     2014-08-23 [1] CRAN (R 3.6.0)             
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)             
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)             
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)             
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)             
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)             
##  modelr        0.1.4   2019-02-18 [1] CRAN (R 3.6.0)             
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)             
##  nlme          3.1-140 2019-05-12 [1] CRAN (R 3.6.0)             
##  openssl       1.4     2019-05-31 [1] CRAN (R 3.6.0)             
##  pillar        1.4.1   2019-05-28 [1] CRAN (R 3.6.0)             
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.6.0)             
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)             
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)             
##  plyr          1.8.4   2016-06-08 [1] CRAN (R 3.6.0)             
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)             
##  processx      3.3.1   2019-05-08 [1] CRAN (R 3.6.0)             
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)             
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)             
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)             
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.6.0)             
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)             
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)             
##  remotes       2.0.4   2019-04-10 [1] CRAN (R 3.6.0)             
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.6.0)             
##  rmarkdown     1.13    2019-05-22 [1] CRAN (R 3.6.0)             
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)             
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)             
##  rtweet      * 0.6.9   2019-05-19 [1] CRAN (R 3.6.0)             
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)             
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)             
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)             
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)             
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)             
##  testthat      2.1.1   2019-04-23 [1] CRAN (R 3.6.0)             
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)             
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)             
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)             
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)             
##  usethis       1.5.0   2019-04-07 [1] CRAN (R 3.6.0)             
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)             
##  xfun          0.7.4   2019-06-10 [1] Github (yihui/xfun@cc966d3)
##  xml2          1.2.0   2018-01-24 [1] CRAN (R 3.6.0)             
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)             
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
