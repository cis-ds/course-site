---
title: "Linear regression"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/stat002_linear_models.html"]
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 2
---




```r
library(tidyverse)
library(modelr)
library(broom)
library(rcfss)
set.seed(1234)

theme_set(theme_minimal())
```

Linear models are the simplest statistical learning method to understand. They adopt a generic form

`$$y = \beta_0 + \beta_1 \times x$$`

where `\(y\)` is the **outcome of interest**, `\(x\)` is the **explanatory** or **predictor** variable, and `\(\beta_0\)` and `\(\beta_1\)` are **parameters** that vary to capture different patterns. Given the empirical values you have for `\(x\)` and `\(y\)`, you generate a **fitted model** that finds the values for the parameters that best fit the data.


```r
ggplot(sim1, aes(x, y)) + 
  geom_point()
```

<img src="/notes/linear-models_files/figure-html/sim-plot-1.png" width="672" />

This looks like a linear relationship. We could randomly generate parameters for the formula `\(y = \beta_0 + \beta_1 \times x\)` to try and explain or predict the relationship between `\(x\)` and `\(y\)`:


```r
models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
  geom_point()
```

<img src="/notes/linear-models_files/figure-html/sim-random-fit-1.png" width="672" />

But obviously some parameters are better than others. We need a definition that can be used to differentiate good parameters from bad parameters. One approach widely used is called **least squares** - it means that the overall solution minimizes the sum of the squares of the errors made in the results of every single equation. The errors are simply the vertical difference between the actual values for `\(y\)` and the predicted values for `\(y\)`.

<img src="/notes/linear-models_files/figure-html/sim-error-1.png" width="672" />

[R for Data Science](http://r4ds.had.co.nz/model-basics.html) walks you through the steps to perform all these calculations manually by writing your own functions. I encourage you to read through and practice some of this code, especially if you have no experience with linear models.

However for our purposes here I will assume you at least get the basics of this process. You can use `ggplot2` to draw the best-fit line:


```r
ggplot(sim1, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm")
```

<img src="/notes/linear-models_files/figure-html/sim-plot-lm-1.png" width="672" />

The line in blue is the best-fit line, with 95% confidence intervals in grey indicating a range of values so defined that there is a 95% probability that the true value of a parameter lies within it. If you want to learn more about the precise definition of confidence intervals and the debate over how useful they actually are, you should take a statistics class.

## Estimating a linear model using `lm()`

But drawing a picture is not always good enough. What if you want to know the actual values of the estimated parameters? To do that, we use the `lm()` function:


```r
sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)
```

```
## (Intercept)           x 
##    4.220822    2.051533
```

The `lm()` function takes two parameters. The first is a *formula* specifying the equation to be estimated (`lm()` translates `y ~ x` into `\(y = \beta_0 + \beta_1 \times x\)`). The second is of course the data frame containing the variables.

Note that we have now begun to leave the `tidyverse` universe. `lm()` is part of the base R program, and the result of `lm()` is decidedly **not tidy**.


```r
str(sim1_mod)
```

```
## List of 12
##  $ coefficients : Named num [1:2] 4.22 2.05
##   ..- attr(*, "names")= chr [1:2] "(Intercept)" "x"
##  $ residuals    : Named num [1:30] -2.072 1.238 -4.147 0.665 1.919 ...
##   ..- attr(*, "names")= chr [1:30] "1" "2" "3" "4" ...
##  $ effects      : Named num [1:30] -84.92 32.275 -4.13 0.761 2.015 ...
##   ..- attr(*, "names")= chr [1:30] "(Intercept)" "x" "" "" ...
##  $ rank         : int 2
##  $ fitted.values: Named num [1:30] 6.27 6.27 6.27 8.32 8.32 ...
##   ..- attr(*, "names")= chr [1:30] "1" "2" "3" "4" ...
##  $ assign       : int [1:2] 0 1
##  $ qr           :List of 5
##   ..$ qr   : num [1:30, 1:2] -5.477 0.183 0.183 0.183 0.183 ...
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:30] "1" "2" "3" "4" ...
##   .. .. ..$ : chr [1:2] "(Intercept)" "x"
##   .. ..- attr(*, "assign")= int [1:2] 0 1
##   ..$ qraux: num [1:2] 1.18 1.24
##   ..$ pivot: int [1:2] 1 2
##   ..$ tol  : num 1e-07
##   ..$ rank : int 2
##   ..- attr(*, "class")= chr "qr"
##  $ df.residual  : int 28
##  $ xlevels      : Named list()
##  $ call         : language lm(formula = y ~ x, data = sim1)
##  $ terms        :Classes 'terms', 'formula'  language y ~ x
##   .. ..- attr(*, "variables")= language list(y, x)
##   .. ..- attr(*, "factors")= int [1:2, 1] 0 1
##   .. .. ..- attr(*, "dimnames")=List of 2
##   .. .. .. ..$ : chr [1:2] "y" "x"
##   .. .. .. ..$ : chr "x"
##   .. ..- attr(*, "term.labels")= chr "x"
##   .. ..- attr(*, "order")= int 1
##   .. ..- attr(*, "intercept")= int 1
##   .. ..- attr(*, "response")= int 1
##   .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. ..- attr(*, "predvars")= language list(y, x)
##   .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
##   .. .. ..- attr(*, "names")= chr [1:2] "y" "x"
##  $ model        :'data.frame':	30 obs. of  2 variables:
##   ..$ y: num [1:30] 4.2 7.51 2.13 8.99 10.24 ...
##   ..$ x: int [1:30] 1 1 1 2 2 2 3 3 3 4 ...
##   ..- attr(*, "terms")=Classes 'terms', 'formula'  language y ~ x
##   .. .. ..- attr(*, "variables")= language list(y, x)
##   .. .. ..- attr(*, "factors")= int [1:2, 1] 0 1
##   .. .. .. ..- attr(*, "dimnames")=List of 2
##   .. .. .. .. ..$ : chr [1:2] "y" "x"
##   .. .. .. .. ..$ : chr "x"
##   .. .. ..- attr(*, "term.labels")= chr "x"
##   .. .. ..- attr(*, "order")= int 1
##   .. .. ..- attr(*, "intercept")= int 1
##   .. .. ..- attr(*, "response")= int 1
##   .. .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. .. ..- attr(*, "predvars")= language list(y, x)
##   .. .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
##   .. .. .. ..- attr(*, "names")= chr [1:2] "y" "x"
##  - attr(*, "class")= chr "lm"
```

The result is stored in a complex list that contains a lot of important information, some of which you may recognize but most of it you do not. Here I will show you tools for extracting useful information from `lm()`.

## Generating predicted values

We can use `sim1_mod` to generate **predicted values**, or the expected value for `\(Y\)` given our knowledge of hypothetical observations with values for `\(X\)`, based on the estimated parameters using `modelr::data_grid()` and `broom::augment()`.^[`package::function()` notation. So `data_grid()` can be found in the `modelr` package, while `augment()` is in `broom`.] `data_grid()` generates an evenly spaced grid of data points covering the region where observed data lies. The first argument is a data frame, and subsequent arguments identify unique columns and generates all possible combinations.


```r
grid <- sim1 %>% 
  data_grid(x) 
grid
```

```
## # A tibble: 10 x 1
##        x
##    <int>
##  1     1
##  2     2
##  3     3
##  4     4
##  5     5
##  6     6
##  7     7
##  8     8
##  9     9
## 10    10
```

`augment()` takes a model object and a data frame, and uses the model to generate predictions for each observation in the data frame.^[Far more detail about `augment()` and the other core `broom` functions coming shortly.]


```r
grid <- augment(sim1_mod, newdata = grid)
grid
```

```
## # A tibble: 10 x 3
##        x .fitted .se.fit
##    <int>   <dbl>   <dbl>
##  1     1    6.27   0.748
##  2     2    8.32   0.634
##  3     3   10.4    0.533
##  4     4   12.4    0.454
##  5     5   14.5    0.408
##  6     6   16.5    0.408
##  7     7   18.6    0.454
##  8     8   20.6    0.533
##  9     9   22.7    0.634
## 10    10   24.7    0.748
```

Using this information, we can draw the best-fit line without using `geom_smooth()`, and instead build it directly from the predicted values.


```r
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = .fitted), data = grid, color = "red", size = 1) +
  geom_point(aes(y = .fitted), data = grid, color = "blue", size = 3)
```

<img src="/notes/linear-models_files/figure-html/plot-lm-predict-1.png" width="672" />

This looks like the line from before, but without the confidence interval. This is a bit more involved of a process, but it can work with any type of model you create - not just very basic, linear models.

## Residuals

We can also calculate the **residuals**, or that distance between the actual and predicted values of `\(y\)`. To do that, we again use `augment()` but do not input a new data frame:


```r
sim1_resid <- augment(sim1_mod)
sim1_resid
```

```
## # A tibble: 30 x 9
##        y     x .fitted .se.fit   .resid   .hat .sigma    .cooksd .std.resid
##    <dbl> <int>   <dbl>   <dbl>    <dbl>  <dbl>  <dbl>      <dbl>      <dbl>
##  1  4.20     1    6.27   0.748 -2.07    0.115    2.20    6.51e-2   -1.00   
##  2  7.51     1    6.27   0.748  1.24    0.115    2.23    2.32e-2    0.598  
##  3  2.13     1    6.27   0.748 -4.15    0.115    2.08    2.61e-1   -2.00   
##  4  8.99     2    8.32   0.634  0.665   0.0828   2.24    4.49e-3    0.315  
##  5 10.2      2    8.32   0.634  1.92    0.0828   2.21    3.74e-2    0.910  
##  6 11.3      2    8.32   0.634  2.97    0.0828   2.16    8.97e-2    1.41   
##  7  7.36     3   10.4    0.533 -3.02    0.0586   2.16    6.21e-2   -1.41   
##  8 10.5      3   10.4    0.533  0.130   0.0586   2.24    1.15e-4    0.0608 
##  9 10.5      3   10.4    0.533  0.136   0.0586   2.24    1.26e-4    0.0637 
## 10 12.4      4   12.4    0.454  0.00763 0.0424   2.24    2.78e-7    0.00354
## # … with 20 more rows
```

```r
ggplot(sim1_resid, aes(.resid)) + 
  geom_freqpoly(binwidth = 0.5)
```

<img src="/notes/linear-models_files/figure-html/resids-1.png" width="672" />

Reviewing your residuals can be helpful. Sometimes your model is better at predicting some types of observations better than others. This could help you isolate further patterns and improve the predictive accuracy of your model.

## Estimating a linear model(s) using `gapminder`

## Overall model

Recall the `gapminder` dataset, which includes measures of life expectancy over time for all countries in the world.


```r
library(gapminder)
gapminder
```

```
## # A tibble: 1,704 x 6
##    country     continent  year lifeExp      pop gdpPercap
##    <fct>       <fct>     <int>   <dbl>    <int>     <dbl>
##  1 Afghanistan Asia       1952    28.8  8425333      779.
##  2 Afghanistan Asia       1957    30.3  9240934      821.
##  3 Afghanistan Asia       1962    32.0 10267083      853.
##  4 Afghanistan Asia       1967    34.0 11537966      836.
##  5 Afghanistan Asia       1972    36.1 13079460      740.
##  6 Afghanistan Asia       1977    38.4 14880372      786.
##  7 Afghanistan Asia       1982    39.9 12881816      978.
##  8 Afghanistan Asia       1987    40.8 13867957      852.
##  9 Afghanistan Asia       1992    41.7 16317921      649.
## 10 Afghanistan Asia       1997    41.8 22227415      635.
## # … with 1,694 more rows
```

Let's say we want to try and understand how life expectancy changes over time. We could visualize the data using a line graph:


```r
gapminder %>% 
  ggplot(aes(year, lifeExp, group = country)) +
    geom_line(alpha = 1/3)
```

<img src="/notes/linear-models_files/figure-html/lifeExp-by-country-1.png" width="672" />

But this is incredibly noise. Why not estimate a simple linear model that summarizes this trend?


```r
gapminder_mod <- lm(lifeExp ~ year, data = gapminder)
summary(gapminder_mod)
```

```
## 
## Call:
## lm(formula = lifeExp ~ year, data = gapminder)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -39.949  -9.651   1.697  10.335  22.158 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -585.65219   32.31396  -18.12   <2e-16 ***
## year           0.32590    0.01632   19.96   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 11.63 on 1702 degrees of freedom
## Multiple R-squared:  0.1898,	Adjusted R-squared:  0.1893 
## F-statistic: 398.6 on 1 and 1702 DF,  p-value: < 2.2e-16
```

```r
grid <- gapminder %>% 
  data_grid(year, country) 
grid
```

```
## # A tibble: 1,704 x 2
##     year country    
##    <int> <fct>      
##  1  1952 Afghanistan
##  2  1952 Albania    
##  3  1952 Algeria    
##  4  1952 Angola     
##  5  1952 Argentina  
##  6  1952 Australia  
##  7  1952 Austria    
##  8  1952 Bahrain    
##  9  1952 Bangladesh 
## 10  1952 Belgium    
## # … with 1,694 more rows
```

```r
grid <- augment(gapminder_mod, newdata = grid) 
grid
```

```
## # A tibble: 1,704 x 4
##     year country     .fitted .se.fit
##    <int> <fct>         <dbl>   <dbl>
##  1  1952 Afghanistan    50.5   0.530
##  2  1952 Albania        50.5   0.530
##  3  1952 Algeria        50.5   0.530
##  4  1952 Angola         50.5   0.530
##  5  1952 Argentina      50.5   0.530
##  6  1952 Australia      50.5   0.530
##  7  1952 Austria        50.5   0.530
##  8  1952 Bahrain        50.5   0.530
##  9  1952 Bangladesh     50.5   0.530
## 10  1952 Belgium        50.5   0.530
## # … with 1,694 more rows
```

```r
ggplot(gapminder, aes(year, group = country)) +
  geom_line(aes(y = lifeExp), alpha = .2) +
  geom_line(aes(y = .fitted), data = grid, color = "red", size = 1)
```

<img src="/notes/linear-models_files/figure-html/lifeExp-mod-1.png" width="672" />

So it appears that there is a positive trend - that is, over time life expectancy is rising. But we can also see a lot of variation in that trend - some countries are doing much better than others. We'll come back to that in a bit.

## Extracting model statistics

Model objects are not very pretty in R. Recall the complicated data structure I mentioned above:


```r
str(gapminder_mod)
```

```
## List of 12
##  $ coefficients : Named num [1:2] -585.652 0.326
##   ..- attr(*, "names")= chr [1:2] "(Intercept)" "year"
##  $ residuals    : Named num [1:1704] -21.7 -21.8 -21.8 -21.4 -20.9 ...
##   ..- attr(*, "names")= chr [1:1704] "1" "2" "3" "4" ...
##  $ effects      : Named num [1:1704] -2455.1 232.2 -20.8 -20.5 -20.2 ...
##   ..- attr(*, "names")= chr [1:1704] "(Intercept)" "year" "" "" ...
##  $ rank         : int 2
##  $ fitted.values: Named num [1:1704] 50.5 52.1 53.8 55.4 57 ...
##   ..- attr(*, "names")= chr [1:1704] "1" "2" "3" "4" ...
##  $ assign       : int [1:2] 0 1
##  $ qr           :List of 5
##   ..$ qr   : num [1:1704, 1:2] -41.2795 0.0242 0.0242 0.0242 0.0242 ...
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:1704] "1" "2" "3" "4" ...
##   .. .. ..$ : chr [1:2] "(Intercept)" "year"
##   .. ..- attr(*, "assign")= int [1:2] 0 1
##   ..$ qraux: num [1:2] 1.02 1.03
##   ..$ pivot: int [1:2] 1 2
##   ..$ tol  : num 1e-07
##   ..$ rank : int 2
##   ..- attr(*, "class")= chr "qr"
##  $ df.residual  : int 1702
##  $ xlevels      : Named list()
##  $ call         : language lm(formula = lifeExp ~ year, data = gapminder)
##  $ terms        :Classes 'terms', 'formula'  language lifeExp ~ year
##   .. ..- attr(*, "variables")= language list(lifeExp, year)
##   .. ..- attr(*, "factors")= int [1:2, 1] 0 1
##   .. .. ..- attr(*, "dimnames")=List of 2
##   .. .. .. ..$ : chr [1:2] "lifeExp" "year"
##   .. .. .. ..$ : chr "year"
##   .. ..- attr(*, "term.labels")= chr "year"
##   .. ..- attr(*, "order")= int 1
##   .. ..- attr(*, "intercept")= int 1
##   .. ..- attr(*, "response")= int 1
##   .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. ..- attr(*, "predvars")= language list(lifeExp, year)
##   .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
##   .. .. ..- attr(*, "names")= chr [1:2] "lifeExp" "year"
##  $ model        :'data.frame':	1704 obs. of  2 variables:
##   ..$ lifeExp: num [1:1704] 28.8 30.3 32 34 36.1 ...
##   ..$ year   : int [1:1704] 1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
##   ..- attr(*, "terms")=Classes 'terms', 'formula'  language lifeExp ~ year
##   .. .. ..- attr(*, "variables")= language list(lifeExp, year)
##   .. .. ..- attr(*, "factors")= int [1:2, 1] 0 1
##   .. .. .. ..- attr(*, "dimnames")=List of 2
##   .. .. .. .. ..$ : chr [1:2] "lifeExp" "year"
##   .. .. .. .. ..$ : chr "year"
##   .. .. ..- attr(*, "term.labels")= chr "year"
##   .. .. ..- attr(*, "order")= int 1
##   .. .. ..- attr(*, "intercept")= int 1
##   .. .. ..- attr(*, "response")= int 1
##   .. .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. .. ..- attr(*, "predvars")= language list(lifeExp, year)
##   .. .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
##   .. .. .. ..- attr(*, "names")= chr [1:2] "lifeExp" "year"
##  - attr(*, "class")= chr "lm"
```

In order to extract model statistics and use them in a **tidy** manner, we can use a set of functions from the `broom` package. For these functions, the input is always the model object itself, not the original data frame.

### `tidy()`

`tidy()` constructs a data frame that summarizes the model's statistical findings. This includes **coefficients** and **p-values** for each parameter in a regression model. Note that depending on the statistical learning method employed, the statistics stored in the columns may vary.


```r
tidy(gapminder_mod)
```

```
## # A tibble: 2 x 5
##   term        estimate std.error statistic  p.value
##   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
## 1 (Intercept) -586.      32.3        -18.1 2.90e-67
## 2 year           0.326    0.0163      20.0 7.55e-80
```

```r
tidy(gapminder_mod) %>%
  str()
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	2 obs. of  5 variables:
##  $ term     : chr  "(Intercept)" "year"
##  $ estimate : num  -585.652 0.326
##  $ std.error: num  32.314 0.0163
##  $ statistic: num  -18.1 20
##  $ p.value  : num  2.90e-67 7.55e-80
```

Notice that the structure of the resulting object is a tidy data frame. Every row contains a single parameter, every column contains a single statistic, and every cell contains exactly one value.

### `augment()`

`augment()` adds columns to the original data that was modeled. This could include predictions, residuals, and other observation-level statistics.


```r
augment(gapminder_mod) %>%
  as_tibble()
```

```
## # A tibble: 1,704 x 9
##    lifeExp  year .fitted .se.fit .resid     .hat .sigma  .cooksd .std.resid
##      <dbl> <int>   <dbl>   <dbl>  <dbl>    <dbl>  <dbl>    <dbl>      <dbl>
##  1    28.8  1952    50.5   0.530  -21.7 0.00208    11.6 0.00363       -1.87
##  2    30.3  1957    52.1   0.463  -21.8 0.00158    11.6 0.00279       -1.88
##  3    32.0  1962    53.8   0.401  -21.8 0.00119    11.6 0.00209       -1.87
##  4    34.0  1967    55.4   0.348  -21.4 0.000895   11.6 0.00151       -1.84
##  5    36.1  1972    57.0   0.307  -20.9 0.000698   11.6 0.00113       -1.80
##  6    38.4  1977    58.7   0.285  -20.2 0.000599   11.6 0.000907      -1.74
##  7    39.9  1982    60.3   0.285  -20.4 0.000599   11.6 0.000926      -1.76
##  8    40.8  1987    61.9   0.307  -21.1 0.000698   11.6 0.00115       -1.81
##  9    41.7  1992    63.5   0.348  -21.9 0.000895   11.6 0.00159       -1.88
## 10    41.8  1997    65.2   0.401  -23.4 0.00119    11.6 0.00242       -2.01
## # … with 1,694 more rows
```

`augment()` will return statistics to the original data used to estimate the model, however if you supply a data frame under the `newdata` argument, it will return a more limited set of statistics.

### `glance()`

`glance()` constructs a concise one-row summary of the model. This typically contains values such as `\(R^2\)`, adjusted `\(R^2\)`, and residual standard error that are computed once for the entire model.


```r
glance(gapminder_mod)
```

```
## # A tibble: 1 x 11
##   r.squared adj.r.squared sigma statistic  p.value    df logLik    AIC
##       <dbl>         <dbl> <dbl>     <dbl>    <dbl> <int>  <dbl>  <dbl>
## 1     0.190         0.189  11.6      399. 7.55e-80     2 -6598. 13202.
## # … with 3 more variables: BIC <dbl>, deviance <dbl>, df.residual <int>
```

While `broom` may not work with every model in R, it is compatible with a wide range of common statistical models. A full list of models with which `broom` is compatible can be found on the [GitHub page for the package](https://github.com/dgrtwo/broom).

## Separate model for USA

What if instead we wanted to fit a separate model for the United States? We can filter `gapminder` for that country and perform the analysis only on U.S. observations.


```r
gapminder %>%
  filter(country == "United States") %>%
  ggplot(aes(year, lifeExp)) +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "United States")
```

<img src="/notes/linear-models_files/figure-html/gapminder-us-1.png" width="672" />

## Separate models for each country using `map()` and nested data frames

What if we want to estimate separate models for **every country**? We could do this manually, creating a new data frame for each country. But this is tedious and repetitive. We learned a couple of weeks ago how to [iterate using `for` loops](/notes/iteration/#writing-for-loops). We could do this using a `for` loop, but this will take a bunch of code. Instead, let's use the [`map()` functions we already learned](/notes/iteration/#map-functions), but add an additional component on top of that.

Instead of repeating an action for each **column** (variable), we want to repeat an action for each **country**, a subset of rows. To do that, we need a new data structure: the **nested data frame**. To create a nested data frame we start with a grouped data frame, and "nest" it:


```r
by_country <- gapminder %>% 
  group_by(country, continent) %>% 
  nest()

by_country
```

```
## # A tibble: 142 x 3
##    country     continent data             
##    <fct>       <fct>     <list>           
##  1 Afghanistan Asia      <tibble [12 × 4]>
##  2 Albania     Europe    <tibble [12 × 4]>
##  3 Algeria     Africa    <tibble [12 × 4]>
##  4 Angola      Africa    <tibble [12 × 4]>
##  5 Argentina   Americas  <tibble [12 × 4]>
##  6 Australia   Oceania   <tibble [12 × 4]>
##  7 Austria     Europe    <tibble [12 × 4]>
##  8 Bahrain     Asia      <tibble [12 × 4]>
##  9 Bangladesh  Asia      <tibble [12 × 4]>
## 10 Belgium     Europe    <tibble [12 × 4]>
## # … with 132 more rows
```

This looks very different from what you've seen in data frames before. Typically every cell in a data frame is a single value. But here, each element in the `data` column is actually **another data frame**. This demonstrates the benefits of lists - they can be used recursively to store other lists, which is exactly what data frames are.

Now we have one row per country, with the variables associated with each country stored in their own column. All the original data is still in this nested data frame, just stored in a different way. Note that to see the values of the variables in `data`, we use the special notation we learned previously:


```r
by_country$data[[1]]
```

```
## # A tibble: 12 x 4
##     year lifeExp      pop gdpPercap
##    <int>   <dbl>    <int>     <dbl>
##  1  1952    28.8  8425333      779.
##  2  1957    30.3  9240934      821.
##  3  1962    32.0 10267083      853.
##  4  1967    34.0 11537966      836.
##  5  1972    36.1 13079460      740.
##  6  1977    38.4 14880372      786.
##  7  1982    39.9 12881816      978.
##  8  1987    40.8 13867957      852.
##  9  1992    41.7 16317921      649.
## 10  1997    41.8 22227415      635.
## 11  2002    42.1 25268405      727.
## 12  2007    43.8 31889923      975.
```

It's hard to see the overall structure, but it's easy to use the `map()` functions to access this data and analyze it. We create a model fitting function:


```r
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}
```

And we want to apply it to each country. That is exactly what `map()` is designed for.


```r
models <- map(by_country$data, country_model)
```

And because `models` is a list and we just saw how to create list-columns, we could store the models as a new column in `by_country` to keep all the data and analysis together.


```r
by_country <- by_country %>%
  mutate(model = map(data, country_model))
by_country
```

```
## # A tibble: 142 x 4
##    country     continent data              model   
##    <fct>       <fct>     <list>            <list>  
##  1 Afghanistan Asia      <tibble [12 × 4]> <S3: lm>
##  2 Albania     Europe    <tibble [12 × 4]> <S3: lm>
##  3 Algeria     Africa    <tibble [12 × 4]> <S3: lm>
##  4 Angola      Africa    <tibble [12 × 4]> <S3: lm>
##  5 Argentina   Americas  <tibble [12 × 4]> <S3: lm>
##  6 Australia   Oceania   <tibble [12 × 4]> <S3: lm>
##  7 Austria     Europe    <tibble [12 × 4]> <S3: lm>
##  8 Bahrain     Asia      <tibble [12 × 4]> <S3: lm>
##  9 Bangladesh  Asia      <tibble [12 × 4]> <S3: lm>
## 10 Belgium     Europe    <tibble [12 × 4]> <S3: lm>
## # … with 132 more rows
```

Now if we filter or change the order of the observations, `models` also changes order.


```r
by_country %>% 
  filter(continent == "Europe")
```

```
## # A tibble: 30 x 4
##    country                continent data              model   
##    <fct>                  <fct>     <list>            <list>  
##  1 Albania                Europe    <tibble [12 × 4]> <S3: lm>
##  2 Austria                Europe    <tibble [12 × 4]> <S3: lm>
##  3 Belgium                Europe    <tibble [12 × 4]> <S3: lm>
##  4 Bosnia and Herzegovina Europe    <tibble [12 × 4]> <S3: lm>
##  5 Bulgaria               Europe    <tibble [12 × 4]> <S3: lm>
##  6 Croatia                Europe    <tibble [12 × 4]> <S3: lm>
##  7 Czech Republic         Europe    <tibble [12 × 4]> <S3: lm>
##  8 Denmark                Europe    <tibble [12 × 4]> <S3: lm>
##  9 Finland                Europe    <tibble [12 × 4]> <S3: lm>
## 10 France                 Europe    <tibble [12 × 4]> <S3: lm>
## # … with 20 more rows
```

### Unnesting

What if we want to compute residuals for 142 countries and 142 models? We still use the `add_residuals()` function, but we have to combine it with a `map()` function call. Because `add_residuals()` requires two arguments (`data` and `model`), we use the `map2()` function. `map2()` allows us to `map()` over two sets of inputs rather than the normal one:


```r
by_country <- by_country %>% 
  mutate(
    resids = map2(data, model, add_residuals)
  )
by_country
```

```
## # A tibble: 142 x 5
##    country     continent data              model    resids           
##    <fct>       <fct>     <list>            <list>   <list>           
##  1 Afghanistan Asia      <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  2 Albania     Europe    <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  3 Algeria     Africa    <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  4 Angola      Africa    <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  5 Argentina   Americas  <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  6 Australia   Oceania   <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  7 Austria     Europe    <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  8 Bahrain     Asia      <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
##  9 Bangladesh  Asia      <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
## 10 Belgium     Europe    <tibble [12 × 4]> <S3: lm> <tibble [12 × 5]>
## # … with 132 more rows
```

What if you want to plot the residuals? We need to **unnest** the residuals. `unnest()` makes each element of the list its own row:


```r
resids <- unnest(by_country, resids)
resids
```

```
## # A tibble: 1,704 x 7
##    country     continent  year lifeExp      pop gdpPercap   resid
##    <fct>       <fct>     <int>   <dbl>    <int>     <dbl>   <dbl>
##  1 Afghanistan Asia       1952    28.8  8425333      779. -1.11  
##  2 Afghanistan Asia       1957    30.3  9240934      821. -0.952 
##  3 Afghanistan Asia       1962    32.0 10267083      853. -0.664 
##  4 Afghanistan Asia       1967    34.0 11537966      836. -0.0172
##  5 Afghanistan Asia       1972    36.1 13079460      740.  0.674 
##  6 Afghanistan Asia       1977    38.4 14880372      786.  1.65  
##  7 Afghanistan Asia       1982    39.9 12881816      978.  1.69  
##  8 Afghanistan Asia       1987    40.8 13867957      852.  1.28  
##  9 Afghanistan Asia       1992    41.7 16317921      649.  0.754 
## 10 Afghanistan Asia       1997    41.8 22227415      635. -0.534 
## # … with 1,694 more rows
```

```r
resids %>% 
  ggplot(aes(year, resid)) +
    geom_line(aes(group = country), alpha = 1 / 3) + 
    geom_smooth(se = FALSE)
```

<img src="/notes/linear-models_files/figure-html/unnest-1.png" width="672" />

## Exercise: linear regression with `scorecard`

Recall the `scorecard` data set which contains information on U.S. institutions of higher learning.


```r
library(rcfss)
scorecard
```

```
## # A tibble: 1,849 x 12
##    unitid name  state type   cost admrate satavg avgfacsal pctpell comprate
##     <int> <chr> <chr> <chr> <int>   <dbl>  <dbl>     <dbl>   <dbl>    <dbl>
##  1 450234 ITT … KS    Priv… 28306    81.3     NA     45054   0.803    0.6  
##  2 448479 ITT … MI    Priv… 26994    98.3     NA     52857   0.774    0.336
##  3 456427 ITT … CA    Priv… 26353    89.3     NA        NA   0.704   NA    
##  4 459596 ITT … FL    Priv… 28894    58.4     NA     47196   0.778   NA    
##  5 459851 Herz… WI    Priv… 23928    68.8     NA     55089   0.610   NA    
##  6 482477 DeVr… IL    Priv… 25625    70.4     NA     62793   0.641    0.294
##  7 482547 DeVr… NV    Priv… 24265    80       NA     47556   0.636    0.636
##  8 482592 DeVr… OR    Priv…    NA    50       NA     60003   0.671    0    
##  9 482617 DeVr… TN    Priv… 20983    66.7     NA     51660   0.720    0    
## 10 482662 DeVr… WA    Priv… 21999    77.8     NA     56160   0.586    0.290
## # … with 1,839 more rows, and 2 more variables: firstgen <dbl>, debt <dbl>
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
    
    <img src="/notes/linear-models_files/figure-html/scorecard-point-1.png" width="672" />
    
      </p>
    </details>

1. Estimate a linear regression of the relationship between admission rate and cost, and report your results in a tidy table.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    scorecard_mod <- lm(cost ~ admrate, data = scorecard)
    tidy(scorecard_mod)
    ```
    
    ```
    ## # A tibble: 2 x 5
    ##   term        estimate std.error statistic   p.value
    ##   <chr>          <dbl>     <dbl>     <dbl>     <dbl>
    ## 1 (Intercept)   43607.    1001.       43.5 1.04e-284
    ## 2 admrate        -182.      14.4     -12.6 3.98e- 35
    ```
    
      </p>
    </details>

1. Estimate separate linear regression models of the relationship between admission rate and cost for each type of college. Report the estimated parameters and standard errors in a tidy data frame.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # model-building function
    type_model <- function(df) {
      lm(cost ~ admrate, data = df)
    }
    
    # nest the data frame
    by_type <- scorecard %>%
      group_by(type) %>%
      nest()
    by_type
    ```
    
    ```
    ## # A tibble: 3 x 2
    ##   type                data                 
    ##   <chr>               <list>               
    ## 1 Private, for-profit <tibble [216 × 11]>  
    ## 2 Private, nonprofit  <tibble [1,092 × 11]>
    ## 3 Public              <tibble [541 × 11]>
    ```
    
    ```r
    # estimate the models
    by_type <- by_type %>%
      mutate(model = map(data, type_model))
    by_type
    ```
    
    ```
    ## # A tibble: 3 x 3
    ##   type                data                  model   
    ##   <chr>               <list>                <list>  
    ## 1 Private, for-profit <tibble [216 × 11]>   <S3: lm>
    ## 2 Private, nonprofit  <tibble [1,092 × 11]> <S3: lm>
    ## 3 Public              <tibble [541 × 11]>   <S3: lm>
    ```
    
    ```r
    # extract the parameters and print a tidy data frame
    by_type %>%
      mutate(results = map(model, tidy)) %>%
      unnest(results)
    ```
    
    ```
    ## # A tibble: 6 x 6
    ##   type                term         estimate std.error statistic   p.value
    ##   <chr>               <chr>           <dbl>     <dbl>     <dbl>     <dbl>
    ## 1 Private, for-profit (Intercept)  33149.      1679.     19.7   2.20e- 49
    ## 2 Private, for-profit admrate        -69.0       21.2    -3.25  1.33e-  3
    ## 3 Private, nonprofit  (Intercept)  50797.      1112.     45.7   2.92e-254
    ## 4 Private, nonprofit  admrate       -198.        16.5   -12.0   2.55e- 31
    ## 5 Public              (Intercept)  20193.       719.     28.1   1.47e-107
    ## 6 Public              admrate         -7.20      10.3    -0.701 4.84e-  1
    ```
    
    The same approach by using an anonymous function with the [one-sided formula format](http://r4ds.had.co.nz/iteration.html#shortcuts):
    
    
    ```r
    by_type %>%
      mutate(model = map(data, ~lm(cost ~ admrate, data = .)),
             results = map(model, tidy)) %>%
      unnest(results)
    ```
    
      </p>
    </details>
    
### Session Info



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
##  broom       * 0.5.1   2018-12-05 [2] CRAN (R 3.5.0)
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
##  modelr      * 0.1.4   2019-02-18 [2] CRAN (R 3.5.2)
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
##  rcfss       * 0.1.5   2019-04-17 [1] local         
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
