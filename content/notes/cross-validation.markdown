---
title: "Cross-validation methods"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/stat005_resampling.html"]
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 5
---




```r
library(tidyverse)
library(modelr)
library(rsample)
library(broom)
library(magrittr)

set.seed(1234)

theme_set(theme_minimal())
```

**Cross-validation methods** are essential to test and evaluate statistical models. Because you likely do not have the resources or capabilities to repeatedly sample from your population of interest, instead you can repeatedly draw from your original sample to obtain additional information about your model. For instance, you could repeatedly draw samples from your data, estimate a linear regression model on each sample, and then examine how the estimated model differs across each sample. This allows you to assess the variability and stability of your model in a way not possible if you can only fit the model once.

## Validation set

One issue with using the same data to both fit and evaluate our model is that we will bias our model towards fitting the data that we have. We may fit our function to create the results we expect or desire, rather than the "true" function. Instead, we can split our data into distinct **training** and **validation** sets. The training set can be used repeatedly to explore or train different models. Once we have a stable model, we can apply it to the validation set of held-out data to determine (unbiasedly) whether the model makes accurate predictions.

## Regression

Here we will examine the relationship between horsepower and car mileage in the `Auto` dataset (found in `library(ISLR)`):


```r
library(ISLR)

Auto <- as_tibble(Auto)
Auto
```

```
## # A tibble: 392 x 9
##      mpg cylinders displacement horsepower weight acceleration  year origin
##    <dbl>     <dbl>        <dbl>      <dbl>  <dbl>        <dbl> <dbl>  <dbl>
##  1    18         8          307        130   3504         12      70      1
##  2    15         8          350        165   3693         11.5    70      1
##  3    18         8          318        150   3436         11      70      1
##  4    16         8          304        150   3433         12      70      1
##  5    17         8          302        140   3449         10.5    70      1
##  6    15         8          429        198   4341         10      70      1
##  7    14         8          454        220   4354          9      70      1
##  8    14         8          440        215   4312          8.5    70      1
##  9    14         8          455        225   4425         10      70      1
## 10    15         8          390        190   3850          8.5    70      1
## # … with 382 more rows, and 1 more variable: name <fct>
```


```r
ggplot(Auto, aes(horsepower, mpg)) +
  geom_point()
```

<img src="/notes/cross-validation_files/figure-html/auto_plot-1.png" width="672" />

The relationship does not appear to be strictly linear:


```r
ggplot(Auto, aes(horsepower, mpg)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
```

<img src="/notes/cross-validation_files/figure-html/auto_plot_lm-1.png" width="672" />

Perhaps by adding [quadratic terms](/notes/logistic-regression/#quadratic-terms) to the linear regression we could improve overall model fit. To evaluate the model, we will split the data into a training set and validation set, estimate a series of higher-order models, and calculate a test statistic summarizing the accuracy of the estimated `mpg`. To calculate the accuracy of the model, we will use **Mean Squared Error** (MSE), defined as

`$$MSE = \frac{1}{n} \sum_{i = 1}^{n}{(y_i - \hat{f}(x_i))^2}$$`

where:

* `\(y_i =\)` the observed response value for the `\(i\)`th observation
* `\(\hat{f}(x_i) =\)` the predicted response value for the `\(i\)`th observation given by `\(\hat{f}\)`
* `\(n =\)` the total number of observations

Boo math! Actually this is pretty intuitive. All we're doing is for each observation, calculating the difference between the actual and predicted values for `\(y\)`, squaring that difference, then calculating the average across all observations. An MSE of 0 indicates the model perfectly predicted each observation. The larger the MSE, the more error in the model.

For this task, first we use `rsample::initial_split()` to create training and validation sets (using a 50/50 split), then estimate a linear regression model without any quadratic terms.

* I use `set.seed()` in the beginning - whenever you are writing a script that involves randomization (here, random subsetting of the data), always set the seed at the beginning of the script. This ensures the results can be reproduced precisely.^[The actual value you use is irrelevant. Just be sure to set it in the script, otherwise R will randomly pick one each time you start a new session.]
* I also use the `glm()` function rather than `lm()` - if you don't change the `family` parameter, the results of `lm()` and `glm()` are exactly the same.^[The default `family` for `glm()` is `gaussian()`, or the **Gaussian** distribution. You probably know it by its other name, the [**Normal** distribution](https://en.wikipedia.org/wiki/Normal_distribution).]


```r
set.seed(1234)

auto_split <- initial_split(data = Auto, prop = 0.5)
auto_train <- training(auto_split)
auto_test <- testing(auto_split)
```


```r
auto_lm <- glm(mpg ~ horsepower, data = auto_train)
summary(auto_lm)
```

```
## 
## Call:
## glm(formula = mpg ~ horsepower, data = auto_train)
## 
## Deviance Residuals: 
##      Min        1Q    Median        3Q       Max  
## -13.7105   -3.4442   -0.5342    2.6256   15.1015  
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 40.057910   1.054798   37.98   <2e-16 ***
## horsepower  -0.157604   0.009402  -16.76   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for gaussian family taken to be 24.80151)
## 
##     Null deviance: 11780.6  on 195  degrees of freedom
## Residual deviance:  4811.5  on 194  degrees of freedom
## AIC: 1189.6
## 
## Number of Fisher Scoring iterations: 2
```

To estimate the MSE for a single partition (i.e. for a training or validation set):

1. Use `broom::augment()` to generate predicted values for the data set
1. Calculate the residuals and square each value
1. Calculate the mean of all the squared residuals in the data set

For the training set, this would look like:


```r
(train_mse <- augment(auto_lm, newdata = auto_train) %>%
  mutate(.resid = mpg - .fitted,
         .resid2 = .resid ^ 2) %$%
  mean(.resid2))
```

```
## [1] 24.54843
```

> Note the special use of the [`$%$` pipe operator from the `magrittr` package](http://r4ds.had.co.nz/pipes.html#other-tools-from-magrittr). This allows us to directly access columns from the data frame entering the pipe. This is especially useful for integrating non-tidy functions into a tidy operation.

For the validation set:


```r
(test_mse <- augment(auto_lm, newdata = auto_test) %>%
  mutate(.resid = mpg - .fitted,
         .resid2 = .resid ^ 2) %$%
  mean(.resid2))
```

```
## [1] 23.38243
```

For a strictly linear model, the MSE for the validation set is 23.38. How does this compare to a quadratic model? We can use the `poly()` function in conjunction with a `map()` iteration to estimate the MSE for a series of models with higher-order polynomial terms:

<img src="/notes/cross-validation_files/figure-html/mse-poly-plot-1.png" width="672" />


```r
# function to estimate model using training set and generate fit statistics
# using the validation set
poly_results <- function(train, test, i) {
  # Fit the model to the training set
  mod <- glm(mpg ~ poly(horsepower, degree = i), data = train)
  
  # `augment` will save the predictions with the test data set
  res <- augment(mod, newdata = test) %>%
    # calculate residuals for future use
    mutate(.resid = mpg - .fitted)
  
  # Return the test data set with the additional columns
  res
}

# function to return MSE for a specific higher-order polynomial term
poly_mse <- function(i, train, test){
  poly_results(train, test, i) %$%
    mean(.resid ^ 2)
}

cv_mse <- tibble(
  terms = seq(from = 1, to = 5),
  mse_test = map_dbl(terms, poly_mse, auto_train, auto_test)
)

ggplot(cv_mse, aes(terms, mse_test)) +
  geom_line() +
  labs(title = "Comparing quadratic linear models",
       subtitle = "Using validation set",
       x = "Highest-order polynomial",
       y = "Mean Squared Error")
```

<img src="/notes/cross-validation_files/figure-html/mse-poly-1.png" width="672" />

Based on the MSE for the validation set, a polynomial model with a quadratic term ($\text{horsepower}^2$) produces the lowest average error. Adding cubic or higher-order terms is just not necessary.

## Classification

Recall our efforts to [predict passenger survival during the sinking of the Titanic](/notes/logistic-regression/#interactive-terms).


```r
library(titanic)
titanic <- as_tibble(titanic_train)

titanic %>%
  head() %>%
  knitr::kable()
```



| PassengerId| Survived| Pclass|Name                                                |Sex    | Age| SibSp| Parch|Ticket           |    Fare|Cabin |Embarked |
|-----------:|--------:|------:|:---------------------------------------------------|:------|---:|-----:|-----:|:----------------|-------:|:-----|:--------|
|           1|        0|      3|Braund, Mr. Owen Harris                             |male   |  22|     1|     0|A/5 21171        |  7.2500|      |S        |
|           2|        1|      1|Cumings, Mrs. John Bradley (Florence Briggs Thayer) |female |  38|     1|     0|PC 17599         | 71.2833|C85   |C        |
|           3|        1|      3|Heikkinen, Miss. Laina                              |female |  26|     0|     0|STON/O2. 3101282 |  7.9250|      |S        |
|           4|        1|      1|Futrelle, Mrs. Jacques Heath (Lily May Peel)        |female |  35|     1|     0|113803           | 53.1000|C123  |S        |
|           5|        0|      3|Allen, Mr. William Henry                            |male   |  35|     0|     0|373450           |  8.0500|      |S        |
|           6|        0|      3|Moran, Mr. James                                    |male   |  NA|     0|     0|330877           |  8.4583|      |Q        |


```r
survive_age_woman_x <- glm(Survived ~ Age * Sex, data = titanic,
                           family = binomial)
summary(survive_age_woman_x)
```

```
## 
## Call:
## glm(formula = Survived ~ Age * Sex, family = binomial, data = titanic)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.9401  -0.7136  -0.5883   0.7626   2.2455  
## 
## Coefficients:
##             Estimate Std. Error z value Pr(>|z|)   
## (Intercept)  0.59380    0.31032   1.913  0.05569 . 
## Age          0.01970    0.01057   1.863  0.06240 . 
## Sexmale     -1.31775    0.40842  -3.226  0.00125 **
## Age:Sexmale -0.04112    0.01355  -3.034  0.00241 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 964.52  on 713  degrees of freedom
## Residual deviance: 740.40  on 710  degrees of freedom
##   (177 observations deleted due to missingness)
## AIC: 748.4
## 
## Number of Fisher Scoring iterations: 4
```

We can use the same validation set approach to evaluate the model's accuracy. For classification models, instead of using MSE we examine the **test error rate**. That is, of all the predictions generated for the validation set, what percentage of predictions are incorrect? The goal is to minimize this value as much as possible (ideally, until we make no errors and our error rate is `\(0%\)`).


```r
# split the data into training and validation sets
titanic_split <- initial_split(data = titanic, prop = 0.5)

# fit model to training data
train_model <- glm(Survived ~ Age * Sex, data = training(titanic_split),
                   family = binomial)
summary(train_model)
```

```
## 
## Call:
## glm(formula = Survived ~ Age * Sex, family = binomial, data = training(titanic_split))
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -2.1511  -0.7346  -0.5386   0.7339   2.2216  
## 
## Coefficients:
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  0.17464    0.41877   0.417 0.676659    
## Age          0.03570    0.01525   2.342 0.019198 *  
## Sexmale     -0.59608    0.56604  -1.053 0.292313    
## Age:Sexmale -0.06833    0.01994  -3.426 0.000612 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 478.37  on 353  degrees of freedom
## Residual deviance: 361.88  on 350  degrees of freedom
##   (92 observations deleted due to missingness)
## AIC: 369.88
## 
## Number of Fisher Scoring iterations: 4
```

```r
# calculate predictions using validation set
x_test_accuracy <- augment(train_model, newdata = testing(titanic_split),
                           type.predict = "response") %>% 
  mutate(pred = as.numeric(.fitted > .5))

# calculate test error rate
mean(x_test_accuracy$Survived != x_test_accuracy$pred, na.rm = TRUE)
```

```
## [1] 0.2166667
```

This interactive model generates an error rate of 21.7%. We could compare this error rate to alternative classification models, either other logistic regression models (using different formulas) or a tree-based method.

## Drawbacks to validation sets

There are two main problems with validation sets:

1. Validation estimates of the test error rates can be highly variable depending on which observations are sampled into the training and validation sets. See what happens if we repeat the sampling, estimation, and validation procedure for the `Auto` data set:

    
    ```r
    # function to simulate training/validation set results
    mse_variable <- function(Auto){
      # split data into training and validation sets
      auto_split <- initial_split(Auto, prop = 0.5)
      auto_train <- training(auto_split)
      auto_test <- testing(auto_split)
      
      # estimate series of higher-order polynomial models
      cv_mse <- tibble(
        terms = seq(from = 1, to = 5),
        mse_test = map_dbl(terms, poly_mse, auto_train, auto_test)
      )
      
      return(cv_mse)
    }
    
    # repeat this process 10 times, each with a different
    # training/validation set split
    rerun(10, mse_variable(Auto)) %>%
      bind_rows(.id = "id") %>%
      ggplot(aes(terms, mse_test, color = id)) +
      geom_line() +
      labs(title = "Variability of MSE estimates",
           subtitle = "10 independent training/validation sets",
           x = "Degree of Polynomial",
           y = "Mean Squared Error") +
      theme(legend.position = "none")
    ```
    
    <img src="/notes/cross-validation_files/figure-html/auto_variable_mse-1.png" width="672" />
    
    Depending on the specific training/test split, our MSE varies by up to 5.

1. If you don't have a large data set, you'll have to dramatically shrink the size of your training set. Most statistical learning methods perform better with more observations - if you don't have enough data in the training set, you might overestimate the error rate in the validation set.

## Leave-one-out cross-validation

An alternative method is **leave-one-out cross validation** (LOOCV). Like with the validation set approach, you split the data into two parts. However the difference is that you only remove one observation for the validation set, and keep all remaining observations in the training set. The statistical learning method is fit on the `\(n-1\)` training set. You then use the held-out observation to calculate the `\(MSE = (y_1 - \hat{y}_1)^2\)` which should be an unbiased estimator of the test error. Because this MSE is highly dependent on which observation is held out, **we repeat this process for every single observation in the data set**. Mathematically, this looks like:

`$$CV_{(n)} = \frac{1}{n} \sum_{i = 1}^{n}{MSE_i}$$`

This method produces estimates of the error rate that have minimal bias and are relatively steady (i.e. non-varying), unlike the validation set approach where the MSE estimate is highly dependent on the sampling process for training/validation sets. LOOCV is also highly flexible and works with any kind of predictive modeling.

Of course the downside is that this method is computationally difficult. You have to estimate `\(n\)` different models - if you have a large `\(n\)` or each individual model takes a long time to compute, you may be stuck waiting a long time for the computer to finish its calculations.

## LOOCV in linear regression

We can use the `loo_cv()` function in the `rsample` library to compute the LOOCV of any linear or logistic regression model. It takes a single argument: the data frame being cross-validated. For the `Auto` dataset, this looks like:


```r
loocv_data <- loo_cv(Auto)
loocv_data
```

```
## # Leave-one-out cross-validation 
## # A tibble: 392 x 2
##    splits          id        
##    <list>          <chr>     
##  1 <split [391/1]> Resample1 
##  2 <split [391/1]> Resample2 
##  3 <split [391/1]> Resample3 
##  4 <split [391/1]> Resample4 
##  5 <split [391/1]> Resample5 
##  6 <split [391/1]> Resample6 
##  7 <split [391/1]> Resample7 
##  8 <split [391/1]> Resample8 
##  9 <split [391/1]> Resample9 
## 10 <split [391/1]> Resample10
## # … with 382 more rows
```

Each element of `loocv_data$splits` is an object of class `rsplit`. This is essentially an efficient container for storing both the **analysis** data (i.e. the training data set) and the **assessment** data (i.e. the validation data set). If we print the contents of a single `rsplit` object:


```r
first_resample <- loocv_data$splits[[1]]
first_resample
```

```
## <391/1/392>
```

This tells us there are 391 observations in the analysis set, 1 observation in the assessment set, and the original data set contained 392 observations. To extract the analysis/assessment sets, use `analysis()` or `assessment()` respectively:


```r
training(first_resample)
```

```
## # A tibble: 391 x 9
##      mpg cylinders displacement horsepower weight acceleration  year origin
##    <dbl>     <dbl>        <dbl>      <dbl>  <dbl>        <dbl> <dbl>  <dbl>
##  1    18         8          307        130   3504         12      70      1
##  2    15         8          350        165   3693         11.5    70      1
##  3    18         8          318        150   3436         11      70      1
##  4    16         8          304        150   3433         12      70      1
##  5    17         8          302        140   3449         10.5    70      1
##  6    15         8          429        198   4341         10      70      1
##  7    14         8          454        220   4354          9      70      1
##  8    14         8          440        215   4312          8.5    70      1
##  9    14         8          455        225   4425         10      70      1
## 10    15         8          390        190   3850          8.5    70      1
## # … with 381 more rows, and 1 more variable: name <fct>
```

```r
assessment(first_resample)
```

```
## # A tibble: 1 x 9
##     mpg cylinders displacement horsepower weight acceleration  year origin
##   <dbl>     <dbl>        <dbl>      <dbl>  <dbl>        <dbl> <dbl>  <dbl>
## 1    25         4          113         95   2228           14    71      3
## # … with 1 more variable: name <fct>
```

Given this new `loocv_data` data frame, we write a function that will, for each resample:

1. Obtain the analysis data set (i.e. the `\(n-1\)` training set)
1. Fit a linear regression model
1. Predict the test data (also known as the **assessment** data, the `\(1\)` validation set) using the `broom` package
1. Determine the MSE for each sample


```r
holdout_results <- function(splits) {
  # Fit the model to the n-1
  mod <- glm(mpg ~ horsepower, data = analysis(splits))
  
  # Save the heldout observation
  holdout <- assessment(splits)
  
  # `augment` will save the predictions with the holdout data set
  res <- augment(mod, newdata = holdout) %>%
    # calculate residuals for future use
    mutate(.resid = mpg - .fitted)
  
  # Return the assessment data set with the additional columns
  res
}
```

This function works for a single resample:


```r
holdout_results(loocv_data$splits[[1]])
```

```
## # A tibble: 1 x 12
##     mpg cylinders displacement horsepower weight acceleration  year origin
##   <dbl>     <dbl>        <dbl>      <dbl>  <dbl>        <dbl> <dbl>  <dbl>
## 1    25         4          113         95   2228           14    71      3
## # … with 4 more variables: name <fct>, .fitted <dbl>, .se.fit <dbl>,
## #   .resid <dbl>
```

To compute the MSE for each heldout observation (i.e. estimate the test MSE for each of the `\(n\)` observations), we use the `map()` function from the `purrr` package to estimate the model for each training test, then calculate the MSE for each observation in each validation set:


```r
loocv_data$results <- map(loocv_data$splits, holdout_results)
loocv_data$mse <- map_dbl(loocv_data$results, ~ mean(.x$.resid ^ 2))
loocv_data
```

```
## # Leave-one-out cross-validation 
## # A tibble: 392 x 4
##    splits          id         results                mse
##    <list>          <chr>      <list>               <dbl>
##  1 <split [391/1]> Resample1  <tibble [1 × 12]>  0.00355
##  2 <split [391/1]> Resample2  <tibble [1 × 12]>  1.25   
##  3 <split [391/1]> Resample3  <tibble [1 × 12]> 19.6    
##  4 <split [391/1]> Resample4  <tibble [1 × 12]>  2.42   
##  5 <split [391/1]> Resample5  <tibble [1 × 12]> 16.7    
##  6 <split [391/1]> Resample6  <tibble [1 × 12]> 97.0    
##  7 <split [391/1]> Resample7  <tibble [1 × 12]> 57.7    
##  8 <split [391/1]> Resample8  <tibble [1 × 12]>  1.77   
##  9 <split [391/1]> Resample9  <tibble [1 × 12]> 15.3    
## 10 <split [391/1]> Resample10 <tibble [1 × 12]> 24.2    
## # … with 382 more rows
```

Now we can compute the overall LOOCV MSE for the data set by calculating the mean of the `mse` column:


```r
loocv_data %>%
  summarize(mse = mean(mse))
```

```
## # A tibble: 1 x 1
##     mse
##   <dbl>
## 1  24.2
```

We can also use this method to compare the optimal number of polynomial terms as before.


```r
# modified function to estimate model with varying highest order polynomial
holdout_results <- function(splits, i) {
  # Fit the model to the n-1
  mod <- glm(mpg ~ poly(horsepower, i), data = analysis(splits))
  
  # Save the heldout observation
  holdout <- assessment(splits)
  
  # `augment` will save the predictions with the holdout data set
  res <- augment(mod, newdata = holdout) %>%
    # calculate residuals for future use
    mutate(.resid = mpg - .fitted)
  
  # Return the assessment data set with the additional columns
  res
}

# function to return MSE for a specific higher-order polynomial term
poly_mse <- function(i, loocv_data){
  loocv_mod <- loocv_data %>%
    mutate(results = map(splits, holdout_results, i),
           mse = map_dbl(results, ~ mean(.x$.resid ^ 2)))
  
  mean(loocv_mod$mse)
}

cv_mse <- tibble(
  terms = seq(from = 1, to = 5),
  mse_loocv = map_dbl(terms, poly_mse, loocv_data)
)
cv_mse
```

```
## # A tibble: 5 x 2
##   terms mse_loocv
##   <int>     <dbl>
## 1     1      24.2
## 2     2      19.2
## 3     3      19.3
## 4     4      19.4
## 5     5      19.0
```

```r
ggplot(cv_mse, aes(terms, mse_loocv)) +
  geom_line() +
  labs(title = "Comparing quadratic linear models",
       subtitle = "Using LOOCV",
       x = "Highest-order polynomial",
       y = "Mean Squared Error")
```

<img src="/notes/cross-validation_files/figure-html/loocv_poly-1.png" width="672" />

And arrive at a similar conclusion. There may be a very marginal advantage to adding a fifth-order polynomial, but not substantial enough for the additional complexity over a mere second-order polynomial.

## LOOCV in classification

Let's verify the error rate of our interactive terms model for the Titanic data set:


```r
# function to generate assessment statistics for titanic model
holdout_results <- function(splits) {
  # Fit the model to the n-1
  mod <- glm(Survived ~ Age * Sex, data = analysis(splits),
             family = binomial)
  
  # Save the heldout observation
  holdout <- assessment(splits)
  
  # `augment` will save the predictions with the holdout data set
  res <- augment(mod, newdata = assessment(splits),
                 type.predict = "response") %>% 
    mutate(pred = as.numeric(.fitted > .5))

  # Return the assessment data set with the additional columns
  res
}

titanic_loocv <- loo_cv(titanic) %>%
  mutate(results = map(splits, holdout_results),
         error_rate = map_dbl(results, ~ mean(.x$Survived != .x$pred, na.rm = TRUE)))
mean(titanic_loocv$error_rate, na.rm = TRUE)
```

```
## [1] 0.219888
```

In a classification problem, the LOOCV tells us the average error rate based on our predictions. So here, it tells us that the interactive `Age * Sex` model has a   22% error rate. This is similar to the validation set result ($21.7\%$)

## Exercise: LOOCV in linear regression

1. Estimate the LOOCV MSE of a linear regression of the relationship between admission rate and cost in the [`scorecard` dataset](/notes/linear-models/#exercise-linear-regression-with-scorecard).

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    library(rcfss)
    
    # function to estimate heldout results for model
    holdout_results <- function(splits) {
      # Fit the model to the n-1
      mod <- glm(cost ~ admrate, data = analysis(splits))
      
      # Save the heldout observation
      holdout <- assessment(splits)
      
      # `augment` will save the predictions with the holdout data set
      res <- augment(mod, newdata = holdout) %>%
        # calculate residuals for future use
        mutate(.resid = cost - .fitted)
      
      # Return the assessment data set with the additional columns
      res
    }
    
    scorecard_loocv <- loo_cv(scorecard) %>%
      mutate(results = map(splits, holdout_results),
             mse = map_dbl(results, ~ mean(.x$.resid ^ 2)))
    mean(scorecard_loocv$mse, na.rm = TRUE)
    ```
    
    ```
    ## [1] 147752431
    ```
    
      </p>
    </details>

1. Estimate the LOOCV MSE of a [logistic regression model of voter turnout](/notes/logistic-regression/#exercise-logistic-regression-with-mental-health) using only `mhealth` as the predictor. Compare this to the LOOCV MSE of a logistic regression model using all available predictors. Which is the better model?

    <details> 
      <summary>Click for the solution</summary>
      <p>

    > Because this problem requires two separate regression formulas, rather than writing `holdout_results()` twice I create a second argument `formula` to the function. `as.formula()` stores a formula for a function as a separate object and can be passed directly into `glm()`.

    
    ```r
    # function to generate assessment statistics for titanic model
    # add the formula argument to pass the regression formula
    holdout_results <- function(splits, formula) {
      # Fit the model to the n-1
      mod <- glm(formula, data = analysis(splits),
                 family = binomial)
      
      # Save the heldout observation
      holdout <- assessment(splits)
      
      # `augment` will save the predictions with the holdout data set
      res <- augment(mod, newdata = assessment(splits),
                     type.predict = "response") %>% 
        mutate(pred = as.numeric(.fitted > .5))
      
      # Return the assessment data set with the additional columns
      res
    }
    
    # basic model
    mh_loocv_lite <- loo_cv(mental_health) %>%
      mutate(results = map(splits, holdout_results,
                           formula = as.formula(vote96 ~ mhealth)),
             error_rate = map_dbl(results, ~ mean(.x$vote96 != .x$pred, na.rm = TRUE)))
    mean(mh_loocv_lite$error_rate, na.rm = TRUE)
    ```
    
    ```
    ## [1] 0.317388
    ```
    
    ```r
    # full model
    mh_loocv_full <- loo_cv(mental_health) %>%
      mutate(results = map(splits, holdout_results,
                           formula = as.formula(vote96 ~ .)),
             error_rate = map_dbl(results, ~ mean(.x$vote96 != .x$pred, na.rm = TRUE)))
    mean(mh_loocv_full$error_rate, na.rm = TRUE)
    ```
    
    ```
    ## [1] 0.2817008
    ```
    
    The full model is better and has a lower error rate.
    
      </p>
    </details>

## `\(k\)`-fold cross-validation

A less computationally-intensive approach to cross validation is **$k$-fold cross-validation**. Rather than dividing the data into `\(n\)` groups, one divides the observations into `\(k\)` groups, or **folds**, of approximately equal size. The first fold is treated as the validation set, and the model is estimated on the remaining `\(k-1\)` folds. This process is repeated `\(k\)` times, with each fold serving as the validation set precisely once. The `\(k\)`-fold CV estimate is calculated by averaging the MSE values for each fold:

`$$CV_{(k)} = \frac{1}{k} \sum_{i = 1}^{k}{MSE_i}$$`

As you may have noticed, LOOCV is a special case of `\(k\)`-fold cross-validation where `\(k = n\)`. More typically researchers will use `\(k=5\)` or `\(k=10\)` depending on the size of the data set and the complexity of the statistical model.

## `\(k\)`-fold CV in linear regression

Let's go back to the `Auto` data set. Instead of LOOCV, let's use 10-fold CV to compare the different polynomial models.


```r
# modified function to estimate model with varying highest order polynomial
holdout_results <- function(splits, i) {
  # Fit the model to the training set
  mod <- glm(mpg ~ poly(horsepower, i), data = analysis(splits))
  
  # Save the heldout observations
  holdout <- assessment(splits)
  
  # `augment` will save the predictions with the holdout data set
  res <- augment(mod, newdata = holdout) %>%
    # calculate residuals for future use
    mutate(.resid = mpg - .fitted)
  
  # Return the assessment data set with the additional columns
  res
}

# function to return MSE for a specific higher-order polynomial term
poly_mse <- function(i, vfold_data){
  vfold_mod <- vfold_data %>%
    mutate(results = map(splits, holdout_results, i),
           mse = map_dbl(results, ~ mean(.x$.resid ^ 2)))
  
  mean(vfold_mod$mse)
}

# split Auto into 10 folds
auto_cv10 <- vfold_cv(data = Auto, v = 10)

cv_mse <- tibble(
  terms = seq(from = 1, to = 5),
  mse_vfold = map_dbl(terms, poly_mse, auto_cv10)
)
cv_mse
```

```
## # A tibble: 5 x 2
##   terms mse_vfold
##   <int>     <dbl>
## 1     1      24.1
## 2     2      19.2
## 3     3      19.3
## 4     4      19.4
## 5     5      18.9
```

How do these results compare to the LOOCV values?


```r
auto_loocv <- loo_cv(Auto)

tibble(
  terms = seq(from = 1, to = 5),
  `10-fold` = map_dbl(terms, poly_mse, auto_cv10),
  LOOCV = map_dbl(terms, poly_mse, auto_loocv)
) %>%
  gather(method, MSE, -terms) %>%
  ggplot(aes(terms, MSE, color = method)) +
  geom_line() +
  labs(title = "MSE estimates",
       x = "Degree of Polynomial",
       y = "Mean Squared Error",
       color = "CV Method")
```

<img src="/notes/cross-validation_files/figure-html/10_fold_auto_loocv-1.png" width="672" />

Pretty much the same results.

## Computational speed of LOOCV vs. `\(k\)`-fold CV


```r
library(microbenchmark)

results_cv <- microbenchmark(
  LOOCV = poly_mse(i = 1, vfold_data = auto_loocv),
  `10-fold CV` = poly_mse(i = 1, vfold_data = auto_cv10)
)

autoplot(results_cv)
```

<img src="/notes/cross-validation_files/figure-html/loocv-kfold-time-1.png" width="672" />

On my machine, 10-fold CV was about 40 times faster than LOOCV. Again, estimating `\(k=10\)` models is going to be much easier than estimating `\(k=392\)` models.

## `\(k\)`-fold CV in logistic regression

You've gotten the idea by now, but let's do it one more time on our interactive Titanic model.


```r
# function to generate assessment statistics for titanic model
holdout_results <- function(splits) {
  # Fit the model to the training set
  mod <- glm(Survived ~ Age * Sex, data = analysis(splits),
             family = binomial)
  
  # Save the heldout observations
  holdout <- assessment(splits)
  
  # `augment` will save the predictions with the holdout data set
  res <- augment(mod, newdata = assessment(splits),
                 type.predict = "response") %>% 
    mutate(pred = as.numeric(.fitted > .5))

  # Return the assessment data set with the additional columns
  res
}

titanic_cv10 <- vfold_cv(data = titanic, v = 10) %>%
  mutate(results = map(splits, holdout_results),
         error_rate = map_dbl(results, ~ mean(.x$Survived != .x$pred, na.rm = TRUE)))
mean(titanic_cv10$error_rate, na.rm = TRUE)
```

```
## [1] 0.2192257
```

Not a large difference from the LOOCV approach, but it take much less time to compute.

## Exercise: `\(k\)`-fold CV

1. Estimate the 10-fold CV MSE of a linear regression of the relationship between admission rate and cost in the [`scorecard` dataset](/notes/linear-models/#exercise-linear-regression-with-scorecard).

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # function to estimate heldout results for model
    holdout_results <- function(splits) {
      # Fit the model to the training set
      mod <- glm(cost ~ admrate, data = analysis(splits))
      
      # Save the heldout observations
      holdout <- assessment(splits)
      
      # `augment` will save the predictions with the holdout data set
      res <- augment(mod, newdata = holdout) %>%
        # calculate residuals for future use
        mutate(.resid = cost - .fitted)
      
      # Return the assessment data set with the additional columns
      res
    }
    
    scorecard_cv10 <- vfold_cv(data = scorecard, v = 10) %>%
      mutate(results = map(splits, holdout_results),
             mse = map_dbl(results, ~ mean(.x$.resid ^ 2)))
    mean(scorecard_cv10$mse, na.rm = TRUE)
    ```
    
    ```
    ## [1] NaN
    ```
    
      </p>
    </details>

1. Estimate the 10-fold CV MSE of a [logistic regression model of voter turnout](/notes/logistic-regression/#exercise-logistic-regression-with-mental-health) using only `mhealth` as the predictor. Compare this to the LOOCV MSE of a logistic regression model using all available predictors. Which is the better model?

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # function to generate assessment statistics for titanic model
    # add the formula argument to pass the regression formula
    holdout_results <- function(splits, formula) {
      # Fit the model to the training set
      mod <- glm(formula, data = analysis(splits),
                 family = binomial)
      
      # Save the heldout observations
      holdout <- assessment(splits)
      
      # `augment` will save the predictions with the holdout data set
      res <- augment(mod, newdata = assessment(splits),
                     type.predict = "response") %>% 
        mutate(pred = as.numeric(.fitted > .5))
      
      # Return the assessment data set with the additional columns
      res
    }
    
    # basic model
    mh_cv10_lite <- vfold_cv(data = mental_health, v = 10) %>%
      mutate(results = map(splits, holdout_results,
                           formula = as.formula(vote96 ~ mhealth)),
             error_rate = map_dbl(results, ~ mean(.x$vote96 != .x$pred, na.rm = TRUE)))
    mean(mh_cv10_lite$error_rate, na.rm = TRUE)
    ```
    
    ```
    ## [1] 0.322681
    ```
    
    ```r
    # full model
    mh_cv10_full <- vfold_cv(data = mental_health, v = 10) %>%
      mutate(results = map(splits, holdout_results,
                           formula = as.formula(vote96 ~ .)),
             error_rate = map_dbl(results, ~ mean(.x$vote96 != .x$pred, na.rm = TRUE)))
    mean(mh_cv10_full$error_rate, na.rm = TRUE)
    ```
    
    ```
    ## [1] 0.2854152
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
##  magrittr    * 1.5     2014-11-22 [2] CRAN (R 3.5.0)
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
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  readr       * 1.3.1   2018-12-21 [2] CRAN (R 3.5.0)
##  readxl        1.3.1   2019-03-13 [2] CRAN (R 3.5.2)
##  remotes       2.0.2   2018-10-30 [1] CRAN (R 3.5.0)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  rsample     * 0.0.4   2019-01-07 [1] CRAN (R 3.5.2)
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
