---
title: "HW07: Statistical learning"
date: 2019-05-06T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post
aliases: ["/hw06-stat-learn.html"]

summary: "Implement statistical learning methods for regression and classification."
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

`rcfss::scorecard` includes `debt`, which reports the median debt of students after leaving school in 2016.

1. Estimate a basic (single variable) linear regression model of the relationship between the average annual total cost of attendance, including tuition and fees, books and supplies, and living expenses (`cost`) and median debt of students post-graduation. That is, predict the median student's debt load as a function of the schools average annual cost of attendance. Visualize the model using `ggplot()` and determine whether there appears to be a significant relationship.

    {{% callout note %}}
    
For the visualization, you can either generate it manually using the predicted values from the linear regression model, or you can generate it within `geom_smooth()` automatically.
    
    {{% /callout %}}
    
1. Estimate a linear regression model of student debt given the variables you have available. You can specify the model in whatever form you choose (e.g. use all variables, add higher-order polynomial terms, convert variables to factors). Present the results of the model as a regression results table (i.e. a tidy, clean looking table presenting the coefficients/standard errors with human-readable labels) and through some set of visualizations. Provide written analysis interpreting the results.

# Part 2: Predicting attitudes towards racist college professors

The [General Social Survey](http://gss.norc.org/) is a biannual survey of the American public.^[Conducted by NORC at the University of Chicago.]

{{% callout note %}}

[The GSS gathers data on contemporary American society in order to monitor and explain trends and constants in attitudes, behaviors, and attributes. Hundreds of trends have been tracked since 1972. In addition, since the GSS adopted questions from earlier surveys, trends can be followed for up to 70 years. The GSS contains a standard core of demographic, behavioral, and attitudinal questions, plus topics of special interest. Among the topics covered are civil liberties, crime and violence, intergroup tolerance, morality, national spending priorities, psychological well-being, social mobility, and stress and traumatic events.](http://gss.norc.org/About-The-GSS)

{{% /callout %}}

`rcfss::gss` contains a selection of variables from the 2012 GSS. You are going to predict attitudes towards racist college professors. Specifically, each respondent was asked "Should a person who believes that Blacks are genetically inferior be allowed to teach in a college or university?" Given the kerfuffle over Richard J. Herrnstein and Charles Murray's [*The Bell Curve*](https://en.wikipedia.org/wiki/The_Bell_Curve) and the ostracization of Nobel Prize laureate [James Watson](https://en.wikipedia.org/wiki/James_Watson) over his controversial views on race and intelligence, this analysis will provide further insight into the public debate over this issue.

The outcome of interest `colrac` is a factor variable coded as either `"ALLOWED"` (respondent believes the person should be allowed to teach) or `"NOT ALLOWED"` (respondent believes the person should not allowed to teach).

{{% callout note %}}

Make sure you are using the most recent version of `rcfss` (currently version 0.2.1). If you cannot find `gss` in the package, please reinstall `rcfss` so you are running the most up-to-date version.

{{% /callout %}}

You will estimate a logistic regression model predicting whether or not an individual believes the person should be allowed to teach. As before, the specification of that model is entirely up to you. Present your results using some combination of techniques learned this week [in class](/syllabus/working-with-statistical-models/). Your submission should be written in the style of a short report focusing on the substantive question on attitudes towards racist college professors. I expect around 500-750 words of written analysis, supplemented by the results of your statistical model.

{{% callout note %}}

Documentation for the other predictors (if the variable is not clearly coded) can be viewed [here](https://gssdataexplorer.norc.org/variables/vfilter). You can also run `?gss` to open a documentation file in R.

{{% /callout %}}

# Submit the assignment

Your assignment should be submitted as a set of two R Markdown documents using the `github_document` format. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Needs improvement: Cannot get code to run or is poorly documented. No documentation in the `README` file. Severe misinterpretations of the results. Overall a shoddy or incomplete assignment.

Satisfactory: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Excellent: Interpretation is clear and in-depth. Accurately interprets the results, with appropriate caveats for what the technique can and cannot do. Code is reproducible. Writes a user-friendly `README` file. Implements appropriate visualization techniques for the statistical model. Results are presented in a clear and intuitive manner.
