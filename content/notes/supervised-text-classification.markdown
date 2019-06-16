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
library(tidytext)
library(stringr)
library(caret)
library(tm)

set.seed(1234)
theme_set(theme_minimal())
```

A common task in social science involves hand-labeling sets of documents for specific variables (e.g. manual coding). In previous years, this required hiring a set of research assistants and training them to read and evaluate text by hand. It was expensive, prone to error, required extensive data quality checks, and was infeasible if you had an extremely large corpus of text that required classification.

Alternatively, we can now use statistical learning models to classify text into specific sets of categories. This is known as **supervised learning**. The basic process is:

1. Hand-code a small set of documents (say `\(1000\)`) for whatever variable(s) you care about
1. Train a statistical learning model on the hand-coded data, using the variable as the outcome of interest and the text features of the documents as the predictors
1. Evaluate the effectiveness of the statistical learning model via [cross-validation](/notes/cross-validation/)
1. Once you have trained a model with sufficient predictive accuracy, apply the model to the remaining set of documents that have never been hand-coded (say `\(1000000\)`)

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
##       ID  cong billnum h_or_sen major text                    label        
##    <dbl> <dbl>   <dbl> <chr>    <dbl> <chr>                   <chr>        
##  1     1   107    4499 HR          18 To suspend temporarily… Foreign trade
##  2     2   107    4500 HR          18 To suspend temporarily… Foreign trade
##  3     3   107    4501 HR          18 To suspend temporarily… Foreign trade
##  4     4   107    4502 HR          18 To reduce temporarily … Foreign trade
##  5     5   107    4503 HR           5 To amend the Immigrati… Labor and em…
##  6     6   107    4504 HR          21 To amend title 38, Uni… Public lands…
##  7     7   107    4505 HR          15 To repeal subtitle B o… Banking, fin…
##  8     8   107    4506 HR          18 To suspend temporarily… Foreign trade
##  9     9   107    4507 HR          18 To suspend temporarily… Foreign trade
## 10    10   107    4508 HR          18 To suspend temporarily… Foreign trade
## # … with 4,439 more rows
```

`USCongress` contains a sample of hand-labeled bills from the United States Congress. For each bill we have a text description of the bill's purpose (e.g. "To amend the Immigration and Nationality Act in regard to Caribbean-born immigrants.") as well as the bill's [major policy topic code corresponding to the subject of the bill](http://www.comparativeagendas.net/pages/master-codebook). There are 20 major policy topics according to this coding scheme (e.g. Macroeconomics, Civil Rights, Health). These topic codes have been labeled by hand. The current dataset only contains a sample of bills from the 107th Congress (2001-03). If we wanted to obtain policy topic codes for all bills introduced over a longer period, we would have to manually code tens of thousands if not millions of bill descriptions. Clearly a task outside of our capabilities.

Instead, we can build a statistical learning model which predicts the major topic code of a bill given its text description. These notes outline a potential `tidytext` workflow for such an approach.

## Create tidy text data frame

First we convert `USCongress` into a tidy text data frame.


```r
(congress_tokens <- congress %>%
   unnest_tokens(output = word, input = text) %>%
   # remove numbers
   filter(!str_detect(word, "^[0-9]*$")) %>%
   # remove stop words
   anti_join(stop_words) %>%
   # stem the words
   mutate(word = SnowballC::wordStem(word)))
```

```
## Joining, by = "word"
```

```
## # A tibble: 58,820 x 7
##       ID  cong billnum h_or_sen major label         word       
##    <dbl> <dbl>   <dbl> <chr>    <dbl> <chr>         <chr>      
##  1     1   107    4499 HR          18 Foreign trade suspend    
##  2     1   107    4499 HR          18 Foreign trade temporarili
##  3     1   107    4499 HR          18 Foreign trade duti       
##  4     1   107    4499 HR          18 Foreign trade fast       
##  5     1   107    4499 HR          18 Foreign trade magenta    
##  6     1   107    4499 HR          18 Foreign trade stage      
##  7     2   107    4500 HR          18 Foreign trade suspend    
##  8     2   107    4500 HR          18 Foreign trade temporarili
##  9     2   107    4500 HR          18 Foreign trade duti       
## 10     2   107    4500 HR          18 Foreign trade fast       
## # … with 58,810 more rows
```

Notice there are a few key steps involved here:

* `unnest_tokens(output = word, input = text)` - converts the data frame to a tidy text data frame and automatically converts all tokens to lowercase
* `filter(!str_detect(word, "^[0-9]*$"))` - removes all tokens which are strictly numbers. Numbers are generally not useful features in classifying documents (though sometimes they may be useful - you can compare results with and without numbers)
* `anti_join(stop_words)` - remove common stop words that are uninformative and will likely not be useful in predicting major topic codes
* `mutate(word = SnowballC::wordStem(word)))` - uses the [Porter stemming algorithm](https://tartarus.org/martin/PorterStemmer/) to stem all the tokens to their root word

Most of these steps are to reduce the number of text features in the set of documents. This is necessary because as you increase the number of observations (i.e. documents) and variables/features (i.e. tokens/words), the resulting statistical learning model will become more complex and harder to compute. Given a large enough corpus or set of variables, you may not be able to estimate many statistical learning models with your local computer - you would need to offload the work to a remote computing cluster.

## Create document-term matrix

Tidy text data frames are one-row-per-token, but for statistical learning algorithms we need our data in a one-row-per-document format. That is, a document-term matrix. We can use `cast_dtm()` to create a document-term matrix.


```r
(congress_dtm <- congress_tokens %>%
   # get count of each token in each document
   count(ID, word) %>%
   # create a document-term matrix with all features and tf weighting
   cast_dtm(document = ID, term = word, value = n))
```

```
## <<DocumentTermMatrix (documents: 4449, terms: 4902)>>
## Non-/sparse entries: 55033/21753965
## Sparsity           : 100%
## Maximal term length: 24
## Weighting          : term frequency (tf)
```

## Weighting

The default approach is to use [**term frequency** (tf) weighting](http://tidytextmining.com/tfidf.html), or a simple count of how frequently a word occurs in a document. An alternative approach is **term frequency inverse document frequency** (tf-idf), which is the frequency of a term adjusted for how rarely it is used. To generate tf-idf and use this for the document-term matrix, we can change the weighting function in `cast_dtm()`:^[We use `weightTfIdf()` from the `tm` package to calculate the new weights. [`tm`](http://tm.r-forge.r-project.org/) is a robust package in R for text mining and has many useful features for text analysis (though is not part of the `tidyverse`, so it may take some familiarization).]


```r
congress_tokens %>%
  # get count of each token in each document
  count(ID, word) %>%
  # create a document-term matrix with all features and tf-idf weighting
  cast_dtm(document = ID, term = word, value = n,
           weighting = tm::weightTfIdf)
```

```
## <<DocumentTermMatrix (documents: 4449, terms: 4902)>>
## Non-/sparse entries: 55033/21753965
## Sparsity           : 100%
## Maximal term length: 24
## Weighting          : term frequency - inverse document frequency (normalized) (tf-idf)
```

For now, let's just continue to use the term frequency approach. But it is a good idea to compare the results of tf vs. tf-idf to see if one method improves model performance over the other method.

## Sparsity

Another approach to reducing model complexity is to remove sparse terms from the model. That is, remove tokens which do not appear across many documents. It is similar to using tf-idf weighting, but directly deletes sparse variables from the document-term matrix. This results in a statistical learning model with a much smaller set of variables.

The `tm` package contains the `removeSparseTerms()` function, which does this task. The first argument is a document-term matrix, and the second argument defines the maximal allowed sparsity in the range from 0 to 1. So for instance, `sparse = .99` would remove any tokens which are missing from more than `\(99\%\)` of the documents in the corpus (i.e. the token must appear in at least `\(1\%\)` of the documents to be retained). Notice the effect changing this value has on the number of variables (tokens) retained in the document-term matrix:


```r
removeSparseTerms(congress_dtm, sparse = .99)
```

```
## <<DocumentTermMatrix (documents: 4449, terms: 209)>>
## Non-/sparse entries: 33794/896047
## Sparsity           : 96%
## Maximal term length: 11
## Weighting          : term frequency (tf)
```

```r
removeSparseTerms(congress_dtm, sparse = .95)
```

```
## <<DocumentTermMatrix (documents: 4449, terms: 28)>>
## Non-/sparse entries: 18447/106125
## Sparsity           : 85%
## Maximal term length: 11
## Weighting          : term frequency (tf)
```

```r
removeSparseTerms(congress_dtm, sparse = .90)
```

```
## <<DocumentTermMatrix (documents: 4449, terms: 16)>>
## Non-/sparse entries: 14917/56267
## Sparsity           : 79%
## Maximal term length: 9
## Weighting          : term frequency (tf)
```

It will be tough to build an effective model with just 16 tokens. Normal values for `sparse` are generally around `\(.99\)`. Let’s use that to create and store our final document-term matrix.


```r
(congress_dtm <- removeSparseTerms(congress_dtm, sparse = .99))
```

```
## <<DocumentTermMatrix (documents: 4449, terms: 209)>>
## Non-/sparse entries: 33794/896047
## Sparsity           : 96%
## Maximal term length: 11
## Weighting          : term frequency (tf)
```

## Exploratory analysis

Before building a fancy schmancy statistical model, we can first investigate if there are certain terms or tokens associated with each major topic category. We can do this purely with `tidytext` tools: we directly calculate the tf-idf for each term **treating each major topic code as the document**, rather than the individual bill. Then we can visualize the tokens with the highest tf-idf associated with each topic.^[See [here](http://tidytextmining.com/tfidf.html) for a more in-depth explanation of this approach.]

To calculate tf-idf directly in the data frame, first we `count()` the frequency each token appears in bills from each major topic code, then use `bind_tf_idf()` to calculate the tf-idf for each token in each topic:^[Notice our effort to remove numbers was not exactly perfect, but it probably removed a good portion of them.]


```r
(congress_tfidf <- congress_tokens %>%
   count(label, word) %>%
   bind_tf_idf(term = word, document = label, n = n))
```

```
## # A tibble: 13,190 x 6
##    label       word        n       tf   idf    tf_idf
##    <chr>       <chr>   <int>    <dbl> <dbl>     <dbl>
##  1 Agriculture abund       2 0.00106  3.00  0.00317  
##  2 Agriculture access      1 0.000529 0.163 0.0000860
##  3 Agriculture account     1 0.000529 0.223 0.000118 
##  4 Agriculture acet        2 0.00106  2.30  0.00244  
##  5 Agriculture acid        2 0.00106  1.90  0.00201  
##  6 Agriculture acreag      1 0.000529 2.30  0.00122  
##  7 Agriculture act        59 0.0312   0     0        
##  8 Agriculture action      5 0.00265  0.598 0.00158  
##  9 Agriculture activ       2 0.00106  0.223 0.000236 
## 10 Agriculture actual      1 0.000529 1.90  0.00100  
## # … with 13,180 more rows
```

Now all we need to do is plot the words with the highest tf-idf scores for each category. Since there are 20 major topics and a 20 panel facet graph is very dense, let's just look at four of the categories:


```r
# sort the data frame and convert word to a factor column
plot_congress <- congress_tfidf %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word))))

# graph the top 10 tokens for 4 categories
plot_congress %>%
  filter(label %in% c("Macroeconomics",
                      "Civil rights, minority issues, civil liberties",
                      "Health", "Education")) %>%
  group_by(label) %>%
  top_n(10) %>%
  ungroup() %>%
  ggplot(aes(word, tf_idf)) +
  geom_col() +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~ label, scales = "free") +
  coord_flip()
```

```
## Selecting by tf_idf
```

<img src="/notes/supervised-text-classification_files/figure-html/plot-tf-idf-1.png" width="672" />

Do these make sense? I think they do (well, some of them). This suggests a statistical learning model may find these tokens useful in predicting major topic codes.

## Estimate model

Now to estimate the model, we return to the `caret` package. Let's try a random forest model first. Here is the syntax for estimating the model:

```r
congress_rf <- train(x = as.matrix(congress_dtm),
                     y = factor(congress$major),
                     method = "ranger",
                     num.trees = 200,
                     trControl = trainControl(method = "oob"))
```

Note the differences from [how we specified them before with a standard data frame](/notes/decision-trees/#estimating-a-random-forest).

* `x = as.matrix(congress_dtm)` - instead of using a formula, we pass the independent and dependent variables separately into `train()`. `x` needs to be a simple matrix, data frame, or sparse matrix. These are specific types of objects in R. `congress_dtm` is a `DocumentTermMatrix`, so we use `as.matrix()` to convert it to a simple matrix.
* `y = factor(congress$major)` - we return to the original `congress` data frame to obtain the vector of outcome values for each document. Here, this is the major topic code associated with each bill. The important thing is that the order of documents in `x` remains the same as the order of documents in `y`, so that each document is associated with the correct outcome. Because `congress$major` is a numeric vector, we need to convert it to a factor vector so that we perform classification (and not regression).
* We use `method = "ranger"` to implement the random forest model. It is much faster and more efficient than the standard `rf` model, necessary due to the number of variables (tokens) in the model. The argument for setting the number of trees is now `num.trees`.

Otherwise everything else is the same as before. Notice how long it takes to build a random forest model with 10 trees, compared to a more typical random forest model with 200 trees:


```r
# some documents are lost due to not having any relevant tokens after tokenization
# make sure to remove their associated labels so we have the same number of observations
congress_slice <- slice(congress, as.numeric(congress_dtm$dimnames$Docs))

library(tictoc)

tic()
congress_rf_10 <- train(x = as.matrix(congress_dtm),
                        y = factor(congress_slice$major),
                        method = "ranger",
                        num.trees = 10,
                        importance = "impurity",
                        trControl = trainControl(method = "oob"))
toc()
```

```
## 8.406 sec elapsed
```


```r
tic()
congress_rf_200 <- train(x = as.matrix(congress_dtm),
                         y = factor(congress_slice$major),
                         method = "ranger",
                         num.trees = 200,
                         importance = "impurity",
                         trControl = trainControl(method = "oob"))
```

```
## Growing trees.. Progress: 47%. Estimated remaining time: 34 seconds.
## Growing trees.. Progress: 81%. Estimated remaining time: 7 seconds.
```

```r
toc()
```

```
## 157.455 sec elapsed
```

This is why it is important to remove sparse features and simplify the document-term matrix as much as possible - the more text features and observations in the document-term matrix, the longer it takes to train the model.

Otherwise, the result is no different from a model trained on categorical or continuous variables. We can generate the same diagnostics information:


```r
congress_rf_200$finalModel
```

```
## Ranger result
## 
## Call:
##  ranger::ranger(dependent.variable.name = ".outcome", data = x,      mtry = min(param$mtry, ncol(x)), min.node.size = param$min.node.size,      splitrule = as.character(param$splitrule), write.forest = TRUE,      probability = classProbs, ...) 
## 
## Type:                             Classification 
## Number of trees:                  200 
## Sample size:                      4449 
## Number of independent variables:  209 
## Mtry:                             105 
## Target node size:                 1 
## Variable importance mode:         impurity 
## Splitrule:                        extratrees 
## OOB prediction error:             32.37 %
```


```r
congress_rf_10$finalModel %>%
  # extract variable importance metrics
  ranger::importance() %>%
  # convert to a data frame
  enframe(name = "variable", value = "varimp") %>%
  top_n(n = 20, wt = varimp) %>%
  # plot the metrics
  ggplot(aes(x = fct_reorder(variable, varimp), y = varimp)) +
  geom_col() +
  coord_flip() +
  labs(x = "Token",
       y = "Variable importance (higher is more important)")
```

<img src="/notes/supervised-text-classification_files/figure-html/rf-varimp-1.png" width="672" />

And if we had a test set of observations (or a set of congressional bills never previously hand-coded), we could use this model to predict their major topic codes.

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.5        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-06-10                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package      * version    date       lib source        
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 3.6.0)
##  backports      1.1.4      2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown       0.12       2019-05-01 [1] CRAN (R 3.6.0)
##  bookdown       0.11       2019-05-28 [1] CRAN (R 3.6.0)
##  broom          0.5.2      2019-04-07 [1] CRAN (R 3.6.0)
##  callr          3.2.0      2019-03-15 [1] CRAN (R 3.6.0)
##  caret        * 6.0-84     2019-04-27 [1] CRAN (R 3.6.0)
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 3.6.0)
##  class          7.3-15     2019-01-01 [1] CRAN (R 3.6.0)
##  cli            1.1.0      2019-03-19 [1] CRAN (R 3.6.0)
##  codetools      0.2-16     2018-12-24 [1] CRAN (R 3.6.0)
##  colorspace     1.4-1      2019-03-18 [1] CRAN (R 3.6.0)
##  crayon         1.3.4      2017-09-16 [1] CRAN (R 3.6.0)
##  data.table     1.12.2     2019-04-07 [1] CRAN (R 3.6.0)
##  desc           1.2.0      2018-05-01 [1] CRAN (R 3.6.0)
##  devtools       2.0.2      2019-04-08 [1] CRAN (R 3.6.0)
##  digest         0.6.19     2019-05-20 [1] CRAN (R 3.6.0)
##  dplyr        * 0.8.1      2019-05-14 [1] CRAN (R 3.6.0)
##  e1071          1.7-2      2019-06-05 [1] CRAN (R 3.6.0)
##  ellipsis       0.1.0      2019-02-19 [1] CRAN (R 3.6.0)
##  evaluate       0.14       2019-05-28 [1] CRAN (R 3.6.0)
##  fansi          0.4.0      2018-10-05 [1] CRAN (R 3.6.0)
##  forcats      * 0.4.0      2019-02-17 [1] CRAN (R 3.6.0)
##  foreach        1.4.4      2017-12-12 [1] CRAN (R 3.6.0)
##  fs             1.3.1      2019-05-06 [1] CRAN (R 3.6.0)
##  generics       0.0.2      2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2      * 3.1.1      2019-04-07 [1] CRAN (R 3.6.0)
##  glue           1.3.1      2019-03-12 [1] CRAN (R 3.6.0)
##  gower          0.2.1      2019-05-14 [1] CRAN (R 3.6.0)
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 3.6.0)
##  haven          2.1.0      2019-02-19 [1] CRAN (R 3.6.0)
##  here           0.1        2017-05-28 [1] CRAN (R 3.6.0)
##  hms            0.4.2      2018-03-10 [1] CRAN (R 3.6.0)
##  htmltools      0.3.6      2017-04-28 [1] CRAN (R 3.6.0)
##  httr           1.4.0      2018-12-11 [1] CRAN (R 3.6.0)
##  ipred          0.9-9      2019-04-28 [1] CRAN (R 3.6.0)
##  iterators      1.0.10     2018-07-13 [1] CRAN (R 3.6.0)
##  janeaustenr    0.1.5      2017-06-10 [1] CRAN (R 3.6.0)
##  jsonlite       1.6        2018-12-07 [1] CRAN (R 3.6.0)
##  knitr          1.23       2019-05-18 [1] CRAN (R 3.6.0)
##  labeling       0.3        2014-08-23 [1] CRAN (R 3.6.0)
##  lattice      * 0.20-38    2018-11-04 [1] CRAN (R 3.6.0)
##  lava           1.6.5      2019-02-12 [1] CRAN (R 3.6.0)
##  lazyeval       0.2.2      2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate      1.7.4      2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr       1.5        2014-11-22 [1] CRAN (R 3.6.0)
##  MASS           7.3-51.4   2019-03-31 [1] CRAN (R 3.6.0)
##  Matrix         1.2-17     2019-03-22 [1] CRAN (R 3.6.0)
##  memoise        1.1.0      2017-04-21 [1] CRAN (R 3.6.0)
##  ModelMetrics   1.2.2      2018-11-03 [1] CRAN (R 3.6.0)
##  modelr         0.1.4      2019-02-18 [1] CRAN (R 3.6.0)
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 3.6.0)
##  nlme           3.1-140    2019-05-12 [1] CRAN (R 3.6.0)
##  NLP          * 0.2-0      2018-10-18 [1] CRAN (R 3.6.0)
##  nnet           7.3-12     2016-02-02 [1] CRAN (R 3.6.0)
##  pillar         1.4.1      2019-05-28 [1] CRAN (R 3.6.0)
##  pkgbuild       1.0.3      2019-03-20 [1] CRAN (R 3.6.0)
##  pkgconfig      2.0.2      2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload        1.0.2      2018-10-29 [1] CRAN (R 3.6.0)
##  plyr           1.8.4      2016-06-08 [1] CRAN (R 3.6.0)
##  prettyunits    1.0.2      2015-07-13 [1] CRAN (R 3.6.0)
##  processx       3.3.1      2019-05-08 [1] CRAN (R 3.6.0)
##  prodlim        2018.04.18 2018-04-18 [1] CRAN (R 3.6.0)
##  ps             1.3.0      2018-12-21 [1] CRAN (R 3.6.0)
##  purrr        * 0.3.2      2019-03-15 [1] CRAN (R 3.6.0)
##  R6             2.4.0      2019-02-14 [1] CRAN (R 3.6.0)
##  ranger         0.11.2     2019-03-07 [1] CRAN (R 3.6.0)
##  Rcpp           1.0.1      2019-03-17 [1] CRAN (R 3.6.0)
##  readr        * 1.3.1      2018-12-21 [1] CRAN (R 3.6.0)
##  readxl         1.3.1      2019-03-13 [1] CRAN (R 3.6.0)
##  recipes        0.1.5      2019-03-21 [1] CRAN (R 3.6.0)
##  remotes        2.0.4      2019-04-10 [1] CRAN (R 3.6.0)
##  reshape2       1.4.3      2017-12-11 [1] CRAN (R 3.6.0)
##  rlang          0.3.4      2019-04-07 [1] CRAN (R 3.6.0)
##  rmarkdown      1.13       2019-05-22 [1] CRAN (R 3.6.0)
##  rpart          4.1-15     2019-04-12 [1] CRAN (R 3.6.0)
##  rprojroot      1.3-2      2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi     0.10       2019-03-19 [1] CRAN (R 3.6.0)
##  rvest          0.3.4      2019-05-15 [1] CRAN (R 3.6.0)
##  scales         1.0.0      2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 3.6.0)
##  slam           0.1-45     2019-02-26 [1] CRAN (R 3.6.0)
##  SnowballC      0.6.0      2019-01-15 [1] CRAN (R 3.6.0)
##  stringi        1.4.3      2019-03-12 [1] CRAN (R 3.6.0)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 3.6.0)
##  survival       2.44-1.1   2019-04-01 [1] CRAN (R 3.6.0)
##  testthat       2.1.1      2019-04-23 [1] CRAN (R 3.6.0)
##  tibble       * 2.1.3      2019-06-06 [1] CRAN (R 3.6.0)
##  tictoc       * 1.0        2014-06-17 [1] CRAN (R 3.6.0)
##  tidyr        * 0.8.3      2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect     0.2.5      2018-10-11 [1] CRAN (R 3.6.0)
##  tidytext     * 0.2.0      2018-10-17 [1] CRAN (R 3.6.0)
##  tidyverse    * 1.2.1      2017-11-14 [1] CRAN (R 3.6.0)
##  timeDate       3043.102   2018-02-21 [1] CRAN (R 3.6.0)
##  tm           * 0.7-6      2018-12-21 [1] CRAN (R 3.6.0)
##  tokenizers     0.2.1      2018-03-29 [1] CRAN (R 3.6.0)
##  usethis        1.5.0      2019-04-07 [1] CRAN (R 3.6.0)
##  utf8           1.1.4      2018-05-24 [1] CRAN (R 3.6.0)
##  vctrs          0.1.0      2018-11-29 [1] CRAN (R 3.6.0)
##  withr          2.1.2      2018-03-15 [1] CRAN (R 3.6.0)
##  xfun           0.7        2019-05-14 [1] CRAN (R 3.6.0)
##  xml2           1.2.0      2018-01-24 [1] CRAN (R 3.6.0)
##  yaml           2.2.0      2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot        0.1.0      2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
