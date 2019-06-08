---
title: "HW03: Wrangling and visualizing data"
date: 2019-04-15T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-03-01

draft: false
type: post
aliases: ["/hw03-wrangle-data.html"]

summary: "Wrangle and explore messy datasets in practical research environments."
url_code: "https://github.com/cfss-su19/hw03"
---



# Overview

Due before class on Monday July 8th.

The goal of this assignment is to practice wrangling and exploring data in a research context.

# Fork the `hw03` repository

Go [here](https://github.com/cfss-su19/hw03) to fork the repo.

# Part 1: Tidying messy data

In the `rcfss` package, there is a data frame called `dadmom`.


```
## # A tibble: 3 x 5
##   famid named  incd namem  incm
##   <dbl> <chr> <dbl> <chr> <dbl>
## 1     1 Bill  30000 Bess  15000
## 2     2 Art   22000 Amy   18000
## 3     3 Paul  25000 Pat   50000
```

Tidy this data frame so that it adheres to the tidy data principles:

1. Each variable must have its own column.
1. Each observation must have its own row.
1. Each value must have its own cell.

**NOTE: You can accomplish this task in a single piped operation using only `tidyr` functions. Code which does not use `tidyr` functions is acceptable, but will not merit a "check plus" on your evaluation.**

# Part 2: Joining data frames

Recall the `gapminder` data frame [we previously explored](/notes/gapminder/). That data frame contains just six columns from the larger [data in Gapminder World](https://www.gapminder.org/data/). In this part, you will join the original `gapminder` data frame with a new data file containing the [HIV prevalence rate](http://www.gapminder.org/world/#$majorMode=chart$is;shi=t;ly=2003;lb=f;il=t;fs=11;al=30;stl=t;st=t;nsl=t;se=t$wst;tts=C$ts;sp=5.59290322580644;ti=2010$zpv;v=0$inc_x;mmid=XCOORDS;iid=phAwcNAVuyj1jiMAkmq1iMg;by=ind$inc_y;mmid=YCOORDS;iid=pyj6tScZqmEfbZyl0qjbiRQ;by=ind$inc_s;uniValue=8.21;iid=phAwcNAVuyj0XOoBL_n5tAQ;by=ind$inc_c;uniValue=255;gid=CATID0;by=grp$map_x;scale=log;dataMin=194;dataMax=96846$map_y;scale=lin;dataMin=0.0095;dataMax=27$map_s;sma=50;smi=2$cd;bd=0$inds=) in the country.^[More specifically, the estimated number of people living with HIV per 100 population of age group 15-49.]

The HIV prevalence rate is stored in the `data` folder as a CSV file. You need to import and merge the data with `gapminder` to answer these two questions:

1. What is the relationship between HIV prevalence and life expectancy? Generate a scatterplot with a smoothing line to report your results.
1. Which continents have the most observations with missing HIV data? Generate a bar chart, ordered in descending height (i.e. the continent with the most missing values on the left, the continent with the fewest missing values on the right).

For each question, you need to perform a [specific type of join operation](http://r4ds.had.co.nz/relational-data.html). Think about what type makes the most sense **and explain why you chose it**.

# Part 3: Wrangling and visualizing messy(ish) data

The [Supreme Court Database](http://scdb.wustl.edu/) contains detailed information of decisions of the U.S. Supreme Court. It is perhaps the most utilized database in the study of judicial politics. Until recently, the database only contained records on cases from the "modern" era (1946-present). Recently the database was extended backwards to include all decisions since the formation of the Court in 1791. While still in beta form, this extension opens the doors to new studies of the Court's pre-modern era decisions.

In the `hw03` repository, you will find two data files: `SCDB_Legacy_03_justiceCentered_Citation.csv` and `SCDB_2017_01_justiceCentered_Citation.csv`. These are the exact same files you would obtain if you downloaded them from the original website; I have included them in the repository merely for your convenience. Documentation for the datasets can be found [here](http://scdb.wustl.edu/documentation.php).

The data is structured in a tidy fashion.^[Tidy, though not necessarily the most efficient. You could definitely reorganize the datasets into multiple tables of relational data.] That is, every row is a vote by one justice on one case for every case decided from the 1791-2016 terms.^[Also known as a panel dataset. Terms run from October through June, so the 2016 term contains cases decided from October 2016 - June 2017] There are several ID variables which are useful for other types of research: for our purposes, the only ID variable you need to concern yourself with is `caseIssuesId`. Variables you will want to familiarize yourself with include `term`, `justice`, `justiceName`, `decisionDirection`, `majVotes`, `minVotes`, `majority`, `chief`, `dateDecision`, and `decisionType`. Pay careful attention in the documentation to how these variables are coded.

In order to analyze the Supreme Court data, you will need to import these two files and combine them together (see `bind_rows()` from the `dplyr` package). Friendly warning: you will initially encounter an error attempting to bind the two data frames. Use your powers of deduction (and [R4DS](http://r4ds.had.co.nz/data-import.html)/Google/Stack Overflow/classmates/me and the TAs) to figure out how to fix this error.

Once joined, use your data wrangling and visualization skills to answer the following questions:

{{% alert note %}}

Pay careful attention to the unit of analysis required to answer each question. Remember that the dataset is structured as one row per justice per case. Some questions may require you to de-duplicate the dataset so that it is only one row per case.

{{% /alert %}}

1. What percentage of cases in each term are decided by a one-vote margin (i.e. 5-4, 4-3, etc.)
1. For each term he served on the Court, in what percentage of cases was Justice Antonin Scalia in the majority?
1. **Create a graph similar to above that compares the percentage for all cases versus non-unanimous cases (i.e. there was at least one dissenting vote)**
1. In each term, what percentage of cases were decided in the conservative direction?
1. **The Chief Justice is frequently seen as capable of influencing the ideological direction of the Court. Create a graph similar to the previous one that also incorporates information on who was the Chief Justice during the term.**
1. In each term, how many of the term's published decisions (decided after oral arguments) were announced in a given month?
    * You may want to skim/read chapter 16 in [R for Data Science](http://r4ds.had.co.nz/dates-and-times.html) as it discusses working with dates and times using the `lubridate` package
    * Let me emphasize: you want to skim/read chapter 16 in [R for Data Science](http://r4ds.had.co.nz/dates-and-times.html) as it discusses working with dates and times using the `lubridate` package
    * Also note, the Supreme Court's calendar runs on the federal government's [fiscal year](https://en.wikipedia.org/wiki/Fiscal_year#Federal_government). That means the first month of the court's term is October, running through September of the following calendar year.

> You only need to complete one of the two bolded questions. Only complete both if you are feeling particularly masochistic!

# Submit the assignment

Your assignment should be submitted as three RMarkdown documents. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Check minus: Displays minimal effort. Doesn't complete all components. Code is poorly written and not documented. Uses the same type of plot for each graph, or doesn't use plots appropriate for the variables being analyzed. No record of commits other than the final push to GitHub.

Check: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Check plus: Finished all components of the assignment correctly and attempted at least one advanced challenge. Code is well-documented (both self-documented and with additional comments as necessary). Graphs and tables are properly labeled. Use multiple commits to back up and show a progression in the work. Analysis is clear and easy to follow, either because graphs are labeled clearly or you've written additional text to describe how you interpret the output.
