---
title: "Working with statistical models"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 4
---




```r
library(tidyverse)
library(tidymodels)
library(rcfss)

set.seed(123)

theme_set(theme_minimal())
```

{{% alert note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/statistical-learning")
```

{{% /alert %}}

## Exercise: linear regression with `scorecard`

Recall the `scorecard` data set which contains information on U.S. institutions of higher learning.


```r
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

Answer the following questions using the statistical modeling tools you have learned.

1. What is the relationship between admission rate and cost? Report this relationship using a scatterplot and a linear best-fit line.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    ggplot(scorecard, aes(admrate, cost)) +
      geom_point() +
      geom_smooth(method = "lm")
    ```
    
    <img src="/notes/work-with-models-exercise_files/figure-html/scorecard-point-1.png" width="672" />
    
      </p>
    </details>

1. Estimate a linear regression of the relationship between admission rate and cost, and report your results in a tidy table.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
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
    ## 1 (Intercept)   47723.     1187.      40.2 2.08e-248
    ## 2 admrate      -19972.     1714.     -11.7 3.06e- 30
    ```
    
      </p>
    </details>

1. Estimate a linear regression of the relationship between admission rate and cost, while also accounting for type of college and percent of Pell Grant recipients, and report your results in a tidy table.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
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
    ## 1 (Intercept)               44347.      925.      47.9 5.47e-317
    ## 2 admrate                  -10758.     1068.     -10.1 3.12e- 23
    ## 3 typePrivate, nonprofit    19205.      462.      41.6 1.24e-260
    ## 4 typePrivate, for-profit   18067.     1080.      16.7 3.40e- 58
    ## 5 pctpell                  -41725.     1322.     -31.6 3.11e-172
    ```
    
      </p>
    </details>

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

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
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
    
    <img src="/notes/work-with-models-exercise_files/figure-html/mh-model-1.png" width="672" />
    
      </p>
    </details>

1. Estimate a second logistic regression model of voter turnout using using age and gender (i.e. the `female` column). Extract predicted probabilities and confidence intervals for all possible values of age, and visualize using `ggplot()`.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
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
    
    <img src="/notes/work-with-models-exercise_files/figure-html/mh-model-all-1.png" width="672" />
    
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
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-11-06                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version    date       lib source        
##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.0)
##  backports     1.1.10     2020-09-15 [1] CRAN (R 4.0.2)
##  blob          1.2.1      2020-01-20 [1] CRAN (R 4.0.0)
##  blogdown      0.20.1     2020-10-19 [1] local         
##  bookdown      0.21       2020-10-13 [1] CRAN (R 4.0.2)
##  broom       * 0.7.1      2020-10-02 [1] CRAN (R 4.0.2)
##  callr         3.5.1      2020-10-13 [1] CRAN (R 4.0.2)
##  cellranger    1.1.0      2016-07-27 [1] CRAN (R 4.0.0)
##  class         7.3-17     2020-04-26 [1] CRAN (R 4.0.2)
##  cli           2.1.0      2020-10-12 [1] CRAN (R 4.0.2)
##  codetools     0.2-16     2018-12-24 [1] CRAN (R 4.0.2)
##  colorspace    1.4-1      2019-03-18 [1] CRAN (R 4.0.0)
##  crayon        1.3.4      2017-09-16 [1] CRAN (R 4.0.0)
##  DBI           1.1.0      2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr        1.4.4      2020-05-27 [1] CRAN (R 4.0.0)
##  desc          1.2.0      2018-05-01 [1] CRAN (R 4.0.0)
##  devtools      2.3.2      2020-09-18 [1] CRAN (R 4.0.2)
##  dials       * 0.0.9      2020-09-16 [1] CRAN (R 4.0.2)
##  DiceDesign    1.8-1      2019-07-31 [1] CRAN (R 4.0.0)
##  digest        0.6.25     2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr       * 1.0.2      2020-08-18 [1] CRAN (R 4.0.2)
##  ellipsis      0.3.1      2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.0)
##  fansi         0.4.1      2020-01-08 [1] CRAN (R 4.0.0)
##  forcats     * 0.5.0      2020-03-01 [1] CRAN (R 4.0.0)
##  foreach       1.5.0      2020-03-30 [1] CRAN (R 4.0.0)
##  fs            1.5.0      2020-07-31 [1] CRAN (R 4.0.2)
##  furrr         0.2.0      2020-10-12 [1] CRAN (R 4.0.2)
##  future        1.19.1     2020-09-22 [1] CRAN (R 4.0.2)
##  generics      0.0.2      2018-11-29 [1] CRAN (R 4.0.0)
##  ggplot2     * 3.3.2      2020-06-19 [1] CRAN (R 4.0.2)
##  globals       0.13.1     2020-10-11 [1] CRAN (R 4.0.2)
##  glue          1.4.2      2020-08-27 [1] CRAN (R 4.0.2)
##  gower         0.2.2      2020-06-23 [1] CRAN (R 4.0.2)
##  GPfit         1.0-8      2019-02-08 [1] CRAN (R 4.0.0)
##  gtable        0.3.0      2019-03-25 [1] CRAN (R 4.0.0)
##  haven         2.3.1      2020-06-01 [1] CRAN (R 4.0.0)
##  here          0.1        2017-05-28 [1] CRAN (R 4.0.0)
##  hms           0.5.3      2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools     0.5.0      2020-06-16 [1] CRAN (R 4.0.2)
##  httr          1.4.2      2020-07-20 [1] CRAN (R 4.0.2)
##  infer       * 0.5.3      2020-07-14 [1] CRAN (R 4.0.2)
##  ipred         0.9-9      2019-04-28 [1] CRAN (R 4.0.0)
##  iterators     1.0.12     2019-07-26 [1] CRAN (R 4.0.0)
##  jsonlite      1.7.1      2020-09-07 [1] CRAN (R 4.0.2)
##  knitr         1.30       2020-09-22 [1] CRAN (R 4.0.2)
##  lattice       0.20-41    2020-04-02 [1] CRAN (R 4.0.2)
##  lava          1.6.8      2020-09-26 [1] CRAN (R 4.0.2)
##  lhs           1.1.1      2020-10-05 [1] CRAN (R 4.0.2)
##  lifecycle     0.2.0      2020-03-06 [1] CRAN (R 4.0.0)
##  listenv       0.8.0      2019-12-05 [1] CRAN (R 4.0.0)
##  lubridate     1.7.9      2020-06-08 [1] CRAN (R 4.0.2)
##  magrittr      1.5        2014-11-22 [1] CRAN (R 4.0.0)
##  MASS          7.3-53     2020-09-09 [1] CRAN (R 4.0.2)
##  Matrix        1.2-18     2019-11-27 [1] CRAN (R 4.0.2)
##  memoise       1.1.0      2017-04-21 [1] CRAN (R 4.0.0)
##  modeldata   * 0.0.2      2020-06-22 [1] CRAN (R 4.0.2)
##  modelr        0.1.8      2020-05-19 [1] CRAN (R 4.0.0)
##  munsell       0.5.0      2018-06-12 [1] CRAN (R 4.0.0)
##  nnet          7.3-14     2020-04-26 [1] CRAN (R 4.0.2)
##  parsnip     * 0.1.3      2020-08-04 [1] CRAN (R 4.0.2)
##  pillar        1.4.6      2020-07-10 [1] CRAN (R 4.0.1)
##  pkgbuild      1.1.0      2020-07-13 [1] CRAN (R 4.0.2)
##  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload       1.1.0      2020-05-29 [1] CRAN (R 4.0.0)
##  plyr          1.8.6      2020-03-03 [1] CRAN (R 4.0.0)
##  prettyunits   1.1.1      2020-01-24 [1] CRAN (R 4.0.0)
##  pROC          1.16.2     2020-03-19 [1] CRAN (R 4.0.0)
##  processx      3.4.4      2020-09-03 [1] CRAN (R 4.0.2)
##  prodlim       2019.11.13 2019-11-17 [1] CRAN (R 4.0.0)
##  ps            1.4.0      2020-10-07 [1] CRAN (R 4.0.2)
##  purrr       * 0.3.4      2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.4.1      2019-11-12 [1] CRAN (R 4.0.0)
##  rcfss       * 0.2.1      2020-11-02 [1] local         
##  Rcpp          1.0.5      2020-07-06 [1] CRAN (R 4.0.2)
##  readr       * 1.4.0      2020-10-05 [1] CRAN (R 4.0.2)
##  readxl        1.3.1      2019-03-13 [1] CRAN (R 4.0.0)
##  recipes     * 0.1.13     2020-06-23 [1] CRAN (R 4.0.2)
##  remotes       2.2.0      2020-07-21 [1] CRAN (R 4.0.2)
##  reprex        0.3.0      2019-05-16 [1] CRAN (R 4.0.0)
##  rlang         0.4.8      2020-10-08 [1] CRAN (R 4.0.2)
##  rmarkdown     2.4        2020-09-30 [1] CRAN (R 4.0.2)
##  rpart         4.1-15     2019-04-12 [1] CRAN (R 4.0.2)
##  rprojroot     1.3-2      2018-01-03 [1] CRAN (R 4.0.0)
##  rsample     * 0.0.8      2020-09-23 [1] CRAN (R 4.0.2)
##  rstudioapi    0.11       2020-02-07 [1] CRAN (R 4.0.0)
##  rvest         0.3.6      2020-07-25 [1] CRAN (R 4.0.2)
##  scales      * 1.1.1      2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)
##  stringr     * 1.4.0      2019-02-10 [1] CRAN (R 4.0.0)
##  survival      3.2-7      2020-09-28 [1] CRAN (R 4.0.2)
##  testthat      2.3.2      2020-03-02 [1] CRAN (R 4.0.0)
##  tibble      * 3.0.3      2020-07-10 [1] CRAN (R 4.0.2)
##  tidymodels  * 0.1.1      2020-07-14 [1] CRAN (R 4.0.2)
##  tidyr       * 1.1.2      2020-08-27 [1] CRAN (R 4.0.2)
##  tidyselect    1.1.0      2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse   * 1.3.0      2019-11-21 [1] CRAN (R 4.0.0)
##  timeDate      3043.102   2018-02-21 [1] CRAN (R 4.0.0)
##  tune        * 0.1.1      2020-07-08 [1] CRAN (R 4.0.2)
##  usethis       1.6.3      2020-09-17 [1] CRAN (R 4.0.2)
##  vctrs         0.3.4      2020-08-29 [1] CRAN (R 4.0.2)
##  withr         2.3.0      2020-09-22 [1] CRAN (R 4.0.2)
##  workflows   * 0.2.1      2020-10-08 [1] CRAN (R 4.0.2)
##  xfun          0.18       2020-09-29 [1] CRAN (R 4.0.2)
##  xml2          1.3.2      2020-04-23 [1] CRAN (R 4.0.0)
##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.0)
##  yardstick   * 0.0.7      2020-07-13 [1] CRAN (R 4.0.2)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
