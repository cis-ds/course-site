---
date: "2018-09-09T00:00:00-05:00"
draft: true
weight: 40
title: "Accessing RStudio Cloud"
toc: true
type: book
aliases: ["/setup_cloud.html", "/setup/r-cloud/"]
---



## R

[R](https://www.r-project.org/) is an open-source programming language based on the [S](https://en.wikipedia.org/wiki/S_(programming_language)) from the 1970s. It is very popular in the physical and social sciences due to it's cost (free) and versatility. Thousands of expansion libraries have been published which extend the tasks R can perform, and users can write their own custom functions and/or libraries to perform specific operations.

## RStudio

The base R distribution is not the best for developing and writing programs. Instead, we want an integrated development environment (IDE) which will allow us to write and execute code, debug programs, and automate certain tasks. In this course we will use [RStudio](https://www.rstudio.com/products/RStudio/), perhaps the most popular IDE available for R. Like R, it is open-source, expandable, and provides many useful tools and enhancements over the base R environment.

## RStudio Cloud

Rather than installing your own copy of R and RStudio, you can access R and RStudio remotely hosted on a server. Specifically, [RStudio Cloud](https://rstudio.cloud) hosts a free version of RStudio. Rather than running an application on your computer, you open RStudio in your web browser. All the processing and computation is done on a remote server. This means virtually all of the software is pre-configured for you. Setup is minimal.

## Accessing RStudio Cloud

1. Go to [this link](https://rstudio.cloud/spaces/3051/join?access_code=Yfr9a7jh4xfgGHgGRbJdQ08vt2XT%2FjXQ74A1q3y5) to join our class workspace.
    * Joining the class workspace will ensure for each assignment a standard set of packages is already installed and accessible.
    * I strongly recommend logging in using "Log in with Github" so you do not have to create a separate account. This does require [registering your GitHub account before setuping up RStudio](https://github.com/).
1. You're done. You should see a fresh RStudio window in your browser.

## Test it

1. Access the "Computing for Information Science" workspace. There should be an option in the navigation bar on the left side of the screen.
1. Create a "new project".

    {{< figure src="https://rstudio.cloud/images/guide/newProjectGit.png" caption="" >}}
    
    You should see something that looks like this:
    
    {{< figure src="rstudio-server.png" caption="" >}}

We'll discuss this in more detail later, but the RStudio IDE is divided into 4 separate panes (one of which is hidden for now) which all serve specific functions. For now, to make sure R and RStudio are setup correctly, type `x <- 5 + 2` into the *console* pane (the one on the left side of your screen - this is equivalent to the main window you saw when you opened the base R program, where you can type and run live R code) and execute it by pressing Enter/Return. You just created an object in R called `x`. What does this object contain? Type `print(x)` into the console and press enter again. Your console should now contain the following output:


```r
x <- 5 + 2
print(x)
```

```
## [1] 7
```

## Using RStudio Cloud

To complete each course assignment, you will [clone a Git repository](/faq/homework-guidelines/). We will discuss this terminology in-class in more detail. For now, the important thing to remember is that for each assignment you should create a new project from a Git repo:

{{< figure src="https://rstudio.cloud/images/guide/newProjectGit.png" caption="" >}}

Unlike using RStudio locally, you cannot [store your username and password](/setup/git-cache-credentials/). You will need to enter it every time you sync your Git repository with GitHub.

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
