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
data(USCongress, package = "RTextTools")

(congress <- as_tibble(USCongress) %>%
    mutate(text = as.character(text)))
```

```
## # A tibble: 4,449 x 6
##       ID  cong billnum h_or_sen major text                                 
##    <int> <int>   <int> <fct>    <int> <chr>                                
##  1     1   107    4499 HR          18 To suspend temporarily the duty on F…
##  2     2   107    4500 HR          18 To suspend temporarily the duty on F…
##  3     3   107    4501 HR          18 To suspend temporarily the duty on m…
##  4     4   107    4502 HR          18 To reduce temporarily the duty on Pr…
##  5     5   107    4503 HR           5 To amend the Immigration and Nationa…
##  6     6   107    4504 HR          21 To amend title 38, United States Cod…
##  7     7   107    4505 HR          15 To repeal subtitle B of title III of…
##  8     8   107    4506 HR          18 To suspend temporarily the duty on T…
##  9     9   107    4507 HR          18 To suspend temporarily the duty on 2…
## 10    10   107    4508 HR          18 To suspend temporarily the duty on T…
## # … with 4,439 more rows
```

`USCongress` from the [`RTextTools` package](http://www.rtexttools.com/) contains a sample of hand-labeled bills from the United States Congress. For each bill we have a text description of the bill's purpose (e.g. "To amend the Immigration and Nationality Act in regard to Caribbean-born immigrants.") as well as the bill's [major policy topic code corresponding to the subject of the bill](http://www.comparativeagendas.net/pages/master-codebook). There are 20 major policy topics according to this coding scheme (e.g. Macroeconomics, Civil Rights, Health). These topic codes have been labeled by hand. The current dataset only contains a sample of bills from the 107th Congress (2001-03). If we wanted to obtain policy topic codes for all bills introduced over a longer period, we would have to manually code tens of thousands if not millions of bill descriptions. Clearly a task outside of our capabilities.

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
## # A tibble: 58,820 x 6
##       ID  cong billnum h_or_sen major word       
##    <int> <int>   <int> <fct>    <int> <chr>      
##  1     1   107    4499 HR          18 suspend    
##  2     1   107    4499 HR          18 temporarili
##  3     1   107    4499 HR          18 duti       
##  4     1   107    4499 HR          18 fast       
##  5     1   107    4499 HR          18 magenta    
##  6     1   107    4499 HR          18 stage      
##  7     2   107    4500 HR          18 suspend    
##  8     2   107    4500 HR          18 temporarili
##  9     2   107    4500 HR          18 duti       
## 10     2   107    4500 HR          18 fast       
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

It will be tough to build an effective model with just 16 tokens. Normal values for `sparse` are generally around `\(.99\)`. Let's use that to create and store our final document-term matrix.


```r
congress_dtm <- removeSparseTerms(congress_dtm, sparse = .99)
```

## Exploratory analysis

Before building a fancy schmancy statistical model, we can first investigate if there are certain terms or tokens associated with each major topic category. We can do this purely with `tidytext` tools: we directly calculate the tf-idf for each term **treating each major topic code as the document**, rather than the individual bill. Then we can visualize the tokens with the highest tf-idf associated with each topic.^[See [here](http://tidytextmining.com/tfidf.html) for a more in-depth explanation of this approach.]

To calculate tf-idf directly in the data frame, first we `count()` the frequency each token appears in bills from each major topic code, then use `bind_tf_idf()` to calculate the tf-idf for each token in each topic:^[Notice our effort to remove numbers was not exactly perfect, but it probably removed a good portion of them.]


```r
(congress_tfidf <- congress_tokens %>%
   count(major, word) %>%
   bind_tf_idf(term = word, document = major, n = n))
```

```
## # A tibble: 13,190 x 6
##    major word          n       tf   idf   tf_idf
##    <int> <chr>     <int>    <dbl> <dbl>    <dbl>
##  1     1 25,000        1 0.000484 1.90  0.000917
##  2     1 3,500,000     1 0.000484 3.00  0.00145 
##  3     1 38.6          1 0.000484 3.00  0.00145 
##  4     1 abolish       1 0.000484 2.30  0.00111 
##  5     1 abroad        1 0.000484 1.90  0.000917
##  6     1 abus          2 0.000967 1.05  0.00102 
##  7     1 acceler       1 0.000484 1.05  0.000508
##  8     1 account       6 0.00290  0.223 0.000647
##  9     1 accur         1 0.000484 1.05  0.000508
## 10     1 acquir        2 0.000967 1.39  0.00134 
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
  filter(major %in% c(1, 2, 3, 6)) %>%
  mutate(major = factor(major, levels = c(1, 2, 3, 6),
                        labels = c("Macroeconomics", "Civil Rights",
                                   "Health", "Education"))) %>%
  group_by(major) %>%
  top_n(10) %>%
  ungroup() %>%
  ggplot(aes(word, tf_idf)) +
  geom_col() +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~major, scales = "free") +
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
                     method = "rf",
                     ntree = 200,
                     trControl = trainControl(method = "oob"))
```

Note the differences from [how we specified them before with a standard data frame](/notes/decision-trees/#estimating-a-random-forest).

* `x = as.matrix(congress_dtm)` - instead of using a formula, we pass the independent and dependent variables separately into `train()`. `x` needs to be a simple matrix, data frame, or sparse matrix. These are specific types of objects in R. `congress_dtm` is a `DocumentTermMatrix`, so we use `as.matrix()` to convert it to a simple matrix.
* `y = factor(congress$major)` - we return to the original `congress` data frame to obtain the vector of outcome values for each document. Here, this is the major topic code associated with each bill. The important thing is that the order of documents in `x` remains the same as the order of documents in `y`, so that each document is associated with the correct outcome. Because `congress$major` is a numeric vector, we need to convert it to a factor vector so that we perform classification (and not regression).

Otherwise everything else is the same as before. Notice how long it takes to build a random forest model with 10 trees, compared to a more typical random forest model with 200 trees:


```r
system.time({
  congress_rf_10 <- train(x = as.matrix(congress_dtm),
                          y = factor(congress$major),
                          method = "rf",
                          ntree = 10,
                          trControl = trainControl(method = "oob"))
})
```

```
##    user  system elapsed 
##  10.372   0.133  10.660
```


```r
system.time({
  congress_rf_200 <- train(x = as.matrix(congress_dtm),
                           y = factor(congress$major),
                           method = "rf",
                           ntree = 200,
                           trControl = trainControl(method = "oob"))
})
```

```
##    user  system elapsed 
## 170.867   1.009 177.976
```

This is why it is important to remove sparse features and simplify the document-term matrix as much as possible - the more text features and observations in the document-term matrix, the longer it takes to train the model.

Otherwise, the result is no different from a model trained on categorical or continuous variables. We can generate the same diagnostics information:


```r
congress_rf_200$finalModel
```

```
## 
## Call:
##  randomForest(x = x, y = y, ntree = 200, mtry = param$mtry) 
##                Type of random forest: classification
##                      Number of trees: 200
## No. of variables tried at each split: 105
## 
##         OOB estimate of  error rate: 32.86%
## Confusion matrix:
##      1  2   3  4   5   6   7   8 10  12 13 14  15  16 17  18 19  20  21 99
## 1  107  0   2  0   3   3   2   5  6   6  0  2  11   2  1   3  1   8   1  0
## 2    2 18   5  1   4   4   4   1  3   6  3  2   6   6  2   1  1  11   4  0
## 3    3  1 537  2  12  11   3   0  5   9  5  3   7  10  1   0  0   5   3  0
## 4    2  1   9 90   2   2   5   1  2   1  0  1   2   0  2   6  0   2   5  0
## 5    6  3  12  2 147  11   4   2  9  13  2  1   8   5  6  11  4   7   8  1
## 6    8  1   7  0   9 164   3   0  1   6  1  1   5   2  2   4  2   2   4  0
## 7    3  3   6  6   5   2 105   4  9   7  1  2   6   4  4   4  2   5  23  0
## 8    6  1   1  1   2   1   4 102  4   3  0  2   3   1  0   1  0   1   5  0
## 10   3  1   1  3   4   1   6   3 99  14  0  0   7   3  3   4  2  12   5  0
## 12   9  2  20  3  11   6   7   0  6 148  4  3  14   4  6   8  5  27   5  3
## 13   5  0   4  0   4   0   3   2  1   1 65  2   1   0  1   1  1   2   1  0
## 14   3  0   1  2   5   2   2   2  4   2  1 42   4   2  4   2  0   1   1  0
## 15  13  6   8  4  13   2   9   5  5  14  1  2 152   4  7  11  8  12   2  1
## 16   1  6   1  0   7   4   3   2  7   5  1  1   5 135  1  10  6  18   6  0
## 17   4  0   3  1   6   3   3   1  3   7  2  2   2   2 40   1  1   5   3  1
## 18   0  0   3  2   2   0   5   2  2   1  0  0   1   1  0 372  7   2   2  0
## 19   2  0   5  1   8   6   7   0  5   7  0  1   3   6  0   9 48   4   9  0
## 20  10  2   7  1  15   3   5   1  6  23  1  3   9  14  7  13  2 235  22  1
## 21   7  3   5  2   6   4  24   1  8   4  1  5   3  10  3  11  3  15 356  1
## 99   0  0   0  0   1   0   0   0  1   0  0  0   0   1  1   0  0   0   1 25
##    class.error
## 1   0.34355828
## 2   0.78571429
## 3   0.12965964
## 4   0.32330827
## 5   0.43893130
## 6   0.26126126
## 7   0.47761194
## 8   0.26086957
## 10  0.42105263
## 12  0.49140893
## 13  0.30851064
## 14  0.47500000
## 15  0.45519713
## 16  0.38356164
## 17  0.55555556
## 18  0.07462687
## 19  0.60330579
## 20  0.38157895
## 21  0.24576271
## 99  0.16666667
```


```r
randomForest::varImpPlot(congress_rf_200$finalModel)
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
##  package      * version    date       lib source        
##  assertthat     0.2.1      2019-03-21 [2] CRAN (R 3.5.3)
##  backports      1.1.3      2018-12-14 [2] CRAN (R 3.5.0)
##  blogdown       0.11       2019-03-11 [1] CRAN (R 3.5.2)
##  bookdown       0.9        2018-12-21 [1] CRAN (R 3.5.0)
##  broom          0.5.1      2018-12-05 [2] CRAN (R 3.5.0)
##  callr          3.2.0      2019-03-15 [2] CRAN (R 3.5.2)
##  caret        * 6.0-81     2018-11-20 [1] CRAN (R 3.5.0)
##  cellranger     1.1.0      2016-07-27 [2] CRAN (R 3.5.0)
##  class          7.3-15     2019-01-01 [2] CRAN (R 3.5.3)
##  cli            1.1.0      2019-03-19 [1] CRAN (R 3.5.2)
##  codetools      0.2-16     2018-12-24 [2] CRAN (R 3.5.3)
##  colorspace     1.4-1      2019-03-18 [2] CRAN (R 3.5.2)
##  crayon         1.3.4      2017-09-16 [2] CRAN (R 3.5.0)
##  data.table     1.12.0     2019-01-13 [2] CRAN (R 3.5.2)
##  desc           1.2.0      2018-05-01 [2] CRAN (R 3.5.0)
##  devtools       2.0.1      2018-10-26 [1] CRAN (R 3.5.1)
##  digest         0.6.18     2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr        * 0.8.0.1    2019-02-15 [1] CRAN (R 3.5.2)
##  evaluate       0.13       2019-02-12 [2] CRAN (R 3.5.2)
##  forcats      * 0.4.0      2019-02-17 [2] CRAN (R 3.5.2)
##  foreach        1.4.4      2017-12-12 [2] CRAN (R 3.5.0)
##  fs             1.2.7      2019-03-19 [1] CRAN (R 3.5.3)
##  generics       0.0.2      2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2      * 3.1.0      2018-10-25 [1] CRAN (R 3.5.0)
##  glue           1.3.1      2019-03-12 [2] CRAN (R 3.5.2)
##  gower          0.2.0      2019-03-07 [2] CRAN (R 3.5.2)
##  gtable         0.2.0      2016-02-26 [2] CRAN (R 3.5.0)
##  haven          2.1.0      2019-02-19 [2] CRAN (R 3.5.2)
##  here           0.1        2017-05-28 [2] CRAN (R 3.5.0)
##  hms            0.4.2      2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools      0.3.6      2017-04-28 [1] CRAN (R 3.5.0)
##  httr           1.4.0      2018-12-11 [2] CRAN (R 3.5.0)
##  ipred          0.9-8      2018-11-05 [1] CRAN (R 3.5.0)
##  iterators      1.0.10     2018-07-13 [2] CRAN (R 3.5.0)
##  janeaustenr    0.1.5      2017-06-10 [2] CRAN (R 3.5.0)
##  jsonlite       1.6        2018-12-07 [2] CRAN (R 3.5.0)
##  knitr          1.22       2019-03-08 [2] CRAN (R 3.5.2)
##  lattice      * 0.20-38    2018-11-04 [2] CRAN (R 3.5.3)
##  lava           1.6.5      2019-02-12 [2] CRAN (R 3.5.2)
##  lazyeval       0.2.2      2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate      1.7.4      2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr       1.5        2014-11-22 [2] CRAN (R 3.5.0)
##  MASS           7.3-51.1   2018-11-01 [2] CRAN (R 3.5.3)
##  Matrix         1.2-15     2018-11-01 [2] CRAN (R 3.5.3)
##  memoise        1.1.0      2017-04-21 [2] CRAN (R 3.5.0)
##  ModelMetrics   1.2.2      2018-11-03 [2] CRAN (R 3.5.0)
##  modelr         0.1.4      2019-02-18 [2] CRAN (R 3.5.2)
##  munsell        0.5.0      2018-06-12 [2] CRAN (R 3.5.0)
##  nlme           3.1-137    2018-04-07 [2] CRAN (R 3.5.3)
##  NLP          * 0.2-0      2018-10-18 [2] CRAN (R 3.5.0)
##  nnet           7.3-12     2016-02-02 [2] CRAN (R 3.5.3)
##  pillar         1.3.1      2018-12-15 [2] CRAN (R 3.5.0)
##  pkgbuild       1.0.3      2019-03-20 [1] CRAN (R 3.5.3)
##  pkgconfig      2.0.2      2018-08-16 [2] CRAN (R 3.5.1)
##  pkgload        1.0.2      2018-10-29 [1] CRAN (R 3.5.0)
##  plyr           1.8.4      2016-06-08 [2] CRAN (R 3.5.0)
##  prettyunits    1.0.2      2015-07-13 [2] CRAN (R 3.5.0)
##  processx       3.3.0      2019-03-10 [2] CRAN (R 3.5.2)
##  prodlim        2018.04.18 2018-04-18 [2] CRAN (R 3.5.0)
##  ps             1.3.0      2018-12-21 [2] CRAN (R 3.5.0)
##  purrr        * 0.3.2      2019-03-15 [2] CRAN (R 3.5.2)
##  R6             2.4.0      2019-02-14 [1] CRAN (R 3.5.2)
##  Rcpp           1.0.1      2019-03-17 [1] CRAN (R 3.5.2)
##  readr        * 1.3.1      2018-12-21 [2] CRAN (R 3.5.0)
##  readxl         1.3.1      2019-03-13 [2] CRAN (R 3.5.2)
##  recipes        0.1.5      2019-03-21 [1] CRAN (R 3.5.3)
##  remotes        2.0.2      2018-10-30 [1] CRAN (R 3.5.0)
##  reshape2       1.4.3      2017-12-11 [2] CRAN (R 3.5.0)
##  rlang          0.3.4      2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown      1.12       2019-03-14 [1] CRAN (R 3.5.2)
##  rpart          4.1-13     2018-02-23 [1] CRAN (R 3.5.0)
##  rprojroot      1.3-2      2018-01-03 [2] CRAN (R 3.5.0)
##  rstudioapi     0.10       2019-03-19 [1] CRAN (R 3.5.3)
##  rvest          0.3.2      2016-06-17 [2] CRAN (R 3.5.0)
##  scales         1.0.0      2018-08-09 [1] CRAN (R 3.5.0)
##  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 3.5.0)
##  slam           0.1-45     2019-02-26 [1] CRAN (R 3.5.2)
##  SnowballC      0.6.0      2019-01-15 [2] CRAN (R 3.5.2)
##  stringi        1.4.3      2019-03-12 [1] CRAN (R 3.5.2)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 3.5.2)
##  survival       2.43-3     2018-11-26 [2] CRAN (R 3.5.3)
##  testthat       2.0.1      2018-10-13 [2] CRAN (R 3.5.0)
##  tibble       * 2.1.1      2019-03-16 [2] CRAN (R 3.5.2)
##  tidyr        * 0.8.3      2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect     0.2.5      2018-10-11 [1] CRAN (R 3.5.0)
##  tidytext     * 0.2.0      2018-10-17 [1] CRAN (R 3.5.0)
##  tidyverse    * 1.2.1      2017-11-14 [2] CRAN (R 3.5.0)
##  timeDate       3043.102   2018-02-21 [2] CRAN (R 3.5.0)
##  tm           * 0.7-6      2018-12-21 [2] CRAN (R 3.5.0)
##  tokenizers     0.2.1      2018-03-29 [2] CRAN (R 3.5.0)
##  usethis        1.4.0      2018-08-14 [1] CRAN (R 3.5.0)
##  withr          2.1.2      2018-03-15 [2] CRAN (R 3.5.0)
##  xfun           0.5        2019-02-20 [1] CRAN (R 3.5.2)
##  xml2           1.2.0      2018-01-24 [2] CRAN (R 3.5.0)
##  yaml           2.2.0      2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
