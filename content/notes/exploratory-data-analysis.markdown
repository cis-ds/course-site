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
library(palmerpenguins)
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

Graphs generated through EDA are distinct from final graphs. You will typically generate dozens, if not hundreds, of exploratory graphs in the course of analyzing a dataset. Of these graphs, you may end up publishing one or two in a final format. One purpose of EDA is to develop a personal understanding of the data, so all your code and graphs should be geared towards that purpose. Important details that you might add if you were to publish a graph^[In perhaps an academic journal, or maybe a homework submission.] are not necessary in an exploratory graph. For example, say I want to explore how the flipper length of a penguin varies with it's body mass size. An appropriate technique would be a scatterplot:


```r
ggplot(data = penguins,
       mapping = aes(x = body_mass_g, y = flipper_length_mm)) +
  geom_point() +
  geom_smooth()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/penguins-eda-1.png" width="672" />

This is a great exploratory graph: it took just three lines of code and clearly establishes a positive relationship between the flipper length and body mass of a penguin. But what if I were publishing this graph in a research note? I would probably submit something to the editor that looks like this:


```r
ggplot(data = penguins,
       mapping = aes(x = body_mass_g, y = flipper_length_mm)) +
  geom_point(alpha = .1) +
  geom_smooth(se = FALSE) +
  labs(title = "Relationship between body mass and flipper length of a penguin",
       subtitle = "Sample of 344 penguins",
       x = "Body mass(g)",
       y = "Flipper length(mm)") +
  theme_minimal()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/penguins-final-1.png" width="672" />

These additional details are very helpful in communicating the meaning of the graph, but take a substantial amount of time and code to write. For EDA, you don't have to add this detail to every exploratory graph.

## Scorecard

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2016 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub.  Here let's examine the data to answer the following question: **how does cost of attendance vary across universities?**

## Import the data

The `scorecard` dataset is included as part of the `rcfss` library:


```r
library(rcfss)
data("scorecard")

scorecard
```

```
## # A tibble: 1,733 x 14
##    unitid name  state type  admrate satavg  cost avgfacsal pctpell comprate
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>     <dbl>   <dbl>    <dbl>
##  1 147244 Mill… IL    Priv…   0.638   1047 43149     55197   0.405    0.600
##  2 147341 Monm… IL    Priv…   0.521   1045 45005     61101   0.413    0.558
##  3 145691 Illi… IL    Priv…   0.540     NA 41869     63765   0.419    0.68 
##  4 148131 Quin… IL    Priv…   0.662    991 39686     50166   0.379    0.511
##  5 146667 Linc… IL    Priv…   0.529   1007 25542     52713   0.464    0.613
##  6 150774 Holy… IN    Priv…   0.910   1053 39437     47367   0.286    0.407
##  7 150941 Hunt… IN    Priv…   0.892   1019 36227     58563   0.350    0.654
##  8 148584 Univ… IL    Priv…   0.492   1068 39175     70425   0.382    0.629
##  9 148627 Sain… IL    Priv…   0.752   1009 38260     65619   0.533    0.510
## 10 151111 Indi… IN    Publ…   0.740   1025 20451     76608   0.381    0.463
## # … with 1,723 more rows, and 4 more variables: firstgen <dbl>, debt <dbl>,
## #   locale <fct>, openadmp <fct>
```

```r
glimpse(x = scorecard)
```

```
## Rows: 1,733
## Columns: 14
## $ unitid    <int> 147244, 147341, 145691, 148131, 146667, 150774, 150941, 148…
## $ name      <chr> "Millikin University", "Monmouth College", "Illinois Colleg…
## $ state     <chr> "IL", "IL", "IL", "IL", "IL", "IN", "IN", "IL", "IL", "IN",…
## $ type      <fct> "Private, nonprofit", "Private, nonprofit", "Private, nonpr…
## $ admrate   <dbl> 0.6380, 0.5206, 0.5403, 0.6623, 0.5288, 0.9101, 0.8921, 0.4…
## $ satavg    <dbl> 1047, 1045, NA, 991, 1007, 1053, 1019, 1068, 1009, 1025, 10…
## $ cost      <int> 43149, 45005, 41869, 39686, 25542, 39437, 36227, 39175, 382…
## $ avgfacsal <dbl> 55197, 61101, 63765, 50166, 52713, 47367, 58563, 70425, 656…
## $ pctpell   <dbl> 0.4054, 0.4127, 0.4191, 0.3789, 0.4640, 0.2857, 0.3502, 0.3…
## $ comprate  <dbl> 0.6004, 0.5577, 0.6800, 0.5110, 0.6132, 0.4069, 0.6540, 0.6…
## $ firstgen  <dbl> 0.3184783, 0.3224401, 0.3109756, 0.3300493, 0.3122172, 0.28…
## $ debt      <dbl> 20375.0, 20000.0, 22300.0, 13000.0, 17500.0, 11000.0, 22500…
## $ locale    <fct> City, Town, Town, Town, Town, Suburb, Town, Suburb, City, C…
## $ openadmp  <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, No,…
```

Each row represents a different four-year college or university in the United States. `cost` identifies the average annual total cost of attendance.

## Assessing variation

Assessing **variation** requires examining the values of a variable as they change from measurement to measurement. Here, let's examine variation in cost of attendance and related variables using a few different graphical techniques.

### Histogram


```r
ggplot(data = scorecard,
       mapping = aes(x = cost)) +
  geom_histogram()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```
## Warning: Removed 42 rows containing non-finite values (stat_bin).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-1.png" width="672" />

It appears there are three sets of peak values for cost of attendance, around 20,000, 40,000, and 65,000 dollars in declining overall frequency. This could suggest some underlying factor or set of differences between the universities that clusters them into separate groups based on cost of attendance.

By default, `geom_histogram()` bins the observations into 30 intervals of equal width. You can adjust this using the `bins` parameter:


```r
ggplot(data = scorecard,
       mapping = aes(x = cost)) +
  geom_histogram(bins = 50)
```

```
## Warning: Removed 42 rows containing non-finite values (stat_bin).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-bins-50-1.png" width="672" />


```r
ggplot(data = scorecard,
       mapping = aes(x = cost)) +
  geom_histogram(bins = 10)
```

```
## Warning: Removed 42 rows containing non-finite values (stat_bin).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-bins-10-1.png" width="672" />

Different `bins` can lead to different inferences about the data. Here if we set a larger number of bins, the overall picture seems to be the same - the distribution is trimodal. But if we collapse the number of bins to 10, we lose the clarity of each of these peaks.

### Bar chart


```r
ggplot(data = scorecard,
       mapping = aes(x = type)) +
  geom_bar()
```

<img src="/notes/exploratory-data-analysis_files/figure-html/barplot-1.png" width="672" />

To examine the distribution of a categorical variable, we can use a **bar chart**. Here we see the most common type of four-year college is a private, nonprofit institution.

## Covariation

**Covariation** is the tendency for the values of two or more variables to vary together in a related way. Visualizing data in two or more dimensions allows us to assess covariation and differences in variation across groups. There are a few major approaches to visualizing two dimensions:

1. Two-dimensional graphs
1. Multiple window plots
1. Utilizing additional channels

## Two-dimensional graphs

**Two-dimensional graphs** are visualizations that are naturally designed to visualize two variables. For instance, if you have a discrete variable and a continuous variable, you could use a **box plot** to visualize the distribution of the values of the continuous variable for each category in the discrete variable:


```r
ggplot(data = scorecard,
       mapping = aes(x = type, y = cost)) +
  geom_boxplot()
```

```
## Warning: Removed 42 rows containing non-finite values (stat_boxplot).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/boxplot-1.png" width="672" />

Here we see that on average, public universities are least expensive, followed by private for-profit institutions. I was somewhat surprised by this since for-profit institutions by definition seek to generate a profit, so wouldn't they be the most expensive? But perhaps this makes sense, because they have to attract students so need to offer a better financial value than competing nonprofit or public institutions. Is there a better explanation for these differences? Another question you could explore after viewing this visualization.

If you have two continuous variables, you may use a **scatterplot** which maps each variable to an $x$ or $y$-axis coordinate. Here we visualize the relationship between financial aid awards^[Percentage of undergraduates who receive a [Pell Grant](https://studentaid.gov/understand-aid/types/grants/pell/), regularly employed as a proxy for low-income students.] and cost of attendance:


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = cost)) +
  geom_point()
```

```
## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-1.png" width="672" />

As percentage of Pell Grant recipients increases, average cost of attendance declines.

## Multiple window plots

Sometimes you want to compare the conditional distribution of a variable across specific groups or subsets of the data. To do that, we implement a **multiple window plot** (also known as a **trellis** or **facet** graph). This involves drawing the same plot repeatedly, using a separate window for each category defined by a variable. For instance, if we want to examine variation in cost of attendance separately for college type, we could draw a graph like this:


```r
ggplot(data = scorecard,
       mapping = aes(x = cost)) +
  geom_histogram() +
  facet_wrap(~ type)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```
## Warning: Removed 42 rows containing non-finite values (stat_bin).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/histogram-facet-1.png" width="672" />

This helps answer one of our earlier questions. Colleges in the 20,000 dollar range tend to be public universities, while the heaps around 40,000 and 65,000 dollars are from private nonprofits.

You may also want to use a multiple windows plot with a two-dimensional graph. For example, the relationship between Pell Grant recipients and cost of attendance by college type:


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = cost)) +
  geom_point() +
  facet_wrap(~ type)
```

```
## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-facet-1.png" width="672" />

## Utilizing additional channels

If you want to visualize three or more dimensions of data without resorting to 3D animations^[Though with the growth of virtual reality technology and 3D printing, perhaps this isn't a bad idea.] or window plots, the best approach is to incorporate additional **channels** into the visualization. Channels are used to encode variables inside of a graphic. For instance, a scatterplot uses vertical and horizontal spatial position channels to encode the values for two variables in a visually intuitive manner.

Depending on the type of graph and variables you wish to encode, there are several different channels you can use to encode additional information. For instance, **color** can be used to distinguish between classes in a categorical variable.


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell,
                     y = cost,
                     color = type)) +
  geom_point()
```

```
## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-color-1.png" width="672" />

We can even use a fourth channel to communicate another variable (median debt load after leaving school) by making use of the size channel:


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell,
                     y = cost,
                     color = type,
                     size = debt)) +
  geom_point()
```

```
## Warning: Removed 113 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis_files/figure-html/scatterplot-color-size-1.png" width="672" />

Note that some channels are not always appropriate, even if they can technically be implemented. For example, the graph above has become quite challenging to read due to so many overlapping data points. Just because one **can** construct a graph does not mean one **should** construct a graph.

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.2 (2020-06-22)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-10-05                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package        * version date       lib source        
##  assertthat       0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports        1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
##  blob             1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
##  blogdown         0.20.1  2020-07-02 [1] local         
##  bookdown         0.20    2020-06-23 [1] CRAN (R 4.0.2)
##  broom            0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
##  callr            3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
##  cellranger       1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli              2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
##  colorspace       1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
##  crayon           1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  DBI              1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr           1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
##  desc             1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools         2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
##  digest           0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr          * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
##  ellipsis         0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate         0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi            0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  forcats        * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
##  fs               1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
##  generics         0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
##  ggplot2        * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
##  glue             1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
##  gtable           0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven            2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
##  here             0.1     2017-05-28 [1] CRAN (R 4.0.0)
##  hms              0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools        0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
##  httr             1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
##  jsonlite         1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
##  knitr            1.29    2020-06-23 [1] CRAN (R 4.0.1)
##  lattice          0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
##  lifecycle        0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
##  lubridate        1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
##  magrittr         1.5     2014-11-22 [1] CRAN (R 4.0.0)
##  memoise          1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  modelr           0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell          0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  nlme             3.1-148 2020-05-24 [1] CRAN (R 4.0.2)
##  palmerpenguins * 0.1.0   2020-07-23 [1] CRAN (R 4.0.2)
##  pillar           1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
##  pkgbuild         1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
##  pkgconfig        2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload          1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  prettyunits      1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx         3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
##  ps               1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
##  purrr          * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6               2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
##  Rcpp             1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
##  readr          * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
##  readxl           1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes          2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
##  reprex           0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
##  rlang            0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
##  rmarkdown        2.3     2020-06-18 [1] CRAN (R 4.0.2)
##  rprojroot        1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
##  rstudioapi       0.11    2020-02-07 [1] CRAN (R 4.0.0)
##  rvest            0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
##  scales           1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo      1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi          1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
##  stringr        * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat         2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
##  tibble         * 3.0.3   2020-07-10 [1] CRAN (R 4.0.1)
##  tidyr          * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
##  tidyselect       1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse      * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
##  usethis          1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
##  vctrs            0.3.1   2020-06-05 [1] CRAN (R 4.0.1)
##  withr            2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
##  xfun             0.15    2020-06-21 [1] CRAN (R 4.0.1)
##  xml2             1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml             2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
