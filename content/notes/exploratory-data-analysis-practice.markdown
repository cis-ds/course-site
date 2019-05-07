---
title: "Practice exploring college education (data)"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/eda_college.html"]
categories: ["eda"]

menu:
  notes:
    parent: Exploratory data analysis
    weight: 2
---




```r
library(tidyverse)
```

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2013 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub. To install the package, run the command `devtools::install_github("uc-cfss/rcfss")` in the console.

> If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages("devtools")`, then run `devtools::install_github("uc-cfss/rcfss")`.


```r
library(rcfss)
data("scorecard")
glimpse(scorecard)
```

```
## Observations: 1,849
## Variables: 12
## $ unitid    <int> 450234, 448479, 456427, 459596, 459851, 482477, 482547…
## $ name      <chr> "ITT Technical Institute-Wichita", "ITT Technical Inst…
## $ state     <chr> "KS", "MI", "CA", "FL", "WI", "IL", "NV", "OR", "TN", …
## $ type      <chr> "Private, for-profit", "Private, for-profit", "Private…
## $ cost      <int> 28306, 26994, 26353, 28894, 23928, 25625, 24265, NA, 2…
## $ admrate   <dbl> 81.31, 98.31, 89.26, 58.37, 68.75, 70.40, 80.00, 50.00…
## $ satavg    <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ avgfacsal <dbl> 45054, 52857, NA, 47196, 55089, 62793, 47556, 60003, 5…
## $ pctpell   <dbl> 0.8030, 0.7735, 0.7038, 0.7781, 0.6098, 0.6411, 0.6356…
## $ comprate  <dbl> 0.6000, 0.3359, NA, NA, NA, 0.2939, 0.6364, 0.0000, 0.…
## $ firstgen  <dbl> 0.5057590, 0.5057590, 0.5057590, 0.5057590, 0.5171601,…
## $ debt      <dbl> 13000, 13000, 13000, 13000, 9500, 14250, 14250, 14250,…
```

Type `?scorecard` in the console to open up the help file for this data set. This includes the documentation for all the variables. Use your knowledge of `dplyr` and `ggplot2` functions to answer the following questions.

## Which type of college has the highest average SAT score?

**NOTE: This time, use a graph to visualize your answer, [not a table](/notes/transform-college/#generate-a-data-frame-with-the-average-sat-score-for-each-type-of-college).**

<details> 
  <summary>Click for the solution</summary>
  <p>
  
We could use a **boxplot** to visualize the distribution of SAT scores.


```r
ggplot(data = scorecard,
       mapping = aes(x = type, y = satavg)) +
  geom_boxplot()
```

```
## Warning: Removed 471 rows containing non-finite values (stat_boxplot).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/sat-boxplot-1.png" width="672" />

According to this graph, private, nonprofit schools have the highest average SAT score, followed by public and then private, for-profit schools. But this doesn't reveal the entire picture. What happens if we plot a **histogram** or **frequency polygon**?


```r
ggplot(data = scorecard,
       mapping = aes(x = satavg)) +
  geom_histogram() +
  facet_wrap(~ type)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```
## Warning: Removed 471 rows containing non-finite values (stat_bin).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/sat-histo-freq-1.png" width="672" />

```r
ggplot(data = scorecard,
       mapping = aes(x = satavg, color = type)) +
  geom_freqpoly()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```
## Warning: Removed 471 rows containing non-finite values (stat_bin).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/sat-histo-freq-2.png" width="672" />

Now we can see the averages for each college type are based on widely varying sample sizes.


```r
ggplot(data = scorecard,
       mapping = aes(x = type)) +
  geom_bar()
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/sat-bar-1.png" width="672" />

There are far fewer private, for-profit colleges than the other categories. A boxplot alone would not reveal this detail, which could be important in future analysis.
  </p>
</details>

## What is the relationship between college attendance cost and faculty salaries? How does this relationship differ across types of colleges?

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
# geom_point
ggplot(data = scorecard,
       mapping = aes(x = cost, y = avgfacsal)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 42 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/cost-avgfacsal-1.png" width="672" />

```r
# geom_point with alpha transparency to reveal dense clusters
ggplot(data = scorecard,
       mapping = aes(x = cost, y = avgfacsal)) +
  geom_point(alpha = .2) +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 42 rows containing non-finite values (stat_smooth).

## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/cost-avgfacsal-2.png" width="672" />

```r
# geom_hex
ggplot(data = scorecard,
       mapping = aes(x = cost, y = avgfacsal)) +
  geom_hex() +
  geom_smooth()
```

```
## Warning: Removed 42 rows containing non-finite values (stat_binhex).
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 42 rows containing non-finite values (stat_smooth).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/cost-avgfacsal-3.png" width="672" />

```r
# geom_point with smoothing lines for each type
ggplot(data = scorecard,
       mapping = aes(x = cost,
                     y = avgfacsal,
                     color = type)) +
  geom_point(alpha = .2) +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 42 rows containing non-finite values (stat_smooth).

## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/cost-avgfacsal-4.png" width="672" />

```r
# geom_point with facets for each type
ggplot(data = scorecard,
       mapping = aes(x = cost,
                     y = avgfacsal,
                     color = type)) +
  geom_point(alpha = .2) +
  geom_smooth() +
  facet_grid(. ~ type)
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 42 rows containing non-finite values (stat_smooth).

## Warning: Removed 42 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/cost-avgfacsal-5.png" width="672" />

  </p>
</details>

## How are a college's Pell Grant recipients related to the average student's education debt?

<details> 
  <summary>Click for the solution</summary>
  <p>

Two continuous variables suggest a **scatterplot** would be appropriate.


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_point()
```

```
## Warning: Removed 75 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-scatter-1.png" width="672" />

Hmm. There seem to be a lot of data points. It isn't really clear if there is a trend. What if we **jitter** the data points?


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_jitter()
```

```
## Warning: Removed 75 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-jitter-1.png" width="672" />

Meh, didn't really do much. What if we make our data points semi-transparent using the `alpha` aesthetic?


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_point(alpha = .2)
```

```
## Warning: Removed 75 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-alpha-1.png" width="672" />

Now we're getting somewhere. I'm beginning to see some dense clusters in the middle. Maybe a **hexagon binning** plot would help


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_hex()
```

```
## Warning: Removed 75 rows containing non-finite values (stat_binhex).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-bin-1.png" width="672" />

This is getting better. It looks like there might be a downward trend; that is, as the percentage of Pell grant recipients increases, average student debt decreases. Let's confirm this by going back to the scatterplot and overlaying a **smoothing line**.


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_point(alpha = .2) +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 75 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 75 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-smooth-1.png" width="672" />

This confirms our initial evidence - there is an apparent negative relationship. Notice how I iterated through several different plots before I created one that provided the most informative visualization. **You will not create the perfect graph on your first attempt.** Trial and error is necessary in this exploratory stage. Be prepared to revise your code again and again.

  </p>
</details>

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.5.3 (2019-03-11)
##  os       macOS Mojave 10.14.3        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-05-07                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.3   2018-12-14 [2] CRAN (R 3.5.0)
##  blogdown      0.11    2019-03-11 [1] CRAN (R 3.5.2)
##  bookdown      0.9     2018-12-21 [1] CRAN (R 3.5.0)
##  broom         0.5.1   2018-12-05 [2] CRAN (R 3.5.0)
##  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
##  cellranger    1.1.0   2016-07-27 [2] CRAN (R 3.5.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
##  colorspace    1.4-1   2019-03-18 [2] CRAN (R 3.5.2)
##  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.1   2018-10-26 [1] CRAN (R 3.5.1)
##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr       * 0.8.0.1 2019-02-15 [1] CRAN (R 3.5.2)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  forcats     * 0.4.0   2019-02-17 [2] CRAN (R 3.5.2)
##  fs            1.2.7   2019-03-19 [1] CRAN (R 3.5.3)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2     * 3.1.0   2018-10-25 [1] CRAN (R 3.5.0)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  gtable        0.2.0   2016-02-26 [2] CRAN (R 3.5.0)
##  haven         2.1.0   2019-02-19 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite      1.6     2018-12-07 [2] CRAN (R 3.5.0)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  lattice       0.20-38 2018-11-04 [2] CRAN (R 3.5.3)
##  lazyeval      0.2.2   2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate     1.7.4   2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  modelr        0.1.4   2019-02-18 [2] CRAN (R 3.5.2)
##  munsell       0.5.0   2018-06-12 [2] CRAN (R 3.5.0)
##  nlme          3.1-137 2018-04-07 [2] CRAN (R 3.5.3)
##  pillar        1.3.1   2018-12-15 [2] CRAN (R 3.5.0)
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.5.3)
##  pkgconfig     2.0.2   2018-08-16 [2] CRAN (R 3.5.1)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
##  plyr          1.8.4   2016-06-08 [2] CRAN (R 3.5.0)
##  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.0   2019-03-10 [2] CRAN (R 3.5.2)
##  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
##  purrr       * 0.3.2   2019-03-15 [2] CRAN (R 3.5.2)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  readr       * 1.3.1   2018-12-21 [2] CRAN (R 3.5.0)
##  readxl        1.3.1   2019-03-13 [2] CRAN (R 3.5.2)
##  remotes       2.0.2   2018-10-30 [1] CRAN (R 3.5.0)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.5.3)
##  rvest         0.3.2   2016-06-17 [2] CRAN (R 3.5.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.5.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.0.1   2018-10-13 [2] CRAN (R 3.5.0)
##  tibble      * 2.1.1   2019-03-16 [2] CRAN (R 3.5.2)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.5.0)
##  tidyverse   * 1.2.1   2017-11-14 [2] CRAN (R 3.5.0)
##  usethis       1.4.0   2018-08-14 [1] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
