---
title: "HW02: Exploring and visualizing data"
date: 2019-04-08T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-03-01

draft: false
type: post
aliases: ["/hw02-explore-data.html"]

summary: "Transform and explore a cleaned dataset on gun deaths in the United States."
url_code: "https://github.com/cfss-fa19/hw02"
---



# Overview

Due before class on October 15th.

Now that you've demonstrated your software is setup, the goal of this assignment is to practice transforming and exploring data.

# Fork the `hw02` repository

Go [here](https://github.com/cfss-fa19/hw02) to fork the repo.

# Exploring clean data

The United States experiences far more mass shooting events than any other developed country in the world. While policymakers, politicians, the media, activists, and the general public recognize the widespread prevalence of these tragic events, policies intended to stop these events should be grounded in evidence and empirical data. Regrettably, mass shootings are not well-documented in the United States, and generalizable data is difficult to collect.

In July 2012, in the aftermath of a mass shooting in a movie theater in Aurora, Colorado,
[Mother Jones](https://www.motherjones.com/politics/2012/07/mass-shootings-map/) published a report on mass shootings in the United States since 1982. Importantly, they provided the underlying data set as [an open-source database](https://www.motherjones.com/politics/2012/12/mass-shootings-mother-jones-full-data/) for anyone interested in studying and understanding this criminal behavior.

## Obtain the data

I have included this dataset in the [`rcfss`](https://github.com/uc-cfss/rcfss) library on GitHub. To install the package, use the command `devtools::install_github("uc-cfss/rcfss")` in R. If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages()`, then install `rcfss`. The mass shootings dataset can be loaded using `data("mass_shootings")`.^[For the purposes of this assignment, I have performed some data cleaning of the underlying raw data. You can view the data cleaning code [here](https://github.com/uc-cfss/rcfss/blob/master/data-raw/mass-shootings.R).] Use the help function in R (`?mass_shootings`) to get detailed information on the variables and coding information.

## Explore the data

### Very specific prompts

1. Generate a data frame that summarizes the number of mass shootings per year. Print the data frame as a formatted `kable()` table.
1. Generate a bar chart that identifies the number of mass shooters associated with each race category. The bars should be sorted from highest to lowest.
1. Generate a boxplot visualizing the number of total victims, by type of location. Redraw the same plot, but remove the Las Vegas Strip massacre from the dataset.

### More open-ended questions

Answer the following questions. Generate appropriate figures/tables to support your conclusions.

1. How many white males with prior signs of mental illness initiated a mass shooting after 2000?
1. Which month of the year has the most mass shootings? Generate a bar chart sorted in chronological order to provide evidence of your answer.
1. How does the distribution of mass shooting fatalities differ between white and black shooters? What about white and latino shooters?

### Very open-ended

1. Are mass shootings with shooters suffering from mental illness different from mass shootings with no signs of mental illness in the shooter? Assess the relationship between mental illness and total victims, mental illness and race, and the intersection of all three variables.

{{% alert note %}}

Make sure to provide 1-2 brief paragraphs of written interpretation of your tables/figures. Graphs and tables alone will not be sufficient to answer this question.

{{% /alert %}}

### Formatting graphs

While you are practicing exploratory data analysis, your final graphs should be appropriate for sharing with outsiders. That means your graphs should have:

* [A title](http://r4ds.had.co.nz/graphics-for-communication.html#label)
* Labels on the axes (see `?labs` for details)

This is just a starting point. Consider adopting your own color scales, [taking control of your legends (if any)](http://www.cookbook-r.com/Graphs/Legends_(ggplot2)/), playing around with [themes](https://ggplot2.tidyverse.org/reference/index.html#section-themes), etc.

### Formatting tables

When presenting tabular data (aka `dplyr::summarize()`), make sure you format it correctly. Use the `kable()` function from the `knitr` package to format the table for the final document. For instance, this is a poorly presented table summarizing where gun deaths occurred:




```
## # A tibble: 6 x 2
##   location_type     n
##   <chr>         <int>
## 1 Airport           1
## 2 Military          5
## 3 Other            47
## 4 Religious         6
## 5 School           17
## 6 Workplace        38
```

Instead, use `kable()` to format the table, add a caption, and label the columns:


|Location  | Number of incidents|
|:---------|-------------------:|
|Airport   |                   1|
|Military  |                   5|
|Other     |                  47|
|Religious |                   6|
|School    |                  17|
|Workplace |                  38|

Run `?kable` in the console to see how additional options.

> Note that when viewed on GitHub, table captions will not show up. Just a (missing) feature of Markdown on GitHub 🙍

# Submit the assignment

Your assignment should be submitted as an R Markdown document. **Don't know what an R Markdown document is? [Read this!](http://rmarkdown.rstudio.com/lesson-1.html) Or [this!](http://r4ds.had.co.nz/r-markdown.html)** I have included starter files for you to modify to complete the assignment, so you are not beginning completely from scratch.

Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Check minus: Displays minimal effort. Doesn't complete all components. Code is poorly written and not documented. Uses the same type of plot for each graph, or doesn't use plots appropriate for the variables being analyzed. No record of commits other than the final push to GitHub.

Check: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Check plus: Finished all components of the assignment correctly. Code is well-documented (both self-documented and with additional comments as necessary). Graphs and tables are properly labeled. Uses multiple commits to back up and show a progression in the work. Analysis is clear and easy to follow, either because graphs are labeled clearly or you've written additional text to describe how you interpret the output.
