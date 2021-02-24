---
title: "Working with statistical models"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["stat-learn"]

menu:
  notes:
    parent: Machine learning
    weight: 4
---




```r
library(tidyverse)
library(tidymodels)
library(rcfss)

set.seed(123)

theme_set(theme_minimal())
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/statistical-learning")
```

{{% /callout %}}

## Exercise: linear regression with `scorecard`

Recall the `scorecard` data set which contains information on U.S. institutions of higher learning.


```r
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

Answer the following questions using the statistical modeling tools you have learned.

1. What is the relationship between admission rate and cost? Report this relationship using a scatterplot and a linear best-fit line.

    {{< spoiler text="Click for the solution" >}}


```r
ggplot(scorecard, aes(admrate, cost)) +
  geom_point() +
  geom_smooth(method = "lm")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scorecard-point-1.png" width="672" />

    {{< /spoiler >}}

1. Estimate a linear regression of the relationship between admission rate and cost, and report your results in a tidy table.

    {{< spoiler text="Click for the solution" >}}
    

```r
scorecard_fit <- linear_reg() %>%
  set_engine("lm") %>%
  fit(cost ~ admrate, data = scorecard)
tidy(scorecard_fit)
```

```
## # A tibble: 2 x 5
##   term        estimate std.error statistic   p.value
##   <chr>          <dbl>     <dbl>     <dbl>     <dbl>
## 1 (Intercept)   51723.     1242.      41.6 3.74e-262
## 2 admrate      -22928.     1768.     -13.0 9.32e- 37
```
   
    {{< /spoiler >}}

1. Estimate a linear regression of the relationship between admission rate and cost, while also accounting for type of college and percent of Pell Grant recipients, and report your results in a tidy table.

    {{< spoiler text="Click for the solution" >}}
    

```r
 scorecard_fit <- linear_reg() %>%
  set_engine("lm") %>%
  fit(cost ~ admrate + type + pctpell, data = scorecard)
tidy(scorecard_fit)
```

```
## # A tibble: 5 x 5
##   term                    estimate std.error statistic   p.value
##   <chr>                      <dbl>     <dbl>     <dbl>     <dbl>
## 1 (Intercept)               47642.     1010.      47.2 1.94e-311
## 2 admrate                  -12456.     1145.     -10.9 1.06e- 26
## 3 typePrivate, nonprofit    20235.      512.      39.5 4.58e-243
## 4 typePrivate, for-profit   16833.     1203.      14.0 3.50e- 42
## 5 pctpell                  -43757.     1465.     -29.9 4.02e-158
```
    
    {{< /spoiler >}}

## Exercise: logistic regression with `mental_health`

Why do some people vote in elections while others do not? Typical explanations focus on a resource model of participation -- individuals with greater resources, such as time, money, and civic skills, are more likely to participate in politics. An emerging theory assesses an individual's mental health and its effect on political participation.^[[Ojeda, C. (2015). Depression and political participation. *Social Science Quarterly*, 96(5), 1226-1243.](http://onlinelibrary.wiley.com.proxy.uchicago.edu/doi/10.1111/ssqu.12173/abstract)] Depression increases individuals' feelings of hopelessness and political efficacy, so depressed individuals will have less desire to participate in politics. More importantly to our resource model of participation, individuals with depression suffer physical ailments such as a lack of energy, headaches, and muscle soreness which drain an individual's energy and requires time and money to receive treatment. For these reasons, we should expect that individuals with depression are less likely to participate in election than those without symptoms of depression.

Use the `mental_health` data set in `library(rcfss)` and logistic regression to predict whether or not an individual voted in the 1996 presidential election.


```r
mental_health
```

```
## # A tibble: 1,317 x 5
##    vote96   age  educ female mhealth
##     <dbl> <dbl> <dbl>  <dbl>   <dbl>
##  1      1    60    12      0       0
##  2      1    36    12      0       1
##  3      0    21    13      0       7
##  4      0    29    13      0       6
##  5      1    39    18      1       2
##  6      1    41    15      1       1
##  7      1    48    20      0       2
##  8      0    20    12      1       9
##  9      0    27    11      1       9
## 10      0    34     7      1       2
## # … with 1,307 more rows
```

1. Estimate a logistic regression model of voter turnout with `mhealth` as the predictor. Estimate predicted probabilities and a 95% confidence interval, and plot the logistic regression predictions using `ggplot`.

    {{< spoiler text="Click for the solution" >}}
    

```r
# convert vote96 to a factor column
mental_health <- rcfss::mental_health %>%
  mutate(vote96 = factor(vote96, labels = c("Not voted", "Voted")))
```


```r
# estimate model
mh_mod <- logistic_reg() %>%
  set_engine("glm") %>%
  fit(vote96 ~ mhealth, data = mental_health)

# generate predicted probabilities + confidence intervals
new_points <- tibble(
  mhealth = seq(
    from = min(mental_health$mhealth),
    to = max(mental_health$mhealth)
  )
)

bind_cols(
  new_points,
  # predicted probabilities
  predict(mh_mod, new_data = new_points, type = "prob"),
  # confidence intervals
  predict(mh_mod, new_data = new_points, type = "conf_int")
) %>%
  # graph the predictions
  ggplot(mapping = aes(x = mhealth, y = .pred_Voted)) +
  geom_pointrange(mapping = aes(ymin = .pred_lower_Voted, ymax = .pred_upper_Voted)) +
  labs(title = "Relationship Between Mental Health and Voter Turnout",
       x = "Mental health status",
       y = "Predicted Probability of Voting")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/mh-model-1.png" width="672" />
    
    {{< /spoiler >}}

1. Estimate a second logistic regression model of voter turnout using using age and gender (i.e. the `female` column). Extract predicted probabilities and confidence intervals for all possible values of age, and visualize using `ggplot()`.

    {{< spoiler text="Click for the solution" >}}


```r
# recode female
mental_health <- rcfss::mental_health %>%
  mutate(vote96 = factor(vote96, labels = c("Not voted", "Voted")),
         female = factor(female, labels = c("Male", "Female")))

# estimate model
mh_int_mod <- logistic_reg() %>%
  set_engine("glm") %>%
  fit(vote96 ~ age * female, data = mental_health)

# generate predicted probabilities + confidence intervals
new_points <- expand.grid(
  age = seq(
    from = min(mental_health$age),
    to = max(mental_health$age)
  ),
  female = unique(mental_health$female)
)

bind_cols(
  new_points,
  # predicted probabilities
  predict(mh_int_mod, new_data = new_points, type = "prob"),
  # confidence intervals
  predict(mh_int_mod, new_data = new_points, type = "conf_int")
) %>%
  # graph the predictions
  ggplot(mapping = aes(x = age, y = .pred_Voted, color = female)) +
  # predicted probability
  geom_line(linetype = 2) +
  # confidence interval
  geom_ribbon(mapping = aes(ymin = .pred_lower_Voted, ymax = .pred_upper_Voted,
                            fill = female), alpha = .2) +
  scale_color_viridis_d(end = 0.7, aesthetics = c("color", "fill"),
                        name = NULL) +
  labs(title = "Relationship Between Age and Voter Turnout",
       x = "Age",
       y = "Predicted Probability of Voting")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/mh-model-all-1.png" width="672" />

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
##  date     2021-02-24                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version    date       lib source                              
##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports     1.2.1      2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown      1.1        2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown      0.21       2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom       * 0.7.3      2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr         3.5.1      2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger    1.1.0      2016-07-27 [1] CRAN (R 4.0.0)                      
##  class         7.3-17     2020-04-26 [1] CRAN (R 4.0.3)                      
##  cli           2.2.0      2020-11-20 [1] CRAN (R 4.0.2)                      
##  codetools     0.2-18     2020-11-04 [1] CRAN (R 4.0.2)                      
##  colorspace    2.0-0      2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon        1.3.4      2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI           1.1.0      2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr        2.0.0      2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc          1.2.0      2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools      2.3.2      2020-09-18 [1] CRAN (R 4.0.2)                      
##  dials       * 0.0.9      2020-09-16 [1] CRAN (R 4.0.2)                      
##  DiceDesign    1.8-1      2019-07-31 [1] CRAN (R 4.0.0)                      
##  digest        0.6.27     2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr       * 1.0.2      2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis      0.3.1      2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi         0.4.1      2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats     * 0.5.0      2020-03-01 [1] CRAN (R 4.0.0)                      
##  foreach       1.5.1      2020-10-15 [1] CRAN (R 4.0.2)                      
##  fs            1.5.0      2020-07-31 [1] CRAN (R 4.0.2)                      
##  furrr         0.2.1      2020-10-21 [1] CRAN (R 4.0.2)                      
##  future        1.21.0     2020-12-10 [1] CRAN (R 4.0.2)                      
##  generics      0.1.0      2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2     * 3.3.3      2020-12-30 [1] CRAN (R 4.0.2)                      
##  globals       0.14.0     2020-11-22 [1] CRAN (R 4.0.2)                      
##  glue          1.4.2      2020-08-27 [1] CRAN (R 4.0.2)                      
##  gower         0.2.2      2020-06-23 [1] CRAN (R 4.0.2)                      
##  GPfit         1.0-8      2019-02-08 [1] CRAN (R 4.0.0)                      
##  gtable        0.3.0      2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven         2.3.1      2020-06-01 [1] CRAN (R 4.0.0)                      
##  here          1.0.1      2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms           0.5.3      2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools     0.5.1.1    2021-01-22 [1] CRAN (R 4.0.2)                      
##  httr          1.4.2      2020-07-20 [1] CRAN (R 4.0.2)                      
##  infer       * 0.5.3      2020-07-14 [1] CRAN (R 4.0.2)                      
##  ipred         0.9-9      2019-04-28 [1] CRAN (R 4.0.0)                      
##  iterators     1.0.13     2020-10-15 [1] CRAN (R 4.0.2)                      
##  jsonlite      1.7.2      2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr         1.31       2021-01-27 [1] CRAN (R 4.0.2)                      
##  lattice       0.20-41    2020-04-02 [1] CRAN (R 4.0.3)                      
##  lava          1.6.8.1    2020-11-04 [1] CRAN (R 4.0.2)                      
##  lhs           1.1.1      2020-10-05 [1] CRAN (R 4.0.2)                      
##  lifecycle     0.2.0      2020-03-06 [1] CRAN (R 4.0.0)                      
##  listenv       0.8.0      2019-12-05 [1] CRAN (R 4.0.0)                      
##  lubridate     1.7.9.2    2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr      2.0.1      2020-11-17 [1] CRAN (R 4.0.2)                      
##  MASS          7.3-53     2020-09-09 [1] CRAN (R 4.0.3)                      
##  Matrix        1.3-0      2020-12-22 [1] CRAN (R 4.0.2)                      
##  memoise       1.1.0      2017-04-21 [1] CRAN (R 4.0.0)                      
##  modeldata   * 0.1.0      2020-10-22 [1] CRAN (R 4.0.2)                      
##  modelr        0.1.8      2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell       0.5.0      2018-06-12 [1] CRAN (R 4.0.0)                      
##  nnet          7.3-14     2020-04-26 [1] CRAN (R 4.0.3)                      
##  parallelly    1.22.0     2020-12-13 [1] CRAN (R 4.0.2)                      
##  parsnip     * 0.1.4      2020-10-27 [1] CRAN (R 4.0.2)                      
##  pillar        1.4.7      2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild      1.2.0      2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload       1.1.0      2020-05-29 [1] CRAN (R 4.0.0)                      
##  plyr          1.8.6      2020-03-03 [1] CRAN (R 4.0.0)                      
##  prettyunits   1.1.1      2020-01-24 [1] CRAN (R 4.0.0)                      
##  pROC          1.16.2     2020-03-19 [1] CRAN (R 4.0.0)                      
##  processx      3.4.5      2020-11-30 [1] CRAN (R 4.0.2)                      
##  prodlim       2019.11.13 2019-11-17 [1] CRAN (R 4.0.0)                      
##  ps            1.5.0      2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr       * 0.3.4      2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6            2.5.0      2020-10-28 [1] CRAN (R 4.0.2)                      
##  rcfss       * 0.2.1      2020-12-08 [1] local                               
##  Rcpp          1.0.6      2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr       * 1.4.0      2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl        1.3.1      2019-03-13 [1] CRAN (R 4.0.0)                      
##  recipes     * 0.1.15     2020-11-11 [1] CRAN (R 4.0.2)                      
##  remotes       2.2.0      2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex        1.0.0      2021-01-27 [1] CRAN (R 4.0.2)                      
##  rlang         0.4.10     2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown     2.6        2020-12-14 [1] CRAN (R 4.0.2)                      
##  rpart         4.1-15     2019-04-12 [1] CRAN (R 4.0.3)                      
##  rprojroot     2.0.2      2020-11-15 [1] CRAN (R 4.0.2)                      
##  rsample     * 0.0.8      2020-09-23 [1] CRAN (R 4.0.2)                      
##  rstudioapi    0.13       2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest         0.3.6      2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales      * 1.1.1      2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr     * 1.4.0      2019-02-10 [1] CRAN (R 4.0.0)                      
##  survival      3.2-7      2020-09-28 [1] CRAN (R 4.0.3)                      
##  testthat      3.0.1      2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble      * 3.0.4      2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidymodels  * 0.1.2      2020-11-22 [1] CRAN (R 4.0.2)                      
##  tidyr       * 1.1.2      2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect    1.1.0      2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse   * 1.3.0      2019-11-21 [1] CRAN (R 4.0.0)                      
##  timeDate      3043.102   2018-02-21 [1] CRAN (R 4.0.0)                      
##  tune        * 0.1.2      2020-11-17 [1] CRAN (R 4.0.2)                      
##  usethis       2.0.0      2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs         0.3.6      2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr         2.3.0      2020-09-22 [1] CRAN (R 4.0.2)                      
##  workflows   * 0.2.1      2020-10-08 [1] CRAN (R 4.0.2)                      
##  xfun          0.21       2021-02-10 [1] CRAN (R 4.0.2)                      
##  xml2          1.3.2      2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.0)                      
##  yardstick   * 0.0.7      2020-07-13 [1] CRAN (R 4.0.2)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
