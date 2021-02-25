---
title: "Tune model parameters"
date: 2020-11-01

type: docs
toc: true
draft: false
categories: ["stat-learn"]

menu:
  notes:
    parent: Machine learning
    weight: 7
---




```r
library(tidymodels)
library(rpart)
library(modeldata)
library(kableExtra)
library(vip)

set.seed(123)
doParallel::registerDoParallel()
theme_set(theme_minimal())
```

## Introduction {#intro}

Some model parameters cannot be learned directly from a data set during model training; these kinds of parameters are called **hyperparameters**. Some examples of hyperparameters include the number of predictors that are sampled at splits in a tree-based model (we call this `mtry` in `tidymodels`) or the learning rate in a boosted tree model (we call this `learn_rate`). Instead of learning these kinds of hyperparameters during model training, we can _estimate_ the best values for these values by training many models on resampled data sets and exploring how well all these models perform. This process is called **tuning**.

## The General Social Survey (revisited) {#data}

In our previous [*Evaluate your model with resampling*](/notes/resampling/) article, we introduced a data set of survey respondents who indicated whether or not they believed Muslim clergymen who express anti-American attitudes should be allowed to teach in a college or university. We trained a [random forest model](/notes/resampling/#modeling) to predict respondents' responses, and used [resampling](/notes/resampling/#resampling) to estimate the performance of our model on this data.


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


<table style='width: auto;'
        class='table table-condensed'>
<caption>Table 1: Data summary</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;">   </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Name </td>
   <td style="text-align:left;"> gss </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Number of rows </td>
   <td style="text-align:left;"> 940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Number of columns </td>
   <td style="text-align:left;"> 12 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> _______________________ </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Column type frequency: </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> factor </td>
   <td style="text-align:left;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ________________________ </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Group variables </td>
   <td style="text-align:left;"> None </td>
  </tr>
</tbody>
</table>


**Variable type: factor**

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> skim_variable </th>
   <th style="text-align:right;"> n_missing </th>
   <th style="text-align:right;"> complete_rate </th>
   <th style="text-align:left;"> ordered </th>
   <th style="text-align:right;"> n_unique </th>
   <th style="text-align:left;"> top_counts </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> colmslm </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Not: 582, Yes: 358 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> black </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> No: 779, Yes: 161 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> degree </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> HS: 477, Bac: 190, Gra: 105, &lt;HS: 91 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> hispanic_2 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> No: 856, Yes: 84 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> polviews </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Mod: 335, Con: 160, Slg: 135, Lib: 123 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pray </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> ONC: 295, SEV: 256, NEV: 125, LT : 107 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sex </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Fem: 509, Mal: 431 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> south </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Non: 561, Sou: 379 </td>
  </tr>
</tbody>
</table>


**Variable type: numeric**

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> skim_variable </th>
   <th style="text-align:right;"> n_missing </th>
   <th style="text-align:right;"> complete_rate </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> p0 </th>
   <th style="text-align:right;"> p25 </th>
   <th style="text-align:right;"> p50 </th>
   <th style="text-align:right;"> p75 </th>
   <th style="text-align:right;"> p100 </th>
   <th style="text-align:left;"> hist </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> id </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1002.01 </td>
   <td style="text-align:right;"> 550.04 </td>
   <td style="text-align:right;"> 2.00 </td>
   <td style="text-align:right;"> 515.75 </td>
   <td style="text-align:right;"> 991.50 </td>
   <td style="text-align:right;"> 1463.50 </td>
   <td style="text-align:right;"> 1972.00 </td>
   <td style="text-align:left;"> ▇▇▇▇▇ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> wtss </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 0.59 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 1.24 </td>
   <td style="text-align:right;"> 5.24 </td>
   <td style="text-align:left;"> ▇▂▁▁▁ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> age </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 48.57 </td>
   <td style="text-align:right;"> 16.92 </td>
   <td style="text-align:right;"> 18.00 </td>
   <td style="text-align:right;"> 34.00 </td>
   <td style="text-align:right;"> 48.00 </td>
   <td style="text-align:right;"> 61.00 </td>
   <td style="text-align:right;"> 89.00 </td>
   <td style="text-align:left;"> ▆▇▇▆▂ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tolerance </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 10.59 </td>
   <td style="text-align:right;"> 3.64 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 8.00 </td>
   <td style="text-align:right;"> 12.00 </td>
   <td style="text-align:right;"> 14.00 </td>
   <td style="text-align:right;"> 15.00 </td>
   <td style="text-align:left;"> ▁▂▃▅▇ </td>
  </tr>
</tbody>
</table>

## Predicting attitudes, but better {#why-tune}

Random forest models are a tree-based ensemble method, and typically perform well with [default hyperparameters](https://bradleyboehmke.github.io/HOML/random-forest.html#out-of-the-box-performance). However, the accuracy of some other tree-based models, such as [boosted tree models](https://en.wikipedia.org/wiki/Gradient_boosting#Gradient_tree_boosting) or [decision tree models](https://en.wikipedia.org/wiki/Decision_tree), can be sensitive to the values of hyperparameters. In this article, we will train a **decision tree** model. There are several hyperparameters for decision tree models that can be tuned for better performance. Let's explore:

- the complexity parameter (which we call `cost_complexity` in tidymodels) for the tree, and
- the maximum `tree_depth`.

Tuning these hyperparameters can improve model performance because decision tree models are prone to [overfitting](https://bookdown.org/max/FES/important-concepts.html#overfitting). This happens because single tree models tend to fit the training data _too well_ &mdash; so well, in fact, that they over-learn patterns present in the training data that end up being detrimental when predicting new data. 

We will tune the model hyperparameters to avoid overfitting. Tuning the value of `cost_complexity` helps by [pruning](https://bradleyboehmke.github.io/HOML/DT.html#pruning) back our tree. It adds a cost, or penalty, to error rates of more complex trees; a cost closer to zero decreases the number tree nodes pruned and is more likely to result in an overfit tree. However, a high cost increases the number of tree nodes pruned and can result in the opposite problem &mdash; an underfit tree. Tuning `tree_depth`, on the other hand, helps by [stopping](https://bradleyboehmke.github.io/HOML/DT.html#early-stopping)  our tree from growing after it reaches a certain depth. We want to tune these hyperparameters to find what those two values should be for our model to do the best job predicting image segmentation. 

Before we start the tuning process, we split our data into training and testing sets, just like when we trained the model with one default set of hyperparameters. As [before](/notes/resampling/), we can use `strata = class` if we want our training and testing sets to be created using stratified sampling so that both have the same proportion of both kinds of segmentation.


```r
set.seed(123)
gss_split <- initial_split(gss, strata = colmslm)

gss_train <- training(gss_split)
gss_test  <- testing(gss_split)
```

We use the training data for tuning the model.

## Tuning hyperparameters {#tuning}

Let’s start with the `parsnip` package, using a [`decision_tree()`](https://tidymodels.github.io/parsnip/reference/decision_tree.html) model with the [rpart](https://cran.r-project.org/web/packages/rpart/index.html) engine. To tune the decision tree hyperparameters `cost_complexity` and `tree_depth`, we create a model specification that identifies which hyperparameters we plan to tune. 


```r
tune_spec <- 
  decision_tree(
    cost_complexity = tune(),
    tree_depth = tune()
  ) %>% 
  set_engine("rpart") %>% 
  set_mode("classification")

tune_spec
```

```
## Decision Tree Model Specification (classification)
## 
## Main Arguments:
##   cost_complexity = tune()
##   tree_depth = tune()
## 
## Computational engine: rpart
```

Think of `tune()` here as a placeholder. After the tuning process, we will select a single numeric value for each of these hyperparameters. For now, we specify our parsnip model object and identify the hyperparameters we will `tune()`.

We can't train this specification on a single data set (such as the entire training set) and learn what the hyperparameter values should be, but we _can_ train many models using resampled data and see which models turn out best. We can create a regular grid of values to try using some convenience functions for each hyperparameter:


```r
tree_grid <- grid_regular(cost_complexity(),
                          tree_depth(),
                          levels = 5)
```

The function [`grid_regular()`](https://tidymodels.github.io/dials/reference/grid_regular.html) is from the [dials](https://tidymodels.github.io/dials/) package. It chooses sensible values to try for each hyperparameter; here, we asked for 5 of each. Since we have two to tune, `grid_regular()` returns 5 $\times$ 5 = 25 different possible tuning combinations to try in a tidy tibble format.


```r
tree_grid
```

```
## # A tibble: 25 x 2
##    cost_complexity tree_depth
##              <dbl>      <int>
##  1    0.0000000001          1
##  2    0.0000000178          1
##  3    0.00000316            1
##  4    0.000562              1
##  5    0.1                   1
##  6    0.0000000001          4
##  7    0.0000000178          4
##  8    0.00000316            4
##  9    0.000562              4
## 10    0.1                   4
## # … with 15 more rows
```

Here, you can see all 5 values of `cost_complexity` ranging up to 0.1. These values get repeated for each of the 5 values of `tree_depth`:


```r
tree_grid %>% 
  count(tree_depth)
```

```
## # A tibble: 5 x 2
##   tree_depth     n
##        <int> <int>
## 1          1     5
## 2          4     5
## 3          8     5
## 4         11     5
## 5         15     5
```

Armed with our grid filled with 25 candidate decision tree models, let's create [cross-validation folds](/notes/resampling/) for tuning:


```r
set.seed(234)
gss_folds <- vfold_cv(gss_train)
```

Tuning in `tidymodels` requires a resampled object created with the [`rsample`](https://tidymodels.github.io/rsample/) package.

## Model tuning with a grid {#tune-grid}

We are ready to tune! Let's use [`tune_grid()`](https://tidymodels.github.io/tune/reference/tune_grid.html) to fit models at all the different values we chose for each tuned hyperparameter. There are several options for building the object for tuning:

+ Tune a model specification along with a recipe or model, or 

+ Tune a [`workflow()`](https://tidymodels.github.io/workflows/) that bundles together a model specification and a recipe or model preprocessor. 

Here we use a `workflow()` with a straightforward formula; if this model required more involved data preprocessing, we could use `add_recipe()` instead of `add_formula()`.


```r
set.seed(345)

tree_wf <- workflow() %>%
  add_model(tune_spec) %>%
  add_formula(colmslm ~ .)

tree_res <- 
  tree_wf %>% 
  tune_grid(
    resamples = gss_folds,
    grid = tree_grid
    )

tree_res
```

```
## # Tuning results
## # 10-fold cross-validation 
## # A tibble: 10 x 4
##    splits           id     .metrics          .notes          
##    <list>           <chr>  <list>            <list>          
##  1 <split [635/71]> Fold01 <tibble [50 × 6]> <tibble [0 × 1]>
##  2 <split [635/71]> Fold02 <tibble [50 × 6]> <tibble [0 × 1]>
##  3 <split [635/71]> Fold03 <tibble [50 × 6]> <tibble [0 × 1]>
##  4 <split [635/71]> Fold04 <tibble [50 × 6]> <tibble [0 × 1]>
##  5 <split [635/71]> Fold05 <tibble [50 × 6]> <tibble [0 × 1]>
##  6 <split [635/71]> Fold06 <tibble [50 × 6]> <tibble [0 × 1]>
##  7 <split [636/70]> Fold07 <tibble [50 × 6]> <tibble [0 × 1]>
##  8 <split [636/70]> Fold08 <tibble [50 × 6]> <tibble [0 × 1]>
##  9 <split [636/70]> Fold09 <tibble [50 × 6]> <tibble [0 × 1]>
## 10 <split [636/70]> Fold10 <tibble [50 × 6]> <tibble [0 × 1]>
```

Once we have our tuning results, we can both explore them through visualization and then select the best result. The function `collect_metrics()` gives us a tidy tibble with all the results. We had 25 candidate models and two metrics, `accuracy` and `roc_auc`, and we get a row for each `.metric` and model. 


```r
tree_res %>% 
  collect_metrics()
```

```
## # A tibble: 50 x 8
##    cost_complexity tree_depth .metric  .estimator  mean     n std_err .config
##              <dbl>      <int> <chr>    <chr>      <dbl> <int>   <dbl> <chr>  
##  1    0.0000000001          1 accuracy binary     0.812    10  0.0111 Model01
##  2    0.0000000001          1 roc_auc  binary     0.809    10  0.0108 Model01
##  3    0.0000000178          1 accuracy binary     0.812    10  0.0111 Model02
##  4    0.0000000178          1 roc_auc  binary     0.809    10  0.0108 Model02
##  5    0.00000316            1 accuracy binary     0.812    10  0.0111 Model03
##  6    0.00000316            1 roc_auc  binary     0.809    10  0.0108 Model03
##  7    0.000562              1 accuracy binary     0.812    10  0.0111 Model04
##  8    0.000562              1 roc_auc  binary     0.809    10  0.0108 Model04
##  9    0.1                   1 accuracy binary     0.812    10  0.0111 Model05
## 10    0.1                   1 roc_auc  binary     0.809    10  0.0108 Model05
## # … with 40 more rows
```

We might get more out of plotting these results:


```r
tree_res %>%
  collect_metrics() %>%
  mutate(tree_depth = factor(tree_depth)) %>%
  ggplot(aes(cost_complexity, mean, color = tree_depth)) +
  geom_line(size = 1.5, alpha = 0.6) +
  geom_point(size = 2) +
  facet_wrap(~ .metric, scales = "free", nrow = 2) +
  scale_x_log10(labels = scales::label_number()) +
  scale_color_viridis_d(option = "plasma", begin = .9, end = 0)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/best-tree-1.png" width="768" />

We can see that our "stubbiest" tree, with a depth of 1, is the worst model according to `roc_auc` (though surprisingly the most accurate) and across all candidate values of `cost_complexity`. Deeper trees tend to do better for this problem. However, the best tree seems to be between these values with a tree depth of 8. The [`show_best()`](https://tidymodels.github.io/tune/reference/show_best.html) function shows us the top 5 candidate models by default:


```r
tree_res %>%
  show_best("roc_auc")
```

```
## # A tibble: 5 x 8
##   cost_complexity tree_depth .metric .estimator  mean     n std_err .config
##             <dbl>      <int> <chr>   <chr>      <dbl> <int>   <dbl> <chr>  
## 1    0.0000000001          8 roc_auc binary     0.839    10  0.0157 Model11
## 2    0.0000000178          8 roc_auc binary     0.839    10  0.0157 Model12
## 3    0.00000316            8 roc_auc binary     0.839    10  0.0157 Model13
## 4    0.000562              8 roc_auc binary     0.839    10  0.0157 Model14
## 5    0.0000000001         15 roc_auc binary     0.838    10  0.0179 Model21
```

We can also use the [`select_best()`](https://tidymodels.github.io/tune/reference/show_best.html) function to pull out the single set of hyperparameter values for our best decision tree model:


```r
best_tree <- tree_res %>%
  select_best("roc_auc")

best_tree
```

```
## # A tibble: 1 x 3
##   cost_complexity tree_depth .config
##             <dbl>      <int> <chr>  
## 1    0.0000000001          8 Model11
```

These are the values for `tree_depth` and `cost_complexity` that maximize AUC in this data set of respondents. 

## Finalizing our model {#final-model}

We can update (or "finalize") our workflow object `tree_wf` with the values from `select_best()`. 


```r
final_wf <- 
  tree_wf %>% 
  finalize_workflow(best_tree)

final_wf
```

```
## ══ Workflow ════════════════════════════════════════════════════════════════════
## Preprocessor: Formula
## Model: decision_tree()
## 
## ── Preprocessor ────────────────────────────────────────────────────────────────
## colmslm ~ .
## 
## ── Model ───────────────────────────────────────────────────────────────────────
## Decision Tree Model Specification (classification)
## 
## Main Arguments:
##   cost_complexity = 1e-10
##   tree_depth = 8
## 
## Computational engine: rpart
```

Our tuning is done!

### Exploring results

Let's fit this final model to the training data. What does the decision tree look like?


```r
final_tree <- 
  final_wf %>%
  fit(data = gss_train) 

final_tree
```

```
## ══ Workflow [trained] ══════════════════════════════════════════════════════════
## Preprocessor: Formula
## Model: decision_tree()
## 
## ── Preprocessor ────────────────────────────────────────────────────────────────
## colmslm ~ .
## 
## ── Model ───────────────────────────────────────────────────────────────────────
## n= 706 
## 
## node), split, n, loss, yval, (yprob)
##       * denotes terminal node
## 
##   1) root 706 269 Not allowed (0.38101983 0.61898017)  
##     2) tolerance>=12.5 305  83 Yes, allowed (0.72786885 0.27213115)  
##       4) tolerance>=13.5 238  48 Yes, allowed (0.79831933 0.20168067)  
##         8) id< 1840 223  38 Yes, allowed (0.82959641 0.17040359)  
##          16) id>=1632.5 27   0 Yes, allowed (1.00000000 0.00000000) *
##          17) id< 1632.5 196  38 Yes, allowed (0.80612245 0.19387755)  
##            34) wtss>=1.697784 35   2 Yes, allowed (0.94285714 0.05714286) *
##            35) wtss< 1.697784 161  36 Yes, allowed (0.77639752 0.22360248)  
##              70) id< 463.5 44   4 Yes, allowed (0.90909091 0.09090909) *
##              71) id>=463.5 117  32 Yes, allowed (0.72649573 0.27350427)  
##               142) id>=595.5 103  24 Yes, allowed (0.76699029 0.23300971) *
##               143) id< 595.5 14   6 Not allowed (0.42857143 0.57142857) *
##         9) id>=1840 15   5 Not allowed (0.33333333 0.66666667) *
##       5) tolerance< 13.5 67  32 Not allowed (0.47761194 0.52238806)  
##        10) pray=SEVERAL TIMES A DAY,ONCE A DAY,SEVERAL TIMES A WEEK,LT ONCE A WEEK 55  24 Yes, allowed (0.56363636 0.43636364)  
##          20) polviews=ExtrmLib,Liberal,ExtrmCons 12   2 Yes, allowed (0.83333333 0.16666667) *
##          21) polviews=SlghtLib,Moderate,SlghtCons,Conserv 43  21 Not allowed (0.48837209 0.51162791)  
##            42) degree=HS,Junior Coll,Bachelor deg 35  15 Yes, allowed (0.57142857 0.42857143)  
##              84) sex=Male 14   3 Yes, allowed (0.78571429 0.21428571) *
##              85) sex=Female 21   9 Not allowed (0.42857143 0.57142857)  
##               170) degree=Junior Coll,Bachelor deg 10   4 Yes, allowed (0.60000000 0.40000000) *
##               171) degree=HS 11   3 Not allowed (0.27272727 0.72727273) *
##            43) degree=<HS,Graduate deg 8   1 Not allowed (0.12500000 0.87500000) *
##        11) pray=ONCE A WEEK,NEVER 12   1 Not allowed (0.08333333 0.91666667) *
##     3) tolerance< 12.5 401  47 Not allowed (0.11720698 0.88279302)  
##       6) id< 646.5 109  24 Not allowed (0.22018349 0.77981651)  
##        12) tolerance>=7.5 83  24 Not allowed (0.28915663 0.71084337)  
##          24) id>=570.5 7   1 Yes, allowed (0.85714286 0.14285714) *
##          25) id< 570.5 76  18 Not allowed (0.23684211 0.76315789)  
##            50) pray=SEVERAL TIMES A DAY,ONCE A DAY,NEVER 55  16 Not allowed (0.29090909 0.70909091)  
##             100) polviews=ExtrmLib,Liberal,ExtrmCons 10   4 Yes, allowed (0.60000000 0.40000000) *
##             101) polviews=SlghtLib,Moderate,SlghtCons,Conserv 45  10 Not allowed (0.22222222 0.77777778)  
##               202) age< 59.5 33  10 Not allowed (0.30303030 0.69696970)  
##                 404) age>=53.5 9   4 Yes, allowed (0.55555556 0.44444444) *
##                 405) age< 53.5 24   5 Not allowed (0.20833333 0.79166667) *
##               203) age>=59.5 12   0 Not allowed (0.00000000 1.00000000) *
##            51) pray=SEVERAL TIMES A WEEK,ONCE A WEEK,LT ONCE A WEEK 21   2 Not allowed (0.09523810 0.90476190) *
##        13) tolerance< 7.5 26   0 Not allowed (0.00000000 1.00000000) *
##       7) id>=646.5 292  23 Not allowed (0.07876712 0.92123288)  
##        14) age< 26.5 36   9 Not allowed (0.25000000 0.75000000)  
##          28) pray=ONCE A DAY,SEVERAL TIMES A WEEK,ONCE A WEEK,NEVER 25   9 Not allowed (0.36000000 0.64000000)  
##            56) polviews=Liberal,SlghtLib 7   3 Yes, allowed (0.57142857 0.42857143) *
##            57) polviews=Moderate,SlghtCons 18   5 Not allowed (0.27777778 0.72222222) *
##          29) pray=SEVERAL TIMES A DAY,LT ONCE A WEEK 11   0 Not allowed (0.00000000 1.00000000) *
##        15) age>=26.5 256  14 Not allowed (0.05468750 0.94531250) *
## 
## ...
## and 0 more lines.
```

This `final_tree` object has the finalized, fitted model object inside. You may want to extract the model object from the workflow. To do this, you can use the helper function [`pull_workflow_fit()`](https://tidymodels.github.io/workflows/reference/workflow-extractors.html).

For example, perhaps we would also like to understand what variables are important in this final model. We can use the [vip](https://koalaverse.github.io/vip/) package to estimate variable importance. 


```r
library(vip)

final_tree %>% 
  pull_workflow_fit() %>% 
  vip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/vip-1.png" width="576" />

These are the survey variables that are the most important in driving predictions on the Muslim clergymen question.

### The last fit

Finally, let's return to our test data and estimate the model performance we expect to see with new data. We can use the function [`last_fit()`](https://tidymodels.github.io/tune/reference/last_fit.html) with our finalized model; this function _fits_ the finalized model on the full training data set and _evaluates_ the finalized model on the testing data.


```r
final_fit <- 
  final_wf %>%
  last_fit(gss_split) 

final_fit %>%
  collect_metrics()
```

```
## # A tibble: 2 x 3
##   .metric  .estimator .estimate
##   <chr>    <chr>          <dbl>
## 1 accuracy binary         0.765
## 2 roc_auc  binary         0.801
```

```r
final_fit %>%
  collect_predictions() %>% 
  roc_curve(colmslm, `.pred_Yes, allowed`) %>% 
  autoplot()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/last-fit-1.png" width="672" />

The performance metrics from the test set indicate that we did not overfit during our tuning procedure.

We leave it to the reader to explore whether you can tune a different decision tree hyperparameter. You can explore the [reference docs](http://tidymodels.org/find/parsnip/#models), or use the `args()` function to see which parsnip object arguments are available:


```r
args(decision_tree)
```

```
## function (mode = "unknown", cost_complexity = NULL, tree_depth = NULL, 
##     min_n = NULL) 
## NULL
```

You could tune the other hyperparameter we didn't use here, `min_n`, which sets the minimum `n` to split at any node. This is another early stopping method for decision trees that can help prevent overfitting. Use this [searchable table](http://tidymodels.org/find/parsnip/#model-args) to find the original argument for `min_n` in the `rpart` package ([hint](https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.control.html)). See whether you can tune a different combination of hyperparameters and/or values to improve a tree's ability to predict respondents' answers.

## Acknowledgments

Example drawn from [Get Started - Tune model parameters](https://www.tidymodels.org/start/tuning/) and licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

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
##  class         7.3-17     2020-04-26 [1] CRAN (R 4.0.3)                      
##  cli           2.2.0      2020-11-20 [1] CRAN (R 4.0.2)                      
##  codetools     0.2-18     2020-11-04 [1] CRAN (R 4.0.2)                      
##  colorspace    2.0-0      2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon        1.3.4      2017-09-16 [1] CRAN (R 4.0.0)                      
##  desc          1.2.0      2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools      2.3.2      2020-09-18 [1] CRAN (R 4.0.2)                      
##  dials       * 0.0.9      2020-09-16 [1] CRAN (R 4.0.2)                      
##  DiceDesign    1.8-1      2019-07-31 [1] CRAN (R 4.0.0)                      
##  digest        0.6.27     2020-10-24 [1] CRAN (R 4.0.2)                      
##  doParallel    1.0.16     2020-10-16 [1] CRAN (R 4.0.2)                      
##  dplyr       * 1.0.2      2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis      0.3.1      2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi         0.4.1      2020-01-08 [1] CRAN (R 4.0.0)                      
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
##  gridExtra     2.3        2017-09-09 [1] CRAN (R 4.0.0)                      
##  gtable        0.3.0      2019-03-25 [1] CRAN (R 4.0.0)                      
##  here          1.0.1      2020-12-13 [1] CRAN (R 4.0.2)                      
##  htmltools     0.5.1.1    2021-01-22 [1] CRAN (R 4.0.2)                      
##  httr          1.4.2      2020-07-20 [1] CRAN (R 4.0.2)                      
##  infer       * 0.5.3      2020-07-14 [1] CRAN (R 4.0.2)                      
##  ipred         0.9-9      2019-04-28 [1] CRAN (R 4.0.0)                      
##  iterators     1.0.13     2020-10-15 [1] CRAN (R 4.0.2)                      
##  kableExtra  * 1.3.1      2020-10-22 [1] CRAN (R 4.0.2)                      
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
##  Rcpp          1.0.6      2021-01-15 [1] CRAN (R 4.0.2)                      
##  recipes     * 0.1.15     2020-11-11 [1] CRAN (R 4.0.2)                      
##  remotes       2.2.0      2020-07-21 [1] CRAN (R 4.0.2)                      
##  rlang         0.4.10     2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown     2.6        2020-12-14 [1] CRAN (R 4.0.2)                      
##  rpart       * 4.1-15     2019-04-12 [1] CRAN (R 4.0.3)                      
##  rprojroot     2.0.2      2020-11-15 [1] CRAN (R 4.0.2)                      
##  rsample     * 0.0.8      2020-09-23 [1] CRAN (R 4.0.2)                      
##  rstudioapi    0.13       2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest         0.3.6      2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales      * 1.1.1      2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr       1.4.0      2019-02-10 [1] CRAN (R 4.0.0)                      
##  survival      3.2-7      2020-09-28 [1] CRAN (R 4.0.3)                      
##  testthat      3.0.1      2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble      * 3.0.4      2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidymodels  * 0.1.2      2020-11-22 [1] CRAN (R 4.0.2)                      
##  tidyr       * 1.1.2      2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect    1.1.0      2020-05-11 [1] CRAN (R 4.0.0)                      
##  timeDate      3043.102   2018-02-21 [1] CRAN (R 4.0.0)                      
##  tune        * 0.1.2      2020-11-17 [1] CRAN (R 4.0.2)                      
##  usethis       2.0.0      2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs         0.3.6      2020-12-17 [1] CRAN (R 4.0.2)                      
##  vip         * 0.3.2      2020-12-17 [1] CRAN (R 4.0.2)                      
##  viridisLite   0.3.0      2018-02-01 [1] CRAN (R 4.0.0)                      
##  webshot       0.5.2      2019-11-22 [1] CRAN (R 4.0.0)                      
##  withr         2.3.0      2020-09-22 [1] CRAN (R 4.0.2)                      
##  workflows   * 0.2.1      2020-10-08 [1] CRAN (R 4.0.2)                      
##  xfun          0.21       2021-02-10 [1] CRAN (R 4.0.2)                      
##  xml2          1.3.2      2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.0)                      
##  yardstick   * 0.0.7      2020-07-13 [1] CRAN (R 4.0.2)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
