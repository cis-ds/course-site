---
date: "2018-09-09T00:00:00-05:00"
draft: false
menu:
  setup:
    parent: R/RStudio
    weight: 4
title: "Accessing RStudio Server"
toc: true
type: docs
aliases: "/setup_server.html"
---



## R

[R](https://www.r-project.org/) is an open-source programming language based on the [S](https://en.wikipedia.org/wiki/S_(programming_language)) from the 1970s. It is very popular in the physical and social sciences due to it's cost (free) and versatility. Thousands of expansion libraries have been published which extend the tasks R can perform, and users can write their own custom functions and/or libraries to perform specific operations.

## RStudio

The base R distribution is not the best for developing and writing programs. Instead, we want an integrated development environment (IDE) which will allow us to write and execute code, debug programs, and automate certain tasks. In this course we will use [RStudio](https://www.rstudio.com/products/RStudio/), perhaps the most popular IDE available for R. Like R, it is open-source, expandable, and provides many useful tools and enhancements over the base R environment.

## RStudio Server

Rather than installing your own copy of R and RStudio, you can access R and RStudio remotely hosted on a server. Specifically, the [Social Sciences Computing Services](https://sscs.uchicago.edu/) hosts an RStudio Server for us. Rather than running an application on your computer, you open RStudio in your web browser. All the processing and computation is done on a remote server. This means virtually all of the software is pre-configured for you. Setup is minimal.

The downside is that you only have access to this server for the duration of the class. If you intend to use R and RStudio in future classes/research projects, you will need to install and configure everything on your own computer after the course is completed.

## Accessing RStudio Server

1. Connect to the [University of Chicago Virtual Private Network (VPN)](https://uchicago.service-now.com/it?id=kb_article&kb=KB00015292). You will not be able to access the RStudio Server unless you are connected using the VPN. Follow the setup instructions [here](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000630) if you do not already have this software installed on your computer.
1. Go to [this link](https://macss-r.uchicago.edu/) to login to the server.
1. Use your [CNetID](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000393) and password to login (this is the same username/password you use for other UChicago online services, such as email).
1. You're done. You should see a fresh RStudio window in your browser.

{{% alert note %}}

Only students in this course who have been approved by SSCS can access this server. If you cannot log on to the server, apply for an account at https://iota.uchicago.edu/ (VPN required) and email [sscs@uchicago.edu](mailto:sscs@uchicago.edu) to let them know that they are enrolled in the class.

{{% /alert %}}

## Test it

You should see something that looks like this:

![](/img/rstudio-server.png)

We'll discuss this in more detail later, but the RStudio IDE is divided into 4 separate panes (one of which is hidden for now) which all serve specific functions. For now, to make sure R and RStudio are setup correctly, type `x <- 5 + 2` into the *console* pane (the one on the left side of your screen - this is equivalent to the main window you saw when you opened the base R program, where you can type and run live R code) and execute it by pressing Enter/Return. You just created an object in R called `x`. What does this object contain? Type `print(x)` into the console and press enter again. Your console should now contain the following output:


```r
x <- 5 + 2
print(x)
```

```
## [1] 7
```

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
