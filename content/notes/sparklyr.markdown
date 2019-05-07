---
title: "Spark and sparklyr"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/distrib003_spark.html"]
categories: ["distributed-computing"]

menu:
  notes:
    parent: Distributed computing
    weight: 3
---




```r
library(rsparkling)
library(sparklyr)
library(h2o)
library(tidyverse)

set.seed(1234)
theme_set(theme_minimal())
```

## Hadoop and Spark

[Apache Hadoop](http://hadoop.apache.org/) is an open-source software library that enables distributed processing of large data sets across clusters of computers. It is highly **scalable**, in that can be loaded on a single server or spread across thousands of separate machines. It includes several modules including the Hadoop Distributed File System (HDFS) for distributed file storage, Hadoop MapReduce for parallel processing of large data sets, and [Spark](http://spark.apache.org/), a general engine for large-scale data processing, including statistical learning.

## `sparklyr` {#sparklyr}

Learning to use Hadoop and Spark can be very complicated. They use their own programming language to specify functions and perform operations. In this class, we will interact with Spark through [`sparklyr`](http://spark.rstudio.com/), a package in R from the same authors of RStudio and the `tidyverse`. This allows us to:

* Connect to Spark from R using the `dplyr` interface
* Interact with SQL databases stored on a Spark cluster
* Implement distributed [statistical learning](/notes/statistical-learning/) algorithms

See [here](http://spark.rstudio.com/) for more detailed instructions for setting up and using `sparklyr`.

### Installation

First you need to install `sparklyr`:

```r
install.packages("sparklyr")
```

You also need to install a local version of Spark to run it on your computer:

```r
library(sparklyr)
spark_install(version = "2.1.0")
```

### Connecting to Spark

You can connect to both local instances of Spark as well as remote Spark clusters. Let's use the `spark_connect()` function to connect to a local cluster built on our computer:


```r
library(sparklyr)
sc <- spark_connect(master = "local")
```

## Machine learning with Spark

You can use `sparklyr` to fit a wide range of machine learning algorithms in Apache Spark. Rather than using `caret::train()`, you use a set of `ml_` functions depending on which algorithm you want to employ.

## Load the data

Let's continue using the Titanic dataset. First, load the `titanic` package, which contains the data files we have been using for past statistical learning exercises, into the local Spark cluster:


```r
library(titanic)
(titanic_tbl <- copy_to(sc, titanic::titanic_train, "titanic", overwrite = TRUE))
```

```
## # Source: spark<titanic> [?? x 12]
##    PassengerId Survived Pclass Name  Sex     Age SibSp Parch Ticket  Fare
##          <int>    <int>  <int> <chr> <chr> <dbl> <int> <int> <chr>  <dbl>
##  1           1        0      3 Brau… male     22     1     0 A/5 2…  7.25
##  2           2        1      1 Cumi… fema…    38     1     0 PC 17… 71.3 
##  3           3        1      3 Heik… fema…    26     0     0 STON/…  7.92
##  4           4        1      1 Futr… fema…    35     1     0 113803 53.1 
##  5           5        0      3 Alle… male     35     0     0 373450  8.05
##  6           6        0      3 Mora… male    NaN     0     0 330877  8.46
##  7           7        0      1 McCa… male     54     0     0 17463  51.9 
##  8           8        0      3 Pals… male      2     3     1 349909 21.1 
##  9           9        1      3 John… fema…    27     0     2 347742 11.1 
## 10          10        1      2 Nass… fema…    14     1     0 237736 30.1 
## # … with more rows, and 2 more variables: Cabin <chr>, Embarked <chr>
```

## Tidy the data

You can use `dplyr` syntax to tidy and reshape data in Spark, as well as specialized functions from the [Spark machine learning library](http://spark.apache.org/docs/latest/ml-features.html).

### Spark SQL transforms

These are **feature transforms** (aka mutating or filtering the columns/rows) using Spark SQL. This allows you to create new columns and modify existing columns while still employing the `dplyr` syntax. Here let's modify 4 columns:

1. `Family_Size` - create number of siblings and parents
1. `Pclass` - format passenger class as character not numeric
1. `Embarked` - remove a small number of missing records
1. `Age` - impute missing age with average age

We use `sdf_register()` at the end of the operation to store the table in the Spark cluster.


```r
titanic2_tbl <- titanic_tbl %>% 
  mutate(Family_Size = SibSp + Parch + 1L) %>% 
  mutate(Pclass = as.character(Pclass)) %>%
  filter(!is.na(Embarked), Embarked != "") %>%
  mutate(Age = if_else(is.na(Age), mean(Age), Age)) %>%
  sdf_register("titanic2")
```

### Spark ML transforms

Spark also includes several functions to transform features. We can access several of them [directly through `sparklyr`](http://spark.rstudio.com/reference/sparklyr/latest/index.html). For instance, to transform `Family_Sizes` into bins, use `ft_bucketizer()`.


```r
titanic_final_tbl <- titanic2_tbl %>%
  mutate(Family_Size = as.numeric(Family_size)) %>%
  ft_bucketizer(input_col = "Family_Size",
                output_col = "Family_Sizes",
                splits = c(1,2,5,12)) %>%
  mutate(Family_Sizes = as.character(as.integer(Family_Sizes))) %>%
  sdf_register("titanic_final")
```

> `ft_bucketizer()` is equivalent to `cut()` in R.

### Train-validation split

Randomly partition the data into training/test sets.


```r
# Partition the data
partition <- titanic_final_tbl %>% 
  mutate(Survived = as.numeric(Survived),
         SibSp = as.numeric(SibSp),
         Parch = as.numeric(Parch)) %>%
  select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked, Family_Sizes) %>%
  sdf_partition(train = 0.75, test = 0.25, seed = 1234)

# Create table references
train_tbl <- partition$train
test_tbl <- partition$test
```

## Train the models

Spark ML includes several types of machine learning algorithms. We can use these algorithms to fit models using the training data, then evaluate model performance using the test data.

### Logistic regression


```r
# Model survival as a function of several predictors
ml_formula <- formula(Survived ~ Pclass + Sex + Age + SibSp +
                        Parch + Fare + Embarked + Family_Sizes)

# Train a logistic regression model
(ml_log <- ml_logistic_regression(train_tbl, ml_formula))
```

```
## Formula: Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Family_Sizes
## 
## Coefficients:
##    (Intercept)       Pclass_3       Pclass_1       Sex_male            Age 
##   -0.941224041   -0.951432266    1.102333020   -2.786064873   -0.035430214 
##          SibSp          Parch           Fare     Embarked_S     Embarked_C 
##    0.158166815    0.457386427    0.002039045   -0.373681708   -0.214559272 
## Family_Sizes_0 Family_Sizes_1 
##    3.749924209    3.443534112
```

### Other machine learning algorithms

Run the same formula using the other machine learning algorithms. Notice that training times vary greatly between methods.


```r
# Decision Tree
ml_dt <- ml_decision_tree(train_tbl, ml_formula)

# Random Forest
ml_rf <- ml_random_forest(train_tbl, ml_formula)

# Gradient Boosted Tree
ml_gbt <- ml_gradient_boosted_trees(train_tbl, ml_formula)

# Naive Bayes
ml_nb <- ml_naive_bayes(train_tbl, ml_formula)

# Neural Network
ml_nn <- ml_multilayer_perceptron(train_tbl, ml_formula, layers = c(11, 15, 2))
```

### Validation data


```r
# Bundle the models into a single list object
ml_models <- list(
  "Logistic" = ml_log,
  "Decision Tree" = ml_dt,
  "Random Forest" = ml_rf,
  "Gradient Boosted Trees" = ml_gbt,
  "Naive Bayes" = ml_nb,
  "Neural Net" = ml_nn
)

# Create a function for scoring
score_test_data <- function(model, data = test_tbl){
  pred <- sdf_predict(data, model)
  select(pred, Survived, prediction)
}

# Score all the models
ml_score <- map(ml_models, score_test_data)
```

## Compare results

To pick the best model, compare the test set results by examining performance metrics: lift, accuracy, and [area under the curve (AUC)](https://en.wikipedia.org/wiki/Receiver_operating_characteristic).

## Model lift

**Lift** compares how well the model predicts survival compared to random guessing. The function below calculates the model lift for each scored decile in the test data.


```r
# Lift function
calculate_lift <- function(scored_data) {
  scored_data %>%
    mutate(bin = ntile(desc(prediction), 10)) %>% 
    group_by(bin) %>% 
    summarize(count = sum(Survived)) %>% 
    mutate(prop = count / sum(count)) %>% 
    arrange(bin) %>% 
    mutate(prop = cumsum(prop)) %>% 
    select(-count) %>% 
    collect() %>% 
    as.data.frame()
}

# Initialize results
ml_gains <- tibble(
  bin = seq(from = 1, to = 10),
  prop = seq(0, 1, len = 10),
  model = "Base"
)

# Calculate lift
for(i in names(ml_score)){
  ml_gains <- ml_score[[i]] %>%
    calculate_lift %>%
    mutate(model = i) %>%
    bind_rows(ml_gains, .)
}

# Plot results
ggplot(ml_gains, aes(x = bin, y = prop, color = model)) +
  geom_point() +
  geom_line() +
  scale_color_brewer(type = "qual") +
  labs(title = "Lift Chart for Predicting Survival",
       subtitle = "Test Data Set",
       x = NULL,
       y = NULL)
```

<img src="/notes/sparklyr_files/figure-html/model-lift-1.png" width="672" />

The lift chart suggests the tree-based models (random forest, gradient boosted trees, and decision tree) provide the best prediction.

## Accuracy and AUC

**Receiver operating characteristic (ROC) curves** are graphical plots that illustrate the performance of a binary classifier. They visualize the relationship between the true positive rate (TPR) against the false positive rate (FPR).

![From [Receiver operating characteristic](https://en.wikipedia.org/wiki/Receiver_operating_characteristic)](https://upload.wikimedia.org/wikipedia/commons/3/36/ROC_space-2.png)

![From [Receiver operating characteristic](https://en.wikipedia.org/wiki/Receiver_operating_characteristic)](https://upload.wikimedia.org/wikipedia/commons/6/6b/Roccurves.png)

The ideal model perfectly classifies all positive outcomes as true and all negative outcomes as false (i.e. TPR = 1 and FPR = 0). The line on the second graph is made by calculating predicted outcomes at different cutpoint thresholds (i.e. `\(.1, .2, .5, .8\)`) and connecting the dots. The diagonal line indicates expected true/false positive rates if you guessed at random. The area under the curve (AUC) summarizes how good the model is across these threshold points simultaneously. An area of 1 indicates that for any threshold value, the model always makes perfect preditions. **This will almost never occur in real life.** Good AUC values are between `\(.6\)` and `\(.8\)`. While we cannot draw the ROC graph using Spark, we can extract the AUC values based on the predictions.


```r
# Function for calculating accuracy
calc_accuracy <- function(data, cutpoint = 0.5){
  data %>% 
    mutate(prediction = if_else(prediction > cutpoint, 1.0, 0.0)) %>%
    ml_classification_eval("prediction", "Survived", "accuracy")
}

# Calculate AUC and accuracy
perf_metrics <- tibble(
  model = names(ml_score),
  AUC = 100 * map_dbl(ml_score, ml_binary_classification_eval, "Survived", "prediction"),
  Accuracy = 100 * map_dbl(ml_score, calc_accuracy)
  )
perf_metrics
```

```
## # A tibble: 6 x 3
##   model                    AUC Accuracy
##   <chr>                  <dbl>    <dbl>
## 1 Logistic                81.0     82.4
## 2 Decision Tree           85.0     77.6
## 3 Random Forest           87.5     80.5
## 4 Gradient Boosted Trees  82.9     80  
## 5 Naive Bayes             66.5     69.3
## 6 Neural Net              79.8     80.5
```

```r
# Plot results
gather(perf_metrics, metric, value, AUC, Accuracy) %>%
  ggplot(aes(reorder(model, value), value, fill = metric)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  coord_flip() +
  labs(title = "Performance metrics",
       x = NULL,
       y = "Percent")
```

<img src="/notes/sparklyr_files/figure-html/titanic_eval-1.png" width="672" />

Overall it appears the tree-based models performed the best - they had the highest accuracy rates and AUC values.

## Feature importance

It is also interesting to compare the features that were identified by each model as being important predictors for survival. The tree models implement feature importance metrics (a la `randomForest::varImpPlot()`. Sex, fare, and age are some of the most important features.


```r
# Initialize results
feature_importance <- tibble()

# Calculate feature importance
for(i in c("Decision Tree", "Random Forest", "Gradient Boosted Trees")){
  feature_importance <- ml_tree_feature_importance(ml_models[[i]]) %>%
    mutate(Model = i) %>%
    rbind(feature_importance, .)
}

# Plot results
feature_importance %>%
  ggplot(aes(reorder(feature, importance), importance, fill = Model)) + 
  facet_wrap(~Model) +
  geom_bar(stat = "identity") + 
  coord_flip() +
  labs(title = "Feature importance",
       x = NULL) +
  theme(legend.position = "none")
```

<img src="/notes/sparklyr_files/figure-html/titanic_feature-1.png" width="672" />

## Compare run times

The time to train a model is important. Some algorithms are more complex than others, so sometimes you need to balance the trade-off between accuracy and efficiency. The following code evaluates each model `n` times and plots the results. Notice that gradient boosted trees and neural nets take considerably longer to train than the other methods.


```r
# Number of reps per model
n <- 10

# Format model formula as character
format_as_character <- function(x){
  x <- paste(deparse(x), collapse = "")
  x <- gsub("\\s+", " ", paste(x, collapse = ""))
  x
}

# Create model statements with timers
format_statements <- function(y){
  y <- format_as_character(y[[".call"]])
  y <- gsub('ml_formula', ml_formula_char, y)
  y <- paste0("system.time(", y, ")")
  y
}

# Convert model formula to character
ml_formula_char <- format_as_character(ml_formula)

# Create n replicates of each model statements with timers
all_statements <- map_chr(ml_models, format_statements) %>%
  rep(., n) %>%
  parse(text = .)

# Evaluate all model statements
res <- map(all_statements, eval)

# Compile results
result <- tibble(model = rep(names(ml_models), n),
                 time = map_dbl(res, function(x){as.numeric(x["elapsed"])})) 

# Plot
result %>%
  ggplot(aes(time, reorder(model, time))) + 
  geom_boxplot() + 
  geom_jitter(width = 0.4, aes(color = model)) +
  scale_color_discrete(guide = FALSE) +
  labs(title = "Model training times",
       x = "Seconds",
       y = NULL)
```

<img src="/notes/sparklyr_files/figure-html/titanic_compare_runtime-1.png" width="672" />

## Sparkling Water (H2O) and machine learning

Where's the LOOCV? Where's the `\(k\)`-fold cross validation? Well, `sparklyr` is still under development. It doesn't allow you to do every single thing Spark can do. The functions we used above to estimate the models are part of **Spark’s distributed [machine learning library](https://spark.apache.org/docs/latest/mllib-guide.html)** (MLlib). MLlib contains [cross-validation functions](http://spark.apache.org/docs/latest/ml-tuning.html#cross-validation) - there just isn't an interface to them in `sparklyr` [yet](https://github.com/rstudio/sparklyr/issues/196).^[In refreshing my notes for the term, I saw CV was just incorporated into the development version of `sparklyr` but it is not yet deployed on CRAN.] A real drag.

If you are serious about utilizing Spark and need cross-validation and other more robust machine learning tools, another option is [**H2O**](https://www.h2o.ai/h2o/), an alternative open-source cross-platform machine learning software package. The `rsparkling` package provides functions to access H2O's distributed [machine learning functions](https://www.h2o.ai/h2o/machine-learning/) via `sparklyr`. H2O has many of the same features as MLlib (if not more so through `sparklyr`), however implementing it is a bit more complicated. Hence we focused most our code above on MLlib algorithms.

### H2O and logistic regression

As a quick demonstration, let's estimate a logistic regression model with 10-fold CV using H2O. First we need to load some additional packages:


```r
library(rsparkling)
library(h2o)
```

We will reuse the previously modified Titanic table `titanic_final_tbl`. However to use it with H2O functions, we need to convert it to an H2O data frame:


```r
titanic_h2o <- titanic_final_tbl %>% 
  mutate(Survived = as.numeric(Survived),
         SibSp = as.numeric(SibSp),
         Parch = as.numeric(Parch)) %>%
  select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked, Family_Sizes) %>%
  as_h2o_frame(sc, ., strict_version_check = FALSE)
```

Next we can estimate the logistic regression model using `h2o.glm()`.

* This function does not use a formula to pass in the indepenent and dependent variables; instead they are passed as character vector arguments to `x` and `y`
* `family = "binomial"` - ensure we run logistic regression, not linear regression for continuous dependent variables
* `training_frame` - data frame containing the training set (here we use the entire data frame because we also use cross-validation)
* `lambda_search = TRUE` - argument for the optimizer function to calculate the parameter values
* `nfolds = 10` - estimate the model using 10-fold cross-validation


```r
glm_model <- h2o.glm(x = c("Pclass", "Sex", "Age", "SibSp", "Parch",
                           "Fare", "Embarked", "Family_Sizes"), 
                     y = "Survived",
                     family = "binomial",
                     training_frame = titanic_h2o,
                     lambda_search = TRUE,
                     nfolds = 10)
```

```
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |========================                                         |  36%
  |                                                                       
  |=================================================================| 100%
```

```r
glm_model
```

```
## Model Details:
## ==============
## 
## H2OBinomialModel: glm
## Model ID:  GLM_model_R_1553795420603_1 
## GLM Model: summary
##     family  link                               regularization
## 1 binomial logit Elastic Net (alpha = 0.5, lambda = 0.00454 )
##                                                                   lambda_search
## 1 nlambda = 100, lambda.max = 0.248, lambda.min = 0.00454, lambda.1se = 0.04234
##   number_of_predictors_total number_of_active_predictors
## 1                          4                           4
##   number_of_iterations                                  training_frame
## 1                   66 frame_rdd_1483_88ddbcb42d2a296fc1b2c1a09d154075
## 
## Coefficients: glm coefficients
##       names coefficients standardized_coefficients
## 1 Intercept    -0.247725                 -0.456082
## 2       Age    -0.021755                 -0.282125
## 3     SibSp    -0.278618                 -0.307512
## 4     Parch     0.097131                  0.078361
## 5      Fare     0.016993                  0.844486
## 
## H2OBinomialMetrics: glm
## ** Reported on training data. **
## 
## MSE:  0.2087326
## RMSE:  0.4568726
## LogLoss:  0.6123973
## Mean Per-Class Error:  0.3641755
## AUC:  0.7074226
## pr_auc:  0.6091871
## Gini:  0.4148452
## R^2:  0.1162235
## Residual Deviance:  1088.842
## AIC:  1098.842
## 
## Confusion Matrix (vertical: actual; across: predicted) for F1-optimal threshold:
##          0   1    Error      Rate
## 0      288 261 0.475410  =261/549
## 1       86 254 0.252941   =86/340
## Totals 374 515 0.390326  =347/889
## 
## Maximum Metrics: Maximum metrics at their respective thresholds
##                         metric threshold    value idx
## 1                       max f1  0.323235 0.594152 268
## 2                       max f2  0.177828 0.759268 395
## 3                 max f0point5  0.397845 0.646825 169
## 4                 max accuracy  0.397845 0.725534 169
## 5                max precision  0.999557 1.000000   0
## 6                   max recall  0.177828 1.000000 395
## 7              max specificity  0.999557 1.000000   0
## 8             max absolute_mcc  0.397845 0.396588 169
## 9   max min_per_class_accuracy  0.348824 0.632353 231
## 10 max mean_per_class_accuracy  0.397845 0.678686 169
## 
## Gains/Lift Table: Extract with `h2o.gainsLift(<model>, <data>)` or `h2o.gainsLift(<model>, valid=<T/F>, xval=<T/F>)`
## 
## H2OBinomialMetrics: glm
## ** Reported on cross-validation data. **
## ** 10-fold cross-validation on training data (Metrics computed for combined holdout predictions) **
## 
## MSE:  0.2110744
## RMSE:  0.4594283
## LogLoss:  0.6200238
## Mean Per-Class Error:  0.373141
## AUC:  0.6969088
## pr_auc:  0.5910164
## Gini:  0.3938176
## R^2:  0.1063082
## Residual Deviance:  1102.402
## AIC:  1112.402
## 
## Confusion Matrix (vertical: actual; across: predicted) for F1-optimal threshold:
##          0   1    Error      Rate
## 0      283 266 0.484517  =266/549
## 1       89 251 0.261765   =89/340
## Totals 372 517 0.399325  =355/889
## 
## Maximum Metrics: Maximum metrics at their respective thresholds
##                         metric threshold    value idx
## 1                       max f1  0.323694 0.585764 255
## 2                       max f2  0.182015 0.759268 389
## 3                 max f0point5  0.398319 0.629006 158
## 4                 max accuracy  0.398319 0.715411 158
## 5                max precision  0.999666 1.000000   0
## 6                   max recall  0.182015 1.000000 389
## 7              max specificity  0.999666 1.000000   0
## 8             max absolute_mcc  0.398319 0.372536 158
## 9   max min_per_class_accuracy  0.346878 0.635701 223
## 10 max mean_per_class_accuracy  0.383650 0.669712 174
## 
## Gains/Lift Table: Extract with `h2o.gainsLift(<model>, <data>)` or `h2o.gainsLift(<model>, valid=<T/F>, xval=<T/F>)`
## Cross-Validation Metrics Summary: 
##                 mean          sd cv_1_valid cv_2_valid cv_3_valid
## accuracy   0.6363816 0.081763744  0.7352941 0.53571427  0.5121951
## auc       0.70465577 0.025236415  0.6798419  0.6637249 0.71381384
## err       0.36361834 0.081763744  0.2647059  0.4642857  0.4878049
## err_count       32.5    8.113261       18.0       39.0       40.0
## f0point5  0.58311796  0.06883179  0.5882353  0.4915254  0.5362319
##           cv_4_valid cv_5_valid cv_6_valid cv_7_valid cv_8_valid
## accuracy   0.5483871 0.48863637 0.81395346   0.537037  0.7108434
## auc        0.6968811 0.65290177 0.77008796    0.68125 0.71526057
## err        0.4516129  0.5113636 0.18604651 0.46296296 0.28915662
## err_count       42.0       45.0       16.0       50.0       24.0
## f0point5   0.5092593 0.46686748  0.7723577 0.49202126 0.61290324
##           cv_9_valid cv_10_valid
## accuracy  0.74311924   0.7386364
## auc        0.7546584  0.71813726
## err       0.25688073  0.26136363
## err_count       28.0        23.0
## f0point5  0.70388347  0.65789473
## 
## ---
##                         mean          sd cv_1_valid cv_2_valid  cv_3_valid
## precision         0.56370723   0.0937683        0.6 0.43939394  0.48051947
## r2                0.09700534 0.028344909 0.13034455 0.05100168 0.058908857
## recall            0.78828907 0.118836045 0.54545456  0.9354839         1.0
## residual_deviance 109.340614   10.753652  76.485695    107.024   107.88405
## rmse              0.46016112 0.008946765  0.4362696 0.47008047  0.48273537
## specificity       0.53406245  0.20690754 0.82608694  0.3018868  0.11111111
##                   cv_4_valid cv_5_valid  cv_6_valid cv_7_valid cv_8_valid
## precision         0.45833334 0.41333333  0.82608694 0.44047618 0.61290324
## r2                0.10442999 0.09471381 0.108684175 0.04697987 0.07101416
## recall             0.9166667    0.96875  0.61290324      0.925 0.61290324
## residual_deviance  115.83938 106.614815   103.72015  137.37405   104.6229
## rmse              0.46095178  0.4576983  0.45329356 0.47142404  0.4662394
## specificity       0.31578946 0.21428572  0.92727274 0.30882353  0.7692308
##                   cv_9_valid cv_10_valid
## precision              0.725  0.64102566
## r2                0.18336025 0.120616004
## recall             0.6304348   0.7352941
## residual_deviance  127.44652   106.39462
## rmse              0.44631138   0.4566074
## specificity       0.82539684   0.7407407
```

We get lots of information back about the model. Many of these statistics can be extracted and stored as tidy data frames or used to create visualizations.

### Acknowledgments

* Titanic machine learning example drawn from [Comparison of ML Classifiers Using Sparklyr](https://beta.rstudioconnect.com/content/1518/notebook-classification.html)

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
##  package     * version   date       lib source        
##  askpass       1.1       2019-01-13 [2] CRAN (R 3.5.2)
##  assertthat    0.2.1     2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.3     2018-12-14 [2] CRAN (R 3.5.0)
##  base64enc     0.1-3     2015-07-28 [2] CRAN (R 3.5.0)
##  bitops        1.0-6     2013-08-17 [2] CRAN (R 3.5.0)
##  blogdown      0.11      2019-03-11 [1] CRAN (R 3.5.2)
##  bookdown      0.9       2018-12-21 [1] CRAN (R 3.5.0)
##  broom         0.5.1     2018-12-05 [2] CRAN (R 3.5.0)
##  callr         3.2.0     2019-03-15 [2] CRAN (R 3.5.2)
##  cellranger    1.1.0     2016-07-27 [2] CRAN (R 3.5.0)
##  cli           1.1.0     2019-03-19 [1] CRAN (R 3.5.2)
##  colorspace    1.4-1     2019-03-18 [2] CRAN (R 3.5.2)
##  config        0.3       2018-03-27 [2] CRAN (R 3.5.0)
##  crayon        1.3.4     2017-09-16 [2] CRAN (R 3.5.0)
##  DBI           1.0.0     2018-05-02 [2] CRAN (R 3.5.0)
##  dbplyr        1.3.0     2019-01-09 [2] CRAN (R 3.5.2)
##  desc          1.2.0     2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.1     2018-10-26 [1] CRAN (R 3.5.1)
##  digest        0.6.18    2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr       * 0.8.0.1   2019-02-15 [1] CRAN (R 3.5.2)
##  ellipsis      0.1.0     2019-02-19 [2] CRAN (R 3.5.2)
##  evaluate      0.13      2019-02-12 [2] CRAN (R 3.5.2)
##  fansi         0.4.0     2018-10-05 [2] CRAN (R 3.5.0)
##  forcats     * 0.4.0     2019-02-17 [2] CRAN (R 3.5.2)
##  forge         0.2.0     2019-02-26 [2] CRAN (R 3.5.2)
##  fs            1.2.7     2019-03-19 [1] CRAN (R 3.5.3)
##  generics      0.0.2     2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2     * 3.1.0     2018-10-25 [1] CRAN (R 3.5.0)
##  glue          1.3.1     2019-03-12 [2] CRAN (R 3.5.2)
##  gtable        0.2.0     2016-02-26 [2] CRAN (R 3.5.0)
##  h2o         * 3.22.1.1  2019-01-10 [2] CRAN (R 3.5.2)
##  haven         2.1.0     2019-02-19 [2] CRAN (R 3.5.2)
##  here          0.1       2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2     2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6     2017-04-28 [1] CRAN (R 3.5.0)
##  htmlwidgets   1.3       2018-09-30 [2] CRAN (R 3.5.0)
##  httr          1.4.0     2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite      1.6       2018-12-07 [2] CRAN (R 3.5.0)
##  knitr         1.22      2019-03-08 [2] CRAN (R 3.5.2)
##  lattice       0.20-38   2018-11-04 [2] CRAN (R 3.5.3)
##  lazyeval      0.2.2     2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate     1.7.4     2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr      1.5       2014-11-22 [2] CRAN (R 3.5.0)
##  memoise       1.1.0     2017-04-21 [2] CRAN (R 3.5.0)
##  modelr        0.1.4     2019-02-18 [2] CRAN (R 3.5.2)
##  munsell       0.5.0     2018-06-12 [2] CRAN (R 3.5.0)
##  nlme          3.1-137   2018-04-07 [2] CRAN (R 3.5.3)
##  openssl       1.3       2019-03-22 [2] CRAN (R 3.5.3)
##  pillar        1.3.1     2018-12-15 [2] CRAN (R 3.5.0)
##  pkgbuild      1.0.3     2019-03-20 [1] CRAN (R 3.5.3)
##  pkgconfig     2.0.2     2018-08-16 [2] CRAN (R 3.5.1)
##  pkgload       1.0.2     2018-10-29 [1] CRAN (R 3.5.0)
##  plyr          1.8.4     2016-06-08 [2] CRAN (R 3.5.0)
##  prettyunits   1.0.2     2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.0     2019-03-10 [2] CRAN (R 3.5.2)
##  ps            1.3.0     2018-12-21 [2] CRAN (R 3.5.0)
##  purrr       * 0.3.2     2019-03-15 [2] CRAN (R 3.5.2)
##  r2d3          0.2.3     2018-12-18 [2] CRAN (R 3.5.0)
##  R6            2.4.0     2019-02-14 [1] CRAN (R 3.5.2)
##  rappdirs      0.3.1     2016-03-28 [2] CRAN (R 3.5.0)
##  Rcpp          1.0.1     2019-03-17 [1] CRAN (R 3.5.2)
##  RCurl         1.95-4.12 2019-03-04 [2] CRAN (R 3.5.2)
##  readr       * 1.3.1     2018-12-21 [2] CRAN (R 3.5.0)
##  readxl        1.3.1     2019-03-13 [2] CRAN (R 3.5.2)
##  remotes       2.0.2     2018-10-30 [1] CRAN (R 3.5.0)
##  rlang         0.3.4     2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12      2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2     2018-01-03 [2] CRAN (R 3.5.0)
##  rsparkling  * 0.2.18    2019-01-30 [2] CRAN (R 3.5.2)
##  rstudioapi    0.10      2019-03-19 [1] CRAN (R 3.5.3)
##  rvest         0.3.2     2016-06-17 [2] CRAN (R 3.5.0)
##  scales        1.0.0     2018-08-09 [1] CRAN (R 3.5.0)
##  sessioninfo   1.1.1     2018-11-05 [1] CRAN (R 3.5.0)
##  sparklyr    * 1.0.0     2019-02-25 [2] CRAN (R 3.5.2)
##  stringi       1.4.3     2019-03-12 [1] CRAN (R 3.5.2)
##  stringr     * 1.4.0     2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.0.1     2018-10-13 [2] CRAN (R 3.5.0)
##  tibble      * 2.1.1     2019-03-16 [2] CRAN (R 3.5.2)
##  tidyr       * 0.8.3     2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect    0.2.5     2018-10-11 [1] CRAN (R 3.5.0)
##  tidyverse   * 1.2.1     2017-11-14 [2] CRAN (R 3.5.0)
##  titanic     * 0.1.0     2015-08-31 [2] CRAN (R 3.5.0)
##  usethis       1.4.0     2018-08-14 [1] CRAN (R 3.5.0)
##  utf8          1.1.4     2018-05-24 [2] CRAN (R 3.5.0)
##  withr         2.1.2     2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5       2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0     2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0     2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
