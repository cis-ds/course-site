---
date: "2018-09-09T00:00:00-05:00"
draft: false
menu:
  faq:
    parent: Overview
    weight: 4
title: "How to properly ask for help"
toc: true
type: docs
aliases: "/hw00_asking_questions.html"
---



Asking questions is an important part of this class. Remember the **15 minute rule**:

> Once you've spent 15 minutes attempting to troubleshoot a problem, **you must ask for help**.

Questions should be posted to [the class discussion repo on GitHub](https://github.com/uc-cfss/Discussion). However, there are good and bad ways to ask questions. Here are some tips you should always follow when posting questions.

## Introduce the problem with an informative title

* Bad title: "I need help!"
* Good title: "Getting a 'file not found error' when importing scotus.csv"

Be specific with your title. It should be brief, but also informative so that when others are looking at the Issues page (and they have a similar error and/or solution), they can easily find it.

## Summarize the problem

Introduce the problem you are having. Include what task you are trying to perform, pertinent error messages, and any solutions you've already attempted. This helps us narrow down and troubleshoot your problem.

## Include a reproducible example

Including a [minimal, complete, and verifiable example](http://stackoverflow.com/help/mcve) of the code you are using greatly helps us resolve your problem. You don't need to copy all the code from your program into the comment, but include enough code that we can run it successfully **until the point at which the error occurs**.

Make sure you have [pushed](/setup/git-with-rstudio/#step-4-push-your-local-changes-online-to-github) your recent commits to the GitHub repo. If it is up-to-date, we can quickly look in or clone your repo to our machines to replicate the problem.

## Format your code snippets with `reprex`

The [`reprex`](http://reprex.tidyverse.org/) package allows you to quickly generate reproducible examples that are easily shared on GitHub with all the proper formatting and syntax. Install it by running the following command from the console:

```r
install.packages("reprex")
```

To use it, copy your code onto your clipboard (e.g. select the code and **Ctrl + C** or **⌘ + C**). For example, copy this demonstration code to your clipboard:






```
library(tidyverse)
count(diamonds, colour)
```

Then run `reprex()` from the console, where the default target venue is GitHub:


```r
reprex()
```

A nicely rendered HTML preview will display in RStudio's Viewer (if you're in RStudio) or your default browser otherwise.

![Output of `reprex()`](/img/reprex-output.png)

The relevant bit of GitHub-flavored Markdown is ready to be pasted from your clipboard:


````
``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Column `colour` is unknown
```

<sup>Created on 2019-09-15 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>
````

Here's what that Markdown would look like rendered in a GitHub issue:


``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Column `colour` is unknown
```

<sup>Created on 2019-09-15 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>

Anyone else can copy, paste, and run this immediately. The nice thing is that if your script also produces images or graphs (probably using `ggplot()`) these images are automatically uploaded and included in the issue.

> To ensure your example is a reproducible example, you need to make sure to load all necessary packages and data objects at the top of your copied code. This may involve opening a new tab in the editor panel and writing a short version of the script that only includes the essentials, then copying that script to the clipboard and `reprex()` it.



## Include your `session_info()`

Sometimes problems are caused by using older or incompatible versions of packages. The `session_info()` function in the `devtools` library will print a list of all active packages and their respective versions. Include this in your post so we know which versions of packages you are using by setting `si = TRUE` in the `reprex()` function, like this: `reprex(si = TRUE)`.

## Post your solution

Once you have solved the problem (either by yourself or with the help of an instructor/classmate), **post the solution**. This let's us know that you have fixed the issue AND if anyone else encounters a similar error, they can refer to your solution to fix their problem.

### Acknowledgments

* ["How do I ask a good question?" StackOverflow.com](http://stackoverflow.com/help/how-to-ask)
* ["How to Ask Programming Questions," ProPublica.com](https://www.propublica.org/nerds/item/how-to-ask-programming-questions)
