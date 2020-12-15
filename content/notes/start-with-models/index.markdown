---
title: "Build a linear model"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 2
---




```r
library(tidymodels)
library(tidyverse)
library(rcfss)
library(rstanarm)
library(broom.mixed)

set.seed(123)
theme_set(theme_minimal())
```

## Introduction {#intro}

There are several different approaches to fitting a linear model in R.^[See [*Tidy Modeling with R*](https://www.tmwr.org/base-r.html) for an overview of how these approaches vary.] Here, we introduce `tidymodels` and demonstrate how to construct a basic linear regression model.

[`tidymodels`](https://www.tidymodels.org/) is a collection of packages for statistical modeling and machine learning using `tidyverse` principles. Given this emphasis, it pairs nicely with the tidy-centric approach we have covered so far for tasks such as data visualization, data wrangling, importation of data files, and publishing results.

`tidymodels` is still under active development and contains a range of packages and functions for many different aspects of statistical modeling. Here we demonstrate how to start with data for modeling, specify and train models using different engines using the [`parsnip` package](https://tidymodels.github.io/parsnip/), and understand why these functions are designed this way.

## `scorecard`

As in past exercises, let's use the `rcfss::scorecard` dataset which contains detailed information on all four-year colleges and universities in the United States. Here we will consider the average faculty salary to understand how it is influenced by factors such as the average annual total cost of attendance and whether the university is public, private nonprofit, or private for-profit.


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

```r
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

As a first step in modeling, it's always a good idea to plot the data: 


```r
ggplot(data = scorecard,
       mapping = aes(x = cost, 
           y = avgfacsal, 
           col = type)) + 
  geom_point(alpha = .3) + 
  geom_smooth(method = lm, se = FALSE) +
  scale_color_viridis_d(option = "plasma", end = .7)
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## Warning: Removed 52 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 52 rows containing missing values (geom_point).
```

<img src="/notes/start-with-models_files/figure-html/scorecard-plot-1.png" width="672" />

We can see that public and private non-profit schools have the strongest correlation between total cost of attendance and average faculty salaries -- private for-profit schools tend to be pretty flat in terms of average salaries regardless of cost of attendance. 

## Build and fit a model {#build-model}

A standard two-way analysis of variance ([ANOVA](https://www.itl.nist.gov/div898/handbook/prc/section4/prc43.htm)) model makes sense for this dataset because we have both a continuous predictor and a categorical predictor. Since the slopes appear to be different for at least two of the college types, let's build a model that allows for two-way interactions. Specifying an R formula with our variables in this way: 


```r
avgfacsal ~ cost * type
```

allows our regression model depending on cost to have separate slopes and intercepts for each type of college. 

For this kind of model, ordinary least squares is a good initial approach. With `tidymodels`, we start by specifying the _functional form_ of the model that we want using the [`parsnip` package](https://tidymodels.github.io/parsnip/). Since there is a numeric outcome and the model should be linear with slopes and intercepts, the model type is ["linear regression"](https://tidymodels.github.io/parsnip/reference/linear_reg.html). We can declare this with: 



```r
linear_reg()
```

```
## Linear Regression Model Specification (regression)
```

That is pretty underwhelming since, on its own, it doesn't really do much. However, now that the type of model has been specified, a method for _fitting_ or training the model can be stated using the **engine**. The engine value is often a mash-up of the software that can be used to fit or train the model as well as the estimation method. For example, to use ordinary least squares, we can set the engine to be `lm`:


```r
linear_reg() %>% 
  set_engine("lm")
```

```
## Linear Regression Model Specification (regression)
## 
## Computational engine: lm
```

The [documentation page for `linear_reg()`](https://tidymodels.github.io/parsnip/reference/linear_reg.html) lists the possible engines. We'll save this model object as `lm_mod`.


```r
lm_mod <- linear_reg() %>% 
  set_engine("lm")
```

From here, the model can be estimated or trained using the [`fit()`](https://tidymodels.github.io/parsnip/reference/fit.html) function:


```r
lm_fit <- lm_mod %>% 
  fit(avgfacsal ~ cost * type, data = scorecard)
lm_fit
```

```
## parsnip model object
## 
## Fit time:  4ms 
## 
## Call:
## stats::lm(formula = avgfacsal ~ cost * type, data = data)
## 
## Coefficients:
##                  (Intercept)                          cost  
##                    3.697e+04                     1.964e+00  
##       typePrivate, nonprofit       typePrivate, for-profit  
##                   -2.490e+04                     9.261e+03  
##  cost:typePrivate, nonprofit  cost:typePrivate, for-profit  
##                   -6.327e-01                    -1.611e+00
```

Perhaps our analysis requires a description of the model parameter estimates and their statistical properties. Although the `summary()` function for `lm` objects can provide that, it gives the results back in an unwieldy format. Many models have a `tidy()` method that provides the summary results in a more predictable and useful format (e.g. a data frame with standard column names): 


```r
tidy(lm_fit)
```

```
## # A tibble: 6 x 5
##   term                           estimate std.error statistic  p.value
##   <chr>                             <dbl>     <dbl>     <dbl>    <dbl>
## 1 (Intercept)                   36969.     3211.        11.5  1.42e-29
## 2 cost                              1.96      0.149     13.2  8.72e-38
## 3 typePrivate, nonprofit       -24905.     3572.        -6.97 4.48e-12
## 4 typePrivate, for-profit        9261.     8317.         1.11 2.66e- 1
## 5 cost:typePrivate, nonprofit      -0.633     0.153     -4.13 3.86e- 5
## 6 cost:typePrivate, for-profit     -1.61      0.278     -5.79 8.49e- 9
```

## Use a model to predict {#predict-model}

This fitted object `lm_fit` has the `lm` model output built-in, which you can access with `lm_fit$fit`, but there are some benefits to using the fitted parsnip model object when it comes to predicting.

Suppose that, for a publication, it would be particularly interesting to make a plot of the expected average faculty salary for colleges with a total cost of attendance of $20,000. To create such a graph, we start with some new example data that we will make predictions for, to show in our graph:


```r
new_points <- expand.grid(
  cost = 20000, 
  type = c("Public", "Private, nonprofit", "Private, for-profit")
)
new_points
```

```
##    cost                type
## 1 20000              Public
## 2 20000  Private, nonprofit
## 3 20000 Private, for-profit
```

To get our predicted results, we can use the `predict()` function to find the expected salaries at $20,000 cost of attendance. 

It is also important to communicate the variability, so we also need to find the predicted confidence intervals. If we had used `lm()` to fit the model directly, a few minutes of reading the [documentation page](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html) for `predict.lm()` would explain how to do this. However, if we decide to use a different model to estimate average faculty salaries (_spoiler:_ we will!), it is likely that a completely different syntax would be required. 

Instead, with `tidymodels`, the types of predicted values are standardized so that we can use the same syntax to get these values. 

First, let's generate the expected salary values: 


```r
mean_pred <- predict(lm_fit, new_data = new_points)
mean_pred
```

```
## # A tibble: 3 x 1
##    .pred
##    <dbl>
## 1 76254.
## 2 38695.
## 3 53301.
```

When making predictions, the `tidymodels` convention is to always produce a tibble of results with standardized column names. This makes it easy to combine the original data and the predictions in a usable format: 


```r
conf_int_pred <- predict(lm_fit,
  new_data = new_points,
  type = "conf_int"
)
conf_int_pred
```

```
## # A tibble: 3 x 2
##   .pred_lower .pred_upper
##         <dbl>       <dbl>
## 1      74884.      77624.
## 2      36902.      40488.
## 3      46788.      59815.
```

```r
# Now combine
plot_data <- new_points %>%
  bind_cols(mean_pred) %>%
  bind_cols(conf_int_pred)

# And plot
ggplot(data = plot_data, mapping = aes(x = type)) +
  geom_point(mapping = aes(y = .pred)) +
  geom_errorbar(
    mapping = aes(
      ymin = .pred_lower,
      ymax = .pred_upper
    ),
    width = .2
  ) +
  labs(y = "Expected average faculty salary")
```

<img src="/notes/start-with-models_files/figure-html/lm-all-pred-1.png" width="672" />

## Model with a different engine {#new-engine}

Every one on your team is happy with that plot _except_ that one person who just read their first book on [Bayesian analysis](https://bayesian.org/what-is-bayesian-analysis/). They are interested in knowing if the results would be different if the model were estimated using a Bayesian approach. In such an analysis, a [_prior distribution_](https://towardsdatascience.com/introduction-to-bayesian-linear-regression-e66e60791ea7) needs to be declared for each model parameter that represents the possible values of the parameters (before being exposed to the observed data). After some discussion, the group agrees that the priors should be bell-shaped but, since no one has any idea what the range of values should be, to take a conservative approach and make the priors _wide_ using a Cauchy distribution (which is the same as a t-distribution with a single degree of freedom).

The [documentation](https://mc-stan.org/rstanarm/articles/priors.html) on the `rstanarm` package shows us that the `stan_glm()` function can be used to estimate this model, and that the function arguments that need to be specified are called `prior` and `prior_intercept`. It turns out that `linear_reg()` has a [`stan` engine](https://tidymodels.github.io/parsnip/reference/linear_reg.html#details). Since these prior distribution arguments are specific to the Stan software, they are passed as arguments to [`parsnip::set_engine()`](https://tidymodels.github.io/parsnip/reference/set_engine.html). After that, the same exact `fit()` call is used:


```r
# set the prior distribution
prior_dist <- rstanarm::student_t(df = 1)

set.seed(123)

# make the parsnip model
bayes_mod <- linear_reg() %>% 
  set_engine("stan", 
             prior_intercept = prior_dist, 
             prior = prior_dist,
             # increase number of iterations to converge to stable solution
             iter = 4000) 

# train the model
bayes_fit <- bayes_mod %>% 
  fit(avgfacsal ~ cost * type, data = scorecard)

print(bayes_fit, digits = 5)
```

```
## parsnip model object
## 
## Fit time:  16.5s 
## stan_glm
##  family:       gaussian [identity]
##  formula:      avgfacsal ~ cost * type
##  observations: 1681
##  predictors:   6
## ------
##                              Median       MAD_SD      
## (Intercept)                   36750.20927   2902.55453
## cost                              1.97283      0.13628
## typePrivate, nonprofit       -24158.29954   3401.79232
## typePrivate, for-profit           0.00398      3.63590
## cost:typePrivate, nonprofit      -0.65329      0.14175
## cost:typePrivate, for-profit     -1.33632      0.07838
## 
## Auxiliary parameter(s):
##       Median      MAD_SD     
## sigma 15926.06779   276.24491
## 
## ------
## * For help interpreting the printed output see ?print.stanreg
## * For info on the priors used see ?prior_summary.stanreg
```

{{% callout note %}}

This kind of Bayesian analysis (like many models) involves randomly generated numbers in its fitting procedure. We can use `set.seed()` to ensure that the same (pseudo-)random numbers are generated each time we run this code. The number `123` isn't special or related to our data; it is just a "seed" used to choose random numbers.

{{% /callout %}}

To update the parameter table, the `tidy()` method is once again used: 


```r
tidy(bayes_fit, conf.int = TRUE)
```

```
## # A tibble: 6 x 5
##   term                             estimate std.error   conf.low  conf.high
##   <chr>                               <dbl>     <dbl>      <dbl>      <dbl>
## 1 (Intercept)                   36750.      2903.      31813.     41699.   
## 2 cost                              1.97       0.136       1.74       2.21 
## 3 typePrivate, nonprofit       -24158.      3402.     -29835.    -18442.   
## 4 typePrivate, for-profit           0.00398    3.64      -15.9       14.3  
## 5 cost:typePrivate, nonprofit      -0.653      0.142      -0.895     -0.409
## 6 cost:typePrivate, for-profit     -1.34       0.0784     -1.47      -1.21
```

A goal of the `tidymodels` packages is that the **interfaces to common tasks are standardized** (as seen in the `tidy()` results above). The same is true for getting predictions; we can use the same code even though the underlying packages use very different syntax:


```r
bayes_plot_data <- new_points %>% 
  bind_cols(predict(bayes_fit, new_data = new_points)) %>% 
  bind_cols(predict(bayes_fit, new_data = new_points, type = "conf_int"))

ggplot(data = bayes_plot_data, mapping = aes(x = type)) +
  geom_point(mapping = aes(y = .pred)) +
  geom_errorbar(
    mapping = aes(
      ymin = .pred_lower,
      ymax = .pred_upper
    ),
    width = .2
  ) +
  labs(y = "Expected average faculty salary")
```

<img src="/notes/start-with-models_files/figure-html/stan-pred-1.png" width="672" />

This isn't very different from the non-Bayesian results (except in interpretation). 

{{% callout note %}}

The [`parsnip`](https://parsnip.tidymodels.org/) package can work with many model types, engines, and arguments. Check out [tidymodels.org/find/parsnip/](https://www.tidymodels.org/find/parsnip/) to see what is available.

{{% /callout %}}

## Why does it work that way? {#why}

The extra step of defining the model using a function like `linear_reg()` might seem superfluous since a call to `lm()` is much more succinct. However, the problem with standard modeling functions is that they don't separate what you want to do from the execution. For example, the process of executing a formula has to happen repeatedly across model calls even when the formula does not change; we can't recycle those computations. 

Also, using the `tidymodels` framework, we can do some interesting things by incrementally creating a model (instead of using single function call). [Model tuning](https://www.tidymodels.org/start/tuning/) with `tidymodels` uses the specification of the model to declare what parts of the model should be tuned. That would be very difficult to do if `linear_reg()` immediately fit the model. 

## Acknowledgments

Example drawn from [Get Started - Build a model](https://www.tidymodels.org/start/models/) and licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

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
##  date     2020-12-15                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version    date       lib source        
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 4.0.0)
##  backports      1.1.10     2020-09-15 [1] CRAN (R 4.0.2)
##  base64enc      0.1-3      2015-07-28 [1] CRAN (R 4.0.0)
##  bayesplot      1.7.2      2020-05-28 [1] CRAN (R 4.0.0)
##  blob           1.2.1      2020-01-20 [1] CRAN (R 4.0.0)
##  blogdown       0.21       2020-12-11 [1] local         
##  bookdown       0.21       2020-10-13 [1] CRAN (R 4.0.2)
##  boot           1.3-25     2020-04-26 [1] CRAN (R 4.0.2)
##  broom        * 0.7.1      2020-10-02 [1] CRAN (R 4.0.2)
##  broom.mixed  * 0.2.6      2020-05-17 [1] CRAN (R 4.0.2)
##  callr          3.5.1      2020-10-13 [1] CRAN (R 4.0.2)
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 4.0.0)
##  class          7.3-17     2020-04-26 [1] CRAN (R 4.0.2)
##  cli            2.1.0      2020-10-12 [1] CRAN (R 4.0.2)
##  coda           0.19-4     2020-09-30 [1] CRAN (R 4.0.2)
##  codetools      0.2-16     2018-12-24 [1] CRAN (R 4.0.2)
##  colorspace     1.4-1      2019-03-18 [1] CRAN (R 4.0.0)
##  colourpicker   1.1.0      2020-09-14 [1] CRAN (R 4.0.2)
##  crayon         1.3.4      2017-09-16 [1] CRAN (R 4.0.0)
##  crosstalk      1.1.0.1    2020-03-13 [1] CRAN (R 4.0.0)
##  curl           4.3        2019-12-02 [1] CRAN (R 4.0.0)
##  DBI            1.1.0      2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr         1.4.4      2020-05-27 [1] CRAN (R 4.0.0)
##  desc           1.2.0      2018-05-01 [1] CRAN (R 4.0.0)
##  devtools       2.3.2      2020-09-18 [1] CRAN (R 4.0.2)
##  dials        * 0.0.9      2020-09-16 [1] CRAN (R 4.0.2)
##  DiceDesign     1.8-1      2019-07-31 [1] CRAN (R 4.0.0)
##  digest         0.6.25     2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr        * 1.0.2      2020-08-18 [1] CRAN (R 4.0.2)
##  DT             0.15       2020-08-05 [1] CRAN (R 4.0.2)
##  dygraphs       1.1.1.6    2018-07-11 [1] CRAN (R 4.0.0)
##  ellipsis       0.3.1      2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate       0.14       2019-05-28 [1] CRAN (R 4.0.0)
##  fansi          0.4.1      2020-01-08 [1] CRAN (R 4.0.0)
##  fastmap        1.0.1      2019-10-08 [1] CRAN (R 4.0.0)
##  forcats      * 0.5.0      2020-03-01 [1] CRAN (R 4.0.0)
##  foreach        1.5.0      2020-03-30 [1] CRAN (R 4.0.0)
##  fs             1.5.0      2020-07-31 [1] CRAN (R 4.0.2)
##  furrr          0.2.0      2020-10-12 [1] CRAN (R 4.0.2)
##  future         1.19.1     2020-09-22 [1] CRAN (R 4.0.2)
##  generics       0.0.2      2018-11-29 [1] CRAN (R 4.0.0)
##  ggplot2      * 3.3.2      2020-06-19 [1] CRAN (R 4.0.2)
##  ggridges       0.5.2      2020-01-12 [1] CRAN (R 4.0.0)
##  globals        0.13.1     2020-10-11 [1] CRAN (R 4.0.2)
##  glue           1.4.2      2020-08-27 [1] CRAN (R 4.0.2)
##  gower          0.2.2      2020-06-23 [1] CRAN (R 4.0.2)
##  GPfit          1.0-8      2019-02-08 [1] CRAN (R 4.0.0)
##  gridExtra      2.3        2017-09-09 [1] CRAN (R 4.0.0)
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 4.0.0)
##  gtools         3.8.2      2020-03-31 [1] CRAN (R 4.0.0)
##  haven          2.3.1      2020-06-01 [1] CRAN (R 4.0.0)
##  here           0.1        2017-05-28 [1] CRAN (R 4.0.0)
##  hms            0.5.3      2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools      0.5.0      2020-06-16 [1] CRAN (R 4.0.2)
##  htmlwidgets    1.5.2      2020-10-03 [1] CRAN (R 4.0.2)
##  httpuv         1.5.4      2020-06-06 [1] CRAN (R 4.0.1)
##  httr           1.4.2      2020-07-20 [1] CRAN (R 4.0.2)
##  igraph         1.2.6      2020-10-06 [1] CRAN (R 4.0.2)
##  infer        * 0.5.3      2020-07-14 [1] CRAN (R 4.0.2)
##  inline         0.3.16     2020-09-06 [1] CRAN (R 4.0.2)
##  ipred          0.9-9      2019-04-28 [1] CRAN (R 4.0.0)
##  iterators      1.0.12     2019-07-26 [1] CRAN (R 4.0.0)
##  jsonlite       1.7.1      2020-09-07 [1] CRAN (R 4.0.2)
##  knitr          1.30       2020-09-22 [1] CRAN (R 4.0.2)
##  later          1.1.0.1    2020-06-05 [1] CRAN (R 4.0.1)
##  lattice        0.20-41    2020-04-02 [1] CRAN (R 4.0.2)
##  lava           1.6.8      2020-09-26 [1] CRAN (R 4.0.2)
##  lhs            1.1.1      2020-10-05 [1] CRAN (R 4.0.2)
##  lifecycle      0.2.0      2020-03-06 [1] CRAN (R 4.0.0)
##  listenv        0.8.0      2019-12-05 [1] CRAN (R 4.0.0)
##  lme4           1.1-23     2020-04-07 [1] CRAN (R 4.0.0)
##  loo            2.3.1      2020-07-14 [1] CRAN (R 4.0.2)
##  lubridate      1.7.9      2020-06-08 [1] CRAN (R 4.0.2)
##  magrittr       1.5        2014-11-22 [1] CRAN (R 4.0.0)
##  markdown       1.1        2019-08-07 [1] CRAN (R 4.0.0)
##  MASS           7.3-53     2020-09-09 [1] CRAN (R 4.0.2)
##  Matrix         1.2-18     2019-11-27 [1] CRAN (R 4.0.2)
##  matrixStats    0.57.0     2020-09-25 [1] CRAN (R 4.0.2)
##  memoise        1.1.0      2017-04-21 [1] CRAN (R 4.0.0)
##  mime           0.9        2020-02-04 [1] CRAN (R 4.0.0)
##  miniUI         0.1.1.1    2018-05-18 [1] CRAN (R 4.0.0)
##  minqa          1.2.4      2014-10-09 [1] CRAN (R 4.0.0)
##  modeldata    * 0.0.2      2020-06-22 [1] CRAN (R 4.0.2)
##  modelr         0.1.8      2020-05-19 [1] CRAN (R 4.0.0)
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 4.0.0)
##  nlme           3.1-149    2020-08-23 [1] CRAN (R 4.0.2)
##  nloptr         1.2.2.2    2020-07-02 [1] CRAN (R 4.0.2)
##  nnet           7.3-14     2020-04-26 [1] CRAN (R 4.0.2)
##  parsnip      * 0.1.3      2020-08-04 [1] CRAN (R 4.0.2)
##  pillar         1.4.6      2020-07-10 [1] CRAN (R 4.0.1)
##  pkgbuild       1.1.0      2020-07-13 [1] CRAN (R 4.0.2)
##  pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload        1.1.0      2020-05-29 [1] CRAN (R 4.0.0)
##  plyr           1.8.6      2020-03-03 [1] CRAN (R 4.0.0)
##  prettyunits    1.1.1      2020-01-24 [1] CRAN (R 4.0.0)
##  pROC           1.16.2     2020-03-19 [1] CRAN (R 4.0.0)
##  processx       3.4.4      2020-09-03 [1] CRAN (R 4.0.2)
##  prodlim        2019.11.13 2019-11-17 [1] CRAN (R 4.0.0)
##  promises       1.1.1      2020-06-09 [1] CRAN (R 4.0.2)
##  ps             1.4.0      2020-10-07 [1] CRAN (R 4.0.2)
##  purrr        * 0.3.4      2020-04-17 [1] CRAN (R 4.0.0)
##  R6             2.4.1      2019-11-12 [1] CRAN (R 4.0.0)
##  rcfss        * 0.2.1      2020-12-08 [1] local         
##  Rcpp         * 1.0.5      2020-07-06 [1] CRAN (R 4.0.2)
##  RcppParallel   5.0.2      2020-06-24 [1] CRAN (R 4.0.2)
##  readr        * 1.4.0      2020-10-05 [1] CRAN (R 4.0.2)
##  readxl         1.3.1      2019-03-13 [1] CRAN (R 4.0.0)
##  recipes      * 0.1.13     2020-06-23 [1] CRAN (R 4.0.2)
##  remotes        2.2.0      2020-07-21 [1] CRAN (R 4.0.2)
##  reprex         0.3.0      2019-05-16 [1] CRAN (R 4.0.0)
##  reshape2       1.4.4      2020-04-09 [1] CRAN (R 4.0.0)
##  rlang          0.4.8      2020-10-08 [1] CRAN (R 4.0.2)
##  rmarkdown      2.4        2020-09-30 [1] CRAN (R 4.0.2)
##  rpart          4.1-15     2019-04-12 [1] CRAN (R 4.0.2)
##  rprojroot      1.3-2      2018-01-03 [1] CRAN (R 4.0.0)
##  rsample      * 0.0.8      2020-09-23 [1] CRAN (R 4.0.2)
##  rsconnect      0.8.16     2019-12-13 [1] CRAN (R 4.0.0)
##  rstan          2.21.1     2020-07-08 [1] CRAN (R 4.0.2)
##  rstanarm     * 2.21.1     2020-07-20 [1] CRAN (R 4.0.2)
##  rstantools     2.1.1      2020-07-06 [1] CRAN (R 4.0.2)
##  rstudioapi     0.11       2020-02-07 [1] CRAN (R 4.0.0)
##  rvest          0.3.6      2020-07-25 [1] CRAN (R 4.0.2)
##  scales       * 1.1.1      2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 4.0.0)
##  shiny          1.5.0      2020-06-23 [1] CRAN (R 4.0.2)
##  shinyjs        2.0.0      2020-09-09 [1] CRAN (R 4.0.2)
##  shinystan      2.5.0      2018-05-01 [1] CRAN (R 4.0.0)
##  shinythemes    1.1.2      2018-11-06 [1] CRAN (R 4.0.0)
##  StanHeaders    2.21.0-6   2020-08-16 [1] CRAN (R 4.0.2)
##  statmod        1.4.34     2020-02-17 [1] CRAN (R 4.0.0)
##  stringi        1.5.3      2020-09-09 [1] CRAN (R 4.0.2)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 4.0.0)
##  survival       3.2-7      2020-09-28 [1] CRAN (R 4.0.2)
##  testthat       2.3.2      2020-03-02 [1] CRAN (R 4.0.0)
##  threejs        0.3.3      2020-01-21 [1] CRAN (R 4.0.0)
##  tibble       * 3.0.3      2020-07-10 [1] CRAN (R 4.0.2)
##  tidymodels   * 0.1.1      2020-07-14 [1] CRAN (R 4.0.2)
##  tidyr        * 1.1.2      2020-08-27 [1] CRAN (R 4.0.2)
##  tidyselect     1.1.0      2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse    * 1.3.0      2019-11-21 [1] CRAN (R 4.0.0)
##  timeDate       3043.102   2018-02-21 [1] CRAN (R 4.0.0)
##  TMB            1.7.18     2020-07-27 [1] CRAN (R 4.0.2)
##  tune         * 0.1.1      2020-07-08 [1] CRAN (R 4.0.2)
##  usethis        1.6.3      2020-09-17 [1] CRAN (R 4.0.2)
##  V8             3.2.0      2020-06-19 [1] CRAN (R 4.0.2)
##  vctrs          0.3.4      2020-08-29 [1] CRAN (R 4.0.2)
##  withr          2.3.0      2020-09-22 [1] CRAN (R 4.0.2)
##  workflows    * 0.2.1      2020-10-08 [1] CRAN (R 4.0.2)
##  xfun           0.18       2020-09-29 [1] CRAN (R 4.0.2)
##  xml2           1.3.2      2020-04-23 [1] CRAN (R 4.0.0)
##  xtable         1.8-4      2019-04-21 [1] CRAN (R 4.0.0)
##  xts            0.12.1     2020-09-09 [1] CRAN (R 4.0.2)
##  yaml           2.2.1      2020-02-01 [1] CRAN (R 4.0.0)
##  yardstick    * 0.0.7      2020-07-13 [1] CRAN (R 4.0.2)
##  zoo            1.8-8      2020-05-02 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
