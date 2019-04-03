---
date: "2018-09-09T00:00:00-05:00"
draft: false
menu:
  setup:
    parent: Git/GitHub
    weight: 4
title: "Personalize Git"
toc: true
type: docs
aliases: "/git03.html"
---



**You only have to do this once per machine.**

In order to track changes and attribute them to the correct user, we need to tell Git your name and email address.

## Option 1: use `usethis`

The [`usethis`](https://usethis.r-lib.org/) package includes helpful functions for common setup and development operations in R. Install it by running the command

```r
install.packages("usethis")
```

from the console in RStudio. Then run the following commands:

```r
library(usethis)
use_git_config(user.name = "Benjamin Soltoff", user.email = "ben@bensoltoff.com")
```

Replace `Benjamin Soltoff` and `ben@bensoltoff.com` with your name and email address. Your name could be your GitHub username, or your actual first and last name. **Your email address must be the email address associated with your GitHub account.**

## Option 2: use the shell

Open the [shell](/setup/shell/) on your computer. From there, type the following commands (replace the relevant parts with your own information):

* `git config --global user.name 'Benjamin Soltoff'`
    * This can be your full name, your username on GitHub, whatever you want. Each of your commits will be logged with this name, so make sure it is informative **for others**.
* `git config --global user.email 'ben@bensoltoff.com'`
    * **This must be the email address you used to register on GitHub.**

You will not see any output from these commands. To ensure the changes were made, run `git config --global --list`.

### Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
