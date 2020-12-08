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

{{% alert note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/statistical-learning")
```

{{% /alert %}}

Linear models are the simplest statistical learning method to understand. They adopt a generic form

$$y = \beta_0 + \beta_1 \times x$$

where $y$ is the **outcome of interest**, $x$ is the **explanatory** or **predictor** variable, and $\beta_0$ and $\beta_1$ are **parameters** that vary to capture different patterns. Given the empirical values you have for $x$ and $y$, you generate a **fitted model** that finds the values for the parameters that best fit the data.


```r
ggplot(sim1, aes(x, y)) + 
  geom_point()
```

<img src="/notes/linear-models_files/figure-html/sim-plot-1.png" width="672" />

This looks like a linear relationship. We could randomly generate parameters for the formula $y = \beta_0 + \beta_1 \times x$ to try and explain or predict the relationship between $x$ and $y$:


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

But obviously some parameters are better than others. We need a definition that can be used to differentiate good parameters from bad parameters. One approach widely used is called **least squares** - it means that the overall solution minimizes the sum of the squares of the errors made in the results of every single equation. The errors are simply the vertical difference between the actual values for $y$ and the predicted values for $y$.

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

The `lm()` function takes two parameters. The first is a *formula* specifying the equation to be estimated (`lm()` translates `y ~ x` into $y = \beta_0 + \beta_1 \times x$). The second is of course the data frame containing the variables.

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

We can use `sim1_mod` to generate **predicted values**, or the expected value for $Y$ given our knowledge of hypothetical observations with values for $X$, based on the estimated parameters using `modelr::data_grid()` and `broom::augment()`.^[`package::function()` notation. So `data_grid()` can be found in the `modelr` package, while `augment()` is in `broom`.] `data_grid()` generates an evenly spaced grid of data points covering the region where observed data lies. The first argument is a data frame, and subsequent arguments identify unique columns and generates all possible combinations.


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
## # A tibble: 10 x 2
##        x .fitted
##    <int>   <dbl>
##  1     1    6.27
##  2     2    8.32
##  3     3   10.4 
##  4     4   12.4 
##  5     5   14.5 
##  6     6   16.5 
##  7     7   18.6 
##  8     8   20.6 
##  9     9   22.7 
## 10    10   24.7
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

We can also calculate the **residuals**, or that distance between the actual and predicted values of $y$. To do that, we again use `augment()` but do not input a new data frame:


```r
sim1_resid <- augment(sim1_mod)
sim1_resid
```

```
## # A tibble: 30 x 8
##        y     x .fitted   .resid .std.resid   .hat .sigma     .cooksd
##    <dbl> <int>   <dbl>    <dbl>      <dbl>  <dbl>  <dbl>       <dbl>
##  1  4.20     1    6.27 -2.07      -1.00    0.115    2.20 0.0651     
##  2  7.51     1    6.27  1.24       0.598   0.115    2.23 0.0232     
##  3  2.13     1    6.27 -4.15      -2.00    0.115    2.08 0.261      
##  4  8.99     2    8.32  0.665      0.315   0.0828   2.24 0.00449    
##  5 10.2      2    8.32  1.92       0.910   0.0828   2.21 0.0374     
##  6 11.3      2    8.32  2.97       1.41    0.0828   2.16 0.0897     
##  7  7.36     3   10.4  -3.02      -1.41    0.0586   2.16 0.0621     
##  8 10.5      3   10.4   0.130      0.0608  0.0586   2.24 0.000115   
##  9 10.5      3   10.4   0.136      0.0637  0.0586   2.24 0.000126   
## 10 12.4      4   12.4   0.00763    0.00354 0.0424   2.24 0.000000278
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
## # A tibble: 1,704 x 3
##     year country     .fitted
##    <int> <fct>         <dbl>
##  1  1952 Afghanistan    50.5
##  2  1952 Albania        50.5
##  3  1952 Algeria        50.5
##  4  1952 Angola         50.5
##  5  1952 Argentina      50.5
##  6  1952 Australia      50.5
##  7  1952 Austria        50.5
##  8  1952 Bahrain        50.5
##  9  1952 Bangladesh     50.5
## 10  1952 Belgium        50.5
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
## tibble [2 × 5] (S3: tbl_df/tbl/data.frame)
##  $ term     : chr [1:2] "(Intercept)" "year"
##  $ estimate : num [1:2] -585.652 0.326
##  $ std.error: num [1:2] 32.314 0.0163
##  $ statistic: num [1:2] -18.1 20
##  $ p.value  : num [1:2] 2.90e-67 7.55e-80
```

Notice that the structure of the resulting object is a tidy data frame. Every row contains a single parameter, every column contains a single statistic, and every cell contains exactly one value.

### `augment()`

`augment()` adds columns to the original data that was modeled. This could include predictions, residuals, and other observation-level statistics.


```r
augment(gapminder_mod) %>%
  as_tibble()
```

```
## # A tibble: 1,704 x 8
##    lifeExp  year .fitted .resid .std.resid     .hat .sigma  .cooksd
##      <dbl> <int>   <dbl>  <dbl>      <dbl>    <dbl>  <dbl>    <dbl>
##  1    28.8  1952    50.5  -21.7      -1.87 0.00208    11.6 0.00363 
##  2    30.3  1957    52.1  -21.8      -1.88 0.00158    11.6 0.00279 
##  3    32.0  1962    53.8  -21.8      -1.87 0.00119    11.6 0.00209 
##  4    34.0  1967    55.4  -21.4      -1.84 0.000895   11.6 0.00151 
##  5    36.1  1972    57.0  -20.9      -1.80 0.000698   11.6 0.00113 
##  6    38.4  1977    58.7  -20.2      -1.74 0.000599   11.6 0.000907
##  7    39.9  1982    60.3  -20.4      -1.76 0.000599   11.6 0.000926
##  8    40.8  1987    61.9  -21.1      -1.81 0.000698   11.6 0.00115 
##  9    41.7  1992    63.5  -21.9      -1.88 0.000895   11.6 0.00159 
## 10    41.8  1997    65.2  -23.4      -2.01 0.00119    11.6 0.00242 
## # … with 1,694 more rows
```

`augment()` will return statistics to the original data used to estimate the model, however if you supply a data frame under the `newdata` argument, it will return a more limited set of statistics.

### `glance()`

`glance()` constructs a concise one-row summary of the model. This typically contains values such as $R^2$, adjusted $R^2$, and residual standard error that are computed once for the entire model.


```r
glance(gapminder_mod)
```

```
## # A tibble: 1 x 12
##   r.squared adj.r.squared sigma statistic  p.value    df logLik    AIC    BIC
##       <dbl>         <dbl> <dbl>     <dbl>    <dbl> <dbl>  <dbl>  <dbl>  <dbl>
## 1     0.190         0.189  11.6      399. 7.55e-80     1 -6598. 13202. 13218.
## # … with 3 more variables: deviance <dbl>, df.residual <int>, nobs <int>
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
## # Groups:   country, continent [142]
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
## # Groups:   country, continent [142]
##    country     continent data              model 
##    <fct>       <fct>     <list>            <list>
##  1 Afghanistan Asia      <tibble [12 × 4]> <lm>  
##  2 Albania     Europe    <tibble [12 × 4]> <lm>  
##  3 Algeria     Africa    <tibble [12 × 4]> <lm>  
##  4 Angola      Africa    <tibble [12 × 4]> <lm>  
##  5 Argentina   Americas  <tibble [12 × 4]> <lm>  
##  6 Australia   Oceania   <tibble [12 × 4]> <lm>  
##  7 Austria     Europe    <tibble [12 × 4]> <lm>  
##  8 Bahrain     Asia      <tibble [12 × 4]> <lm>  
##  9 Bangladesh  Asia      <tibble [12 × 4]> <lm>  
## 10 Belgium     Europe    <tibble [12 × 4]> <lm>  
## # … with 132 more rows
```

Now if we filter or change the order of the observations, `models` also changes order.


```r
by_country %>% 
  filter(continent == "Europe")
```

```
## # A tibble: 30 x 4
## # Groups:   country, continent [30]
##    country                continent data              model 
##    <fct>                  <fct>     <list>            <list>
##  1 Albania                Europe    <tibble [12 × 4]> <lm>  
##  2 Austria                Europe    <tibble [12 × 4]> <lm>  
##  3 Belgium                Europe    <tibble [12 × 4]> <lm>  
##  4 Bosnia and Herzegovina Europe    <tibble [12 × 4]> <lm>  
##  5 Bulgaria               Europe    <tibble [12 × 4]> <lm>  
##  6 Croatia                Europe    <tibble [12 × 4]> <lm>  
##  7 Czech Republic         Europe    <tibble [12 × 4]> <lm>  
##  8 Denmark                Europe    <tibble [12 × 4]> <lm>  
##  9 Finland                Europe    <tibble [12 × 4]> <lm>  
## 10 France                 Europe    <tibble [12 × 4]> <lm>  
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
## # Groups:   country, continent [142]
##    country     continent data              model  resids           
##    <fct>       <fct>     <list>            <list> <list>           
##  1 Afghanistan Asia      <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  2 Albania     Europe    <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  3 Algeria     Africa    <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  4 Angola      Africa    <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  5 Argentina   Americas  <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  6 Australia   Oceania   <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  7 Austria     Europe    <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  8 Bahrain     Asia      <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
##  9 Bangladesh  Asia      <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
## 10 Belgium     Europe    <tibble [12 × 4]> <lm>   <tibble [12 × 5]>
## # … with 132 more rows
```

What if you want to plot the residuals? We need to **unnest** the residuals. `unnest()` makes each element of the list its own row:


```r
resids <- unnest(by_country, resids)
resids
```

```
## # A tibble: 1,704 x 9
## # Groups:   country, continent [142]
##    country   continent data        model   year lifeExp    pop gdpPercap   resid
##    <fct>     <fct>     <list>      <list> <int>   <dbl>  <int>     <dbl>   <dbl>
##  1 Afghanis… Asia      <tibble [1… <lm>    1952    28.8 8.43e6      779. -1.11  
##  2 Afghanis… Asia      <tibble [1… <lm>    1957    30.3 9.24e6      821. -0.952 
##  3 Afghanis… Asia      <tibble [1… <lm>    1962    32.0 1.03e7      853. -0.664 
##  4 Afghanis… Asia      <tibble [1… <lm>    1967    34.0 1.15e7      836. -0.0172
##  5 Afghanis… Asia      <tibble [1… <lm>    1972    36.1 1.31e7      740.  0.674 
##  6 Afghanis… Asia      <tibble [1… <lm>    1977    38.4 1.49e7      786.  1.65  
##  7 Afghanis… Asia      <tibble [1… <lm>    1982    39.9 1.29e7      978.  1.69  
##  8 Afghanis… Asia      <tibble [1… <lm>    1987    40.8 1.39e7      852.  1.28  
##  9 Afghanis… Asia      <tibble [1… <lm>    1992    41.7 1.63e7      649.  0.754 
## 10 Afghanis… Asia      <tibble [1… <lm>    1997    41.8 2.22e7      635. -0.534 
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

1. What is the relationship between admission rate and net cost? Report this relationship using a scatterplot and a linear best-fit line.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    ggplot(scorecard, aes(admrate, netcost)) +
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
    scorecard_mod <- lm(netcost ~ admrate, data = scorecard)
    tidy(scorecard_mod)
    ```
    
    ```
    ## # A tibble: 2 x 5
    ##   term        estimate std.error statistic   p.value
    ##   <chr>          <dbl>     <dbl>     <dbl>     <dbl>
    ## 1 (Intercept)   23820.      657.     36.3  2.72e-214
    ## 2 admrate       -5119.      934.     -5.48 4.93e-  8
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
      lm(netcost ~ admrate, data = df)
    }
    
    # nest the data frame
    by_type <- scorecard %>%
      group_by(type) %>%
      nest()
    by_type
    ```
    
    ```
    ## # A tibble: 3 x 2
    ## # Groups:   type [3]
    ##   type                data                 
    ##   <fct>               <list>               
    ## 1 Private, nonprofit  <tibble [1,110 × 14]>
    ## 2 Private, for-profit <tibble [91 × 14]>   
    ## 3 Public              <tibble [552 × 14]>
    ```
    
    ```r
    # estimate the models
    by_type <- by_type %>%
      mutate(model = map(data, type_model))
    by_type
    ```
    
    ```
    ## # A tibble: 3 x 3
    ## # Groups:   type [3]
    ##   type                data                  model 
    ##   <fct>               <list>                <list>
    ## 1 Private, nonprofit  <tibble [1,110 × 14]> <lm>  
    ## 2 Private, for-profit <tibble [91 × 14]>    <lm>  
    ## 3 Public              <tibble [552 × 14]>   <lm>
    ```
    
    ```r
    # extract the parameters and print a tidy data frame
    by_type %>%
      mutate(results = map(model, tidy)) %>%
      unnest(results)
    ```
    
    ```
    ## # A tibble: 6 x 8
    ## # Groups:   type [3]
    ##   type         data         model term    estimate std.error statistic   p.value
    ##   <fct>        <list>       <lis> <chr>      <dbl>     <dbl>     <dbl>     <dbl>
    ## 1 Private, no… <tibble [1,… <lm>  (Inter…   26331.      739.   35.6    8.16e-185
    ## 2 Private, no… <tibble [1,… <lm>  admrate   -5331.     1078.   -4.94   8.82e-  7
    ## 3 Private, fo… <tibble [91… <lm>  (Inter…   27053.     3339.    8.10   5.50e- 12
    ## 4 Private, fo… <tibble [91… <lm>  admrate    -282.     4512.   -0.0625 9.50e-  1
    ## 5 Public       <tibble [55… <lm>  (Inter…   12391.      788.   15.7    3.16e- 46
    ## 6 Public       <tibble [55… <lm>  admrate    2976.     1079.    2.76   5.99e-  3
    ```
    
    The same approach by using an anonymous function with the [one-sided formula format](http://r4ds.had.co.nz/iteration.html#shortcuts):
    
    
    ```r
    by_type %>%
      mutate(model = map(data, ~lm(netcost ~ admrate, data = .)),
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
##  date     2020-12-08                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports     1.1.10  2020-09-15 [1] CRAN (R 4.0.2)
##  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
##  blogdown      0.20.1  2020-10-19 [1] local         
##  bookdown      0.21    2020-10-13 [1] CRAN (R 4.0.2)
##  broom       * 0.7.1   2020-10-02 [1] CRAN (R 4.0.2)
##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli           2.1.0   2020-10-12 [1] CRAN (R 4.0.2)
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 4.0.2)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)
##  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr       * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  farver        2.0.3   2020-01-16 [1] CRAN (R 4.0.0)
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  gapminder   * 0.3.0   2017-10-31 [1] CRAN (R 4.0.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
##  ggplot2     * 3.3.2   2020-06-19 [1] CRAN (R 4.0.2)
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
##  here          0.1     2017-05-28 [1] CRAN (R 4.0.0)
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools     0.5.0   2020-06-16 [1] CRAN (R 4.0.2)
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)
##  jsonlite      1.7.1   2020-09-07 [1] CRAN (R 4.0.2)
##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)
##  labeling      0.3     2014-08-23 [1] CRAN (R 4.0.0)
##  lattice       0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
##  lubridate     1.7.9   2020-06-08 [1] CRAN (R 4.0.2)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
##  Matrix        1.2-18  2019-11-27 [1] CRAN (R 4.0.2)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  mgcv          1.8-33  2020-08-27 [1] CRAN (R 4.0.2)
##  modelr      * 0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  nlme          3.1-149 2020-08-23 [1] CRAN (R 4.0.2)
##  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
##  pkgbuild      1.1.0   2020-07-13 [1] CRAN (R 4.0.2)
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.4.4   2020-09-03 [1] CRAN (R 4.0.2)
##  ps            1.4.0   2020-10-07 [1] CRAN (R 4.0.2)
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
##  rcfss       * 0.2.1   2020-12-08 [1] local         
##  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
##  readr       * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes       2.2.0   2020-07-21 [1] CRAN (R 4.0.2)
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
##  rlang         0.4.8   2020-10-08 [1] CRAN (R 4.0.2)
##  rmarkdown     2.4     2020-09-30 [1] CRAN (R 4.0.2)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
##  rstudioapi    0.11    2020-02-07 [1] CRAN (R 4.0.0)
##  rvest         0.3.6   2020-07-25 [1] CRAN (R 4.0.2)
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
##  tibble      * 3.0.3   2020-07-10 [1] CRAN (R 4.0.2)
##  tidyr       * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
##  usethis       1.6.3   2020-09-17 [1] CRAN (R 4.0.2)
##  utf8          1.1.4   2018-05-24 [1] CRAN (R 4.0.0)
##  vctrs         0.3.4   2020-08-29 [1] CRAN (R 4.0.2)
##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)
##  xfun          0.18    2020-09-29 [1] CRAN (R 4.0.2)
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
