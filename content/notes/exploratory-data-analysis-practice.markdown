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

{{% alert note %}}

Run the below code in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/exploratory-data-analysis")
```

{{% /alert %}}

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2013 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub. To install the package, run the command `devtools::install_github("uc-cfss/rcfss")` in the console.

{{% alert warning %}}

If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages("devtools")`, then run `devtools::install_github("uc-cfss/rcfss")`.

{{% /alert %}}


```r
library(rcfss)
data("scorecard")
glimpse(scorecard)
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
## Warning: Removed 459 rows containing non-finite values (stat_boxplot).
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
## Warning: Removed 459 rows containing non-finite values (stat_bin).
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
## Warning: Removed 459 rows containing non-finite values (stat_bin).
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
## Warning: Removed 52 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 52 rows containing missing values (geom_point).
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
## Warning: Removed 52 rows containing non-finite values (stat_smooth).

## Warning: Removed 52 rows containing missing values (geom_point).
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
## Warning: Removed 52 rows containing non-finite values (stat_binhex).
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 52 rows containing non-finite values (stat_smooth).
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
## Warning: Removed 52 rows containing non-finite values (stat_smooth).

## Warning: Removed 52 rows containing missing values (geom_point).
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
## Warning: Removed 52 rows containing non-finite values (stat_smooth).

## Warning: Removed 52 rows containing missing values (geom_point).
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
## Warning: Removed 96 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-scatter-1.png" width="672" />

Hmm. There seem to be a lot of data points. It isn't really clear if there is a trend. What if we **jitter** the data points?


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_jitter()
```

```
## Warning: Removed 96 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-jitter-1.png" width="672" />

Meh, didn't really do much. What if we make our data points semi-transparent using the `alpha` aesthetic?


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_point(alpha = .2)
```

```
## Warning: Removed 96 rows containing missing values (geom_point).
```

<img src="/notes/exploratory-data-analysis-practice_files/figure-html/pell-alpha-1.png" width="672" />

Now we're getting somewhere. I'm beginning to see some dense clusters in the middle. Maybe a **hexagon binning** plot would help


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_hex()
```

```
## Warning: Removed 96 rows containing non-finite values (stat_binhex).
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
## Warning: Removed 96 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 96 rows containing missing values (geom_point).
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
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.2 (2020-06-22)
##  os       macOS Catalina 10.15.6      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-09-05                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports     1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
##  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
##  blogdown      0.20.1  2020-07-02 [1] local         
##  bookdown      0.20    2020-06-23 [1] CRAN (R 4.0.2)
##  broom         0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
##  callr         3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 4.0.2)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools      2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
##  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr       * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  farver        2.0.3   2020-01-16 [1] CRAN (R 4.0.0)
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
##  fs            1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
##  ggplot2     * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
##  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
##  here          0.1     2017-05-28 [1] CRAN (R 4.0.0)
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
##  jsonlite      1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
##  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.1)
##  labeling      0.3     2014-08-23 [1] CRAN (R 4.0.0)
##  lattice       0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
##  lubridate     1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  nlme          3.1-148 2020-05-24 [1] CRAN (R 4.0.2)
##  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
##  pkgbuild      1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
##  ps            1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
##  rcfss       * 0.2.0   2020-09-05 [1] local         
##  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes       2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
##  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
##  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
##  rstudioapi    0.11    2020-02-07 [1] CRAN (R 4.0.0)
##  rvest         0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
##  tibble      * 3.0.3   2020-07-10 [1] CRAN (R 4.0.1)
##  tidyr       * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
##  usethis       1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
##  vctrs         0.3.1   2020-06-05 [1] CRAN (R 4.0.1)
##  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
##  xfun          0.15    2020-06-21 [1] CRAN (R 4.0.1)
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
