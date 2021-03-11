---
title: "Supervised classification with text data"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/text_classification.html"]
categories: ["text"]

menu:
  notes:
    parent: Text analysis
    weight: 4
---




```r
library(tidyverse)
library(tidymodels)
library(tidytext)

set.seed(1234)
theme_set(theme_minimal())
```

A common task in social science involves hand-labeling sets of documents for specific variables (e.g. manual coding). In previous years, this required hiring a set of research assistants and training them to read and evaluate text by hand. It was expensive, prone to error, required extensive data quality checks, and was infeasible if you had an extremely large corpus of text that required classification.

Alternatively, we can now use machine learning models to classify text into specific sets of categories. This is known as **supervised learning**. The basic process is:

1. Hand-code a small set of documents (say $1000$) for whatever variable(s) you care about
1. Train a machine learning model on the hand-coded data, using the variable as the outcome of interest and the text features of the documents as the predictors
1. Evaluate the effectiveness of the machine learning model via [cross-validation](/notes/resampling/)
1. Once you have trained a model with sufficient predictive accuracy, apply the model to the remaining set of documents that have never been hand-coded (say $1000000$)

## Sample set of documents: `USCongress`


```r
# get USCongress data
data(USCongress, package = "rcfss")

# topic labels
major_topics <- tibble(
  major = c(1:10, 12:21, 99),
  label = c("Macroeconomics", "Civil rights, minority issues, civil liberties",
            "Health", "Agriculture", "Labor and employment", "Education", "Environment",
            "Energy", "Immigration", "Transportation", "Law, crime, family issues",
            "Social welfare", "Community development and housing issues",
            "Banking, finance, and domestic commerce", "Defense",
            "Space, technology, and communications", "Foreign trade",
            "International affairs and foreign aid", "Government operations",
            "Public lands and water management", "Other, miscellaneous")
)

(congress <- as_tibble(USCongress) %>%
    mutate(text = as.character(text)) %>%
    left_join(major_topics))
```

```
## Joining, by = "major"
```

```
## # A tibble: 4,449 x 7
##       ID  cong billnum h_or_sen major text                        label         
##    <dbl> <dbl>   <dbl> <chr>    <dbl> <chr>                       <chr>         
##  1     1   107    4499 HR          18 To suspend temporarily the… Foreign trade 
##  2     2   107    4500 HR          18 To suspend temporarily the… Foreign trade 
##  3     3   107    4501 HR          18 To suspend temporarily the… Foreign trade 
##  4     4   107    4502 HR          18 To reduce temporarily the … Foreign trade 
##  5     5   107    4503 HR           5 To amend the Immigration a… Labor and emp…
##  6     6   107    4504 HR          21 To amend title 38, United … Public lands …
##  7     7   107    4505 HR          15 To repeal subtitle B of ti… Banking, fina…
##  8     8   107    4506 HR          18 To suspend temporarily the… Foreign trade 
##  9     9   107    4507 HR          18 To suspend temporarily the… Foreign trade 
## 10    10   107    4508 HR          18 To suspend temporarily the… Foreign trade 
## # … with 4,439 more rows
```

`USCongress` contains a sample of hand-labeled bills from the United States Congress. For each bill we have a text description of the bill's purpose (e.g. "To amend the Immigration and Nationality Act in regard to Caribbean-born immigrants.") as well as the bill's [major policy topic code corresponding to the subject of the bill](http://www.comparativeagendas.net/pages/master-codebook). There are 20 major policy topics according to this coding scheme (e.g. Macroeconomics, Civil Rights, Health). These topic codes have been labeled by hand. The current dataset only contains a sample of bills from the 107th Congress (2001-03). If we wanted to obtain policy topic codes for all bills introduced over a longer period, we would have to manually code tens of thousands if not millions of bill descriptions. Clearly a task outside of our capabilities.

Instead, we can build a machine learning model which predicts the major topic code of a bill given its text description. These notes outline a potential `tidymodels`/`tidytext` workflow for such an approach.

## Split the data set

First we need to convert `major` to a factor variable based on the levels defined in `label`. Then we can split the data into [training and testing datasets](/notes/resampling/) using `initial_split()` from `rsample`.


```r
set.seed(123)

congress <- congress %>%
  mutate(major = factor(x = major, levels = major, labels = label))

congress_split <- initial_split(data = congress, strata = major, prop = .8)
congress_split
```

```
## <Analysis/Assess/Total>
## <3560/889/4449>
```

```r
congress_train <- training(congress_split)
congress_test <- testing(congress_split)
```

## Preprocessing the data frame

Next we need to preprocess the data in preparation for modeling. Currently we have text data, and we need to construct numeric, quantitative features for machine learning based on that text. As before, we can use `recipes` to construct the set of preprocessing steps we want to perform. This time, we only use the `text` column for the model.


```r
congress_rec <- recipe(major ~ text, data = congress_train)
```

Now we add steps to process the text of the legislation summaries. We use `textrecipes` to handle the `text` variable. First we **tokenize** the text to words with `step_tokenize()`. By default this uses `tokenizers::tokenize_words()`. Next we remove stop words with `step_stopwords()`; the default choice is the Snowball stop word list, but custom lists can be provided too. Before we calculate tf-idf we use `step_tokenfilter()` to only keep the 500 most frequent tokens, to avoid creating too many variables in our first model. To finish, we use `step_tfidf()` to compute tf-idf.


```r
library(textrecipes)

congress_rec <- congress_rec %>%
  step_tokenize(text) %>%
  step_stopwords(text) %>%
  step_tokenfilter(text, max_tokens = 500) %>%
  step_tfidf(text)
```

## Train a model

Using our existing `workflow()` approach to fitting a model, we can establish a workflow using a relatively straightforward type of classification model: naive Bayes. Naive Bayes is particularly useful as it can handle a large number of features.


```r
library(discrim)
```

```
## 
## Attaching package: 'discrim'
```

```
## The following object is masked from 'package:dials':
## 
##     smoothness
```

```r
nb_spec <- naive_Bayes() %>%
  set_mode("classification") %>%
  set_engine("naivebayes")

nb_spec
```

```
## Naive Bayes Model Specification (classification)
## 
## Computational engine: naivebayes
```


```r
nb_wf <- workflow() %>%
  add_recipe(congress_rec) %>%
  add_model(nb_spec)
nb_wf
```

```
## ══ Workflow ════════════════════════════════════════════════════════════════════
## Preprocessor: Recipe
## Model: naive_Bayes()
## 
## ── Preprocessor ────────────────────────────────────────────────────────────────
## 4 Recipe Steps
## 
## ● step_tokenize()
## ● step_stopwords()
## ● step_tokenfilter()
## ● step_tfidf()
## 
## ── Model ───────────────────────────────────────────────────────────────────────
## Naive Bayes Model Specification (classification)
## 
## Computational engine: naivebayes
```

```r
nb_wf %>%
  fit(data = congress_train)
```

```
## ══ Workflow [trained] ══════════════════════════════════════════════════════════
## Preprocessor: Recipe
## Model: naive_Bayes()
## 
## ── Preprocessor ────────────────────────────────────────────────────────────────
## 4 Recipe Steps
## 
## ● step_tokenize()
## ● step_stopwords()
## ● step_tokenfilter()
## ● step_tfidf()
## 
## ── Model ───────────────────────────────────────────────────────────────────────
## 
## ================================== Naive Bayes ================================== 
##  
##  Call: 
## naive_bayes.default(x = maybe_data_frame(x), y = y, usekernel = TRUE)
## 
## --------------------------------------------------------------------------------- 
##  
## Laplace smoothing: 0
## 
## --------------------------------------------------------------------------------- 
##  
##  A priori probabilities: 
## 
##                                  Foreign trade 
##                                    0.088202247 
##                           Labor and employment 
##                                    0.058988764 
##              Public lands and water management 
##                                    0.110674157 
##        Banking, finance, and domestic commerce 
##                                    0.061516854 
##                                        Defense 
##                                    0.049719101 
##                      Law, crime, family issues 
##                                    0.064606742 
## Civil rights, minority issues, civil liberties 
##                                    0.017696629 
##                                         Health 
##                                    0.137359551 
##          International affairs and foreign aid 
##                                    0.028370787 
##                          Government operations 
##                                    0.085393258 
##                           Other, miscellaneous 
##                                    0.006460674 
##                                 Transportation 
##                                    0.039044944 
##                                      Education 
##                                    0.048595506 
##          Space, technology, and communications 
##                                    0.019101124 
##                                    Environment 
##                                    0.046348315 
##                                 Macroeconomics 
##                                    0.035393258 
##                                 Social welfare 
##                                    0.020786517 
##                                         Energy 
##                                    0.030617978 
## 
## ...
## and 1715 more lines.
```

## Evaluation

As we have already seen, we should not use the test set to compare models or different parameters. Instead, we can use **cross-validation** to evaluate our model.

Here, let's reformulate this to use naive Bayes classification with 10-fold cross-validation sets.


```r
set.seed(123)

congress_folds <- vfold_cv(data = congress_train, strata = major)
congress_folds
```

```
## #  10-fold cross-validation using stratification 
## # A tibble: 10 x 2
##    splits              id    
##    <list>              <chr> 
##  1 <rsplit [3203/357]> Fold01
##  2 <rsplit [3203/357]> Fold02
##  3 <rsplit [3203/357]> Fold03
##  4 <rsplit [3204/356]> Fold04
##  5 <rsplit [3204/356]> Fold05
##  6 <rsplit [3204/356]> Fold06
##  7 <rsplit [3204/356]> Fold07
##  8 <rsplit [3205/355]> Fold08
##  9 <rsplit [3205/355]> Fold09
## 10 <rsplit [3205/355]> Fold10
```


```r
nb_cv <- nb_wf %>%
  fit_resamples(
    congress_folds,
    control = control_resamples(save_pred = TRUE)
  )
```

```
## 
## Attaching package: 'rlang'
```

```
## The following objects are masked from 'package:purrr':
## 
##     %@%, as_function, flatten, flatten_chr, flatten_dbl, flatten_int,
##     flatten_lgl, flatten_raw, invoke, list_along, modify, prepend,
##     splice
```

```
## 
## Attaching package: 'vctrs'
```

```
## The following object is masked from 'package:dplyr':
## 
##     data_frame
```

```
## The following object is masked from 'package:tibble':
## 
##     data_frame
```

```
## naivebayes 0.9.7 loaded
```

```
## 
## Attaching package: 'stopwords'
```

```
## The following object is masked from 'package:tm':
## 
##     stopwords
```

```
## ! Fold03: preprocessor 1/1, model 1/1: NAs introduced by coercion to integer range
```

```
## ! Fold08: preprocessor 1/1, model 1/1: NAs introduced by coercion to integer range
```

We can extract relevant information using `collect_metrics()` and `collect_predictions()`.


```r
nb_cv_metrics <- collect_metrics(nb_cv)
nb_cv_predictions <- collect_predictions(nb_cv)

nb_cv_metrics
```

```
## # A tibble: 2 x 6
##   .metric  .estimator  mean     n std_err .config             
##   <chr>    <chr>      <dbl> <int>   <dbl> <chr>               
## 1 accuracy multiclass 0.137    10 0.00532 Preprocessor1_Model1
## 2 roc_auc  hand_till  0.536    10 0.00488 Preprocessor1_Model1
```

The default performance parameters for multiclass classification are accuracy and ROC AUC (area under the receiver operator curve). The accuracy is the percentage of accurate predictions. For both metrics, values closer to 1 are better. These results suggest the naive Bayes model is performing quite poorly.

The [receiver operator curve](https://en.wikipedia.org/wiki/Receiver_operating_characteristic) is a plot that shows the sensitivity at different thresholds. It demonstrates how well a classification model can distinguish between classes.


```r
nb_cv_predictions %>%
  group_by(id) %>%
  roc_curve(truth = major, c(starts_with(".pred"), -.pred_class)) %>%
  autoplot() +
  labs(
    color = NULL,
    title = "Receiver operator curve for Congressional bills",
    subtitle = "Each resample fold is shown in a different color"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/nb-roc-curve-1.png" width="672" />

Another way to evaluate our model is to evaluate the [confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix). A confusion matrix visualizes a model's false positives and false negatives for each class. There is not a trivial way to visualize multiple confusion matrices, so we can look at them individually for a single fold.


```r
nb_cv_predictions %>%
  filter(id == "Fold01") %>%
  conf_mat(major, .pred_class) %>%
  autoplot(type = "heatmap") +
  scale_y_discrete(labels = function(x) str_wrap(x, 20)) +
  scale_x_discrete(labels = function(x) str_wrap(x, 20))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/nb-confusion-1.png" width="672" />

Ideally all observations would fall on the diagonal. However here we can see that all predictions all under "Health" no matter what the true category.

## Compare to the null model

We can assess this model by comparing its performance to a "null model", or a baseline model. This baseline is a simple, non-informative model that always predicts the largest class for classification. In the absence of any information about the individual observations, this is the best strategy we can follow to generate predictions.


```r
null_classification <- null_model() %>%
  set_engine("parsnip") %>%
  set_mode("classification")

null_cv <- workflow() %>%
  add_recipe(congress_rec) %>%
  add_model(null_classification) %>%
  fit_resamples(
    congress_folds
  )

null_cv %>%
  collect_metrics()
```

```
## # A tibble: 2 x 6
##   .metric  .estimator  mean     n std_err .config             
##   <chr>    <chr>      <dbl> <int>   <dbl> <chr>               
## 1 accuracy multiclass 0.137    10 0.00532 Preprocessor1_Model1
## 2 roc_auc  hand_till  0.5      10 0       Preprocessor1_Model1
```

Notice the accuracy is the same as for the naive Bayes model. This is because naive Bayes still leads to every observation predicted as "Health", **which is the exact same result as the null model**. Clearly we need a better modeling strategy.

## Concerns regarding multiclass classification

Remember that each bill could fall under one of 20 major policy topics. Compared to binary classification, this is a much harder challenge. For one, the classes are **imbalanced**. That is, there are far more healthcare related bills than other areas.


```r
ggplot(data = congress, mapping = aes(x = fct_infreq(major) %>% fct_rev())) +
  geom_bar() +
  coord_flip() +
  labs(
    title = "Distribution of legislation",
    subtitle = "By major policy topic",
    x = NULL,
    y = "Number of bills"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/major-topic-dist-1.png" width="672" />

Many machine learning algorithms (such as naive Bayes) do not handle imbalanced data well, while other algorithms may not even be capable of performing multiclass classification.

There are many different ways to deal with imbalanced data. Here we will take a simple approach, **downsampling**, where observations from the majority classes are removed during training to achieve a balanced class distribution. We rely on the `themis` package for recipes which includes the `step_downsample()` function to perform downsampling.


```r
library(themis)
```

```
## Registered S3 methods overwritten by 'themis':
##   method                  from   
##   bake.step_downsample    recipes
##   bake.step_upsample      recipes
##   prep.step_downsample    recipes
##   prep.step_upsample      recipes
##   tidy.step_downsample    recipes
##   tidy.step_upsample      recipes
##   tunable.step_downsample recipes
##   tunable.step_upsample   recipes
```

```
## 
## Attaching package: 'themis'
```

```
## The following objects are masked from 'package:recipes':
## 
##     step_downsample, step_upsample
```

```r
# build on existing recipe
congress_rec <- congress_rec %>%
  step_downsample(major)
congress_rec
```

```
## Data Recipe
## 
## Inputs:
## 
##       role #variables
##    outcome          1
##  predictor          1
## 
## Operations:
## 
## Tokenization for text
## Stop word removal for text
## Text filtering for text
## Term frequency-inverse document frequency with text
## Down-sampling based on major
```

Let's also switch to an alternative modeling approach which handles multiclass problems better, support vector machine (SVM).


```r
svm_spec <- svm_rbf() %>%
  set_mode("classification") %>%
  set_engine("liquidSVM")

svm_spec
```

```
## Radial Basis Function Support Vector Machine Specification (classification)
## 
## Computational engine: liquidSVM
```


```r
svm_wf <- workflow() %>%
  add_recipe(congress_rec) %>%
  add_model(svm_spec)

svm_wf
```

```
## ══ Workflow ════════════════════════════════════════════════════════════════════
## Preprocessor: Recipe
## Model: svm_rbf()
## 
## ── Preprocessor ────────────────────────────────────────────────────────────────
## 5 Recipe Steps
## 
## ● step_tokenize()
## ● step_stopwords()
## ● step_tokenfilter()
## ● step_tfidf()
## ● step_downsample()
## 
## ── Model ───────────────────────────────────────────────────────────────────────
## Radial Basis Function Support Vector Machine Specification (classification)
## 
## Computational engine: liquidSVM
```

The `liquidSVM` engine doesn't support class probabilities as output so we need to replace the default metric set with a metric set that doesn't use class probabilities. Here we use accuracy, sensitivity, and specificity.


```r
set.seed(123)

svm_cv <- fit_resamples(
  svm_wf,
  congress_folds,
  metrics = metric_set(accuracy),
  control = control_resamples(save_pred = TRUE)
)
```

```
## ! Fold01: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold02: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold03: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold04: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold05: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold06: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold07: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold08: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold09: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```
## ! Fold10: preprocessor 1/1, model 1/1: Solution may not be optimal: try training a...
```

```r
svm_cv
```

```
## Warning: This tuning result has notes. Example notes on model fitting include:
## preprocessor 1/1, model 1/1: Solution may not be optimal: try training again using min_gamma=0.04, Solution may not be optimal: try training again using max_gamma=25
## preprocessor 1/1, model 1/1: Solution may not be optimal: try training again using min_gamma=0.04, Solution may not be optimal: try training again using max_gamma=25
## preprocessor 1/1, model 1/1: Solution may not be optimal: try training again using min_gamma=0.04, Solution may not be optimal: try training again using max_gamma=25
```

```
## # Resampling results
## # 10-fold cross-validation using stratification 
## # A tibble: 10 x 5
##    splits              id     .metrics         .notes          .predictions     
##    <list>              <chr>  <list>           <list>          <list>           
##  1 <rsplit [3203/357]> Fold01 <tibble [1 × 4]> <tibble [1 × 1… <tibble [357 × 4…
##  2 <rsplit [3203/357]> Fold02 <tibble [1 × 4]> <tibble [1 × 1… <tibble [357 × 4…
##  3 <rsplit [3203/357]> Fold03 <tibble [1 × 4]> <tibble [1 × 1… <tibble [357 × 4…
##  4 <rsplit [3204/356]> Fold04 <tibble [1 × 4]> <tibble [1 × 1… <tibble [356 × 4…
##  5 <rsplit [3204/356]> Fold05 <tibble [1 × 4]> <tibble [1 × 1… <tibble [356 × 4…
##  6 <rsplit [3204/356]> Fold06 <tibble [1 × 4]> <tibble [1 × 1… <tibble [356 × 4…
##  7 <rsplit [3204/356]> Fold07 <tibble [1 × 4]> <tibble [1 × 1… <tibble [356 × 4…
##  8 <rsplit [3205/355]> Fold08 <tibble [1 × 4]> <tibble [1 × 1… <tibble [355 × 4…
##  9 <rsplit [3205/355]> Fold09 <tibble [1 × 4]> <tibble [1 × 1… <tibble [355 × 4…
## 10 <rsplit [3205/355]> Fold10 <tibble [1 × 4]> <tibble [1 × 1… <tibble [355 × 4…
```


```r
svm_cv_metrics <- collect_metrics(svm_cv)
svm_cv_predictions <- collect_predictions(svm_cv)

svm_cv_metrics
```

```
## # A tibble: 1 x 6
##   .metric  .estimator  mean     n std_err .config             
##   <chr>    <chr>      <dbl> <int>   <dbl> <chr>               
## 1 accuracy multiclass 0.351    10  0.0105 Preprocessor1_Model1
```

While still low, the accuracy has risen substantially compared to the naive Bayes model. This is typical for multiclass models since the classification task is harder than for binary classification - rather than having one right answer and one wrong answer, there is one right answer and nineteen wrong answers.


```r
svm_cv_predictions %>%
  filter(id == "Fold01") %>%
  conf_mat(major, .pred_class) %>%
  autoplot(type = "heatmap") +
  scale_y_discrete(labels = function(x) str_wrap(x, 20)) +
  scale_x_discrete(labels = function(x) str_wrap(x, 20))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/svm-confusion-1.png" width="672" />

It seems the model is still substantially over-predicting the "other" category, but there are more observations on the diagonal now.

## Acknowledgments

- For more detail on machine learning for text classification, see [*Supervised Machine Learning for Text Analysis in R*](https://smltar.com/mlclassification.html) by Emil Hvitfeldt and Julia Silge

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.4 (2021-02-15)
##  os       macOS Big Sur 10.16         
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-03-10                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version    date       lib source        
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 4.0.0)
##  backports      1.2.1      2020-12-09 [1] CRAN (R 4.0.2)
##  BBmisc         1.11       2017-03-10 [1] CRAN (R 4.0.0)
##  blogdown       1.2        2021-03-04 [1] CRAN (R 4.0.3)
##  bookdown       0.21       2020-10-13 [1] CRAN (R 4.0.2)
##  broom        * 0.7.5      2021-02-19 [1] CRAN (R 4.0.2)
##  bslib          0.2.4      2021-01-25 [1] CRAN (R 4.0.2)
##  cachem         1.0.4      2021-02-13 [1] CRAN (R 4.0.2)
##  callr          3.5.1      2020-10-13 [1] CRAN (R 4.0.2)
##  caret        * 6.0-86     2020-03-20 [1] CRAN (R 4.0.0)
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 4.0.0)
##  checkmate      2.0.0      2020-02-06 [1] CRAN (R 4.0.0)
##  class          7.3-18     2021-01-24 [1] CRAN (R 4.0.4)
##  cli            2.3.1      2021-02-23 [1] CRAN (R 4.0.3)
##  codetools      0.2-18     2020-11-04 [1] CRAN (R 4.0.4)
##  colorspace     2.0-0      2020-11-11 [1] CRAN (R 4.0.2)
##  crayon         1.4.1      2021-02-08 [1] CRAN (R 4.0.2)
##  data.table     1.14.0     2021-02-21 [1] CRAN (R 4.0.2)
##  DBI            1.1.1      2021-01-15 [1] CRAN (R 4.0.2)
##  dbplyr         2.1.0      2021-02-03 [1] CRAN (R 4.0.2)
##  debugme        1.1.0      2017-10-22 [1] CRAN (R 4.0.0)
##  desc           1.2.0      2018-05-01 [1] CRAN (R 4.0.0)
##  devtools       2.3.2      2020-09-18 [1] CRAN (R 4.0.2)
##  dials        * 0.0.9      2020-09-16 [1] CRAN (R 4.0.2)
##  DiceDesign     1.9        2021-02-13 [1] CRAN (R 4.0.2)
##  digest         0.6.27     2020-10-24 [1] CRAN (R 4.0.2)
##  discrim      * 0.1.1      2020-10-28 [1] CRAN (R 4.0.2)
##  doParallel     1.0.16     2020-10-16 [1] CRAN (R 4.0.2)
##  dplyr        * 1.0.5      2021-03-05 [1] CRAN (R 4.0.3)
##  ellipsis       0.3.1      2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate       0.14       2019-05-28 [1] CRAN (R 4.0.0)
##  fansi          0.4.2      2021-01-15 [1] CRAN (R 4.0.2)
##  farver         2.1.0      2021-02-28 [1] CRAN (R 4.0.2)
##  fastmap        1.1.0      2021-01-25 [1] CRAN (R 4.0.2)
##  fastmatch      1.1-0      2017-01-28 [1] CRAN (R 4.0.0)
##  FNN            1.1.3      2019-02-15 [1] CRAN (R 4.0.0)
##  forcats      * 0.5.1      2021-01-27 [1] CRAN (R 4.0.2)
##  foreach        1.5.1      2020-10-15 [1] CRAN (R 4.0.2)
##  fs             1.5.0      2020-07-31 [1] CRAN (R 4.0.2)
##  furrr          0.2.2      2021-01-29 [1] CRAN (R 4.0.2)
##  future         1.21.0     2020-12-10 [1] CRAN (R 4.0.2)
##  generics       0.1.0      2020-10-31 [1] CRAN (R 4.0.2)
##  ggplot2      * 3.3.3      2020-12-30 [1] CRAN (R 4.0.2)
##  globals        0.14.0     2020-11-22 [1] CRAN (R 4.0.2)
##  glue           1.4.2      2020-08-27 [1] CRAN (R 4.0.2)
##  gower          0.2.2      2020-06-23 [1] CRAN (R 4.0.2)
##  GPfit          1.0-8      2019-02-08 [1] CRAN (R 4.0.0)
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 4.0.0)
##  haven          2.3.1      2020-06-01 [1] CRAN (R 4.0.0)
##  here           1.0.1      2020-12-13 [1] CRAN (R 4.0.2)
##  highr          0.8        2019-03-20 [1] CRAN (R 4.0.0)
##  hms            1.0.0      2021-01-13 [1] CRAN (R 4.0.2)
##  htmltools      0.5.1.1    2021-01-22 [1] CRAN (R 4.0.2)
##  httr           1.4.2      2020-07-20 [1] CRAN (R 4.0.2)
##  infer        * 0.5.4      2021-01-13 [1] CRAN (R 4.0.2)
##  ipred          0.9-10     2021-03-04 [1] CRAN (R 4.0.2)
##  iterators      1.0.13     2020-10-15 [1] CRAN (R 4.0.2)
##  janeaustenr    0.1.5      2017-06-10 [1] CRAN (R 4.0.0)
##  jquerylib      0.1.3      2020-12-17 [1] CRAN (R 4.0.2)
##  jsonlite       1.7.2      2020-12-09 [1] CRAN (R 4.0.2)
##  knitr          1.31       2021-01-27 [1] CRAN (R 4.0.2)
##  lattice      * 0.20-41    2020-04-02 [1] CRAN (R 4.0.4)
##  lava           1.6.8.1    2020-11-04 [1] CRAN (R 4.0.2)
##  lhs            1.1.1      2020-10-05 [1] CRAN (R 4.0.2)
##  lifecycle      1.0.0      2021-02-15 [1] CRAN (R 4.0.2)
##  liquidSVM    * 1.2.4      2019-09-14 [1] CRAN (R 4.0.3)
##  listenv        0.8.0      2019-12-05 [1] CRAN (R 4.0.0)
##  lubridate      1.7.10     2021-02-26 [1] CRAN (R 4.0.2)
##  magrittr       2.0.1      2020-11-17 [1] CRAN (R 4.0.2)
##  MASS           7.3-53     2020-09-09 [1] CRAN (R 4.0.4)
##  Matrix         1.3-2      2021-01-06 [1] CRAN (R 4.0.4)
##  memoise        2.0.0      2021-01-26 [1] CRAN (R 4.0.2)
##  mlr            2.19.0     2021-02-22 [1] CRAN (R 4.0.2)
##  modeldata    * 0.1.0      2020-10-22 [1] CRAN (R 4.0.2)
##  ModelMetrics   1.2.2.2    2020-03-17 [1] CRAN (R 4.0.0)
##  modelr         0.1.8      2020-05-19 [1] CRAN (R 4.0.0)
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 4.0.0)
##  naivebayes   * 0.9.7      2020-03-08 [1] CRAN (R 4.0.0)
##  nlme           3.1-152    2021-02-04 [1] CRAN (R 4.0.4)
##  NLP          * 0.2-1      2020-10-14 [1] CRAN (R 4.0.2)
##  nnet           7.3-15     2021-01-24 [1] CRAN (R 4.0.4)
##  parallelly     1.23.0     2021-01-04 [1] CRAN (R 4.0.2)
##  parallelMap    1.5.0      2020-03-26 [1] CRAN (R 4.0.0)
##  ParamHelpers   1.14       2020-03-24 [1] CRAN (R 4.0.0)
##  parsnip      * 0.1.5      2021-01-19 [1] CRAN (R 4.0.2)
##  pillar         1.5.1      2021-03-05 [1] CRAN (R 4.0.3)
##  pkgbuild       1.2.0      2020-12-15 [1] CRAN (R 4.0.2)
##  pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload        1.2.0      2021-02-23 [1] CRAN (R 4.0.2)
##  plyr           1.8.6      2020-03-03 [1] CRAN (R 4.0.0)
##  prettyunits    1.1.1      2020-01-24 [1] CRAN (R 4.0.0)
##  pROC           1.17.0.1   2021-01-13 [1] CRAN (R 4.0.2)
##  processx       3.4.5      2020-11-30 [1] CRAN (R 4.0.2)
##  prodlim        2019.11.13 2019-11-17 [1] CRAN (R 4.0.0)
##  ps             1.6.0      2021-02-28 [1] CRAN (R 4.0.2)
##  purrr        * 0.3.4      2020-04-17 [1] CRAN (R 4.0.0)
##  R6             2.5.0      2020-10-28 [1] CRAN (R 4.0.2)
##  RANN           2.6.1      2019-01-08 [1] CRAN (R 4.0.0)
##  Rcpp           1.0.6      2021-01-15 [1] CRAN (R 4.0.2)
##  readr        * 1.4.0      2020-10-05 [1] CRAN (R 4.0.2)
##  readxl         1.3.1      2019-03-13 [1] CRAN (R 4.0.0)
##  recipes      * 0.1.15     2020-11-11 [1] CRAN (R 4.0.2)
##  remotes        2.2.0      2020-07-21 [1] CRAN (R 4.0.2)
##  reprex         1.0.0      2021-01-27 [1] CRAN (R 4.0.2)
##  reshape2       1.4.4      2020-04-09 [1] CRAN (R 4.0.0)
##  rlang        * 0.4.10     2020-12-30 [1] CRAN (R 4.0.2)
##  rmarkdown      2.7        2021-02-19 [1] CRAN (R 4.0.2)
##  ROSE           0.0-3      2014-07-15 [1] CRAN (R 4.0.2)
##  rpart          4.1-15     2019-04-12 [1] CRAN (R 4.0.4)
##  rprojroot      2.0.2      2020-11-15 [1] CRAN (R 4.0.2)
##  rsample      * 0.0.9      2021-02-17 [1] CRAN (R 4.0.2)
##  rstudioapi     0.13       2020-11-12 [1] CRAN (R 4.0.2)
##  rvest          0.3.6      2020-07-25 [1] CRAN (R 4.0.2)
##  sass           0.3.1      2021-01-24 [1] CRAN (R 4.0.2)
##  scales       * 1.1.1      2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 4.0.0)
##  slam           0.1-48     2020-12-03 [1] CRAN (R 4.0.2)
##  SnowballC      0.7.0      2020-04-01 [1] CRAN (R 4.0.0)
##  stopwords    * 2.2        2021-02-10 [1] CRAN (R 4.0.2)
##  stringi        1.5.3      2020-09-09 [1] CRAN (R 4.0.2)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 4.0.0)
##  survival       3.2-7      2020-09-28 [1] CRAN (R 4.0.4)
##  testthat       3.0.2      2021-02-14 [1] CRAN (R 4.0.2)
##  textrecipes  * 0.4.0      2020-11-12 [1] CRAN (R 4.0.2)
##  themis       * 0.1.3      2020-11-12 [1] CRAN (R 4.0.2)
##  tibble       * 3.1.0      2021-02-25 [1] CRAN (R 4.0.2)
##  tictoc       * 1.0        2014-06-17 [1] CRAN (R 4.0.0)
##  tidymodels   * 0.1.2      2020-11-22 [1] CRAN (R 4.0.2)
##  tidyr        * 1.1.3      2021-03-03 [1] CRAN (R 4.0.2)
##  tidyselect     1.1.0      2020-05-11 [1] CRAN (R 4.0.0)
##  tidytext     * 0.3.0      2021-01-06 [1] CRAN (R 4.0.2)
##  tidyverse    * 1.3.0      2019-11-21 [1] CRAN (R 4.0.0)
##  timeDate       3043.102   2018-02-21 [1] CRAN (R 4.0.0)
##  tm           * 0.7-8      2020-11-18 [1] CRAN (R 4.0.2)
##  tokenizers     0.2.1      2018-03-29 [1] CRAN (R 4.0.0)
##  tune         * 0.1.3      2021-02-28 [1] CRAN (R 4.0.2)
##  unbalanced     2.0        2015-06-26 [1] CRAN (R 4.0.2)
##  usethis        2.0.1      2021-02-10 [1] CRAN (R 4.0.2)
##  utf8           1.1.4      2018-05-24 [1] CRAN (R 4.0.0)
##  vctrs        * 0.3.6      2020-12-17 [1] CRAN (R 4.0.2)
##  withr          2.4.1      2021-01-26 [1] CRAN (R 4.0.2)
##  workflows    * 0.2.1      2020-10-08 [1] CRAN (R 4.0.2)
##  xfun           0.21       2021-02-10 [1] CRAN (R 4.0.2)
##  xml2           1.3.2      2020-04-23 [1] CRAN (R 4.0.0)
##  yaml           2.2.1      2020-02-01 [1] CRAN (R 4.0.0)
##  yardstick    * 0.0.7      2020-07-13 [1] CRAN (R 4.0.2)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
