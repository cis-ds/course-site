---
title: "HW11: Build a Shiny application"
date: 2022-11-30T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post
aliases: ["/hw10-shiny.html"]

summary: "Build/enhance a Shiny application."
---



# Overview

Due by 11:59pm on December 6th.

# Accessing the `hw11` repository

Go [here](https://github.coecis.cornell.edu/cis-fa22) and find your copy of the `hw11` repository. It follows the naming convention `hw11-<USERNAME>`. Clone the repository to your computer.

# What we've done

We created a Shiny app that lets you analyze the results of the Ask your Manager survey. We used the [`survey.csv`](https://github.com/cis-ds/shiny) data file and [this code](https://github.com/cis-ds/course-site/blob/main/static/slides/interactive-visualization/manager-survey/app.R) for our app.

# What you need to do

## Option A - extend the Ask a Manager app

For the homework, revise the application to incorporate at least **three new features**. Potential features could be (but are not limited to):

* New layouts
* Use the `DT` package to present the individual responses on the second tab as a paginated table.
* Visually improve the appearance of the plots (adjust the themes, color palettes, add labels, etc.)
* Experiment with packages that add extra features to Shiny, such as `shinyjs`, `leaflet`, `shinydashboard`, `shinythemes`, `ggvis`
* Implement the app using a `flexdashboard` format
* If you know CSS, add CSS to make your app look nicer
* Allow the user to download the filtered table as a .csv file

Emphasis is placed on how you use Shiny and interactivity to implement the new features.

## Option B - create a new Shiny app

This app can use an entirely different dataset. Perhaps write an app to explore the `gapminder` dataset, or use your own data set (maybe you collected it for another assignment). The sky is the limit here, so be creative! Or be simple to minimize your workload over the next week. But the more creative your effort, the more points awarded.

## Expectations for your app

Regardless of which option you select, you **must** do the following things:

1. Your app should be deployed online on [shinyapps.io](http://www.shinyapps.io). Make sure your app actually works online (sometimes your app will work in RStudio but will have errors on shinyapps.io - make sure you deploy early and often to make debugging easier). See [this article on deployment](https://shiny.rstudio.com/articles/shinyapps.html) for instructions.
1. Update the `README.md` file in your homework repo. In it you should describe your app and add a link to the URL where the app is hosted.
1. Include the code for your Shiny app in your repository so we can evaluate it.

# Submit the assignment

Your assignment submission includes two components:

1. A working Shiny app hosted on shinyapps.io
1. A GitHub repo that includes the underlying source code which created the app.

Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow).

# Rubric

Needs improvement: The deployed app does not work or results in many errors. There is no `README` file describing what the app does.

Satisfactory: Shiny app runs. The `README` file describes either a new app or 3+ additions to our Chicago wage employees app. Whatever is described in the `README` is actually implemented in the app.

Excellent: Amazing Shiny app. Lots of new features or a very cool new app idea. App looks great visually.
