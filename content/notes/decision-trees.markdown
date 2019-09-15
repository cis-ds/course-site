---
title: "Tree-based inference"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/stat004_decision_trees.html"]
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 4
---




```r
library(tidyverse)
library(modelr)
library(broom)
set.seed(1234)

theme_set(theme_minimal())
```

## Decision trees

![Does it move?](https://eight2late.files.wordpress.com/2016/02/7214525854_733237dd83_z1.jpg?w=700)

![Are you old? A helpful decision tree](https://s-media-cache-ak0.pinimg.com/564x/0b/87/df/0b87df1a54474716384f8ec94b52eab9.jpg)

![[Should I Have a Cookie?](http://iwastesomuchtime.com/58217)](/img/cookie.gif)

**Decision trees** are intuitive concepts for making decisions. They are also useful methods for regression and classification. They work by splitting the observations into a number of regions, and predictions are made based on the mean or mode of the training observations in that region.

## Interpreting a decision tree

Let's start with the Titanic data.


```r
library(titanic)
titanic <- titanic_train %>%
  as_tibble()

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

I want to predict who lives and who dies during this event. Instead of using [logistic regression](/notes/logistic-regression/), I'm going to calculate a decision tree based on a passenger's age and gender. Here's what that decision tree looks like:

<img src="/notes/decision-trees_files/figure-html/titanic_tree-1.png" width="672" />

Some key terminology:

* Each outcome (survived or died) is a **terminal node** or a **leaf**
* Splits occur at **internal nodes**
* The segments connecting each node are called **branches**

To make a prediction for a specific passenger, we start the decision tree from the top node and follow the appropriate branches down until we reach a terminal node. At each internal node, if our observation matches the condition, then travel down the left branch. If our observation does not match the condition, then travel down the right branch.

So for a 50 year old female passenger:

* Start at the first internal node. The passenger in question is a female, so take the branch to the left.
* We reach a terminal node. The majority of passengers in this node from the dataset survived, so for any given individual we would predict that passenger survived the sinking of the Titanic.

For a 20 year old male passenger:

* Start at the first internal node - the passenger in question is a male, so take the branch to the right.
* The passenger in question is not less than or equal to 6 years old (R would say the condition is `FALSE`), so take the branch to the right.
* We reach a terminal node. The majority of passengers in this node from the dataset died, so for any given individual we would predict that passenger did not survive the sinking of the Titanic.

## Estimating a decision tree

First we need to load the `partykit` library and prepare the data. `partykit` is somewhat finicky about how data must be formatted in order to estimate the tree. For the Titanic data, we need to convert all qualitiative variables to [**factors**](http://r4ds.had.co.nz/factors.html) using the `as.factor()` function. To make interpretation easier, I also recoded `Survived` from its `0/1` coding to explicitly identify which passengers survived and which died.


```r
library(partykit)

titanic_tree_data <- titanic %>%
  mutate(Survived = if_else(Survived == 1, "Survived", "Died"),
         Survived = as.factor(Survived),
         Sex = as.factor(Sex))
titanic_tree_data
```

```
## # A tibble: 891 x 12
##    PassengerId Survived Pclass Name  Sex     Age SibSp Parch Ticket  Fare
##          <int> <fct>     <int> <chr> <fct> <dbl> <int> <int> <chr>  <dbl>
##  1           1 Died          3 Brau… male     22     1     0 A/5 2…  7.25
##  2           2 Survived      1 Cumi… fema…    38     1     0 PC 17… 71.3 
##  3           3 Survived      3 Heik… fema…    26     0     0 STON/…  7.92
##  4           4 Survived      1 Futr… fema…    35     1     0 113803 53.1 
##  5           5 Died          3 Alle… male     35     0     0 373450  8.05
##  6           6 Died          3 Mora… male     NA     0     0 330877  8.46
##  7           7 Died          1 McCa… male     54     0     0 17463  51.9 
##  8           8 Died          3 Pals… male      2     3     1 349909 21.1 
##  9           9 Survived      3 John… fema…    27     0     2 347742 11.1 
## 10          10 Survived      2 Nass… fema…    14     1     0 237736 30.1 
## # … with 881 more rows, and 2 more variables: Cabin <chr>, Embarked <chr>
```

Now we can use the `ctree()` function to estimate the model. The format looks exactly like `lm()` or `glm()` - first we specify the formula that defines the model, then we specify where the data is stored:


```r
titanic_tree <- ctree(Survived ~ Age + Sex, data = titanic_tree_data)
titanic_tree
```

```
## 
## Model formula:
## Survived ~ Age + Sex
## 
## Fitted party:
## [1] root
## |   [2] Sex in female: Survived (n = 314, err = 25.8%)
## |   [3] Sex in male
## |   |   [4] Age <= 6: Survived (n = 32, err = 43.8%)
## |   |   [5] Age > 6: Died (n = 545, err = 16.7%)
## 
## Number of inner nodes:    2
## Number of terminal nodes: 3
```

```r
# misclassification/error rate
# check whether predicted values match actual values, calculate the
# mean of that boolean vector, then subtract from 1 to get the error
# rate (original value identifies accuracy rate)
1 - mean(predict(titanic_tree) == titanic_tree_data$Survived, na.rm = TRUE)
```

```
## [1] 0.2087542
```



Printing the tree-object provides a text-based view of the entire decision tree and some additional statisics.

* There are three terminal nodes in the tree
* There are two internal nodes in the tree
* At each terminal node, we identify the number of observations and the misclassification (error) rate.
* Overall, this decision tree misclassifies `\(20.9\%\)` of the training set observations

That's all well and good, but decision trees are meant to be viewed. Let's plot it!


```r
plot(titanic_tree)
```

<img src="/notes/decision-trees_files/figure-html/titanic_tree_plot-1.png" width="672" />

`partykit` does not use `ggplot2` to graph the results, so the syntax is a bit different. `plot(titanic_tree)` draws the branches and the nodes, and provides some additional information - most explicitly, at the terminal nodes the plot identifies the relative proportion of each possible outcome given the training data. Use `?plot.party` to view the documentation of this function and how to customize the appearance of the plot.

## Build a more complex tree

Since we have a lot of other variables in our Titanic data set, let's estimate a more complex model that accounts for all the information we have.^[Specifically passenger class, gender, age, number of sibling/spouses aboard, number of parents/children aboard, fare, and port of embarkation.] We'll have to format all our columns this time before we can estimate the model. Because there are multiple qualitative variables as predictors, I will use `mutate_if()` to apply `as.factor()` to all character columns in one line of code (another type of iterative/conditional operation):


```r
titanic_tree_full_data <- titanic %>%
  mutate(Survived = if_else(Survived == 1, "Survived",
                           if_else(Survived == 0, "Died", NA_character_))) %>%
  mutate_if(is.character, as.factor)

titanic_tree_full <- ctree(Survived ~ Pclass + Sex + Age + SibSp +
                             Parch + Fare + Embarked,
                           data = titanic_tree_full_data)
titanic_tree_full
```

```
## 
## Model formula:
## Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked
## 
## Fitted party:
## [1] root
## |   [2] Sex in female
## |   |   [3] Pclass <= 2: Survived (n = 170, err = 5.3%)
## |   |   [4] Pclass > 2
## |   |   |   [5] Fare <= 23.25: Survived (n = 117, err = 41.0%)
## |   |   |   [6] Fare > 23.25: Died (n = 27, err = 11.1%)
## |   [7] Sex in male
## |   |   [8] Pclass <= 1
## |   |   |   [9] Age <= 52: Died (n = 93, err = 43.0%)
## |   |   |   [10] Age > 52: Died (n = 29, err = 17.2%)
## |   |   [11] Pclass > 1
## |   |   |   [12] Age <= 9
## |   |   |   |   [13] Pclass <= 2: Survived (n = 9, err = 0.0%)
## |   |   |   |   [14] Pclass > 2: Died (n = 35, err = 22.9%)
## |   |   |   [15] Age > 9: Died (n = 411, err = 11.4%)
## 
## Number of inner nodes:    7
## Number of terminal nodes: 8
```

```r
# error rate
1 - mean(predict(titanic_tree_full) == titanic_tree_data$Survived,
         na.rm = TRUE)
```

```
## [1] 0.1795735
```

```r
plot(titanic_tree_full,
     ip_args = list(
       pval = FALSE,
       id = FALSE),
     tp_args = list(
       id = FALSE)
)
```

<img src="/notes/decision-trees_files/figure-html/titanic_tree_full-1.png" width="672" />

Now we've built a more complicated decision tree. Fortunately it is still pretty interpretable. Notice that some of the variables we included in the model (`Parch` and `Embarked`) ended up being dropped from the final model. This is because to build the tree and ensure it is not overly complicated, the algorithm goes through a process of iteration and **pruning** to remove twigs or branches that result in a complicated model that does not provide significant improvement in overall model accuracy. You can tweak these parameters to ensure the model keeps all the variables, but could result in a nasty looking picture:


```r
titanic_tree_messy <- ctree(Survived ~ Pclass + Sex + Age + SibSp +
                              Parch + Fare + Embarked,
                            data = titanic_tree_full_data,
                            control = ctree_control(
                              alpha = 0.5,
                              splittry = 5L)
)
titanic_tree_messy
```

```
## 
## Model formula:
## Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked
## 
## Fitted party:
## [1] root
## |   [2] Sex in female
## |   |   [3] Pclass <= 2: Survived (n = 170, err = 5.3%)
## |   |   [4] Pclass > 2
## |   |   |   [5] Fare <= 23.25
## |   |   |   |   [6] Age <= 16: Survived (n = 28, err = 28.6%)
## |   |   |   |   [7] Age > 16: Survived (n = 89, err = 44.9%)
## |   |   |   [8] Fare > 23.25: Died (n = 27, err = 11.1%)
## |   [9] Sex in male
## |   |   [10] Pclass <= 1
## |   |   |   [11] Age <= 52: Died (n = 94, err = 42.6%)
## |   |   |   [12] Age > 52: Died (n = 28, err = 17.9%)
## |   |   [13] Pclass > 1
## |   |   |   [14] Age <= 9
## |   |   |   |   [15] Pclass <= 2: Survived (n = 10, err = 0.0%)
## |   |   |   |   [16] Pclass > 2
## |   |   |   |   |   [17] Parch <= 0: Died (n = 9, err = 0.0%)
## |   |   |   |   |   [18] Parch > 0
## |   |   |   |   |   |   [19] SibSp <= 1: Survived (n = 7, err = 0.0%)
## |   |   |   |   |   |   [20] SibSp > 1: Died (n = 16, err = 6.2%)
## |   |   |   [21] Age > 9
## |   |   |   |   [22] Embarked in C
## |   |   |   |   |   [23] Age <= 22: Died (n = 14, err = 42.9%)
## |   |   |   |   |   [24] Age > 22: Died (n = 34, err = 8.8%)
## |   |   |   |   [25] Embarked in Q, S
## |   |   |   |   |   [26] Parch <= 0
## |   |   |   |   |   |   [27] Fare <= 27: Died (n = 322, err = 9.9%)
## |   |   |   |   |   |   [28] Fare > 27: Died (n = 12, err = 41.7%)
## |   |   |   |   |   [29] Parch > 0: Died (n = 31, err = 0.0%)
## 
## Number of inner nodes:    14
## Number of terminal nodes: 15
```

```r
# error rate
1 - mean(predict(titanic_tree_messy) == titanic_tree_data$Survived,
         na.rm = TRUE)
```

```
## [1] 0.1705948
```

```r
plot(titanic_tree_messy,
     ip_args = list(
       pval = FALSE,
       id = FALSE),
     tp_args = list(
       id = FALSE)
)
```

<img src="/notes/decision-trees_files/figure-html/titanic_tree_complicated-1.png" width="672" />

The misclassification error rate for this model is much lower than the previous versions, but it is also much less interpretable. Depending on your audience and how you want to present the results of your statistical model, you need to determine the optimal trade-off between accuracy and interpretability.

## Benefits/drawbacks to decision trees

Decision trees are an entirely different method of estimating functional forms as compared to linear regression. There are some benefits to trees:

* They are easy to explain. Most people, even if they lack statistical training, can understand decision trees.
* They are easily presented as visualizations, and pretty interpretable.
* Qualitative predictors are easily handled without the need to create a long series of dummy variables.

However there are also drawbacks to trees:

* Their accuracy rates are generally lower than other regression and classification approaches.
* Trees can be non-robust. That is, a small change in the data or inclusion/exclusion of a handful of observations can dramatically alter the final estimated tree.

Fortuntately, there is an easy way to improve on these poor predictions: by aggregating many decision trees and averaging across them, we can substantially improve performance.

## Random forests

One method of aggregating trees is the **random forest** approach. This uses the concept of **bootstrapping** to build a forest of trees using the same underlying data set. Bootstrapping is a standard resampling process whereby you repeatedly **sample with replacement** from a data set. So if you have a dataset of 500 observations, you might draw a sample of 500 observations from the data. But by sampling with replacement, some observations may be sampled multiple times and some observations may never be sampled. This essentially treats your data as a population of interest.


```r
(numbers <- seq(from = 1, to = 10))
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```

```r
# sample without replacement
rerun(5, sample(numbers, replace = FALSE))
```

```
## [[1]]
##  [1]  6  1 10  7  5  3  9  2  4  8
## 
## [[2]]
##  [1]  2  4 10  9  7  3  5  8  1  6
## 
## [[3]]
##  [1]  1  9  7  3  5 10  6  8  4  2
## 
## [[4]]
##  [1]  4 10  5  1  8  2  9  3  7  6
## 
## [[5]]
##  [1]  7  2  8  3  9  5  6  4  1 10
```

```r
# sample with replacement
rerun(5, sample(numbers, replace = TRUE))
```

```
## [[1]]
##  [1] 7 5 3 3 2 7 3 1 7 1
## 
## [[2]]
##  [1]  1  3  4  1  2  2  2 10  7  1
## 
## [[3]]
##  [1] 7 9 5 5 8 5 3 1 1 3
## 
## [[4]]
##  [1]  9 10  5  2  4  4  6  4  8 10
## 
## [[5]]
##  [1] 7 4 9 7 6 6 4 7 4 6
```

You repeat this process many times (say `\(k = 1000\)`), then estimate your quantity or model of interest on each sample. Then finally you average across all the bootstrapped samples to calculate the final model or statistical estimator.

As with other resampling methods, each individual sample will have some degree of bias to it. However by averaging across all the bootstrapped samples you cancel out much of this bias. Most importantly, averaging a set of observations reduces **variance** - you achieve stable estimates of the prediction accuracy or overall model error.

In the context of decision trees, this means we draw repeated samples from the original dataset and estimate a decision tree model on each sample. To make predictions, we estimate the outcome using each tree and average across all of them to obtain the final prediction. Rather than being a binary outcome ($[0,1]$, survived/died), the average prediction will be a probability of the given outcome (i.e. the probability of survival). This process is called **bagging**.

Random forests go a step further: when building individual decision trees, each time a split in the tree is considered a random sample of predictors is selected as the candidates for the split. **Random forests specifically exclude a portion of the predictor variables when building individual trees**. Why throw away good data? This ensures each decision tree is not correlated with one another. If one specific variable was a strong predictor in the data set (say gender in the Titanic data set), it could potentially dominate every decision tree and the result would be nearly-identical trees regardless of the sampling procedure. By forcibly excluding a random subset of variables, individual trees in random forests will not have strong correlations with one another. Therefore the average predictions will be more **reliable**.

## Estimating statistical models using `caret`

To estimate a random forest, we move outside the world of `tree` and into a new package in R: [`caret`](https://cran.r-project.org/web/packages/caret/index.html). `caret` is a package in R for training and plotting a wide variety of statistical learning models. It is outside of the `tidyverse` so can be a bit more difficult to master. `caret` does not contain the estimation algorithms itself; instead it creates a unified interface to approximately [233 different models](https://topepo.github.io/caret/available-models.html) from various packages in R. To install `caret` and make sure you install all the related packages it relies on, run the following code:

```r
install.packages("caret", dependencies = TRUE)
```

The basic function to train models is `train()`. We can train regression and classification models using one of [these models](https://topepo.github.io/caret/available-models.html). For instance, rather than using `glm()` to estimate a logistic regression model, we could use `caret` and the `"glm"` method. Note that `caret` is extremely picky about preparing data for analysis. For instance, we have to remove all missing values before training a model.


```r
library(caret)

titanic_clean <- titanic %>%
  drop_na(Survived, Age)

caret_glm <- train(Survived ~ Age, data = titanic_clean,
                   method = "glm",
                   family = binomial,
                   trControl = trainControl(method = "none"))
summary(caret_glm)
```

```
## 
## Call:
## NULL
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.1488  -1.0361  -0.9544   1.3159   1.5908  
## 
## Coefficients:
##             Estimate Std. Error z value Pr(>|z|)  
## (Intercept) -0.05672    0.17358  -0.327   0.7438  
## Age         -0.01096    0.00533  -2.057   0.0397 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 964.52  on 713  degrees of freedom
## Residual deviance: 960.23  on 712  degrees of freedom
## AIC: 964.23
## 
## Number of Fisher Scoring iterations: 4
```

* `trControl = trainControl(method = "none")` - by default `caret` implements a bootstrap resampling procedure to validate the results of the model. For our purposes here I want to turn that off by setting the resampling method to `"none"`.

The results are identical to those obtained by the `glm()` function:^[Because behind the scenes, `caret` is simply using the `glm()` function to train the model.]


```r
glm_glm <- glm(Survived ~ Age, data = titanic_clean, family = "binomial")
summary(glm_glm)
```

```
## 
## Call:
## glm(formula = Survived ~ Age, family = "binomial", data = titanic_clean)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.1488  -1.0361  -0.9544   1.3159   1.5908  
## 
## Coefficients:
##             Estimate Std. Error z value Pr(>|z|)  
## (Intercept) -0.05672    0.17358  -0.327   0.7438  
## Age         -0.01096    0.00533  -2.057   0.0397 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 964.52  on 713  degrees of freedom
## Residual deviance: 960.23  on 712  degrees of freedom
## AIC: 964.23
## 
## Number of Fisher Scoring iterations: 4
```

## Estimating a random forest

We will reuse `titanic_tree_full_data` with the adjustment that we need to remove observations with missing values. In the process, let's pare the data frame down to only columns that will be used the model:


```r
titanic_rf_data <- titanic_tree_full_data %>%
  select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked) %>%
  drop_na()
titanic_rf_data
```

```
## # A tibble: 714 x 8
##    Survived Pclass Sex      Age SibSp Parch  Fare Embarked
##    <fct>     <int> <fct>  <dbl> <int> <int> <dbl> <fct>   
##  1 Died          3 male      22     1     0  7.25 S       
##  2 Survived      1 female    38     1     0 71.3  C       
##  3 Survived      3 female    26     0     0  7.92 S       
##  4 Survived      1 female    35     1     0 53.1  S       
##  5 Died          3 male      35     0     0  8.05 S       
##  6 Died          1 male      54     0     0 51.9  S       
##  7 Died          3 male       2     3     1 21.1  S       
##  8 Survived      3 female    27     0     2 11.1  S       
##  9 Survived      2 female    14     1     0 30.1  C       
## 10 Survived      3 female     4     1     1 16.7  S       
## # … with 704 more rows
```

Now that the data is prepped, let's estimate the model. To start, we'll estimate a simple model that only uses age and gender. Again we use the `train()` function but this time we will use the `rf` method.^[[There are many packages that use algorithms to estimate random forests.](https://topepo.github.io/caret/train-models-by-tag.html#random-forest) They all do the same basic thing, though with some notable differences. The `rf` method is generally popular, so I use it here.] To start with, I will estimate a forest with 200 trees (the default is 500 trees) and set the `trainControl` method to `"oob"` (I will explain this shortly):


```r
titanic_rf <- train(Survived ~ ., data = titanic_rf_data,
                    method = "rf",
                    ntree = 200,
                    trControl = trainControl(method = "oob"))
titanic_rf
```

```
## Random Forest 
## 
## 714 samples
##   7 predictor
##   2 classes: 'Died', 'Survived' 
## 
## No pre-processing
## Resampling results across tuning parameters:
## 
##   mtry  Accuracy   Kappa    
##   2     0.8221289  0.6194509
##   5     0.8123249  0.6044812
##   9     0.7941176  0.5696855
## 
## Accuracy was used to select the optimal model using the largest value.
## The final value used for the model was mtry = 2.
```

> `Survived ~ .` tells `train()` to include all the columns other than `Survived` as independent variables.

Hmm. What have we generated here? How can we analyze the results?

## Structure of `train()` object

The object generated by `train()` is a named list:


```r
str(titanic_rf, max.level = 1)
```

```
## List of 24
##  $ method      : chr "rf"
##  $ modelInfo   :List of 15
##  $ modelType   : chr "Classification"
##  $ results     :'data.frame':	3 obs. of  3 variables:
##  $ pred        : NULL
##  $ bestTune    :'data.frame':	1 obs. of  1 variable:
##  $ call        : language train.formula(form = Survived ~ ., data = titanic_rf_data, method = "rf",      ntree = 200, trControl = trainCont| __truncated__
##  $ dots        :List of 1
##  $ metric      : chr "Accuracy"
##  $ control     :List of 26
##  $ finalModel  :List of 23
##   ..- attr(*, "class")= chr "randomForest"
##  $ preProcess  : NULL
##  $ trainingData:Classes 'tbl_df', 'tbl' and 'data.frame':	714 obs. of  8 variables:
##  $ resample    : NULL
##  $ resampledCM : NULL
##  $ perfNames   : chr [1:2] "Accuracy" "Kappa"
##  $ maximize    : logi TRUE
##  $ yLimits     : NULL
##  $ times       :List of 3
##  $ levels      : chr [1:2] "Died" "Survived"
##   ..- attr(*, "ordered")= logi FALSE
##  $ terms       :Classes 'terms', 'formula'  language Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked
##   .. ..- attr(*, "variables")= language list(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked)
##   .. ..- attr(*, "factors")= int [1:8, 1:7] 0 1 0 0 0 0 0 0 0 0 ...
##   .. .. ..- attr(*, "dimnames")=List of 2
##   .. ..- attr(*, "term.labels")= chr [1:7] "Pclass" "Sex" "Age" "SibSp" ...
##   .. ..- attr(*, "order")= int [1:7] 1 1 1 1 1 1 1
##   .. ..- attr(*, "intercept")= int 1
##   .. ..- attr(*, "response")= int 1
##   .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. ..- attr(*, "predvars")= language list(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked)
##   .. ..- attr(*, "dataClasses")= Named chr [1:8] "factor" "numeric" "factor" "numeric" ...
##   .. .. ..- attr(*, "names")= chr [1:8] "Survived" "Pclass" "Sex" "Age" ...
##  $ coefnames   : chr [1:9] "Pclass" "Sexmale" "Age" "SibSp" ...
##  $ contrasts   :List of 2
##  $ xlevels     :List of 2
##  - attr(*, "class")= chr [1:2] "train" "train.formula"
```

The model itself is always stored in the `finalModel` element. So to use the model in other functions, we would refer to it as `titanic_rf$finalModel`.

## Model statistics


```r
titanic_rf$finalModel
```

```
## 
## Call:
##  randomForest(x = x, y = y, ntree = 200, mtry = param$mtry) 
##                Type of random forest: classification
##                      Number of trees: 200
## No. of variables tried at each split: 2
## 
##         OOB estimate of  error rate: 19.19%
## Confusion matrix:
##          Died Survived class.error
## Died      389       35  0.08254717
## Survived  102      188  0.35172414
```

This tells us some important things:

* We used 200 trees
* At every potential branch, the model randomly used one of 2 variables to define the split
* The **out-of-bag** (OOB) error rate

    This requires further explanation. Because each tree is built from a bootstrapped sample, for any given tree approximately one-third of the observations are not used to build the tree. In essence, we have a natural validation set for each tree. For each observation, we predict the outcome of interest using all trees where the observation was not used to build the tree, then average across these predictions. For any observation, we should have `\(K/3\)` validation predictions where `\(K\)` is the total number of trees in the forest. Averaging across these predictions gives us an out-of-bag error rate for every observation (even if they are derived from different combinations of trees). Because the OOB estimate is built only using trees that were not fit to the observation, this is a valid estimate of the test error for the random forest.
    
    Here we get an OOB estimate of the error rate of  20%. This means for test observations, the model misclassifies the individual's survival  20% of the time.
* The **confusion matrix** - this compares the predictions to the actual known outcomes.

    
    ```r
    knitr::kable(titanic_rf$finalModel$confusion)
    ```
    
    
    
    |         | Died| Survived| class.error|
    |:--------|----:|--------:|-----------:|
    |Died     |  389|       35|   0.0825472|
    |Survived |  102|      188|   0.3517241|
    
    The rows indicate the actual known outcomes, and the columns indicate the predictions. A perfect model would have 0s on the off-diagonal cells because every prediction is perfect. Clearly that is not the case. Not only is there substantial error, most it comes from misclassifying survivors. The error rate for those who actually died is much smaller than for those who actually survived.

## Look at an individual tree

We could look at one tree generated by the model:


```r
randomForest::getTree(titanic_rf$finalModel, labelVar = TRUE)
```

```
##    left daughter right daughter split var split point status prediction
## 1              2              3 EmbarkedC     0.50000      1       <NA>
## 2              4              5       Age    19.50000      1       <NA>
## 3              0              0      <NA>     0.00000     -1   Survived
## 4              6              7    Pclass     2.50000      1       <NA>
## 5              8              9   Sexmale     0.50000      1       <NA>
## 6             10             11     Parch     0.50000      1       <NA>
## 7             12             13   Sexmale     0.50000      1       <NA>
## 8             14             15     SibSp     0.50000      1       <NA>
## 9             16             17 EmbarkedS     0.50000      1       <NA>
## 10            18             19   Sexmale     0.50000      1       <NA>
## 11             0              0      <NA>     0.00000     -1   Survived
## 12            20             21      Fare    17.25000      1       <NA>
## 13            22             23 EmbarkedQ     0.50000      1       <NA>
## 14            24             25    Pclass     2.50000      1       <NA>
## 15            26             27       Age    29.50000      1       <NA>
## 16             0              0      <NA>     0.00000     -1       Died
## 17            28             29    Pclass     1.50000      1       <NA>
## 18             0              0      <NA>     0.00000     -1   Survived
## 19            30             31       Age    18.50000      1       <NA>
## 20            32             33     SibSp     0.50000      1       <NA>
## 21             0              0      <NA>     0.00000     -1       Died
## 22            34             35       Age     9.50000      1       <NA>
## 23             0              0      <NA>     0.00000     -1       Died
## 24             0              0      <NA>     0.00000     -1   Survived
## 25            36             37       Age    28.00000      1       <NA>
## 26            38             39       Age    24.50000      1       <NA>
## 27            40             41      Fare    43.18750      1       <NA>
## 28            42             43      Fare    31.41040      1       <NA>
## 29            44             45    Pclass     2.50000      1       <NA>
## 30             0              0      <NA>     0.00000     -1       Died
## 31             0              0      <NA>     0.00000     -1       Died
## 32            46             47 EmbarkedQ     0.50000      1       <NA>
## 33             0              0      <NA>     0.00000     -1   Survived
## 34             0              0      <NA>     0.00000     -1       Died
## 35            48             49      Fare     7.97290      1       <NA>
## 36            50             51       Age    22.50000      1       <NA>
## 37            52             53       Age    54.00000      1       <NA>
## 38             0              0      <NA>     0.00000     -1   Survived
## 39            54             55      Fare    28.00000      1       <NA>
## 40             0              0      <NA>     0.00000     -1   Survived
## 41             0              0      <NA>     0.00000     -1   Survived
## 42            56             57       Age    56.00000      1       <NA>
## 43             0              0      <NA>     0.00000     -1       Died
## 44            58             59     Parch     0.50000      1       <NA>
## 45             0              0      <NA>     0.00000     -1       Died
## 46            60             61     Parch     0.50000      1       <NA>
## 47             0              0      <NA>     0.00000     -1   Survived
## 48             0              0      <NA>     0.00000     -1       Died
## 49            62             63      Fare     8.35625      1       <NA>
## 50             0              0      <NA>     0.00000     -1       Died
## 51            64             65       Age    25.00000      1       <NA>
## 52            66             67 EmbarkedS     0.50000      1       <NA>
## 53             0              0      <NA>     0.00000     -1   Survived
## 54             0              0      <NA>     0.00000     -1       Died
## 55             0              0      <NA>     0.00000     -1   Survived
## 56            68             69      Fare    25.93750      1       <NA>
## 57             0              0      <NA>     0.00000     -1       Died
## 58            70             71      Fare    12.63750      1       <NA>
## 59             0              0      <NA>     0.00000     -1       Died
## 60             0              0      <NA>     0.00000     -1   Survived
## 61            72             73      Fare    11.37500      1       <NA>
## 62             0              0      <NA>     0.00000     -1   Survived
## 63             0              0      <NA>     0.00000     -1       Died
## 64            74             75      Fare     8.20000      1       <NA>
## 65             0              0      <NA>     0.00000     -1   Survived
## 66             0              0      <NA>     0.00000     -1       Died
## 67            76             77     Parch     1.00000      1       <NA>
## 68             0              0      <NA>     0.00000     -1       Died
## 69            78             79      Fare    28.52500      1       <NA>
## 70             0              0      <NA>     0.00000     -1       Died
## 71             0              0      <NA>     0.00000     -1       Died
## 72            80             81       Age    10.00000      1       <NA>
## 73             0              0      <NA>     0.00000     -1   Survived
## 74             0              0      <NA>     0.00000     -1   Survived
## 75             0              0      <NA>     0.00000     -1       Died
## 76             0              0      <NA>     0.00000     -1       Died
## 77             0              0      <NA>     0.00000     -1       Died
## 78            82             83      Fare    26.46875      1       <NA>
## 79             0              0      <NA>     0.00000     -1   Survived
## 80             0              0      <NA>     0.00000     -1       Died
## 81             0              0      <NA>     0.00000     -1   Survived
## 82             0              0      <NA>     0.00000     -1   Survived
## 83             0              0      <NA>     0.00000     -1   Survived
```

Unfortunately there is no easy plotting mechanism for the result of `getTree()`.^[Remember that it was not generated by the `tree` library, but instead by a function in `randomForest`. Because of that we cannot just call `plot(titanic_rf$finalModel)`.] And yikes. Clearly this tree is pretty complicated. Not something we want to examine directly.

## Variable importance

Another method of interpreting random forests looks at the importance of individual variables in the model.


```r
randomForest::varImpPlot(titanic_rf$finalModel)
```

<img src="/notes/decision-trees_files/figure-html/rf_import-1.png" width="672" />

This tells us how much each variable decreases the average **Gini index**, a measure of how important the variable is to the model. Essentially, it estimates the impact a variable has on the model by comparing prediction accuracy rates for models with and without the variable. Larger values indicate higher importance of the variable. Here we see that the gender variable `Sexmale` is most important.

## Exercise: random forests with `mental_health`

Recall the [`mental_health` dataset we used to practice logistic regression](/notes/logistic-regression/#exercise-logistic-regression-with-mental-health). We could also use decision trees or a random forest approach to predict which individuals voted in the 1996 presidential election based on their mental health. Use the `mental_health` data set in `library(rcfss)` and tree-based methods to predict whether or not an individual voted.^[Update `rcfss` using `devtools::install_github("uc-cfss/rcfss")` if you cannot access the data set.]


```r
library(rcfss)
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

1. Estimate a decision tree using the `tree` library to predict voter turnout using all the predictors. Plot the resulting tree.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # prep data
    mh_tree_data <- mental_health %>%
      mutate(vote96 = factor(vote96, levels = c(0, 1),
                             labels = c("Did not vote", "Voted")),
             female = as.factor(female))
    
    # estimate model
    mh_tree <- ctree(vote96 ~ ., data = mh_tree_data)
    
    # plot the tree
    plot(mh_tree)
    ```
    
    <img src="/notes/decision-trees_files/figure-html/mh-tree-1.png" width="672" />
    
      </p>
    </details>

1. Assess the decision tree's predictive accuracy.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # node-specific error rates
    mh_tree
    ```
    
    ```
    ## 
    ## Model formula:
    ## vote96 ~ age + educ + female + mhealth
    ## 
    ## Fitted party:
    ## [1] root
    ## |   [2] educ <= 14
    ## |   |   [3] age <= 43
    ## |   |   |   [4] educ <= 11
    ## |   |   |   |   [5] age <= 33: Did not vote (n = 41, err = 7.3%)
    ## |   |   |   |   [6] age > 33: Did not vote (n = 35, err = 40.0%)
    ## |   |   |   [7] educ > 11: Voted (n = 375, err = 49.3%)
    ## |   |   [8] age > 43
    ## |   |   |   [9] mhealth <= 4
    ## |   |   |   |   [10] educ <= 10: Voted (n = 77, err = 36.4%)
    ## |   |   |   |   [11] educ > 10: Voted (n = 280, err = 16.1%)
    ## |   |   |   [12] mhealth > 4: Voted (n = 95, err = 46.3%)
    ## |   [13] educ > 14
    ## |   |   [14] age <= 29: Voted (n = 69, err = 37.7%)
    ## |   |   [15] age > 29
    ## |   |   |   [16] age <= 55: Voted (n = 255, err = 16.1%)
    ## |   |   |   [17] age > 55: Voted (n = 90, err = 2.2%)
    ## 
    ## Number of inner nodes:    8
    ## Number of terminal nodes: 9
    ```
    
    ```r
    # overall error rate
    (misclass <- formatC((1 - mean(predict(mh_tree) == mh_tree_data$vote96, na.rm = TRUE)) * 100, digits = 3))
    ```
    
    ```
    ## [1] "29.5"
    ```

    The model isn't too bad. It's misclassification error rate is `\(29.5\%\)` (based on the original data).
    
      </p>
    </details>

1. Estimate a random forest using `caret` to predict voter turnout using all the predictors. Make sure your forest includes 200 trees and uses the out-of-bag method to calculate the error rate. How good is this model compared to a single decision tree?

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # prep data
    mh_rf_data <- mh_tree_data %>%
      drop_na()
    
    # estimate model
    mh_rf <- train(vote96 ~ ., data = mh_rf_data,
                   method = "rf",
                   ntree = 200,
                   trControl = trainControl(method = "oob"))
    mh_rf
    ```
    
    ```
    ## Random Forest 
    ## 
    ## 1317 samples
    ##    4 predictor
    ##    2 classes: 'Did not vote', 'Voted' 
    ## 
    ## No pre-processing
    ## Resampling results across tuning parameters:
    ## 
    ##   mtry  Accuracy   Kappa    
    ##   2     0.6924829  0.2724402
    ##   3     0.6689446  0.2278215
    ##   4     0.6735004  0.2346852
    ## 
    ## Accuracy was used to select the optimal model using the largest value.
    ## The final value used for the model was mtry = 2.
    ```
    
    ```r
    mh_rf$finalModel
    ```
    
    ```
    ## 
    ## Call:
    ##  randomForest(x = x, y = y, ntree = 200, mtry = param$mtry) 
    ##                Type of random forest: classification
    ##                      Number of trees: 200
    ## No. of variables tried at each split: 2
    ## 
    ##         OOB estimate of  error rate: 30.83%
    ## Confusion matrix:
    ##              Did not vote Voted class.error
    ## Did not vote          201   229   0.5325581
    ## Voted                 177   710   0.1995490
    ```

    It is comparable to the original decision tree, but worse than the complicated decision tree. If we made every tree as complex inside the random forest, we might see similar improvements.
    
      </p>
    </details>

1. Generate a variable importance plot. Which variables are most important to the model?

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    randomForest::varImpPlot(mh_rf$finalModel)
    ```
    
    <img src="/notes/decision-trees_files/figure-html/mh-rf-varImp-1.png" width="672" />
    
    Age was the most important variable in predicting voter turnout, whereas education and mental health were roughly equivalent in importance.
    
      </p>
    </details>
    
### Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-09-15                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package      * version    date       lib source        
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 3.6.0)
##  backports      1.1.4      2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown       0.14       2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown       0.12       2019-07-11 [1] CRAN (R 3.6.0)
##  broom        * 0.5.2      2019-04-07 [1] CRAN (R 3.6.0)
##  callr          3.3.1      2019-07-18 [1] CRAN (R 3.6.0)
##  caret          6.0-84     2019-04-27 [1] CRAN (R 3.6.0)
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 3.6.0)
##  class          7.3-15     2019-01-01 [1] CRAN (R 3.6.0)
##  cli            1.1.0      2019-03-19 [1] CRAN (R 3.6.0)
##  codetools      0.2-16     2018-12-24 [1] CRAN (R 3.6.0)
##  colorspace     1.4-1      2019-03-18 [1] CRAN (R 3.6.0)
##  crayon         1.3.4      2017-09-16 [1] CRAN (R 3.6.0)
##  data.table     1.12.2     2019-04-07 [1] CRAN (R 3.6.0)
##  desc           1.2.0      2018-05-01 [1] CRAN (R 3.6.0)
##  devtools       2.1.0      2019-07-06 [1] CRAN (R 3.6.0)
##  digest         0.6.20     2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr        * 0.8.3      2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate       0.14       2019-05-28 [1] CRAN (R 3.6.0)
##  forcats      * 0.4.0      2019-02-17 [1] CRAN (R 3.6.0)
##  foreach        1.4.7      2019-07-27 [1] CRAN (R 3.6.0)
##  fs             1.3.1      2019-05-06 [1] CRAN (R 3.6.0)
##  generics       0.0.2      2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2      * 3.2.1      2019-08-10 [1] CRAN (R 3.6.0)
##  glue           1.3.1      2019-03-12 [1] CRAN (R 3.6.0)
##  gower          0.2.1      2019-05-14 [1] CRAN (R 3.6.0)
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 3.6.0)
##  haven          2.1.1      2019-07-04 [1] CRAN (R 3.6.0)
##  here           0.1        2017-05-28 [1] CRAN (R 3.6.0)
##  hms            0.5.0      2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools      0.3.6      2017-04-28 [1] CRAN (R 3.6.0)
##  httr           1.4.1      2019-08-05 [1] CRAN (R 3.6.0)
##  ipred          0.9-9      2019-04-28 [1] CRAN (R 3.6.0)
##  iterators      1.0.12     2019-07-26 [1] CRAN (R 3.6.0)
##  jsonlite       1.6        2018-12-07 [1] CRAN (R 3.6.0)
##  knitr          1.24       2019-08-08 [1] CRAN (R 3.6.0)
##  lattice        0.20-38    2018-11-04 [1] CRAN (R 3.6.0)
##  lava           1.6.6      2019-08-01 [1] CRAN (R 3.6.0)
##  lazyeval       0.2.2      2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate      1.7.4      2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr       1.5        2014-11-22 [1] CRAN (R 3.6.0)
##  MASS           7.3-51.4   2019-03-31 [1] CRAN (R 3.6.0)
##  Matrix         1.2-17     2019-03-22 [1] CRAN (R 3.6.0)
##  memoise        1.1.0      2017-04-21 [1] CRAN (R 3.6.0)
##  ModelMetrics   1.2.2      2018-11-03 [1] CRAN (R 3.6.0)
##  modelr       * 0.1.5      2019-08-08 [1] CRAN (R 3.6.0)
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 3.6.0)
##  nlme           3.1-141    2019-08-01 [1] CRAN (R 3.6.0)
##  nnet           7.3-12     2016-02-02 [1] CRAN (R 3.6.0)
##  pillar         1.4.2      2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild       1.0.4      2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig      2.0.2      2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload        1.0.2      2018-10-29 [1] CRAN (R 3.6.0)
##  plyr           1.8.4      2016-06-08 [1] CRAN (R 3.6.0)
##  prettyunits    1.0.2      2015-07-13 [1] CRAN (R 3.6.0)
##  processx       3.4.1      2019-07-18 [1] CRAN (R 3.6.0)
##  prodlim        2018.04.18 2018-04-18 [1] CRAN (R 3.6.0)
##  ps             1.3.0      2018-12-21 [1] CRAN (R 3.6.0)
##  purrr        * 0.3.2      2019-03-15 [1] CRAN (R 3.6.0)
##  R6             2.4.0      2019-02-14 [1] CRAN (R 3.6.0)
##  Rcpp           1.0.2      2019-07-25 [1] CRAN (R 3.6.0)
##  readr        * 1.3.1      2018-12-21 [1] CRAN (R 3.6.0)
##  readxl         1.3.1      2019-03-13 [1] CRAN (R 3.6.0)
##  recipes        0.1.6      2019-07-02 [1] CRAN (R 3.6.0)
##  remotes        2.1.0      2019-06-24 [1] CRAN (R 3.6.0)
##  reshape2       1.4.3      2017-12-11 [1] CRAN (R 3.6.0)
##  rlang          0.4.0      2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown      1.14       2019-07-12 [1] CRAN (R 3.6.0)
##  rpart          4.1-15     2019-04-12 [1] CRAN (R 3.6.0)
##  rprojroot      1.3-2      2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi     0.10       2019-03-19 [1] CRAN (R 3.6.0)
##  rvest          0.3.4      2019-05-15 [1] CRAN (R 3.6.0)
##  scales         1.0.0      2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 3.6.0)
##  stringi        1.4.3      2019-03-12 [1] CRAN (R 3.6.0)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 3.6.0)
##  survival       2.44-1.1   2019-04-01 [1] CRAN (R 3.6.0)
##  testthat       2.2.1      2019-07-25 [1] CRAN (R 3.6.0)
##  tibble       * 2.1.3      2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr        * 0.8.3      2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect     0.2.5      2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse    * 1.2.1      2017-11-14 [1] CRAN (R 3.6.0)
##  timeDate       3043.102   2018-02-21 [1] CRAN (R 3.6.0)
##  usethis        1.5.1      2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs          0.2.0      2019-07-05 [1] CRAN (R 3.6.0)
##  withr          2.1.2      2018-03-15 [1] CRAN (R 3.6.0)
##  xfun           0.8        2019-06-25 [1] CRAN (R 3.6.0)
##  xml2           1.2.2      2019-08-09 [1] CRAN (R 3.6.0)
##  yaml           2.2.0      2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot        0.1.0      2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
