---
title: "What is exploratory data analysis?"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/eda_defined.html"]
categories: ["eda"]

menu:
  notes:
    parent: Exploratory data analysis
    weight: 1
---




```r
library(tidyverse)
```

**Exploratory data analysis** (EDA) is often the first step to visualizing and transforming your data.^[After any necessary data importation and wrangling.] Hadley Wickham [defines EDA as an iterative cycle](http://r4ds.had.co.nz/exploratory-data-analysis.html):

1. Generate questions about your data
1. Search for answers by visualising, transforming, and modeling your data
1. Use what you learn to refine your questions and or generate new questions
* Rinse and repeat until you publish a paper

EDA is fundamentally a creative process - it is not an exact science. It requires knowledge of your data and a lot of time. At the most basic level, it involves answering two questions

1. What type of **variation** occurs **within** my variables?
2. What type of **covariation** occurs **between** my variables?

EDA relies heavily on visualizations and graphical interpretations of data. While statistical modeling provides a "simple" low-dimensional representation of relationships between variables, they generally require advanced knowledge of statistical techniques and mathematical principles. Visualizations and graphs are typically much more interpretable and easy to generate, so you can rapidly explore many different aspects of a dataset. The ultimate goal is to generate simple summaries of the data that inform your question(s). It is not the final stop in the data science pipeline, but still an important one.

## Characteristics of exploratory graphs

Graphs generated through EDA are distinct from final graphs. You will typically generate dozens, if not hundreds, of exploratory graphs in the course of analyzing a dataset. Of these graphs, you may end up publishing one or two in a final format. One purpose of EDA is to develop a personal understanding of the data, so all your code and graphs should be geared towards that purpose. Important details that you might add if you were to publish a graph^[In perhaps an academic journal, or maybe a homework submission.] are not necessary in an exploratory graph. For example, say I want to [explore how the price of a diamond varies with it's carat size](http://r4ds.had.co.nz/exploratory-data-analysis.html#two-continuous-variables). An appropriate technique would be a scatterplot:


```r
ggplot(data = diamonds,
       mapping = aes(x = carat, y = price)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="/notes/exploratory-data-analysis_files/figure-html/diamonds-eda-1.png" width="672" />

This is a great exploratory graph: it took just three lines of code and clearly establishes an exponential relationship between the carat size and price of a diamond. But what if I were publishing this graph in a research note? I would probably submit something to the editor that looks like this:


```r
ggplot(data = diamonds,
       mapping = aes(x = carat, y = price)) +
  geom_point(alpha = .01) +
  geom_smooth(se = FALSE) +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Exponential relationship between carat size and price",
       subtitle = "Sample of 54,000 diamonds",
       x = "Carat size",
       y = "Price") +
  theme_minimal()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="/notes/exploratory-data-analysis_files/figure-html/diamonds-final-1.png" width="672" />

These additional details are very helpful in communicating the meaning of the graph, but take a substantial amount of time and code to write. For EDA, you don't have to add this detail to every exploratory graph.

## Fuel economy data

The U.S. Environmental Protection Agency (EPA) [collects fuel economy data](http://fueleconomy.gov/) on all vehicles sold in the United States. Here let's examine a subset of that data for 38 popular models of cars sold between 1999 and 2008 to answer the following question: **how does highway fuel efficiency vary across cars?**

## Import the data

The `mpg` dataset is included as part of the `ggplot2` library:


```r
library(ggplot2)
data("mpg")

mpg
```

```
## # A tibble: 234 x 11
##    manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
##    <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
##  1 audi         a4      1.8  1999     4 auto… f        18    29 p     comp…
##  2 audi         a4      1.8  1999     4 manu… f        21    29 p     comp…
##  3 audi         a4      2    2008     4 manu… f        20    31 p     comp…
##  4 audi         a4      2    2008     4 auto… f        21    30 p     comp…
##  5 audi         a4      2.8  1999     6 auto… f        16    26 p     comp…
##  6 audi         a4      2.8  1999     6 manu… f        18    26 p     comp…
##  7 audi         a4      3.1  2008     6 auto… f        18    27 p     comp…
##  8 audi         a4 q…   1.8  1999     4 manu… 4        18    26 p     comp…
##  9 audi         a4 q…   1.8  1999     4 auto… 4        16    25 p     comp…
## 10 audi         a4 q…   2    2008     4 manu… 4        20    28 p     comp…
## # … with 224 more rows
```

```r
glimpse(x = mpg)
```

```
## Observations: 234
## Variables: 11
## $ manufacturer <chr> "audi", "audi", "audi", "audi", "audi", "audi", "au…
## $ model        <chr> "a4", "a4", "a4", "a4", "a4", "a4", "a4", "a4 quatt…
## $ displ        <dbl> 1.8, 1.8, 2.0, 2.0, 2.8, 2.8, 3.1, 1.8, 1.8, 2.0, 2…
## $ year         <int> 1999, 1999, 2008, 2008, 1999, 1999, 2008, 1999, 199…
## $ cyl          <int> 4, 4, 4, 4, 6, 6, 6, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, …
## $ trans        <chr> "auto(l5)", "manual(m5)", "manual(m6)", "auto(av)",…
## $ drv          <chr> "f", "f", "f", "f", "f", "f", "f", "4", "4", "4", "…
## $ cty          <int> 18, 21, 20, 21, 16, 18, 18, 18, 16, 20, 19, 15, 17,…
## $ hwy          <int> 29, 29, 31, 30, 26, 26, 27, 26, 25, 28, 27, 25, 25,…
## $ fl           <chr> "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "…
## $ class        <chr> "compact", "compact", "compact", "compact", "compac…
```

Each row represents a model of car sold in a given year.^[The data is a panel structure, so the same model car appears multiple times.] `hwy` identifies the highway miles per gallon for the vehicle.

## Assessing variation

Assessing **variation** requires examining the values of a variable as they change from measurement to measurement. Here, let's examine variation in highway fuel efficiency and related variables using a few different graphical techniques.

### Histogram


```r
ggplot(data = mpg,
       mapping = aes(x = hwy)) +
  geom_histogram()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-1.png" width="672" />

It appears there is a high concentration of vehicles with highway fuel efficiency between 20 and 30 mpg, with a smaller number of vehicles between 15-20 and some outliers with high fuel efficiency (larger values indicate more efficient vehicles). To view the actual data points, we use `geom_rug()`:


```r
ggplot(data = mpg,
       mapping = aes(x = hwy)) +
  geom_histogram() +
  geom_rug()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/notes/exploratory-data-analysis_files/figure-html/rug-1.png" width="672" />

One thing `geom_rug()` does is illustrate that while `hwy` is a continuous variable, it is measured in integer units - that is, there are no fractional values in the dataset. 26 miles per gallon on the highway is the most common mpg rate in the dataset. Why is that? Something perhaps to investigate further.

By default, `geom_histogram()` bins the observations into 30 intervals of equal width. You can adjust this using the `bins` parameter:


```r
ggplot(data = mpg,
       mapping = aes(x = hwy)) +
  geom_histogram(bins = 50) +
  geom_rug()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-bins-1.png" width="672" />

```r
ggplot(data = mpg,
       mapping = aes(x = hwy)) +
  geom_histogram(bins = 10) +
  geom_rug()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-bins-2.png" width="672" />

### Bar chart


```r
ggplot(data = mpg,
       mapping = aes(x = class)) +
  geom_bar()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/barplot-1.png" width="672" />

To examine the distribution of a categorical variable, we can use a **bar chart**. Here we see the most common type of vehicle in the dataset is an SUV, not surprising given Americans' car culture.

## Covariation

**Covariation** is the tendency for the values of two or more variables to vary together in a related way. Visualizing data in two or more dimensions allows us to assess covariation and differences in variation across groups. There are a few major approaches to visualizing two dimensions:

1. Two-dimensional graphs
1. Multiple window plots
1. Utilizing additional channels

## Two-dimensional graphs

**Two-dimensional graphs** are visualizations that are naturally designed to visualize two variables. For instance, if you have a discrete variable and a continuous variable, you could use a **box plot** to visualize the distribution of the values of the continuous variable for each category in the discrete variable:


```r
ggplot(data = mpg,
       mapping = aes(x = class, y = hwy)) +
  geom_boxplot()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/boxplot-1.png" width="672" />

Here we see that on average, compact and midsize vehicles have the highest highway fuel efficiency whereas pickups and SUVs have the lowest fuel efficiency. What might explain these differences? Another question you could explore after viewing this visualization.

If you have two continuous variables, you may use a **scatterplot** which maps each variable to an `\(x\)` or `\(y\)`-axis coordinate. Here we visualize the relationship between engine displacement (the physical size of the engine) and highway fuel efficiency:


```r
ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy)) +
  geom_point()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-1.png" width="672" />

As engines get larger, highway fuel efficiency declines.

## Multiple window plots

Sometimes you want to compare the conditional distribution of a variable across specific groups or subsets of the data. To do that, we implement a **multiple window plot** (also known as a **trellis** or **facet** graph). This involves drawing the same plot repeatedly, using a separate window for each category defined by a variable. For instance, if we want to examine variation in highway fuel efficiency separately for type of drive (front wheel, rear wheel, or 4 wheel), we could draw a graph like this:


```r
ggplot(data = mpg,
       mapping = aes(x = hwy)) +
  geom_histogram() +
  facet_wrap(~ drv)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-facet-1.png" width="672" />

Highway fuel efficiency is right-skewed for 4 and rear wheel drive vehicles, whereas front wheel drive vehicles are generally unskewed with a couple outliers of 40+ mpg.

You may also want to use a multiple windows plot with a two-dimensional graph. For example, the relationship between engine displacement and highway fuel efficiency by drive type:


```r
ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  facet_wrap(~ drv)
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-facet-1.png" width="672" />

## Utilizing additional channels

If you want to visualize three or more dimensions of data without resorting to 3D animations^[Though with the growth of virtual reality technology and 3D printing, perhaps this isn't a bad idea.] or window plots, the best approach is to incorporate additional **channels** into the visualization. Channels are used to encode variables inside of a graphic. For instance, a scatterplot uses vertical and horizontal spatial position channels to encode the values for two variables in a visually intuitive manner.

Depending on the type of graph and variables you wish to encode, there are several different channels you can use to encode additional information. For instance, **color** can be used to distinguish between classes in a categorical variable.


```r
ggplot(data = mpg,
       mapping = aes(x = displ,
                     y = hwy,
                     color = class)) +
  geom_point()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-color-1.png" width="672" />

We can even use a fourth channel to communicate another variable (number of cylinders) by making use of the size channel:


```r
ggplot(data = mpg,
       mapping = aes(x = displ,
                     y = hwy,
                     color = class,
                     size = cyl)) +
  geom_point()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-color-size-1.png" width="672" />

Note that some channels are not always appropriate, even if they can technically be implemented. For example, instead of using a color channel to visualize `class`, why not distinguish each type of car using the point's shape?


```r
ggplot(data = mpg,
       mapping = aes(x = displ,
                    y = hwy,
                    shape = class)) +
  geom_point()
```

```
## Warning: The shape palette can deal with a maximum of 6 discrete values
## because more than 6 becomes difficult to discriminate; you have 7.
## Consider specifying shapes manually if you must have them.
```

```
## Warning: Removed 62 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-shape-1.png" width="672" />

With this many categories, shape is not very useful in visually distinguishing between each car's class.

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-09-15                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
