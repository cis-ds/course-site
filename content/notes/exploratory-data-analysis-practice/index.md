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

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/exploratory-data-analysis")
```

{{% /callout %}}

The Department of Education collects [annual statistics on colleges and universities in the United States](https://collegescorecard.ed.gov/). I have included a subset of this data from 2018-19 in the [`rcfss`](https://github.com/uc-cfss/rcfss) library from GitHub. To install the package, run the command `devtools::install_github("uc-cfss/rcfss")` in the console.

{{% callout warning %}}

If you don't already have the `devtools` library installed, you will get an error. Go back and install this first using `install.packages("devtools")`, then run `devtools::install_github("uc-cfss/rcfss")`.

{{% /callout %}}


```r
library(rcfss)
data("scorecard")
glimpse(scorecard)
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

Type `?scorecard` in the console to open up the help file for this data set. This includes the documentation for all the variables. Use your knowledge of `dplyr` and `ggplot2` functions to answer the following questions.

## Which type of college has the highest average SAT score?

**NOTE: This time, use a graph to visualize your answer, [not a table](/notes/transform-college/#generate-a-data-frame-with-the-average-sat-score-for-each-type-of-college).**

{{< spoiler text="Click for the solution" >}}

We could use a **boxplot** to visualize the distribution of SAT scores.


```r
ggplot(data = scorecard,
       mapping = aes(x = type, y = satavg)) +
  geom_boxplot()
```

```
## Warning: Removed 475 rows containing non-finite values (stat_boxplot).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/sat-boxplot-1.png" width="672" />

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
## Warning: Removed 475 rows containing non-finite values (stat_bin).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/sat-histo-freq-1.png" width="672" />

```r
ggplot(data = scorecard,
       mapping = aes(x = satavg, color = type)) +
  geom_freqpoly()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```
## Warning: Removed 475 rows containing non-finite values (stat_bin).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/sat-histo-freq-2.png" width="672" />

Now we can see the averages for each college type are based on widely varying sample sizes.


```r
ggplot(data = scorecard,
       mapping = aes(x = type)) +
  geom_bar()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/sat-bar-1.png" width="672" />

There are far fewer private, for-profit colleges than the other categories. A boxplot alone would not reveal this detail, which could be important in future analysis.

{{< /spoiler >}}

## What is the relationship between net cost of attendance and faculty salaries? How does this relationship differ across types of colleges?

{{< spoiler text="Click for the solution" >}}


```r
# geom_point
ggplot(data = scorecard,
       mapping = aes(x = netcost, y = avgfacsal)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 46 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 46 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cost-avgfacsal-1.png" width="672" />

```r
# geom_point with alpha transparency to reveal dense clusters
ggplot(data = scorecard,
       mapping = aes(x = netcost, y = avgfacsal)) +
  geom_point(alpha = .2) +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 46 rows containing non-finite values (stat_smooth).

## Warning: Removed 46 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cost-avgfacsal-2.png" width="672" />

```r
# geom_hex
ggplot(data = scorecard,
       mapping = aes(x = netcost, y = avgfacsal)) +
  geom_hex() +
  geom_smooth()
```

```
## Warning: Removed 46 rows containing non-finite values (stat_binhex).
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 46 rows containing non-finite values (stat_smooth).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cost-avgfacsal-3.png" width="672" />

```r
# geom_point with smoothing lines for each type
ggplot(data = scorecard,
       mapping = aes(x = netcost,
                     y = avgfacsal,
                     color = type)) +
  geom_point(alpha = .2) +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

```
## Warning: Removed 46 rows containing non-finite values (stat_smooth).

## Warning: Removed 46 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cost-avgfacsal-4.png" width="672" />

```r
# geom_point with facets for each type
ggplot(data = scorecard,
       mapping = aes(x = netcost,
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
## Warning: Removed 46 rows containing non-finite values (stat_smooth).

## Warning: Removed 46 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cost-avgfacsal-5.png" width="672" />

{{< /spoiler >}}

## How are a college's Pell Grant recipients related to the average student's education debt?

{{< spoiler text="Click for the solution" >}}

Two continuous variables suggest a **scatterplot** would be appropriate.


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_point()
```

```
## Warning: Removed 108 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/pell-scatter-1.png" width="672" />

Hmm. There seem to be a lot of data points. It isn't really clear if there is a trend. What if we **jitter** the data points?


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_jitter()
```

```
## Warning: Removed 108 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/pell-jitter-1.png" width="672" />

Meh, didn't really do much. What if we make our data points semi-transparent using the `alpha` aesthetic?


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_point(alpha = .2)
```

```
## Warning: Removed 108 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/pell-alpha-1.png" width="672" />

Now we're getting somewhere. I'm beginning to see some dense clusters in the middle. Maybe a **hexagon binning** plot would help


```r
ggplot(data = scorecard,
       mapping = aes(x = pctpell, y = debt)) +
  geom_hex()
```

```
## Warning: Removed 108 rows containing non-finite values (stat_binhex).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/pell-bin-1.png" width="672" />

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
## Warning: Removed 108 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 108 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/pell-smooth-1.png" width="672" />

This confirms our initial evidence - there is an apparent negative relationship. Notice how I iterated through several different plots before I created one that provided the most informative visualization. **You will not create the perfect graph on your first attempt.** Trial and error is necessary in this exploratory stage. Be prepared to revise your code again and again.

{{< /spoiler >}}

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
##  package     * version date       lib source                              
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports     1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown      1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown      0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom         0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  cli           2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace    2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr        2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr       * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics      0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2     * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools     0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate     1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  pillar        1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx      3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps            1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  Rcpp          1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr       * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes       2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown     2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest         0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat      3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble      * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr       * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis       2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun          0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
