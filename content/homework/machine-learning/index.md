---
title: "HW07: Machine learning"
date: 2019-05-06T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post
aliases: ["/hw06-stat-learn.html", "/homework/statistical-learning"]

summary: "Implement machine learning methods for regression and classification."
url_code: "https://github.com/cfss-win21/hw07"
---



# Overview

Due by 9:40am (Chicago) on March 2nd.

# Fork the `hw07` repository

Go [here](https://github.com/cfss-win21/hw07) to fork the repo.

# Part 1: Student debt

Median student debt in the United States has increased substantially over the past twenty years.

<div class="figure">
<img src="https://www.stlouisfed.org/~/media/Blog/2020/January/BlogImage_AvgMedianDebt_011420.png?la=en" alt="Median federal debt for students has increased since 2006. Source: &lt;a href=&quot;https://www.stlouisfed.org/on-the-economy/2020/january/rising-student-debt-great-recession&quot;&gt;Federal Reserve Bank of St. Louis&lt;/a&gt;"  />
<p class="caption">Figure 1: Median federal debt for students has increased since 2006. Source: <a href="https://www.stlouisfed.org/on-the-economy/2020/january/rising-student-debt-great-recession">Federal Reserve Bank of St. Louis</a></p>
</div>

`rcfss::scorecard` includes `debt`, which reports the median debt of students after leaving school in 2019.

{{% callout alert %}}

For all models, exclude `unitid` and `name` as predictors. These serve as id variables in the data set and uniquely identify each observation. They are not useful in predicting an outcome of interest.

{{% /callout %}}

1. Using the `tidymodels` framework, estimate a basic linear regression model to predict `debt` as a function of all the other variables in the dataset except for `state` and `openadmp`. Report the RMSE for the model.^[View the [documentation for `yardstick`](https://yardstick.tidymodels.org/reference/index.html#section-regression-metrics) to find the appropriate function for RMSE.]
1. Estimate the same linear regression model, but this time implement 10-fold cross-validation. Report the RMSE for the model.
1. Estimate a decision tree model to predict `debt` using 10-fold cross-validation. Use the `rpart` engine. Report the RMSE for the model.

## For those looking to stretch themselves

Estimate one or more models which utilize some aspect of feature engineering or [model tuning](/notes/tune-models/). Discuss the process you used to estimate the model and report on its performance.

# Part 2: Predicting attitudes towards racist college professors

The [General Social Survey](http://gss.norc.org/) is a biannual survey of the American public.^[Conducted by NORC at the University of Chicago.]

{{% callout note %}}

[The GSS gathers data on contemporary American society in order to monitor and explain trends and constants in attitudes, behaviors, and attributes. Hundreds of trends have been tracked since 1972. In addition, since the GSS adopted questions from earlier surveys, trends can be followed for up to 70 years. The GSS contains a standard core of demographic, behavioral, and attitudinal questions, plus topics of special interest. Among the topics covered are civil liberties, crime and violence, intergroup tolerance, morality, national spending priorities, psychological well-being, social mobility, and stress and traumatic events.](http://gss.norc.org/About-The-GSS)

{{% /callout %}}

`rcfss::gss` contains a selection of variables from the 2012 GSS. You are going to predict attitudes towards racist college professors. Specifically, each respondent was asked "Should a person who believes that Blacks are genetically inferior be allowed to teach in a college or university?" Given the kerfuffle over Richard J. Herrnstein and Charles Murray's [*The Bell Curve*](https://en.wikipedia.org/wiki/The_Bell_Curve) and the ostracization of Nobel Prize laureate [James Watson](https://en.wikipedia.org/wiki/James_Watson) over his controversial views on race and intelligence, this analysis will provide further insight into the public debate over this issue.

The outcome of interest `colrac` is a factor variable coded as either `"ALLOWED"` (respondent believes the person should be allowed to teach) or `"NOT ALLOWED"` (respondent believes the person should not allowed to teach).

{{% callout note %}}

Use the `gss` data frame, **not `gss_colrac`**. To ensure you have the correct data frame loaded, you can run:

```r
data("gss", package = "rcfss")
```

{{% /callout %}}

{{% callout alert %}}

For all models, exclude `id` and `wtss` as predictors. These serve as id variables in the data set and uniquely identify each observation. They are not useful in predicting an outcome of interest.

{{% /callout %}}

1. Estimate a logistic regression model to predict `colrac` as a function of `age`, `black`, `degree`, `partyid_3`, `sex,` and `south`. Implement 10-fold cross-validation. Report the accuracy of the model.
1. Estimate a random forest model to predict `colrac` as a function of all the other variables in the dataset (except `id` and `wtss`). In order to do this, you need to **impute** missing values for all the predictor columns. This means replacing missing values (`NA`) with plausible values given what we know about the other observations.
    - Remove rows with an `NA` for `colrac` - we want to omit observations with missing values for outcomes, not impute them
    - Use median imputation for numeric predictors
    - Use modal imputation for nominal predictors
    
    Implement 10-fold cross-validation. Report the accuracy of the model.
1. Estimate a $5$-nearest neighbors model to predict `colrac`. Use `recipes` to prepare the data set for training this model (e.g. scaling and normalizing variables, ensuring all predictors are numeric). Be sure to also perform the same preprocessing as for the random forest model. **Make sure your step order is correct for the recipe.** Implement 10-fold cross-validation. Report the accuracy of the model.
1. Estimate a ridge logistic regression model to predict `colrac`.^[`logistic_reg(penalty = .01, mixture = 0)`] Use the same recipe as for the $5$-nearest neighbors model. Implement 10-fold cross-validation, and utilize the same recipe as for the $k$-nearest neighbors model. Report the accuracy of the model.

## For those looking to stretch themselves

Estimate some set of additional models which utilize some aspect of feature engineering or [model tuning](/notes/tune-models/). Discuss the process you used to estimate the model and report on its performance.

{{% callout note %}}

Documentation for the other predictors (if the variable is not clearly coded) can be viewed [here](https://gssdataexplorer.norc.org/variables/vfilter). You can also run `?gss` to open a documentation file in R.

{{% /callout %}}

# Submit the assignment

Your assignment should be submitted as a set of two R Markdown documents using the `github_document` format. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Needs improvement: Cannot get code to run or is poorly documented. No documentation in the `README` file. Severe misinterpretations of the results. Overall a shoddy or incomplete assignment.

Satisfactory: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Excellent: Interpretation is clear and in-depth. Accurately interprets the results, with appropriate caveats for what the technique can and cannot do. Code is reproducible. Writes a user-friendly `README` file. Implements appropriate visualization techniques for the statistical model. Results are presented in a clear and intuitive manner.
