---
title: "HW08: Analyzing text data"
date: 2019-05-27T13:30:00-06:00  # Schedule page publish date
publishdate: 2019-04-01

draft: false
type: post
aliases: ["/hw09-text_analysis.html"]

summary: "Collect text data and analyze it."
url_code: "https://github.com/cfss-su19/hw08"
---



# Overview

Due by 1:30pm on Monday July 29th.

# Fork the `hw08` repository

Go [here](https://github.com/cfss-su19/hw08) to fork the repo.

# Your mission

Perform text analysis.

## Okay, I need more information

Perform sentiment analysis, classification, or topic modeling using text analysis methods as demonstrated in class and in the readings.

## Okay, I need even more information.

Do the above. Can't think of a data source?

* `gutenbergr`
* `AssociatedPress` from the `topicmodels` package
* [Reuters-21578](http://www.daviddlewis.com/resources/testcollections/reuters21578/) - a standard set of text documents (articles published by Reuters in 1987). To access the document-term matrix for this data set, run the following code:

    
    
* [State of the Union speeches](http://www.presidency.ucsb.edu/sou.php)
* Scrape tweets using `rtweet` (you know how to use the API now, right?)

Analyze the text for sentiment OR topic. Or build a statistical learning model using text features to predict some outcome of interest. You don't have to do all these things, just pick one. The lecture notes and [Tidy Text Mining with R](http://tidytextmining.com/) are good starting points for templates to perform this type of analysis, but feel free to **expand beyond these examples**.

# Submit the assignment

Your assignment should be submitted as a set of R scripts, R Markdown documents, data files, etc. Whatever is necessary to show your code and present your results. Follow instructions on [homework workflow](/faq/homework-guidelines/#homework-workflow). As part of the pull request, you're encouraged to reflect on what was hard/easy, problems you solved, helpful tutorials you read, etc.

# Rubric

Check minus: Cannot get code to run or is poorly documented. Severe misinterpretations of the results. No effort is made to pre-process the text for analysis.^[Or you provide no justification for keeping content such as numbers, stop words, etc.]

Check: Solid effort. Hits all the elements. No clear mistakes. Easy to follow (both the code and the output). Nothing spectacular, either bad or good.

Check plus: Interpretation is clear and in-depth. Accurately interprets the results, with appropriate caveats for what the technique can and cannot do. Code is reproducible (i.e. if analyzing tweets, you have stored a copy in a local file so I can exactly reproduce your results as well as run it on a new sample of tweets). Uses a sentiment analysis or topic model approach not directly covered in class.
