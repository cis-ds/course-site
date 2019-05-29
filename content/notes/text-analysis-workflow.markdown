---
title: "Basic workflow for text analysis"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/text001_workflow.html"]
categories: ["text"]

menu:
  notes:
    parent: Text analysis
    weight: 1
---



## Obtain your text sources

Text data can come from lots of areas:

* Web sites
    * Twitter
* Databases
* PDF documents
* Digital scans of printed materials

The easier to convert your text data into digitally stored text, the cleaner your results and fewer transcription errors.

## Extract documents and move into a corpus

A **text corpus** is a large and structured set of texts. It typically stores the text as a [raw character string](http://r4ds.had.co.nz/strings.html) with meta data and details stored with the text.

## Transformation

Examples of typical transformations include:

* Tagging segments of speech for part-of-speech (nouns, verbs, adjectives, etc.) or entity recognition (person, place, company, etc.)
* Standard text processing - we want to remove extraneous information from the text and standardize it into a uniform format. This typically involves:
    * Converting to lower case
    * Removing punctuation
    * Removing numbers
    * Removing **stopwords** - common parts of speech that are not informative such as *a*, *an*, *be*, *of*, etc.
    * Removing domain-specific stopwords
    * Stemming - reduce words to their word stem
        * "Fishing", "fished", and "fisher" -> "fish"

## Extract features

Feature extraction involves converting the text string into some sort of quantifiable measures. The most common approach is the **bag-of-words model**, whereby each document is represented as a vector which counts the frequency of each term's appearance in the document. You can combine all the vectors for each document together and you create a *term-document matrix*:

* Each row is a document
* Each column is a term
* Each cell represents the frequency of the term appearing in the document

However the bag-of-word model ignores **context**. You could randomly scramble the order of terms appearing in the document and still get the same term-document matrix.

An alternative encoding method is **word embeddings**. Word embeddings take a high-dimensional dataset (for instance, documents with thousands or tens of thousands of unique words) and compress it into a lower-dimensional dataset that maintains the same basic configuration and sets of relationships between words. Each word is encoded as a **vector**, or a set of coordinates in geometric space. If the word embedding space represents the semantic meaning of words, we can see these semantic relationships with some basic algebraic operations.

![](https://blogs.mathworks.com/images/loren/2017/vecs.png)

## Perform analysis

At this point you now have data assembled and ready for analysis. There are several approaches you may take when analyzing text depending on your research question. Basic approaches include:

* Word frequency - counting the frequency of words in the text
* Collocation - words commonly appearing near each other
* Dictionary tagging - locating a specific set of words in the texts

More advanced methods include **document classification**, or assigning documents to different categories. This can be **supervised** (the potential categories are defined in advance of the modeling) or **unsupervised** (the potential categories are unknown prior to analysis). You might also conduct **corpora comparison**, or comparing the content of different groups of text. This is the approach used in plagiarism detecting software such as [Turn It In](http://turnitin.com/). Finally, you may attempt to detect clusters of document features, known as **topic modeling**.

## Acknowledgments

* This page is derived in part from ["Tidy Text Mining with R"](http://tidytextmining.com/) and licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 United States License](https://creativecommons.org/licenses/by-nc-sa/3.0/us/).
* This page is derived in part from [Common Text Mining Workflow](https://dzone.com/articles/common-text-mining-workflow).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.5.3 (2019-03-11)
##  os       macOS Mojave 10.14.5        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-05-29                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.4   2019-04-10 [2] CRAN (R 3.5.2)
##  blogdown      0.12    2019-05-01 [1] CRAN (R 3.5.2)
##  bookdown      0.10    2019-05-10 [1] CRAN (R 3.5.2)
##  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
##  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.2   2019-04-08 [1] CRAN (R 3.5.2)
##  digest        0.6.19  2019-05-20 [1] CRAN (R 3.5.2)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.5.2)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.5.3)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
##  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.1   2019-05-08 [1] CRAN (R 3.5.2)
##  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  remotes       2.0.4   2019-04-10 [1] CRAN (R 3.5.2)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.1.1   2019-04-23 [2] CRAN (R 3.5.2)
##  usethis       1.5.0   2019-04-07 [1] CRAN (R 3.5.2)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.7     2019-05-14 [1] CRAN (R 3.5.2)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
