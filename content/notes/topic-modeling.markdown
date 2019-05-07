---
title: "Topic modeling"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/text_topicmodels.html"]
categories: ["text"]

menu:
  notes:
    parent: Text analysis
    weight: 5
---




```r
library(tidyverse)
library(gutenbergr)
library(tidytext)
library(topicmodels)
library(here)

set.seed(1234)
theme_set(theme_minimal())
```

Typically when we search for information online, there are two primary methods:

1. **Keywords** - use a search engine and type in words that relate to whatever it is we want to find
1. **Links** - use the networked structure of the web to travel from page to page. Linked pages are likely to share similar or related content.

An alternative method would be to search and explore documents via themes. For instance, [David Blei](http://delivery.acm.org/10.1145/2140000/2133826/p77-blei.pdf) proposes searching through the complete history of the New York Times. Broad themes may relate to the individual sections in the paper (foreign policy, national affairs, sports) but there might be specific themes within or across these sections (Chinese foreign policy, the conflict in the Middle East, the U.S.'s relationship with Russia). If the documents are grouped by these themes, we could track the evolution of the NYT's reporting on these issues over time, or examine how discussion of different themes intersects.

In order to do this, we would need detailed information on the theme of every article. Hand-coding this corpus would be exceedingly time-consuming, not to mention would requiring knowing the thematic structure of the documents before one even begins coding. For the vast majority of corpa, this is not a feasible approach.

Instead, we can use **probabilistic topic models**, statistical algorithms that analyze words in original text documents to uncover the thematic structure of the both the corpus and individual documents themselves. They do not require any hand coding or labeling of the documents prior to analysis - instead, the algorithms emerge from the analysis of the text.

## Latent Dirichlet allocation

LDA assumes that each document in a corpus contains a mix of topics that are found throughout the entire corpus. The topic structure is hidden - we can only observe the documents and words, not the topics themselves. Because the structure is hidden (also known as **latent**), this method seeks to infer the topic structure given the known words and documents.

## Food and animals

Suppose you have the following set of sentences:

1. I ate a banana and spinach smoothie for breakfast.
1. I like to eat broccoli and bananas.
1. Chinchillas and kittens are cute.
1. My sister adopted a kitten yesterday.
1. Look at this cute hamster munching on a piece of broccoli.

Latent Dirichlet allocation is a way of automatically discovering **topics** that these sentences contain. For example, given these sentences and asked for 2 topics, LDA might produce something like

* Sentences 1 and 2: 100% Topic A
* Sentences 3 and 4: 100% Topic B
* Sentence 5: 60% Topic A, 40% Topic B

* Topic A: 30% broccoli, 15% bananas, 10% breakfast, 10% munching, ...
* Topic B: 20% chinchillas, 20% kittens, 20% cute, 15% hamster, ...

You could infer that topic A is a topic about **food**, and topic B is a topic about **cute animals**. But LDA does not explicitly identify topics in this manner. All it can do is tell you the probability that specific words are associated with the topic.

## An LDA document structure

LDA represents documents as mixtures of topics that spit out words with certain probabilities. It assumes that documents are produced in the following fashion: when writing each document, you

* Decide on the number of words `\(N\)` the document will have
* Choose a topic mixture for the document (according to a [Dirichlet probability distribution](https://en.wikipedia.org/wiki/Dirichlet_distribution) over a fixed set of `\(K\)` topics). For example, assuming that we have the two food and cute animal topics above, you might choose the document to consist of 1/3 food and 2/3 cute animals.
* Generate each word in the document by:
    * First picking a topic (according to the distribution that you sampled above; for example, you might pick the food topic with 1/3 probability and the cute animals topic with 2/3 probability).
    * Then using the topic to generate the word itself (according to the topic's multinomial distribution). For instance, the food topic might output the word "broccoli" with 30% probability, "bananas" with 15% probability, and so on.

Assuming this generative model for a collection of documents, LDA then tries to backtrack from the documents to find a set of topics that are likely to have generated the collection.

### Food and animals

How could we have generated the sentences in the previous example? When generating a document `\(D\)`:

* Decide that `\(D\)` will be 1/2 about food and 1/2 about cute animals.
* Pick 5 to be the number of words in `\(D\)`.
* Pick the first word to come from the food topic, which then gives you the word "broccoli".
* Pick the second word to come from the cute animals topic, which gives you "panda".
* Pick the third word to come from the cute animals topic, giving you "adorable".
* Pick the fourth word to come from the food topic, giving you "cherries".
* Pick the fifth word to come from the food topic, giving you "eating".

So the document generated under the LDA model will be "broccoli panda adorable cherries eating" (remember that LDA uses a bag-of-words model).

## LDA with a known topic structure

LDA can be useful if the topic structure of a set of documents is known **a priori**. For instance, suppose you have four books:

* *Great Expectations* by Charles Dickens
* *The War of the Worlds* by H.G. Wells
* *Twenty Thousand Leagues Under the Sea* by Jules Verne
* *Pride and Prejudice* by Jane Austen

A vandal has broken into your home and torn the books into individual chapters, and left them in one large pile. We can use LDA and topic modeling to discover how the chapters relate to distinct topics (i.e. books).

We'll retrieve these four books using the `gutenbergr` package:


```r
titles <- c("Twenty Thousand Leagues under the Sea", "The War of the Worlds",
            "Pride and Prejudice", "Great Expectations")

library(gutenbergr)

books <- gutenberg_works(title %in% titles) %>%
  gutenberg_download(meta_fields = "title", mirror = "ftp://aleph.gutenberg.org/")
```

As pre-processing, we divide these into chapters, use `unnest_tokens()` from `tidytext` to separate them into words, then remove stop words. We are treating every chapter as a separate "document", each with a name like `Great Expectations_1` or `Pride and Prejudice_11`.


```r
library(tidytext)
library(stringr)

by_chapter <- books %>%
  group_by(title) %>%
  mutate(chapter = cumsum(str_detect(text, regex("^chapter ", ignore_case = TRUE)))) %>%
  ungroup() %>%
  filter(chapter > 0)

by_chapter_word <- by_chapter %>%
  unite(title_chapter, title, chapter) %>%
  unnest_tokens(word, text)

word_counts <- by_chapter_word %>%
  anti_join(stop_words) %>%
  count(title_chapter, word, sort = TRUE) %>%
  ungroup()
```

```
## Joining, by = "word"
```

```r
word_counts
```

```
## # A tibble: 104,722 x 3
##    title_chapter            word        n
##    <chr>                    <chr>   <int>
##  1 Great Expectations_57    joe        88
##  2 Great Expectations_7     joe        70
##  3 Great Expectations_17    biddy      63
##  4 Great Expectations_27    joe        58
##  5 Great Expectations_38    estella    58
##  6 Great Expectations_2     joe        56
##  7 Great Expectations_23    pocket     53
##  8 Great Expectations_15    joe        50
##  9 Great Expectations_18    joe        50
## 10 The War of the Worlds_16 brother    50
## # … with 104,712 more rows
```

## Latent Dirichlet allocation with the `topicmodels` package

Right now this data frame is in a tidy form, with one-term-per-document-per-row. However, the `topicmodels` package requires a `DocumentTermMatrix` (from the `tm` package). We can cast a one-token-per-row table into a `DocumentTermMatrix` with `cast_dtm()`:


```r
chapters_dtm <- word_counts %>%
  cast_dtm(title_chapter, word, n)

chapters_dtm
```

```
## <<DocumentTermMatrix (documents: 193, terms: 18215)>>
## Non-/sparse entries: 104722/3410773
## Sparsity           : 97%
## Maximal term length: 19
## Weighting          : term frequency (tf)
```

Now we are ready to use the [`topicmodels`](https://cran.r-project.org/package=topicmodels) package to create a four topic LDA model.


```r
library(topicmodels)
chapters_lda <- LDA(chapters_dtm, k = 4, control = list(seed = 1234))
chapters_lda
```

```
## A LDA_VEM topic model with 4 topics.
```

* In this case we know there are four topics because there are four books; this is the value of knowing the latent topic structure.
* `seed = 1234` sets the starting point for the random iteration process. If we don't set a consistent seed, each time we run the script we may estimate slightly different models.

Now `tidytext` gives us the option of **returning** to a tidy analysis, using the `tidy()` and `augment()` verbs borrowed from the [`broom` package](https://github.com/dgrtwo/broom). In particular, we start with the `tidy()` verb.


```r
library(tidytext)

chapters_lda_td <- tidy(chapters_lda)
chapters_lda_td
```

```
## # A tibble: 72,860 x 3
##    topic term        beta
##    <int> <chr>      <dbl>
##  1     1 joe     1.44e-17
##  2     2 joe     5.96e-61
##  3     3 joe     9.88e-25
##  4     4 joe     1.45e- 2
##  5     1 biddy   5.14e-28
##  6     2 biddy   5.02e-73
##  7     3 biddy   4.31e-48
##  8     4 biddy   4.78e- 3
##  9     1 estella 2.43e- 6
## 10     2 estella 4.32e-68
## # … with 72,850 more rows
```

Notice that this has turned the model into a one-topic-per-term-per-row format. For each combination the model has **beta** ($\beta$), the probability of that term being generated from that topic.

We could use `top_n()` from `dplyr` to find the top 5 terms within each topic:


```r
top_terms <- chapters_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms
```

```
## # A tibble: 20 x 3
##    topic term         beta
##    <int> <chr>       <dbl>
##  1     1 elizabeth 0.0141 
##  2     1 darcy     0.00881
##  3     1 miss      0.00871
##  4     1 bennet    0.00694
##  5     1 jane      0.00649
##  6     2 captain   0.0155 
##  7     2 nautilus  0.0131 
##  8     2 sea       0.00884
##  9     2 nemo      0.00871
## 10     2 ned       0.00803
## 11     3 people    0.00679
## 12     3 martians  0.00646
## 13     3 time      0.00534
## 14     3 black     0.00528
## 15     3 night     0.00449
## 16     4 joe       0.0145 
## 17     4 time      0.00685
## 18     4 pip       0.00683
## 19     4 looked    0.00637
## 20     4 miss      0.00623
```

This model lends itself to a visualization:


```r
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/top_terms_plot-1.png" width="672" />

* These topics are pretty clearly associated with the four books:
    * "nemo", "sea", and "nautilus" belongs to *Twenty Thousand Leagues Under the Sea*
    * "jane", "darcy", and "elizabeth" belongs to *Pride and Prejudice*
    * "pip" and "joe" from *Great Expectations*
    * "martians", "black", and "night" from *The War of the Worlds*
* Also note that `LDA()` does not assign any label to each topic. They are simply topics 1, 2, 3, and 4. We can infer these are associated with each book, **but it is merely our inference.**

## Per-document classification

Each chapter was a "document" in this analysis. Thus, we may want to know which topics are associated with each document. Can we put the chapters back together in the correct books?


```r
chapters_lda_gamma <- tidy(chapters_lda, matrix = "gamma")
chapters_lda_gamma
```

```
## # A tibble: 772 x 3
##    document                 topic     gamma
##    <chr>                    <int>     <dbl>
##  1 Great Expectations_57        1 0.0000134
##  2 Great Expectations_7         1 0.0000146
##  3 Great Expectations_17        1 0.0000210
##  4 Great Expectations_27        1 0.0000190
##  5 Great Expectations_38        1 0.355    
##  6 Great Expectations_2         1 0.0000171
##  7 Great Expectations_23        1 0.547    
##  8 Great Expectations_15        1 0.0124   
##  9 Great Expectations_18        1 0.0000126
## 10 The War of the Worlds_16     1 0.0000107
## # … with 762 more rows
```

Setting `matrix = "gamma"` returns a tidied version with one-document-per-topic-per-row. Now that we have these document classifiations, we can see how well our unsupervised learning did at distinguishing the four books. First we re-separate the document name into title and chapter:


```r
chapters_lda_gamma <- chapters_lda_gamma %>%
  separate(document, c("title", "chapter"), sep = "_", convert = TRUE)
chapters_lda_gamma
```

```
## # A tibble: 772 x 4
##    title                 chapter topic     gamma
##    <chr>                   <int> <int>     <dbl>
##  1 Great Expectations         57     1 0.0000134
##  2 Great Expectations          7     1 0.0000146
##  3 Great Expectations         17     1 0.0000210
##  4 Great Expectations         27     1 0.0000190
##  5 Great Expectations         38     1 0.355    
##  6 Great Expectations          2     1 0.0000171
##  7 Great Expectations         23     1 0.547    
##  8 Great Expectations         15     1 0.0124   
##  9 Great Expectations         18     1 0.0000126
## 10 The War of the Worlds      16     1 0.0000107
## # … with 762 more rows
```

Then we examine what fraction of chapters we got right for each:


```r
# reorder titles in order of topic 1, topic 2, etc before plotting
chapters_lda_gamma %>%
  mutate(title = reorder(title, gamma * topic)) %>%
  ggplot(aes(factor(topic), gamma)) +
  geom_boxplot() +
  facet_wrap(~ title)
```

<img src="/notes/topic-modeling_files/figure-html/chapters_lda_gamma_plot-1.png" width="768" />

We notice that almost all of the chapters from *Pride and Prejudice*, *War of the Worlds*, and *Twenty Thousand Leagues Under the Sea* were uniquely identified as a single topic each.


```r
chapter_classifications <- chapters_lda_gamma %>%
  group_by(title, chapter) %>%
  top_n(1, gamma) %>%
  ungroup() %>%
  arrange(gamma)

chapter_classifications
```

```
## # A tibble: 193 x 4
##    title              chapter topic gamma
##    <chr>                <int> <int> <dbl>
##  1 Great Expectations      54     3 0.481
##  2 Great Expectations      22     4 0.536
##  3 Great Expectations      23     1 0.547
##  4 Great Expectations      31     4 0.547
##  5 Great Expectations      33     4 0.569
##  6 Great Expectations      47     4 0.580
##  7 Great Expectations      56     4 0.606
##  8 Great Expectations      38     4 0.645
##  9 Great Expectations       3     4 0.660
## 10 Great Expectations      11     4 0.668
## # … with 183 more rows
```

We can determine this by finding the consensus book for each, which we note is correct based on our earlier visualization:


```r
book_topics <- chapter_classifications %>%
  count(title, topic) %>%
  group_by(title) %>%
  top_n(1, n) %>%
  ungroup() %>%
  transmute(consensus = title, topic)

book_topics
```

```
## # A tibble: 4 x 2
##   consensus                             topic
##   <chr>                                 <int>
## 1 Great Expectations                        4
## 2 Pride and Prejudice                       1
## 3 The War of the Worlds                     3
## 4 Twenty Thousand Leagues under the Sea     2
```

Then we see which chapters were misidentified:


```r
chapter_classifications %>%
  inner_join(book_topics, by = "topic") %>%
  count(title, consensus) %>%
  knitr::kable()
```



|title                                 |consensus                             |  n|
|:-------------------------------------|:-------------------------------------|--:|
|Great Expectations                    |Great Expectations                    | 57|
|Great Expectations                    |Pride and Prejudice                   |  1|
|Great Expectations                    |The War of the Worlds                 |  1|
|Pride and Prejudice                   |Pride and Prejudice                   | 61|
|The War of the Worlds                 |The War of the Worlds                 | 27|
|Twenty Thousand Leagues under the Sea |Twenty Thousand Leagues under the Sea | 46|

We see that only a few chapters from *Great Expectations* were misclassified.

## By word assignments: `augment`

One important step in the topic modeling expectation-maximization algorithm is assigning each word in each document to a topic. The more words in a document are assigned to that topic, generally, the more weight (`gamma`) will go on that document-topic classification.

We may want to take the original document-word pairs and find which words in each document were assigned to which topic. This is the job of the `augment()` verb.


```r
assignments <- augment(chapters_lda, data = chapters_dtm)
```

We can combine this with the consensus book titles to find which words were incorrectly classified.


```r
assignments <- assignments %>%
  separate(document, c("title", "chapter"), sep = "_", convert = TRUE) %>%
  inner_join(book_topics, by = c(".topic" = "topic"))

assignments
```

```
## # A tibble: 104,722 x 6
##    title              chapter term  count .topic consensus         
##    <chr>                <int> <chr> <dbl>  <dbl> <chr>             
##  1 Great Expectations      57 joe      88      4 Great Expectations
##  2 Great Expectations       7 joe      70      4 Great Expectations
##  3 Great Expectations      17 joe       5      4 Great Expectations
##  4 Great Expectations      27 joe      58      4 Great Expectations
##  5 Great Expectations       2 joe      56      4 Great Expectations
##  6 Great Expectations      23 joe       1      4 Great Expectations
##  7 Great Expectations      15 joe      50      4 Great Expectations
##  8 Great Expectations      18 joe      50      4 Great Expectations
##  9 Great Expectations       9 joe      44      4 Great Expectations
## 10 Great Expectations      13 joe      40      4 Great Expectations
## # … with 104,712 more rows
```

We can, for example, create a "confusion matrix" using `dplyr::count()` and `tidyr::spread`:


```r
assignments %>%
  count(title, consensus, wt = count) %>%
  spread(consensus, n, fill = 0) %>%
  knitr::kable()
```



|title                                 | Great Expectations| Pride and Prejudice| The War of the Worlds| Twenty Thousand Leagues under the Sea|
|:-------------------------------------|------------------:|-------------------:|---------------------:|-------------------------------------:|
|Great Expectations                    |              49656|                3908|                  1923|                                    81|
|Pride and Prejudice                   |                  1|               37231|                     6|                                     4|
|The War of the Worlds                 |                  0|                   0|                 22561|                                     7|
|Twenty Thousand Leagues under the Sea |                  0|                   5|                     0|                                 39629|

We notice that almost all the words for *Pride and Prejudice*, *Twenty Thousand Leagues Under the Sea*, and *War of the Worlds* were correctly assigned, while *Great Expectations* had a fair amount of misassignment.

What were the most commonly mistaken words?


```r
wrong_words <- assignments %>%
  filter(title != consensus)

wrong_words
```

```
## # A tibble: 4,617 x 6
##    title                 chapter term   count .topic consensus             
##    <chr>                   <int> <chr>  <dbl>  <dbl> <chr>                 
##  1 Great Expectations         38 broth…     2      1 Pride and Prejudice   
##  2 Great Expectations         22 broth…     4      1 Pride and Prejudice   
##  3 Great Expectations         23 miss       2      1 Pride and Prejudice   
##  4 Great Expectations         22 miss      23      1 Pride and Prejudice   
##  5 Twenty Thousand Leag…       8 miss       1      1 Pride and Prejudice   
##  6 Great Expectations         31 miss       1      1 Pride and Prejudice   
##  7 Great Expectations          5 serge…    37      1 Pride and Prejudice   
##  8 Great Expectations         46 capta…     1      2 Twenty Thousand Leagu…
##  9 Great Expectations         32 capta…     1      2 Twenty Thousand Leagu…
## 10 The War of the Worlds      17 capta…     5      2 Twenty Thousand Leagu…
## # … with 4,607 more rows
```

```r
wrong_words %>%
  count(title, consensus, term, wt = count) %>%
  ungroup() %>%
  arrange(desc(n))
```

```
## # A tibble: 3,551 x 4
##    title              consensus             term         n
##    <chr>              <chr>                 <chr>    <dbl>
##  1 Great Expectations Pride and Prejudice   love        44
##  2 Great Expectations Pride and Prejudice   sergeant    37
##  3 Great Expectations Pride and Prejudice   lady        32
##  4 Great Expectations Pride and Prejudice   miss        26
##  5 Great Expectations The War of the Worlds boat        25
##  6 Great Expectations The War of the Worlds tide        20
##  7 Great Expectations The War of the Worlds water       20
##  8 Great Expectations Pride and Prejudice   father      19
##  9 Great Expectations Pride and Prejudice   baby        18
## 10 Great Expectations Pride and Prejudice   flopson     18
## # … with 3,541 more rows
```

Notice the word "flopson" here; these wrong words do not necessarily appear in the novels they were misassigned to. Indeed, we can confirm "flopson" appears only in *Great Expectations*:


```r
word_counts %>%
  filter(word == "flopson")
```

```
## # A tibble: 3 x 3
##   title_chapter         word        n
##   <chr>                 <chr>   <int>
## 1 Great Expectations_22 flopson    10
## 2 Great Expectations_23 flopson     7
## 3 Great Expectations_33 flopson     1
```

The algorithm is stochastic and iterative, and it can accidentally land on a topic that spans multiple books.

## LDA with an unknown topic structure

Frequently when using LDA, you don't actually know the underlying topic structure of the documents. **Generally that is why you are using LDA to analyze the text in the first place**. LDA is still useful in these instances, but we have to perform additional tests and analysis to confirm that the topic structure uncovered by LDA is a good structure.

## Associated Press articles

The `topicmodels` package includes a document-term matrix of a sample of articles published by the Associated Press in 1992. Let's load them into R and convert them to a tidy format.


```r
data("AssociatedPress", package = "topicmodels")

ap_td <- tidy(AssociatedPress)
ap_td
```

```
## # A tibble: 302,031 x 3
##    document term       count
##       <int> <chr>      <dbl>
##  1        1 adding         1
##  2        1 adult          2
##  3        1 ago            1
##  4        1 alcohol        1
##  5        1 allegedly      1
##  6        1 allen          1
##  7        1 apparently     2
##  8        1 appeared       1
##  9        1 arrested       1
## 10        1 assault        1
## # … with 302,021 more rows
```

`AssociatedPress` is originally in a document-term matrix, exactly what we need for topic modeling. Why tidy it first? Because the original document-term matrix contains stop words - we want to remove them before modeling the data. Let's remove the stop words, then cast the data back into a document-term matrix.


```r
ap_dtm <- ap_td %>%
  anti_join(stop_words, by = c(term = "word")) %>%
  cast_dtm(document, term, count)
ap_dtm
```

```
## <<DocumentTermMatrix (documents: 2246, terms: 10134)>>
## Non-/sparse entries: 259208/22501756
## Sparsity           : 99%
## Maximal term length: 18
## Weighting          : term frequency (tf)
```

## Selecting `\(k\)`

Remember that for LDA, you need to specify in advance the number of topics in the underlying topic structure.

### `\(k=4\)`

Let's estimate an LDA model for the Associated Press articles, setting `\(k=4\)`.


```r
ap_lda <- LDA(ap_dtm, k = 4, control = list(seed = 1234))
ap_lda
```

```
## A LDA_VEM topic model with 4 topics.
```

What do the top terms for each of these topics look like?


```r
ap_lda_td <- tidy(ap_lda)

top_terms <- ap_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms
```

```
## # A tibble: 20 x 3
##    topic term          beta
##    <int> <chr>        <dbl>
##  1     1 police     0.0102 
##  2     1 people     0.00856
##  3     1 officials  0.00478
##  4     1 city       0.00399
##  5     1 killed     0.00373
##  6     2 soviet     0.0113 
##  7     2 government 0.00982
##  8     2 president  0.00880
##  9     2 united     0.00775
## 10     2 party      0.00598
## 11     3 percent    0.0191 
## 12     3 million    0.0127 
## 13     3 billion    0.00894
## 14     3 market     0.00649
## 15     3 company    0.00601
## 16     4 court      0.00615
## 17     4 bush       0.00482
## 18     4 people     0.00431
## 19     4 dukakis    0.00419
## 20     4 president  0.00417
```

```r
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 2) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/ap_4_topn-1.png" width="672" />

Fair enough. The four topics generally look to describe:

1. American-Soviet relations
1. Crime and education
1. American (domestic) government
1. [It's the economy, stupid](https://en.wikipedia.org/wiki/It%27s_the_economy,_stupid)

### `\(k=12\)`

What happens if we set `\(k=12\)`? How do our results change?


```r
ap_lda <- LDA(ap_dtm, k = 12, control = list(seed = 1234))
ap_lda
```

```
## A LDA_VEM topic model with 12 topics.
```


```r
ap_lda_td <- tidy(ap_lda)

top_terms <- ap_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms
```

```
## # A tibble: 60 x 3
##    topic term          beta
##    <int> <chr>        <dbl>
##  1     1 people     0.00497
##  2     1 dont       0.00396
##  3     1 air        0.00391
##  4     1 time       0.00377
##  5     1 york       0.00367
##  6     2 soviet     0.0175 
##  7     2 aid        0.0108 
##  8     2 million    0.00640
##  9     2 government 0.00622
## 10     2 corn       0.00572
## # … with 50 more rows
```

```r
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 3) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/ap_12_topn-1.png" width="672" />

Hmm. Well, these topics appear to be more specific, yet not as easily decodeable.

1. Iraq War (I)
1. Bush's reelection campaign
1. Federal courts
1. Apartheid and South Africa
1. Crime
1. Economy
1. ???
1. Soviet Union
1. Environment
1. Stock market
1. Wildfires?
1. Bush-Congress relations (maybe domestic policy?)

Alas, this is the problem with LDA. Several different values for `\(k\)` may be plausible, but by increasing `\(k\)` we sacrifice clarity. Is there any statistical measure which will help us determine the optimal number of topics?

## Perplexity

Well, sort of. Some aspects of LDA are driven by gut-thinking (or perhaps [truthiness](http://www.cc.com/video-clips/63ite2/the-colbert-report-the-word---truthiness)). However we can have some help. [**Perplexity**](https://en.wikipedia.org/wiki/Perplexity) is a statistical measure of how well a probability model predicts a sample. As applied to LDA, for a given value of `\(k\)`, you estimate the LDA model. Then given the theoretical word distributions represented by the topics, compare that to the actual topic mixtures, or distribution of words in your documents.

`topicmodels` includes the function `perplexity()` which calculates this value for a given model.


```r
perplexity(ap_lda)
```

```
## [1] 2277.876
```

However, the statistic is somewhat meaningless on its own. The benefit of this statistic comes in comparing perplexity across different models with varying `\(k\)`s. The model with the lowest perplexity is generally considered the "best".

Let's estimate a series of LDA models on the Associated Press dataset. Here I make use of `purrr` and the `map()` functions to iteratively generate a series of LDA models for the AP corpus, using a different number of topics in each model.^[Note that LDA can quickly become CPU and memory intensive as you scale up the size of the corpus and number of topics. Replicating this analysis on your computer may take a long time (i.e. minutes or even hours). It is very possible you may not be able to replicate this analysis on your machine. If so, you need to reduce the amount of text, the number of models, or offload the analysis to the [Research Computing Center](https://rcc.uchicago.edu/).]


```r
n_topics <- c(2, 4, 10, 20, 50, 100)
ap_lda_compare <- n_topics %>%
  map(LDA, x = ap_dtm, control = list(seed = 1234))
```


```r
n_topics <- c(2, 4, 10, 20, 50, 100)

# takes forever to estimate this model - store results and use if available
if(file.exists(here("static", "extras", "ap_lda_compare.Rdata"))){
  load(file = here("static", "extras", "ap_lda_compare.Rdata"))
} else{
  ap_lda_compare <- n_topics %>%
    map(LDA, x = ap_dtm, control = list(seed = 1234))
  save(ap_lda_compare, file = here("static", "extras", "ap_lda_compare.Rdata"))
}
```


```r
tibble(k = n_topics,
       perplex = map_dbl(ap_lda_compare, perplexity)) %>%
  ggplot(aes(k, perplex)) +
  geom_point() +
  geom_line() +
  labs(title = "Evaluating LDA topic models",
       subtitle = "Optimal number of topics (smaller is better)",
       x = "Number of topics",
       y = "Perplexity")
```

<img src="/notes/topic-modeling_files/figure-html/ap_lda_compare_viz-1.png" width="672" />

It looks like the 100-topic model has the lowest perplexity score. What kind of topics does this generate? Let's look just at the first 12 topics produced by the model (`ggplot2` has difficulty rendering a graph for 100 separate facets):


```r
ap_lda_td <- tidy(ap_lda_compare[[6]])

top_terms <- ap_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms
```

```
## # A tibble: 500 x 3
##    topic term          beta
##    <int> <chr>        <dbl>
##  1     1 president  0.00802
##  2     1 oil        0.00562
##  3     1 people     0.00553
##  4     1 embassy    0.00526
##  5     1 television 0.00518
##  6     2 convention 0.0163 
##  7     2 york       0.0102 
##  8     2 dukakis    0.00849
##  9     2 national   0.00693
## 10     2 jackson    0.00647
## # … with 490 more rows
```

```r
top_terms %>%
  filter(topic <= 12) %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 3) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/ap_100_topn-1.png" width="672" />

We are getting even more specific topics now. The question becomes how would we present these results and use them in an informative way? Not to mention perplexity was still dropping at `\(k=100\)` - would `\(k=200\)` generate an even lower perplexity score?^[I tried to estimate this model, but my computer was taking too long.]

Again, this is where your intuition and domain knowledge as a researcher is important. You can use perplexity as one data point in your decision process, but a lot of the time it helps to simply look at the topics themselves and the highest probability words associated with each one to determine if the structure makes sense. If you have a known topic structure you can compare it to (such as the books example above), this can also be useful.

## Interactive exploration of LDA model

The [`LDAvis`](https://github.com/cpsievert/LDAvis) allows you to interactively visualize an LDA topic model. The major graphical elements include:

1. Default topic circles - `\(K\)` circles, one for each topic, whose areas are set to be proportional to the proportions of the topics across the `\(N\)` total tokens in the corpus.
1. Red bars - represent the estimated number of times a given term was generated by a given topic.
1. Blue bars - represent the overall frequency of each term in the corpus
1. Topic-term circlues - `\(K \times W\)` circles whose areas are set to be proportional to the frequencies with which a given term is estimated to have been generated by the topics.

To install the necessary packages, run the code below:

```r
install.packages("LDAvis")
devtools::install_github("cpsievert/LDAvisData")
```

### Example: This is Jeopardy!

Here we draw an example directly from the `LDAvis` package to visualize a `\(K = 100\)` topic LDA model of 200,000+ Jeopardy! "answers" and categories. The model is pre-generated and relevant components from the `LDA()` function are already stored in a list for us. In order to visualize the model, we need to convert this to a JSON file using `createJSON()` and then pass this object to `serVis()`.


```r
library(LDAvis)
library(LDAvisData)

# retrieve LDA model results
data(Jeopardy, package = "LDAvisData")
str(Jeopardy)
```

```
## List of 5
##  $ phi           : num [1:100, 1:4393] 9.78e-04 3.51e-06 1.31e-02 4.14e-06 4.31e-06 ...
##   ..- attr(*, "dimnames")=List of 2
##   .. ..$ : chr [1:100] "1" "2" "3" "4" ...
##   .. ..$ : chr [1:4393] "one" "name" "first" "city" ...
##  $ theta         : num [1:19979, 1:100] 0.001111 0.001 0.00125 0.001111 0.000909 ...
##   ..- attr(*, "dimnames")=List of 2
##   .. ..$ : NULL
##   .. ..$ : chr [1:100] "1" "2" "3" "4" ...
##  $ doc.length    : int [1:19979] 8 9 7 8 10 7 5 9 7 13 ...
##  $ vocab         : chr [1:4393] "one" "name" "first" "city" ...
##  $ term.frequency: int [1:4393] 1267 1154 1103 730 715 714 667 659 582 564 ...
```

```r
# convert to JSON file
json <- createJSON(phi = Jeopardy$phi,
                   theta = Jeopardy$theta,
                   doc.length = Jeopardy$doc.length,
                   vocab = Jeopardy$vocab,
                   term.frequency = Jeopardy$term.frequency)
```


```r
# view the visualization
serVis(json)
```

* Check out topic 22 (bodies of water) and 95 ("rhyme time")

### Importing our own LDA model

To convert the output of `topicmodels::LDA()` to view with `LDAvis`, use [this function](http://datacm.blogspot.com/2017/03/lda-visualization-with-r-topicmodels.html):


```r
topicmodels_json_ldavis <- function(fitted, doc_term){
  require(LDAvis)
  require(slam)
  
  # Find required quantities
  phi <- as.matrix(posterior(fitted)$terms)
  theta <- as.matrix(posterior(fitted)$topics)
  vocab <- colnames(phi)
  term_freq <- slam::col_sums(doc_term)
  
  # Convert to json
  json_lda <- LDAvis::createJSON(phi = phi, theta = theta,
                                 vocab = vocab,
                                 doc.length = as.vector(table(doc_term$i)),
                                 term.frequency = term_freq)
  
  return(json_lda)
}
```

Let's test it using the `\(k = 10\)` LDA topic model for the AP dataset.


```r
ap_10_json <- topicmodels_json_ldavis(fitted = ap_lda_compare[[3]],
                                       doc_term = ap_dtm)
```

```
## Loading required package: slam
```


```r
serVis(ap_10_json)
```

## Acknowledgments

* This page is derived in part from ["Tidy Text Mining with R"](http://tidytextmining.com/) and licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 United States License](https://creativecommons.org/licenses/by-nc-sa/3.0/us/).
* This page is derived in part from ["What is a good explanation of Latent Dirichlet Allocation?"](https://www.quora.com/What-is-a-good-explanation-of-Latent-Dirichlet-Allocation)

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
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.3   2018-12-14 [2] CRAN (R 3.5.0)
##  blogdown      0.11    2019-03-11 [1] CRAN (R 3.5.2)
##  bookdown      0.9     2018-12-21 [1] CRAN (R 3.5.0)
##  broom         0.5.1   2018-12-05 [2] CRAN (R 3.5.0)
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
##  gutenbergr  * 0.1.4   2018-01-26 [2] CRAN (R 3.5.0)
##  haven         2.1.0   2019-02-19 [2] CRAN (R 3.5.2)
##  here        * 0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  janeaustenr   0.1.5   2017-06-10 [2] CRAN (R 3.5.0)
##  jsonlite      1.6     2018-12-07 [2] CRAN (R 3.5.0)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  lattice       0.20-38 2018-11-04 [2] CRAN (R 3.5.3)
##  lazyeval      0.2.2   2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate     1.7.4   2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  Matrix        1.2-15  2018-11-01 [2] CRAN (R 3.5.3)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  modelr        0.1.4   2019-02-18 [2] CRAN (R 3.5.2)
##  modeltools    0.2-22  2018-07-16 [2] CRAN (R 3.5.0)
##  munsell       0.5.0   2018-06-12 [2] CRAN (R 3.5.0)
##  nlme          3.1-137 2018-04-07 [2] CRAN (R 3.5.3)
##  NLP           0.2-0   2018-10-18 [2] CRAN (R 3.5.0)
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
##  slam          0.1-45  2019-02-26 [1] CRAN (R 3.5.2)
##  SnowballC     0.6.0   2019-01-15 [2] CRAN (R 3.5.2)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.0.1   2018-10-13 [2] CRAN (R 3.5.0)
##  tibble      * 2.1.1   2019-03-16 [2] CRAN (R 3.5.2)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.5.0)
##  tidytext    * 0.2.0   2018-10-17 [1] CRAN (R 3.5.0)
##  tidyverse   * 1.2.1   2017-11-14 [2] CRAN (R 3.5.0)
##  tm            0.7-6   2018-12-21 [2] CRAN (R 3.5.0)
##  tokenizers    0.2.1   2018-03-29 [2] CRAN (R 3.5.0)
##  topicmodels * 0.2-8   2018-12-21 [2] CRAN (R 3.5.0)
##  usethis       1.4.0   2018-08-14 [1] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
