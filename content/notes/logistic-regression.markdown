---
title: "Logistic regression"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/stat003_logistic_regression.html"]
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 3
---




```r
library(tidyverse)
library(modelr)
library(broom)
set.seed(1234)

theme_set(theme_minimal())
```

## Classification problems

The sinking of [RMS Titanic](https://en.wikipedia.org/wiki/RMS_Titanic) provided the world with many things:

* A fundamental shock to the world as its faith in supposedly indestructible technology was shattered by a chunk of ice
* Perhaps the best romantic ballad of all time

    {{< youtube  WNIPqafd4As >}}

* A tragic love story

    ![[Titanic (1997)](https://en.wikipedia.org/wiki/Titanic_(1997_film))](https://i.giphy.com/KSeT85Vtym7m.gif)
    
Why did Jack have to die? Why couldn't he have made it onto a lifeboat like Cal? We may never know the answer, but we can generalize the question a bit: why did some people survive the sinking of the Titanic while others did not?

In essence, we have a classification problem. The response is a binary variable, indicating whether a specific passenger survived. If we combine this with predictors that describe each passenger, we might be able to estimate a general model of survival.^[General at least as applied to the Titanic. I'd like to think technology has advanced some since the early 20th century that the same patterns do not apply today. [Not that sinking ships have gone away.](https://en.wikipedia.org/wiki/Costa_Concordia_disaster)]

Kaggle is an online platform for predictive modeling and analytics. They run regular competitions where they provide the public with a question and data, and anyone can estimate a predictive model to answer the question. They've run a popular contest based on a [dataset of passengers from the Titanic](https://www.kaggle.com/c/titanic/data). The datasets have been conveniently stored in a package called `titanic`. Let's load the package and convert the desired data frame to a tibble.


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

The codebook contains the following information on the variables:

```
VARIABLE DESCRIPTIONS:
Survived        Survival
                (0 = No; 1 = Yes)
Pclass          Passenger Class
                (1 = 1st; 2 = 2nd; 3 = 3rd)
Name            Name
Sex             Sex
Age             Age
SibSp           Number of Siblings/Spouses Aboard
Parch           Number of Parents/Children Aboard
Ticket          Ticket Number
Fare            Passenger Fare
Cabin           Cabin
Embarked        Port of Embarkation
                (C = Cherbourg; Q = Queenstown; S = Southampton)

SPECIAL NOTES:
Pclass is a proxy for socio-economic status (SES)
 1st ~ Upper; 2nd ~ Middle; 3rd ~ Lower

Age is in Years; Fractional if Age less than One (1)
 If the Age is Estimated, it is in the form xx.5

With respect to the family relation variables (i.e. sibsp and parch)
some relations were ignored.  The following are the definitions used
for sibsp and parch.

Sibling:  Brother, Sister, Stepbrother, or Stepsister of Passenger Aboard Titanic
Spouse:   Husband or Wife of Passenger Aboard Titanic (Mistresses and Fiances Ignored)
Parent:   Mother or Father of Passenger Aboard Titanic
Child:    Son, Daughter, Stepson, or Stepdaughter of Passenger Aboard Titanic

Other family relatives excluded from this study include cousins,
nephews/nieces, aunts/uncles, and in-laws.  Some children travelled
only with a nanny, therefore parch=0 for them.  As well, some
travelled with very close friends or neighbors in a village, however,
the definitions do not support such relations.
```

So if this is our data, `Survived` is our **response variable** and the remaining variables are **predictors**. How can we determine who survives and who dies?

## A linear regression approach

Let's concentrate first on the relationship between age and survival. Using the methods we previously learned, we could estimate a linear regression model:


```r
ggplot(titanic, aes(Age, Survived)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
```

<img src="/notes/logistic-regression_files/figure-html/titanic_ols-1.png" width="672" />

Hmm. Not terrible, but you can immediately notice a couple of things. First, the only possible values for `Survival` are `\(0\)` and `\(1\)`. Yet the linear regression model gives us predicted values such as `\(.4\)` and `\(.25\)`. How should we interpret those?

One possibility is that these values are **predicted probabilities**. That is, the estimated probability a passenger will survive given their age. So someone with a predicted probability of `\(.4\)` has a 40% chance of surviving. Okay, but notice that because the line is linear and continuous, it extends infinitely in both directions of age.


```r
ggplot(titanic, aes(Age, Survived)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, fullrange = TRUE) +
  xlim(0, 200)
```

<img src="/notes/logistic-regression_files/figure-html/titanic_ols_old-1.png" width="672" />

What happens if a 200 year old person is on the Titanic? They would have a `\(-.1\)` probability of surviving. **But you cannot have a probability outside of the `\([0,1]\)` interval!** Admittedly this is a trivial example, but in other circumstances this can become a more realistic scenario.

Or what if we didn't want to predict survival, but instead predict the port from which an individual departed (Cherbourg, Queenstown, or Southampton)? We could try and code this as a numeric response variable:

| Numeric value | Port |
|---------------|-------------|
| 1 | Cherbourg |
| 2 | Queenstown |
| 3 | Southampton |

But why not instead code it:

| Numeric value | Port |
|---------------|-------------|
| 1 | Queenstown |
| 2 | Cherbourg |
| 3 | Southampton |

Or even:

| Numeric value | Port |
|---------------|-------------|
| 1 | Southampton |
| 2 | Cherbourg |
| 3 | Queenstown |

**There is no inherent ordering to this variable**. Any claimed linear relationship between a predictor and port of embarkation is completely dependent on how we convert the classes to numeric values.

## Logistic regression

Rather than modeling the response `\(Y\)` directly, logistic regression instead models the **probability** that `\(Y\)` belongs to a particular category. In our first Titanic example, the probability of survival can be written as:

`$$\Pr(\text{survival} = \text{Yes} | \text{age})$$`

The values of `\(\Pr(\text{survival} = \text{Yes} | \text{age})\)` (or simply `\(\Pr(\text{survival})\)`) will range between 0 and 1. Given that predicted probability, we could predict anyone with for whom `\(\Pr(\text{survival}) > .5\)` will survive the sinking, and anyone else will die.^[The threshold can be adjusted depending on how conservative or risky of a prediction you wish to make.]

We can estimate the logistic regression model using the `glm` function.


```r
survive_age <- glm(Survived ~ Age, data = titanic, family = binomial)
summary(survive_age)
```

```
## 
## Call:
## glm(formula = Survived ~ Age, family = binomial, data = titanic)
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
##   (177 observations deleted due to missingness)
## AIC: 964.23
## 
## Number of Fisher Scoring iterations: 4
```

Which produces a line that looks like this:


```r
ggplot(titanic, aes(Age, Survived)) +
  geom_point() +
  geom_smooth(method = "glm",
              method.args = list(family = "binomial"),
              se = FALSE)
```

<img src="/notes/logistic-regression_files/figure-html/titanic_age_glm_plot-1.png" width="672" />

It's hard to tell, but the line is not perfectly linear. Let's expand the range of the x-axis to prove this:


```r
ggplot(titanic, aes(Age, Survived)) +
  geom_point() +
  geom_smooth(method = "glm", method.args = list(family = "binomial"),
              se = FALSE, fullrange = TRUE) +
  xlim(0, 200)
```

<img src="/notes/logistic-regression_files/figure-html/titanic_age_glm_plot_wide-1.png" width="672" />

No more predictions that a 200 year old has a `\(-.1\)` probability of surviving!

## Adding predictions

To visualise the predictions from a model, we start by generating an evenly spaced grid of values that covers the region where our data lies. First we use `modelr::data_grid()` to create a cleaned data frame of potential values:


```r
titanic_age <- titanic %>%
  data_grid(Age)
titanic_age
```

```
## # A tibble: 89 x 1
##      Age
##    <dbl>
##  1  0.42
##  2  0.67
##  3  0.75
##  4  0.83
##  5  0.92
##  6  1   
##  7  2   
##  8  3   
##  9  4   
## 10  5   
## # … with 79 more rows
```

Next we use the `broom::augment()` function to produce the predicted probabilities. By default, `augment()` will generate predicted values in terms of the [**log-odds**](https://wiki.lesswrong.com/wiki/Log_odds) for the outcome. To get predicted probabilities, we explicitly specify the scale of the predicted values with `type.predict = "response'`:


```r
titanic_age <- augment(survive_age, type.predict = "response")
titanic_age
```

```
## # A tibble: 714 x 10
##    .rownames Survived   Age .fitted .se.fit .resid    .hat .sigma .cooksd
##    <chr>        <int> <dbl>   <dbl>   <dbl>  <dbl>   <dbl>  <dbl>   <dbl>
##  1 1                0    22   0.426  0.0209 -1.05  0.00179   1.16 6.68e-4
##  2 2                1    38   0.384  0.0212  1.38  0.00190   1.16 1.53e-3
##  3 3                1    26   0.415  0.0190  1.33  0.00149   1.16 1.05e-3
##  4 4                1    35   0.392  0.0196  1.37  0.00162   1.16 1.26e-3
##  5 5                0    35   0.392  0.0196 -0.997 0.00162   1.16 5.22e-4
##  6 7                0    54   0.343  0.0344 -0.917 0.00524   1.16 1.38e-3
##  7 8                0     2   0.480  0.0410 -1.14  0.00672   1.16 3.15e-3
##  8 9                1    27   0.413  0.0188  1.33  0.00145   1.16 1.03e-3
##  9 10               1    14   0.448  0.0276  1.27  0.00308   1.16 1.91e-3
## 10 11               1     4   0.475  0.0386  1.22  0.00597   1.16 3.34e-3
## # … with 704 more rows, and 1 more variable: .std.resid <dbl>
```

With this information, we can now plot the logistic regression line using the estimated model (and not just `ggplot2::geom_smooth()`):


```r
ggplot(titanic_age, aes(Age, .fitted)) +
  geom_line() +
  labs(title = "Relationship Between Age and Surviving the Titanic",
       y = "Predicted Probability of Survival")
```

<img src="/notes/logistic-regression_files/figure-html/plot_pred-1.png" width="672" />

## Multiple predictors

But as the old principle of the sea goes, ["women and children first"](https://en.wikipedia.org/wiki/Women_and_children_first). What if age isn't the only factor effecting survival? Fortunately logistic regression handles multiple predictors:


```r
survive_age_woman <- glm(Survived ~ Age + Sex, data = titanic,
                         family = binomial)
summary(survive_age_woman)
```

```
## 
## Call:
## glm(formula = Survived ~ Age + Sex, family = binomial, data = titanic)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.7405  -0.6885  -0.6558   0.7533   1.8989  
## 
## Coefficients:
##              Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  1.277273   0.230169   5.549 2.87e-08 ***
## Age         -0.005426   0.006310  -0.860     0.39    
## Sexmale     -2.465920   0.185384 -13.302  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 964.52  on 713  degrees of freedom
## Residual deviance: 749.96  on 711  degrees of freedom
##   (177 observations deleted due to missingness)
## AIC: 755.96
## 
## Number of Fisher Scoring iterations: 4
```

The coefficients essentially tell us the relationship between each individual predictor and the response, **independent of other predictors**. So this model tells us the relationship between age and survival, after controlling for the effects of gender. Likewise, it also tells us the relationship between gender and survival, after controlling for the effects of age. To get a better visualization of this, let's use `data_grid()` and `add_predictions()` again:


```r
titanic_age_sex <- augment(survive_age_woman,
                           newdata = data_grid(titanic, Age, Sex),
                           type.predict = "response")
titanic_age_sex
```

```
## # A tibble: 178 x 4
##      Age Sex    .fitted .se.fit
##    <dbl> <chr>    <dbl>   <dbl>
##  1  0.42 female   0.782  0.0389
##  2  0.42 male     0.233  0.0394
##  3  0.67 female   0.781  0.0388
##  4  0.67 male     0.233  0.0391
##  5  0.75 female   0.781  0.0387
##  6  0.75 male     0.233  0.0390
##  7  0.83 female   0.781  0.0386
##  8  0.83 male     0.233  0.0389
##  9  0.92 female   0.781  0.0386
## 10  0.92 male     0.233  0.0388
## # … with 168 more rows
```

With these predicted probabilities, we can now plot the separate effects of age and gender:


```r
ggplot(titanic_age_sex, aes(Age, .fitted, color = Sex)) +
  geom_line() +
  labs(title = "Probability of Surviving the Titanic",
       y = "Predicted Probability of Survival",
       color = "Sex")
```

<img src="/notes/logistic-regression_files/figure-html/survive_age_woman_plot-1.png" width="672" />

This graph illustrates a key fact about surviving the sinking of the Titanic - age was not really a dominant factor. Instead, one's gender was much more important. Females survived at much higher rates than males, regardless of age.

## Quadratic terms

Logistic regression, like linear regression, assumes each predictor has an independent and linear relationship with the response. That is, it assumes the relationship takes the form `\(y = \beta_0 + \beta_{1}x\)` and looks something like this:


```r
sim_line <- tibble(x = runif(1000),
                   y = x * 1)

ggplot(sim_line, aes(x, y)) +
  geom_line()
```

<img src="/notes/logistic-regression_files/figure-html/straight_line-1.png" width="672" />

But from algebra we know that variables can have non-linear relationships. Perhaps instead the relationship is parabolic like `\(y = \beta_0 + \beta_{1}x + \beta_{2}x^2\)`:


```r
sim_line <- tibble(x = runif(1000, -1, 1),
                   y = x^2 + x)

ggplot(sim_line, aes(x, y)) +
  geom_line()
```

<img src="/notes/logistic-regression_files/figure-html/parabola-1.png" width="672" />

Or a more general quadratic equation `\(y = \beta_0 + \beta_{1}x + \beta_{2}x^2 + \beta_{3}x^3\)`:


```r
sim_line <- tibble(x = runif(1000, -1, 1),
                   y = x^3 + x^2 + x)

ggplot(sim_line, aes(x, y)) +
  geom_line()
```

<img src="/notes/logistic-regression_files/figure-html/quadratic-1.png" width="672" />

These can be accounted for in a logistic regression:


```r
survive_age_square <- glm(Survived ~ Age + I(Age^2), data = titanic,
                          family = binomial)
summary(survive_age_square)
```

```
## 
## Call:
## glm(formula = Survived ~ Age + I(Age^2), family = binomial, data = titanic)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.2777  -1.0144  -0.9516   1.3421   1.4278  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)  
## (Intercept)  0.2688449  0.2722529   0.987   0.3234  
## Age         -0.0365193  0.0172749  -2.114   0.0345 *
## I(Age^2)     0.0003965  0.0002538   1.562   0.1183  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 964.52  on 713  degrees of freedom
## Residual deviance: 957.81  on 711  degrees of freedom
##   (177 observations deleted due to missingness)
## AIC: 963.81
## 
## Number of Fisher Scoring iterations: 4
```

```r
augment(survive_age_square,
        newdata = data_grid(titanic, Age),
        type.predict = "response") %>%
  ggplot(aes(Age, .fitted)) +
  geom_line() +
  labs(title = "Relationship Between Age and Surviving the Titanic",
       y = "Predicted Probability of Survival")
```

<img src="/notes/logistic-regression_files/figure-html/titanic-square-1.png" width="672" />

## Interactive terms

Another assumption of linear and logistic regression is that the relationships between predictors and responses are independent from one another. So for the age and gender example, we assume our function `\(f\)` looks something like:^[In mathematical truth, it looks more like:
    `$$\Pr(\text{survival} = \text{Yes} | \text{age}, \text{gender}) = \frac{1}{1 + e^{-(\beta_{0} + \beta_{1}\text{age} + \beta_{2}\text{gender})}}$$`]

`$$f = \beta_{0} + \beta_{1}\text{age} + \beta_{2}\text{gender}$$`

However once again, that is an assumption. What if the relationship between age and the probability of survival is actually dependent on whether or not the individual is a female? This possibility would take the functional form:

`$$f = \beta_{0} + \beta_{1}\text{age} + \beta_{2}\text{gender} + \beta_{3}(\text{age} \times \text{gender})$$`

This is considered an **interaction** between age and gender. To estimate this in R, we simply specify `Age * Sex` in our formula for the `glm()` function:^[R automatically includes constituent terms, so this turns into `Age + Sex + Age * Sex`. [Generally you always want to include constituent terms in a regression model with an interaction.](https://www-jstor-org.proxy.uchicago.edu/stable/25791835)]


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

As before, let's estimate predicted probabilities and plot the interactive effects of age and gender.


```r
titanic_age_sex_x <- augment(survive_age_woman_x,
                             newdata = data_grid(titanic, Age, Sex),
                             type.predict = "response")
titanic_age_sex_x
```

```
## # A tibble: 178 x 4
##      Age Sex    .fitted .se.fit
##    <dbl> <chr>    <dbl>   <dbl>
##  1  0.42 female   0.646  0.0701
##  2  0.42 male     0.325  0.0575
##  3  0.67 female   0.647  0.0694
##  4  0.67 male     0.323  0.0570
##  5  0.75 female   0.648  0.0692
##  6  0.75 male     0.323  0.0568
##  7  0.83 female   0.648  0.0690
##  8  0.83 male     0.323  0.0567
##  9  0.92 female   0.648  0.0688
## 10  0.92 male     0.322  0.0565
## # … with 168 more rows
```


```r
ggplot(titanic_age_sex_x, aes(Age, .fitted, color = Sex)) +
  geom_line() +
  labs(title = "Probability of Surviving the Titanic",
       y = "Predicted Probability of Survival",
       color = "Sex")
```

<img src="/notes/logistic-regression_files/figure-html/age_woman_plot-1.png" width="672" />

And now our minds are blown once again! For women, as age increases the probability of survival also increases. However for men, we see the opposite relationship: as age increases the probability of survival **decreases**. Again, the basic principle of saving women and children first can be seen empirically in the estimated probability of survival. Male children are treated similarly to female children, and their survival is prioritized. Even still, the odds of survival are always worse for men than women, but the regression function clearly shows a difference from our previous results.

You may think then that it makes sense to throw in interaction terms (and quadratic terms) willy-nilly to all your regression models since we never know for sure if the relationship is strictly linear and independent. You could do that, but once you start adding more predictors (3, 4, 5, etc.) that will get very difficult to keep track of (five-way interactions are extremely difficult to interpret - even three-way get to be problematic). The best advice is to use theory and your domain knowledge as your guide. Do you have a reason to believe the relationship should be interactive? If so, test for it. If not, don't.

## Comparing models

How do we know if a logistic regression model is good or bad? One evalation criteria simply asks: how many prediction errors did the model make? For instance, how often did our basic model just using age perform? First we need to get the predicted probabilities for each individual in the original dataset, convert the probability to a prediction (I use a `\(.5\)` cut-point), then see what percentage of predictions were the same as the actual survivals?


```r
age_accuracy <- augment(survive_age, type.predict = "response") %>%
  mutate(.pred = as.numeric(.fitted > .5))

mean(age_accuracy$Survived != age_accuracy$.pred, na.rm = TRUE)
```

```
## [1] 0.4061625
```

`\(40.6\%\)` of the predictions based on age were incorrect. If we flipped a coin to make our predictions, we'd be right about 50% of the time. So this is a decent improvement. Of course, we also know that `\(61.6\%\)` of passengers died in the sinking, so if we just guessed that every passenger died we'd still make fewer mistakes than our predictive model. Maybe this model isn't so great after all. What about our interactive age and gender model?


```r
x_accuracy <- augment(survive_age_woman_x, type.predict = "response") %>%
  mutate(.pred = as.numeric(.fitted > .5))

mean(x_accuracy$Survived != x_accuracy$.pred, na.rm = TRUE)
```

```
## [1] 0.219888
```

This model is much better. Just by knowing an individual's age and gender, our model is incorrect only   22% of the time.

## Exercise: logistic regression with `mental_health`

Why do some people vote in elections while others do not? Typical explanations focus on a resource model of participation -- individuals with greater resources, such as time, money, and civic skills, are more likely to participate in politics. An emerging theory assesses an individual's mental health and its effect on political participation.^[[Ojeda, C. (2015). Depression and political participation. *Social Science Quarterly*, 96(5), 1226-1243.](http://onlinelibrary.wiley.com.proxy.uchicago.edu/doi/10.1111/ssqu.12173/abstract)] Depression increases individuals' feelings of hopelessness and political efficacy, so depressed individuals will have less desire to participate in politics. More importantly to our resource model of participation, individuals with depression suffer physical ailments such as a lack of energy, headaches, and muscle soreness which drain an individual's energy and requires time and money to receive treatment. For these reasons, we should expect that individuals with depression are less likely to participate in election than those without symptoms of depression.

Use the `mental_health` data set in `library(rcfss)` and logistic regression to predict whether or not an individual voted in the 1996 presidental election.


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

1. Estimate a logistic regression model of voter turnout with `mhealth` as the predictor. Estimate predicted probabilities and plot the logistic regression line using `ggplot`.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # estimate model
    mh_model <- glm(vote96 ~ mhealth, data = mental_health,
                    family = binomial)
    tidy(mh_model)
    ```
    
    ```
    ## # A tibble: 2 x 5
    ##   term        estimate std.error statistic  p.value
    ##   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
    ## 1 (Intercept)    1.22     0.0890     13.7  6.28e-43
    ## 2 mhealth       -0.177    0.0222     -7.97 1.61e-15
    ```
    
    ```r
    # estimate predicted probabilities
    mh_health <- augment(mh_model,
                         newdata = data_grid(mental_health, mhealth),
                         type.predict = "response")
    mh_health
    ```
    
    ```
    ## # A tibble: 10 x 3
    ##    mhealth .fitted .se.fit
    ##      <dbl>   <dbl>   <dbl>
    ##  1       0   0.773  0.0156
    ##  2       1   0.740  0.0143
    ##  3       2   0.705  0.0133
    ##  4       3   0.667  0.0134
    ##  5       4   0.626  0.0151
    ##  6       5   0.584  0.0183
    ##  7       6   0.541  0.0225
    ##  8       7   0.496  0.0270
    ##  9       8   0.452  0.0315
    ## 10       9   0.409  0.0355
    ```
    
    ```r
    # graph the line
    ggplot(mh_health, aes(mhealth, .fitted)) +
      geom_line() +
      labs(title = "Relationship Between Mental Health and Voter Turnout",
           y = "Predicted Probability of Voting") +
      scale_y_continuous(limits = c(0, 1))
    ```
    
    <img src="/notes/logistic-regression_files/figure-html/mh-model-1.png" width="672" />
    
      </p>
    </details>

1. Calculate the error rate of the model.

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    mh_model_accuracy <- augment(mh_model, type.predict = "response") %>%
      mutate(.pred = as.numeric(.fitted > .5))
    
    (mh_model_err <- mean(mh_model_accuracy$vote96 != mh_model_accuracy$.pred,
                          na.rm = TRUE))
    ```
    
    ```
    ## [1] 0.317388
    ```
    
      </p>
    </details>

1. Estimate a second logistic regression model of voter turnout using the training set and all the predictors. Calculate it's error rate using the test set, and compare it to the original model. Which is better?

    <details> 
      <summary>Click for the solution</summary>
      <p>

    
    ```r
    # estimate model
    mh_model_all <- glm(vote96 ~ ., data = mental_health,
                    family = binomial)
    tidy(mh_model_all)
    ```
    
    ```
    ## # A tibble: 5 x 5
    ##   term        estimate std.error statistic  p.value
    ##   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
    ## 1 (Intercept)  -4.26     0.469      -9.07  1.18e-19
    ## 2 age           0.0446   0.00446    10.0   1.47e-23
    ## 3 educ          0.258    0.0266      9.70  3.15e-22
    ## 4 female       -0.0388   0.130      -0.298 7.65e- 1
    ## 5 mhealth      -0.118    0.0241     -4.90  9.51e- 7
    ```
    
    ```r
    # calculate error rate
    mh_model_all_accuracy <- augment(mh_model_all, type.predict = "response") %>%
      mutate(.pred = as.numeric(.fitted > .5))
    
    (mh_model_all_err <- mean(mh_model_all_accuracy$vote96 != mh_model_all_accuracy$.pred,
                              na.rm = TRUE))
    ```
    
    ```
    ## [1] 0.2786636
    ```
    
    The model with all predictors has a 3.87% lower error rate than predictions based only on mental health.
    
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
