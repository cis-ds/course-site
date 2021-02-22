---
title: "Machine learning"
date: 2021-02-23T09:40:00-06:00
publishDate: 2019-05-06T09:40:00-06:00
draft: false

aliases: ["/cm011.html", "/syllabus/statistical-learning-regression",
          "/syllabus/statistical-learning"]

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
time_end: 2021-02-23T11:00:00-06:00
all_day: false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: []

# Abstract and optional shortened version.
abstract: ""
summary: "Review the goals of machine learning, introduce methods for estimating models in R using the `tidymodels` framework, and define a resampling framework for model validation."

# Location of event.
location: "Online"

# Is this a selected talk? (true/false)
selected: false

# Tags (optional).
#   Set `tags: []` for no tags, or use the form `tags: ["A Tag", "Another Tag"]` for one or more tags.
tags: []

# Links (optional).
url_pdf: ""
url_slides: "/slides/machine-learning/"
url_video: ""
url_code: ""

# Does the content use math formatting?
math: false
---



## Overview

* Review the major goals of machine learning
* Introduce the `tidymodels` and `parsnip` packages for estimating regression models
* Define resampling methods for evaluating model performance
* Demonstrate how to conduct cross-validation using `rsample`

## Before class

* Read [Statistical learning: the basics](/notes/statistical-learning/)
* Read [Build a model](/notes/start-with-models/)
* Read [Evaluate your model with resampling](/notes/resampling/)

This is not a math/stats class. In class we will **briefly** summarize how these methods work and spend the bulk of our time on estimating and interpreting these models. That said, you should have some understanding of the mathematical underpinnings of statistical learning methods prior to implementing them yourselves. See below for some recommended readings:

##### For those with little/no statistics training

* Chapters 7-8 of [*OpenIntro Statistics*](https://www.openintro.org/stat/textbook.php?stat_book=os) - an open-source statistics textbook written at the level of an introductory undergraduate course on statistics

##### For those with prior statistics training

* Chapters 2-3, 4.1-3 in [*An Introduction to Statistical Learning*](http://link.springer.com.proxy.uchicago.edu/book/10.1007%2F978-1-4614-7138-7) - a book on statistical learning written at the level of an advanced undergraduate/master's level course
* Chapters 4-5 in [*Hands-On Machine Learning with R*](https://bradleyboehmke.github.io/HOML/) - a recent publication which approaches these methods from the perspective of machine learning rather than traditional statistical inference. Includes code examples using R and the `caret` package.

## Class materials

{{% callout note %}}

Run the code below in your console to download the exercises for today.

```r
usethis::use_course("uc-cfss/machine-learning")
```

{{% /callout %}}

{{% callout note %}}

Materials derived from [Tidymodels, Virtually: An Introduction to Machine Learning with Tidymodels](https://tmv.netlify.app/site/) by [Allison Hill](https://alison.rbind.io/).

{{% /callout %}}

### Additional readings

* [`caret`](https://topepo.github.io/caret/) - a package which unifies hundreds of separate algorithms for generating statistical/machine learning models into a single standardized interface. Very robust, but pre-`tidyverse` and on the path to deprecation.
* [`tidymodels`](https://www.tidymodels.org/start/) - a collection of packages for machine and statistical learning using `tidyverse` principles.

## What you need to do after class
