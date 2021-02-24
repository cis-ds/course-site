---
title: "Evaluate your model with resampling"
date: 2020-11-01

type: docs
toc: true
draft: false
categories: ["stat-learn"]

menu:
  notes:
    parent: Machine learning
    weight: 6
---




```r
library(tidyverse)
library(tidymodels)
library(ranger)
library(rcfss)

set.seed(123)

theme_set(theme_minimal())
```

## Introduction {#intro}

So far, we have [built a model](/notes/start-with-models/) and [preprocessed data with a recipe](/notes/preprocess/). We also introduced [workflows](/notes/preprocess/#fit-workflow) as a way to bundle a [`parsnip` model](https://tidymodels.github.io/parsnip/) and [`recipe`](https://tidymodels.github.io/recipes/) together. Once we have a model trained, we need a way to measure how well that model predicts new data. This tutorial explains how to characterize model performance based on **resampling** statistics. 

## General Social Survey {#gss}

As for [preprocessing](/notes/preprocess/), let's use the [General Social Survey](http://gss.norc.org/) is a biannual survey of the American public.^[Conducted by NORC at the University of Chicago.]


```r
data("gss", package = "rcfss")

# select a smaller subset of variables for analysis
gss <- gss %>%
  select(id, wtss, colmslm, age, black, degree,
         hispanic_2, polviews, pray, sex, south, tolerance) %>%
  # drop observations with missing values - could always use imputation instead
  drop_na()

skimr::skim(gss)
```


Table: Table 1: Data summary

|                         |     |
|:------------------------|:----|
|Name                     |gss  |
|Number of rows           |940  |
|Number of columns        |12   |
|_______________________  |     |
|Column type frequency:   |     |
|factor                   |8    |
|numeric                  |4    |
|________________________ |     |
|Group variables          |None |


**Variable type: factor**

|skim_variable | n_missing| complete_rate|ordered | n_unique|top_counts                             |
|:-------------|---------:|-------------:|:-------|--------:|:--------------------------------------|
|colmslm       |         0|             1|FALSE   |        2|Not: 582, Yes: 358                     |
|black         |         0|             1|FALSE   |        2|No: 779, Yes: 161                      |
|degree        |         0|             1|FALSE   |        5|HS: 477, Bac: 190, Gra: 105, <HS: 91   |
|hispanic_2    |         0|             1|FALSE   |        2|No: 856, Yes: 84                       |
|polviews      |         0|             1|FALSE   |        7|Mod: 335, Con: 160, Slg: 135, Lib: 123 |
|pray          |         0|             1|FALSE   |        6|ONC: 295, SEV: 256, NEV: 125, LT : 107 |
|sex           |         0|             1|FALSE   |        2|Fem: 509, Mal: 431                     |
|south         |         0|             1|FALSE   |        2|Non: 561, Sou: 379                     |


**Variable type: numeric**

|skim_variable | n_missing| complete_rate|    mean|     sd|    p0|    p25|    p50|     p75|    p100|hist  |
|:-------------|---------:|-------------:|-------:|------:|-----:|------:|------:|-------:|-------:|:-----|
|id            |         0|             1| 1002.01| 550.04|  2.00| 515.75| 991.50| 1463.50| 1972.00|▇▇▇▇▇ |
|wtss          |         0|             1|    0.98|   0.59|  0.41|   0.82|   0.82|    1.24|    5.24|▇▂▁▁▁ |
|age           |         0|             1|   48.57|  16.92| 18.00|  34.00|  48.00|   61.00|   89.00|▆▇▇▆▂ |
|tolerance     |         0|             1|   10.59|   3.64|  0.00|   8.00|  12.00|   14.00|   15.00|▁▂▃▅▇ |

`rcfss::gss` contains a selection of variables from the 2012 GSS. This time let's consider whether respondents believe Muslim clergymen who express anti-American attitudes should be allowed to teach in a college or university.

The outcome of interest `colmslm` is a factor variable coded as either ``"Yes, allowed"`` (respondent believes the person should be allowed to teach) or `"Not allowed"` (respondent believes the person should not allowed to teach). The rates of these classes are somewhat imbalanced; the majority of respondents do not believe these individuals should be allowed to teach in college:


```r
gss %>% 
  count(colmslm) %>% 
  mutate(prop = n/sum(n))
```

```
## # A tibble: 2 x 3
##   colmslm          n  prop
##   <fct>        <int> <dbl>
## 1 Yes, allowed   358 0.381
## 2 Not allowed    582 0.619
```

## Data splitting {#data-split}

In our previous [*Preprocess your data with `recipes`*](/notes/preprocess/#data-split), we started by splitting our data. It is common when beginning a modeling project to [separate the data set](https://bookdown.org/max/FES/data-splitting.html) into two partitions: 

 * The _training set_ is used to estimate parameters, compare models and feature engineering techniques, tune models, etc.

 * The _test set_ is held in reserve until the end of the project, at which point there should only be one or two models under serious consideration. It is used as an unbiased source for measuring final model performance. 

There are different ways to create these partitions of the data. The most common approach is to use a random sample. Suppose that one quarter of the data were reserved for the test set. Random sampling would randomly select 25% for the test set and use the remainder for the training set. We can use the [`rsample`](https://tidymodels.github.io/rsample/) package for this purpose. 

Since random sampling uses random numbers, it is important to set the random number seed. This ensures that the random numbers can be reproduced at a later time (if needed). 

The function `rsample::initial_split()` takes the original data and saves the information on how to make the partitions.


```r
set.seed(123)

gss_split <- initial_split(gss, strata = colmslm)
```

Here we used the [`strata` argument](https://tidymodels.github.io/rsample/reference/initial_split.html), which conducts a stratified split. This ensures that, despite the imbalance we noticed in our `colmslm` variable, our training and test data sets will keep roughly the same proportions of `"Yes, allowed"` and `Not allowed"` as in the original data. After the `initial_split`, the `training()` and `testing()` functions return the actual data sets. 


```r
gss_train <- training(gss_split)
gss_test  <- testing(gss_split)

nrow(gss_train)
```

```
## [1] 706
```

```r
nrow(gss_train) / nrow(gss)
```

```
## [1] 0.7510638
```

```r
# training set proportions by class
gss_train %>% 
  count(colmslm) %>% 
  mutate(prop = n/sum(n))
```

```
## # A tibble: 2 x 3
##   colmslm          n  prop
##   <fct>        <int> <dbl>
## 1 Yes, allowed   269 0.381
## 2 Not allowed    437 0.619
```

```r
# test set proportions by class
gss_test %>% 
  count(colmslm) %>% 
  mutate(prop = n/sum(n))
```

```
## # A tibble: 2 x 3
##   colmslm          n  prop
##   <fct>        <int> <dbl>
## 1 Yes, allowed    89 0.380
## 2 Not allowed    145 0.620
```

The majority of the modeling work is then conducted on the training set data.

## Modeling

[Random forest models](https://en.wikipedia.org/wiki/Random_forest) are [ensembles](https://en.wikipedia.org/wiki/Ensemble_learning) of [decision trees](https://en.wikipedia.org/wiki/Decision_tree). A large number of decision tree models are created for the ensemble based on slightly different versions of the training set. When creating the individual decision trees, the fitting process encourages them to be as diverse as possible. The collection of trees are combined into the random forest model and, when a new sample is predicted, the votes from each tree are used to calculate the final predicted value for the new sample. For categorical outcome variables like `colmslm` in our `gss` data example, the majority vote across all the trees in the random forest determines the predicted class for the new sample.

One of the benefits of a random forest model is that it is very low maintenance;  it requires very little preprocessing of the data and the default parameters tend to give reasonable results. For that reason, we won't create a recipe for the `gss` data.

At the same time, the number of trees in the ensemble should be large (in the thousands) and this makes the model moderately expensive to compute. 

To fit a random forest model on the training set, let's use the [`parsnip`](https://tidymodels.github.io/parsnip/) package with the [`ranger`](https://cran.r-project.org/web/packages/ranger/index.html) engine. We first define the model that we want to create:


```r
rf_mod <- rand_forest(trees = 1000) %>% 
  set_engine("ranger") %>% 
  set_mode("classification")
```

Starting with this parsnip model object, the `fit()` function can be used with a model formula. Since random forest models use random numbers, we again set the seed prior to computing: 


```r
set.seed(234)
rf_fit <- rf_mod %>% 
  fit(colmslm ~ ., data = gss_train)
rf_fit
```

```
## parsnip model object
## 
## Fit time:  454ms 
## Ranger result
## 
## Call:
##  ranger::ranger(formula = colmslm ~ ., data = data, num.trees = ~1000,      num.threads = 1, verbose = FALSE, seed = sample.int(10^5,          1), probability = TRUE) 
## 
## Type:                             Probability estimation 
## Number of trees:                  1000 
## Sample size:                      706 
## Number of independent variables:  11 
## Mtry:                             3 
## Target node size:                 10 
## Variable importance mode:         none 
## Splitrule:                        gini 
## OOB prediction error (Brier s.):  0.1396921
```

This new `rf_fit` object is our fitted model, trained on our training data set. 

## Estimating performance {#performance}

During a modeling project, we might create a variety of different models. To choose between them, we need to consider how well these models do, as measured by some performance statistics. In our example in this article, some options we could use are: 

 * the area under the Receiver Operating Characteristic (ROC) curve, and
 
 * overall classification accuracy.
 
The ROC curve uses the class probability estimates to give us a sense of performance across the entire set of potential probability cutoffs. Overall accuracy uses the hard class predictions to measure performance. The hard class predictions tell us whether our model predicted `Yes, allowed` or `Not allowed` for each respondent But, behind those predictions, the model is actually estimating a probability. A simple 50% probability cutoff is used to categorize a respondent.

The [`yardstick` package](https://tidymodels.github.io/yardstick/) has functions for computing both of these measures called `roc_auc()` and `accuracy()`. 

At first glance, it might seem like a good idea to use the training set data to compute these statistics. (This is actually a very bad idea.) Let's see what happens if we try this. To evaluate performance based on the training set, we call the `predict()` method to get both types of predictions (i.e. probabilities and hard class predictions).


```r
rf_training_pred <- predict(rf_fit, gss_train) %>% 
  bind_cols(predict(rf_fit, gss_train, type = "prob")) %>% 
  # Add the true outcome data back in
  bind_cols(gss_train %>% 
              select(colmslm))
```

Using the `yardstick` functions, this model has spectacular results, so spectacular that you might be starting to get suspicious: 


```r
rf_training_pred %>%                # training set predictions
  roc_auc(truth = colmslm, `.pred_Yes, allowed`)
```

```
## # A tibble: 1 x 3
##   .metric .estimator .estimate
##   <chr>   <chr>          <dbl>
## 1 roc_auc binary         0.988
```

```r
rf_training_pred %>%                # training set predictions
  accuracy(truth = colmslm, .pred_class)
```

```
## # A tibble: 1 x 3
##   .metric  .estimator .estimate
##   <chr>    <chr>          <dbl>
## 1 accuracy binary         0.931
```

Now that we have this model with exceptional performance, we proceed to the test set. Unfortunately, we discover that, although our results aren't bad, they are certainly worse than what we initially thought based on predicting the training set: 


```r
rf_testing_pred <- predict(rf_fit, gss_test) %>% 
  bind_cols(predict(rf_fit, gss_test, type = "prob")) %>% 
  # Add the true outcome data back in
  bind_cols(gss_test %>% 
              select(colmslm))
```


```r
rf_testing_pred %>%                   # test set predictions
  roc_auc(truth = colmslm, `.pred_Yes, allowed`)
```

```
## # A tibble: 1 x 3
##   .metric .estimator .estimate
##   <chr>   <chr>          <dbl>
## 1 roc_auc binary         0.849
```

```r
rf_testing_pred %>%                   # test set predictions
  accuracy(truth = colmslm, .pred_class)
```

```
## # A tibble: 1 x 3
##   .metric  .estimator .estimate
##   <chr>    <chr>          <dbl>
## 1 accuracy binary         0.799
```

### What happened here?

There are several reasons why training set statistics like the ones shown in this section can be unrealistically optimistic: 

 * Models like random forests, neural networks, and other black-box methods can essentially memorize the training set. Re-predicting that same set should always result in nearly perfect results.

* The training set does not have the capacity to be a good arbiter of performance. It is not an independent piece of information; predicting the training set can only reflect what the model already knows. 

To understand that second point better, think about an analogy from teaching. Suppose you give a class a test, then give them the answers, then provide the same test. The student scores on the _second_ test do not accurately reflect what they know about the subject; these scores would probably be higher than their results on the first test. 

## Resampling to the rescue {#resampling}

**Resampling methods**, such as cross-validation and the bootstrap, are empirical simulation systems. They create a series of data sets similar to the training/testing split discussed previously; a subset of the data are used for creating the model and a different subset is used to measure performance. Resampling is always used with the _training set_. This schematic from [Kuhn and Johnson (2019)](https://bookdown.org/max/FES/resampling.html) illustrates data usage for resampling methods:


<img src="/img/resampling.svg" width="85%" style="display: block; margin: auto;" />

In the first level of this diagram, you see what happens when you use `rsample::initial_split()`, which splits the original data into training and test sets. Then, the training set is chosen for resampling, and the test set is held out.

Let's use 10-fold cross-validation (CV) in this example. This method randomly allocates the 706 respondents in the training set to 10 groups of roughly equal size, called "folds". For the first iteration of resampling, the first fold of about 70 respondens are held out for the purpose of measuring performance. This is similar to a test set but, to avoid confusion, we call these data the _assessment set_ in the `tidymodels` framework. 

The other 90% of the data (about 635 respondents) are used to fit the model. Again, this sounds similar to a training set, so in `tidymodels` we call this data the _analysis set_. This model, trained on the analysis set, is applied to the assessment set to generate predictions, and performance statistics are computed based on those predictions. 

In this example, 10-fold CV moves iteratively through the folds and leaves a different 10% out each time for model assessment. At the end of this process, there are 10 sets of performance statistics that were created on 10 data sets that were not used in the modeling process. For the GSS example, this means 10 accuracies and 10 areas under the ROC curve. While 10 models were created, these are not used further; we do not keep the models themselves trained on these folds because their only purpose is calculating performance metrics. 



The final resampling estimates for the model are the **averages** of the performance statistics replicates. For example, suppose for our data the results were: 


|Resample |  Accuracy|   ROC_AUC| Assessment Size|
|:--------|---------:|---------:|---------------:|
|Fold01   | 0.8169014| 0.9025974|              71|
|Fold02   | 0.8169014| 0.8835726|              71|
|Fold03   | 0.8309859| 0.8794872|              71|
|Fold04   | 0.7605634| 0.8316239|              71|
|Fold05   | 0.8591549| 0.8404453|              71|
|Fold06   | 0.8028169| 0.8758065|              71|
|Fold07   | 0.8571429| 0.9235197|              70|
|Fold08   | 0.7857143| 0.8533333|              70|
|Fold09   | 0.8428571| 0.8910985|              70|
|Fold10   | 0.7571429| 0.8480000|              70|

From these resampling statistics, the final estimate of performance for this random forest model would be 0.873 for the area under the ROC curve and 0.813 for accuracy. 

These resampling statistics are an effective method for measuring model performance _without_ predicting the training set directly as a whole. 

## Fit a model with resampling {#fit-resamples}

To generate these results, the first step is to create a resampling object using rsample. There are [several resampling methods](https://tidymodels.github.io/rsample/reference/index.html#section-resampling-methods) implemented in rsample; cross-validation folds can be created using `vfold_cv()`: 


```r
set.seed(345)

folds <- vfold_cv(gss_train, v = 10)
folds
```

```
## #  10-fold cross-validation 
## # A tibble: 10 x 2
##    splits           id    
##    <list>           <chr> 
##  1 <split [635/71]> Fold01
##  2 <split [635/71]> Fold02
##  3 <split [635/71]> Fold03
##  4 <split [635/71]> Fold04
##  5 <split [635/71]> Fold05
##  6 <split [635/71]> Fold06
##  7 <split [636/70]> Fold07
##  8 <split [636/70]> Fold08
##  9 <split [636/70]> Fold09
## 10 <split [636/70]> Fold10
```

The list column for `splits` contains the information on which rows belong in the analysis and assessment sets. There are functions that can be used to extract the individual resampled data called `analysis()` and `assessment()`. 

However, the `tune` package contains high-level functions that can do the required computations to resample a model for the purpose of measuring performance. You have several options for building an object for resampling:

+ Resample a model specification preprocessed with a formula or [`recipe`](/notes/preprocess/), or 

+ Resample a [`workflow()`](https://tidymodels.github.io/workflows/) that bundles together a model specification and formula/recipe. 

For this example, let's use a `workflow()` that bundles together the random forest model and a formula, since we are not using a recipe. Whichever of these options you use, the syntax to `fit_resamples()` is very similar to `fit()`: 


```r
rf_wf <- workflow() %>%
  add_model(rf_mod) %>%
  add_formula(colmslm ~ .)

set.seed(456)
rf_fit_rs <- rf_wf %>% 
  fit_resamples(folds)
```


```r
rf_fit_rs
```

```
## # Resampling results
## # 10-fold cross-validation 
## # A tibble: 10 x 4
##    splits           id     .metrics         .notes          
##    <list>           <chr>  <list>           <list>          
##  1 <split [635/71]> Fold01 <tibble [2 × 3]> <tibble [0 × 1]>
##  2 <split [635/71]> Fold02 <tibble [2 × 3]> <tibble [0 × 1]>
##  3 <split [635/71]> Fold03 <tibble [2 × 3]> <tibble [0 × 1]>
##  4 <split [635/71]> Fold04 <tibble [2 × 3]> <tibble [0 × 1]>
##  5 <split [635/71]> Fold05 <tibble [2 × 3]> <tibble [0 × 1]>
##  6 <split [635/71]> Fold06 <tibble [2 × 3]> <tibble [0 × 1]>
##  7 <split [636/70]> Fold07 <tibble [2 × 3]> <tibble [0 × 1]>
##  8 <split [636/70]> Fold08 <tibble [2 × 3]> <tibble [0 × 1]>
##  9 <split [636/70]> Fold09 <tibble [2 × 3]> <tibble [0 × 1]>
## 10 <split [636/70]> Fold10 <tibble [2 × 3]> <tibble [0 × 1]>
```

The results are similar to the `folds` results with some extra columns. The column `.metrics` contains the performance statistics created from the 10 assessment sets. These can be manually unnested but the `tune` package contains a number of simple functions that can extract these data: 
 

```r
collect_metrics(rf_fit_rs)
```

```
## # A tibble: 2 x 5
##   .metric  .estimator  mean     n std_err
##   <chr>    <chr>      <dbl> <int>   <dbl>
## 1 accuracy binary     0.813    10 0.0116 
## 2 roc_auc  binary     0.873    10 0.00925
```

Think about these values we now have for accuracy and AUC. These performance metrics are now more realistic (i.e. lower) than our ill-advised first attempt at computing performance metrics in the section above. If we wanted to try different model types for this data set, we could more confidently compare performance metrics computed using resampling to choose between models. Also, remember that at the end of our project, we return to our test set to estimate final model performance. We have looked at this once already before we started using resampling, but let's remind ourselves of the results:


```r
rf_testing_pred %>%                   # test set predictions
  roc_auc(truth = colmslm, `.pred_Yes, allowed`)
```

```
## # A tibble: 1 x 3
##   .metric .estimator .estimate
##   <chr>   <chr>          <dbl>
## 1 roc_auc binary         0.849
```

```r
rf_testing_pred %>%                   # test set predictions
  accuracy(truth = colmslm, .pred_class)
```

```
## # A tibble: 1 x 3
##   .metric  .estimator .estimate
##   <chr>    <chr>          <dbl>
## 1 accuracy binary         0.799
```

The performance metrics from the test set are much closer to the performance metrics computed using resampling than our first ("bad idea") attempt. Resampling allows us to simulate how well our model will perform on new data, and the test set acts as the final, unbiased check for our model's performance.

## Acknowledgments

Example drawn from [Get Started - Preprocess your data with `recipes`](https://www.tidymodels.org/start/recipes/) and licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

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
##  ranger      * 0.12.1     2020-01-10 [1] CRAN (R 4.0.0)                      
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
