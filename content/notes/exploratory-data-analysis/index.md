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

![Artwork by @allison_horst](/img/allison_horst_art/ggplot2_exploratory.png)

Graphs generated through EDA are distinct from final graphs. You will typically generate dozens, if not hundreds, of exploratory graphs in the course of analyzing a dataset. Of these graphs, you may end up publishing one or two in a final format. One purpose of EDA is to develop a personal understanding of the data, so all your code and graphs should be geared towards that purpose. Important details that you might add if you were to publish a graph^[In perhaps an academic journal, or maybe a homework submission.] are not necessary in an exploratory graph. For example, say I want to explore how the flipper length of a penguin varies with it's body mass size. An appropriate technique would be a scatterplot:


```r
ggplot(data = penguins,
       mapping = aes(x = body_mass_g, y = flipper_length_mm)) +
  geom_point() +
  geom_smooth()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/penguins-eda-1.png" width="672" />

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

<img src="{{< blogdown/postref >}}index_files/figure-html/penguins-final-1.png" width="672" />

These additional details are very helpful in communicating the meaning of the graph, but take a substantial amount of time and code to write. For EDA, you don't have to add this detail to every exploratory graph.

![Artwork by @allison_horst](/img/allison_horst_art/presenting_monster.png)

## Scorecard

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2018-19 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub.  Here let's examine the data to answer the following question: **how does cost of attendance vary across universities?**

## Import the data

The `scorecard` dataset is included as part of the `rcfss` library:


```r
library(rcfss)
data("scorecard")

scorecard
```

```
## # A tibble: 1,753 x 15
##    unitid name  state type  admrate satavg  cost netcost avgfacsal pctpell
##     <int> <chr> <chr> <fct>   <dbl>  <dbl> <int>   <dbl>     <dbl>   <dbl>
##  1 420325 Yesh… NY    Priv…  0.531      NA 14874    4018     26253   0.958
##  2 430485 The … NE    Priv…  0.667      NA 41627   39020     54000   0.529
##  3 100654 Alab… AL    Publ…  0.899     957 22489   14444     63909   0.707
##  4 102234 Spri… AL    Priv…  0.658    1130 51969   19718     60048   0.342
##  5 100724 Alab… AL    Publ…  0.977     972 21476   13043     69786   0.745
##  6 106467 Arka… AR    Publ…  0.902      NA 18627   12362     61497   0.396
##  7 106704 Univ… AR    Publ…  0.911    1186 21350   14723     63360   0.430
##  8 109651 Art … CA    Priv…  0.676      NA 64097   43010     69984   0.307
##  9 110404 Cali… CA    Priv…  0.0662   1566 68901   23820    179937   0.142
## 10 112394 Cogs… CA    Priv…  0.579      NA 35351   31537     66636   0.461
## # … with 1,743 more rows, and 5 more variables: comprate <dbl>, firstgen <dbl>,
## #   debt <dbl>, locale <fct>, openadmp <fct>
```

```r
glimpse(x = scorecard)
```

```
## Rows: 1,753
## Columns: 15
## $ unitid    <int> 420325, 430485, 100654, 102234, 100724, 106467, 106704, 109…
## $ name      <chr> "Yeshiva D'monsey Rabbinical College", "The Creative Center…
## $ state     <chr> "NY", "NE", "AL", "AL", "AL", "AR", "AR", "CA", "CA", "CA",…
## $ type      <fct> "Private, nonprofit", "Private, for-profit", "Public", "Pri…
## $ admrate   <dbl> 0.5313, 0.6667, 0.8986, 0.6577, 0.9774, 0.9024, 0.9110, 0.6…
## $ satavg    <dbl> NA, NA, 957, 1130, 972, NA, 1186, NA, 1566, NA, NA, 1053, 1…
## $ cost      <int> 14874, 41627, 22489, 51969, 21476, 18627, 21350, 64097, 689…
## $ netcost   <dbl> 4018, 39020, 14444, 19718, 13043, 12362, 14723, 43010, 2382…
## $ avgfacsal <dbl> 26253, 54000, 63909, 60048, 69786, 61497, 63360, 69984, 179…
## $ pctpell   <dbl> 0.9583, 0.5294, 0.7067, 0.3420, 0.7448, 0.3955, 0.4298, 0.3…
## $ comprate  <dbl> 0.6667, 0.6667, 0.2685, 0.5864, 0.3001, 0.4069, 0.4113, 0.7…
## $ firstgen  <dbl> NA, NA, 0.3658281, 0.2516340, 0.3434343, 0.4574780, 0.34595…
## $ debt      <dbl> NA, 12000, 15500, 18270, 18679, 12000, 13100, 27811, 8013, …
## $ locale    <fct> Suburb, City, City, City, City, Town, City, City, City, Cit…
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
## Warning: Removed 41 rows containing non-finite values (stat_bin).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/histogram-1.png" width="672" />

It appears there are three sets of peak values for cost of attendance, around 20,000, 40,000, and 65,000 dollars in declining overall frequency. This could suggest some underlying factor or set of differences between the universities that clusters them into separate groups based on cost of attendance.

By default, `geom_histogram()` bins the observations into 30 intervals of equal width. You can adjust this using the `bins` parameter:


```r
ggplot(data = scorecard,
       mapping = aes(x = cost)) +
  geom_histogram(bins = 50)
```

```
## Warning: Removed 41 rows containing non-finite values (stat_bin).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/histogram-bins-50-1.png" width="672" />


```r
ggplot(data = scorecard,
       mapping = aes(x = cost)) +
  geom_histogram(bins = 10)
```

```
## Warning: Removed 41 rows containing non-finite values (stat_bin).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/histogram-bins-10-1.png" width="672" />

Different `bins` can lead to different inferences about the data. Here if we set a larger number of bins, the overall picture seems to be the same - the distribution is trimodal. But if we collapse the number of bins to 10, we lose the clarity of each of these peaks.

### Bar chart


```r
ggplot(data = scorecard,
       mapping = aes(x = type)) +
  geom_bar()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/barplot-1.png" width="672" />

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
## Warning: Removed 41 rows containing non-finite values (stat_boxplot).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/boxplot-1.png" width="672" />

Here we see that on average, public universities are least expensive, followed by private for-profit institutions. I was somewhat surprised by this since for-profit institutions by definition seek to generate a profit, so wouldn't they be the most expensive? But perhaps this makes sense, because they have to attract students so need to offer a better financial value than competing nonprofit or public institutions. Is there a better explanation for these differences? Another question you could explore after viewing this visualization.

If you have two continuous variables, you may use a **scatterplot** which maps each variable to an $x$ or $y$-axis coordinate. Here we visualize the relationship between annual cost of attendance (sticker price) and net cost of attendance (average amount actually paid by a student):


```r
ggplot(data = scorecard,
       mapping = aes(x = cost, y = netcost)) +
  geom_point()
```

```
## Warning: Removed 41 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatterplot-1.png" width="672" />

As the sticker price increases, the net cost also increases though with significant variation. Some schools have a much lower net cost than their advertised price.

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
## Warning: Removed 41 rows containing non-finite values (stat_bin).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/histogram-facet-1.png" width="672" />

This helps answer one of our earlier questions. Colleges in the 20,000 dollar range tend to be public universities, while the heaps around 40,000 and 65,000 dollars are from private nonprofits.

You may also want to use a multiple windows plot with a two-dimensional graph. For example, the relationship between annual cost and net cost of attendance by college type:


```r
ggplot(data = scorecard,
       mapping = aes(x = cost, y = netcost)) +
  geom_point() +
  facet_wrap(~ type)
```

```
## Warning: Removed 41 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatterplot-facet-1.png" width="672" />

## Utilizing additional channels

If you want to visualize three or more dimensions of data without resorting to 3D animations^[Though with the growth of virtual reality technology and 3D printing, perhaps this isn't a bad idea.] or window plots, the best approach is to incorporate additional **channels** into the visualization. Channels are used to encode variables inside of a graphic. For instance, a scatterplot uses vertical and horizontal spatial position channels to encode the values for two variables in a visually intuitive manner.

Depending on the type of graph and variables you wish to encode, there are several different channels you can use to encode additional information. For instance, **color** can be used to distinguish between classes in a categorical variable.


```r
ggplot(data = scorecard,
       mapping = aes(x = cost,
                     y = netcost,
                     color = type)) +
  geom_point()
```

```
## Warning: Removed 41 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatterplot-color-1.png" width="672" />

We can even use a fourth channel to communicate another variable (median debt load after leaving school) by making use of the size channel:


```r
ggplot(data = scorecard,
       mapping = aes(x = cost,
                     y = netcost,
                     color = type,
                     size = debt)) +
  geom_point()
```

```
## Warning: Removed 128 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatterplot-color-size-1.png" width="672" />

Note that some channels are not always appropriate, even if they can technically be implemented. For example, the graph above has become quite challenging to read due to so many overlapping data points. Just because one **can** construct a graph does not mean one **should** construct a graph.

## Acknowledgments

* Artwork by [@allison_horst](https://github.com/allisonhorst/stats-illustrations)

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.3 (2020-10-10)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-01-21                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package        * version date       lib source                              
##  assertthat       0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports        1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown         1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown         0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom            0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr            3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger       1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  cli              2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace       2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon           1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI              1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr           2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc             1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools         2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest           0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr          * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis         0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate         0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi            0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats        * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  fs               1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics         0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2        * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue             1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable           0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven            2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here             1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms              0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools        0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr             1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite         1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr            1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lifecycle        0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate        1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr         2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  memoise          1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr           0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell          0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  palmerpenguins * 0.1.0   2020-07-23 [1] CRAN (R 4.0.2)                      
##  pillar           1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild         1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig        2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload          1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  prettyunits      1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx         3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps               1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr          * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6               2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  Rcpp             1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr          * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl           1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes          2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex           0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  rlang            0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown        2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot        2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi       0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest            0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales           1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo      1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi          1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr        * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat         3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble         * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr          * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect       1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse      * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis          2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs            0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr            2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun             0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2             1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml             2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
