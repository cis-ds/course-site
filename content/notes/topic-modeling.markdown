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
library(tidytext)
library(topicmodels)
library(here)
library(rjson)
library(tm)
library(tictoc)

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

LDA can be useful if the topic structure of a set of documents is known **a priori**. For instance, consider the `USCongress` dataset of legislation introduced in the U.S. Congress from the `RTextTools` package.


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
) %>%
  mutate(label = factor(major, levels = major, labels = label))

congress <- as_tibble(USCongress) %>%
  mutate(text = as.character(text)) %>%
  left_join(major_topics)
```

```
## Joining, by = "major"
```

```r
glimpse(congress)
```

```
## Observations: 4,449
## Variables: 7
## $ ID       <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, …
## $ cong     <dbl> 107, 107, 107, 107, 107, 107, 107, 107, 107, 107, 107, …
## $ billnum  <dbl> 4499, 4500, 4501, 4502, 4503, 4504, 4505, 4506, 4507, 4…
## $ h_or_sen <chr> "HR", "HR", "HR", "HR", "HR", "HR", "HR", "HR", "HR", "…
## $ major    <dbl> 18, 18, 18, 18, 5, 21, 15, 18, 18, 18, 18, 16, 18, 12, …
## $ text     <chr> "To suspend temporarily the duty on Fast Magenta 2 Stag…
## $ label    <fct> "Foreign trade", "Foreign trade", "Foreign trade", "For…
```

[Previously](/notes/supervised-text-classification/), we assumed the documents were structured based on their policy content under [the structure](https://www.comparativeagendas.net/pages/master-codebook):


```r
major_topics %>%
  knitr::kable(col.names = c("Topic code", "Policy topic"))
```



| Topic code|Policy topic                                   |
|----------:|:----------------------------------------------|
|          1|Macroeconomics                                 |
|          2|Civil rights, minority issues, civil liberties |
|          3|Health                                         |
|          4|Agriculture                                    |
|          5|Labor and employment                           |
|          6|Education                                      |
|          7|Environment                                    |
|          8|Energy                                         |
|          9|Immigration                                    |
|         10|Transportation                                 |
|         12|Law, crime, family issues                      |
|         13|Social welfare                                 |
|         14|Community development and housing issues       |
|         15|Banking, finance, and domestic commerce        |
|         16|Defense                                        |
|         17|Space, technology, and communications          |
|         18|Foreign trade                                  |
|         19|International affairs and foreign aid          |
|         20|Government operations                          |
|         21|Public lands and water management              |
|         99|Other, miscellaneous                           |

We can use LDA and topic modeling to discover whether the documents map onto this topic structure without any assumptions about the structure. That is, using just the text **what is the revealed topic structure**?

As pre-processing, we use `unnest_tokens()` from `tidytext` to separate each bill title into words, filter out tokens which are purely numbers, remove stop words, and stem each token to its root form.


```r
congress_tokens <- congress %>%
  unnest_tokens(output = word, input = text) %>%
  # remove numbers
  filter(!str_detect(word, "^[0-9]*$")) %>%
  # remove stop words
  anti_join(stop_words) %>%
  # stem the words
  mutate(word = SnowballC::wordStem(word))
```

```
## Joining, by = "word"
```

```r
congress_tokens
```

```
## # A tibble: 58,820 x 7
##       ID  cong billnum h_or_sen major label         word       
##    <dbl> <dbl>   <dbl> <chr>    <dbl> <fct>         <chr>      
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

## Latent Dirichlet allocation with the `topicmodels` package

Right now this data frame is in a tidy form, with one-term-per-document-per-row. However, the `topicmodels` package requires a `DocumentTermMatrix` (from the `tm` package). We can cast a one-token-per-row table into a `DocumentTermMatrix` with `cast_dtm()`:^[In the process, we also remove tokens which are relatively uninformative based on their [tf-idf scores](https://www.tidytextmining.com/tfidf.html). Otherwise our LDA model will take forever to estimate due to the vast number of unique tokens.]


```r
# remove terms with low tf-idf for future LDA model
congress_tokens_lite <- congress_tokens %>%
  count(major, word) %>%
  bind_tf_idf(term = word, document = major, n = n) %>%
  group_by(major) %>%
  top_n(40, wt = tf_idf) %>%
  ungroup %>%
  count(word) %>%
  select(-n) %>%
  left_join(congress_tokens)
```

```
## Joining, by = "word"
```

```r
congress_dtm <- congress_tokens_lite %>%
  # get count of each token in each document
  count(ID, word) %>%
  # create a document-term matrix with all features and tf weighting
  cast_dtm(document = ID, term = word, value = n)
congress_dtm
```

```
## <<DocumentTermMatrix (documents: 4319, terms: 787)>>
## Non-/sparse entries: 18149/3380904
## Sparsity           : 99%
## Maximal term length: 22
## Weighting          : term frequency (tf)
```

Now we are ready to use the [`topicmodels`](https://cran.r-project.org/package=topicmodels) package to create a twenty topic LDA model.


```r
library(topicmodels)
congress_lda <- LDA(congress_dtm, k = 20, control = list(seed = 123))
congress_lda
```

```
## A LDA_VEM topic model with 20 topics.
```

* In this case we know there are approximately twenty topics because there are twenty major policy codes; this is the value of knowing (or assuming) the latent topic structure.
* `seed = 123` sets the starting point for the random iteration process. If we don't set a consistent seed, each time we run the script we may estimate slightly different models.

Now `tidytext` gives us the option of **returning** to a tidy analysis, using the `tidy()` and `augment()` verbs borrowed from the [`broom` package](https://github.com/dgrtwo/broom). In particular, we start with the `tidy()` verb.


```r
congress_lda_td <- tidy(congress_lda)
congress_lda_td
```

```
## # A tibble: 15,740 x 3
##    topic term       beta
##    <int> <chr>     <dbl>
##  1     1 duti  3.11e-122
##  2     2 duti  9.22e- 92
##  3     3 duti  4.90e-114
##  4     4 duti  3.09e- 95
##  5     5 duti  5.42e-123
##  6     6 duti  1.27e-148
##  7     7 duti  3.74e- 78
##  8     8 duti  6.64e-105
##  9     9 duti  2.86e-  1
## 10    10 duti  1.08e- 83
## # … with 15,730 more rows
```

Notice that this has turned the model into a one-topic-per-term-per-row format. For each combination the model has **beta** ($\beta$), the probability of that term being generated from that topic.

We could use `top_n()` from `dplyr` to find the top 5 terms within each topic:


```r
top_terms <- congress_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms
```

```
## # A tibble: 102 x 3
##    topic term         beta
##    <int> <chr>       <dbl>
##  1     1 secretari  0.337 
##  2     1 interior   0.116 
##  3     1 transport  0.0961
##  4     1 heritag    0.0432
##  5     1 armi       0.0389
##  6     2 educ       0.276 
##  7     2 school     0.113 
##  8     2 secondari  0.0712
##  9     2 forc       0.0658
## 10     2 elementari 0.0647
## # … with 92 more rows
```

This model lends itself to a visualization:


```r
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 4) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/top-terms-plot-1.png" width="672" />

* Some of these topics are pretty clearly associated with some of the policy topics:
    * "educ", "school", "secondari", "forc", "elementari" seem to be **Education**
    * "health", "care", "insur", "medic", "coverag" seem to be **Health**
    * "water", "park", "indian", "river", "tribe", seem to be **Public lands and water management**
* Note that `LDA()` does not assign any label to each topic. They are simply topics 1, 2, 3, 4, etc. We can infer these are associated with each book, **but it is merely our inference.**
* Other topics are less clear. For instance, topic 16 could also be a health care topic. And some of the policy topics are not visible at all. I don't see a clear **Space, technology, and communications** anywhere in the results.

## Per-document classification

Each bill was a "document" in this analysis. Thus, we may want to know which topics are associated with each bill. Using the topic distributions, can we classify each bill into its hand-coded policy topic?


```r
congress_gamma <- tidy(congress_lda, matrix = "gamma")
congress_gamma
```

```
## # A tibble: 86,380 x 3
##    document topic  gamma
##    <chr>    <int>  <dbl>
##  1 1            1 0.0172
##  2 2            1 0.0152
##  3 3            1 0.0233
##  4 4            1 0.0284
##  5 5            1 0.0198
##  6 6            1 0.0773
##  7 7            1 0.0198
##  8 8            1 0.0233
##  9 9            1 0.0233
## 10 10           1 0.0198
## # … with 86,370 more rows
```

Setting `matrix = "gamma"` returns a tidied version with one-document-per-topic-per-row. Now that we have these document classifiations, we can see how well our unsupervised learning did at distinguishing the policy topics.


```r
congress_tokens_lite %>%
  mutate(document = as.character(row_number())) %>%
  # join with the gamma values
  left_join(congress_gamma) %>%
  # remove missing values
  na.omit() %>%
  group_by(topic, major, label) %>%
  summarize(gamma = median(gamma)) %>%
  # plot the topic distributions for each policy topic
  ggplot(aes(factor(topic), gamma)) +
  geom_segment(aes(x = factor(topic), xend = factor(topic), y = 0, yend = gamma), color = "grey50") +
  geom_point() +
  facet_wrap(~ label) +
  labs(x = "LDA topic",
       y = expression(gamma))
```

```
## Joining, by = "document"
```

<img src="/notes/topic-modeling_files/figure-html/congress-model-compare-1.png" width="672" />

The LDA model does not perform well in predicting the policy topic of each bill. If it performed well, we would see one of the LDA topics with a high median value for `\(\gamma\)`. That is, for bills actually in the policy topic one of the LDA topics assigns a high probability value. Most all of these distributions are flat, indicating there are few LDA topics predominantly associated with policy topic.

## LDA with an unknown topic structure

Frequently when using LDA, you don't actually know the underlying topic structure of the documents. **Generally that is why you are using LDA to analyze the text in the first place**. LDA is still useful in these instances, but we have to perform additional tests and analysis to confirm that the topic structure uncovered by LDA is a good structure.

## `r/jokes`

<blockquote class="reddit-card" data-card-created="1552319072"><a href="https://www.reddit.com/r/Jokes/comments/a593r0/twenty_years_from_now_kids_are_gonna_think_baby/">Twenty years from now, kids are gonna think "Baby it's cold outside" is really weird, and we're gonna have to explain that it has to be understood as a product of its time.</a> from <a href="http://www.reddit.com/r/Jokes">r/Jokes</a></blockquote>
<script async src="//embed.redditmedia.com/widgets/platform.js" charset="UTF-8"></script>

[`r/jokes`](https://www.reddit.com/r/Jokes/) is a subreddit for text-based jokes. Jokes can be up or down-voted depending on their popularity. [`joke-dataset`](https://github.com/taivop/joke-dataset/) contains a dataset of all joke submissions through February 2, 2017. We can obtain the JSON file storing these jokes and convert them into a document-term matrix:


```r
# obtain r/jokes and extract values from the JSON file
jokes_json <- fromJSON(file = "https://github.com/taivop/joke-dataset/raw/master/reddit_jokes.json")

jokes <- jokes_json %>%
  {
    tibble(
      id = map_chr(., "id"),
      title = map_chr(., "title"),
      body = map_chr(., "body"),
      score = map_dbl(., "score")
    )
  }
glimpse(jokes)
```

```
## Observations: 194,553
## Variables: 4
## $ id    <chr> "5tz52q", "5tz4dd", "5tz319", "5tz2wj", "5tz1pc", "5tz1o1"…
## $ title <chr> "I hate how you cant even say black paint anymore", "What'…
## $ body  <chr> "Now I have to say \"Leroy can you please paint the fence?…
## $ score <dbl> 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 15, 0, 0, 3, 1, 0, 3, 2, 2, …
```


```r
# convert into a document-term matrix
set.seed(123)
n_grams <- 1:5                          # extract n-grams for n=1,2,3,4,5
jokes_lite <- sample_n(jokes, 50000)    # randomly sample only 50,000 jokes

jokes_tokens <- map_df(n_grams, ~ jokes_lite %>%
                         # combine title and body
                         unite(col = joke, title, body, sep = " ") %>%
                         # tokenize
                         unnest_tokens(output = word,
                                       input = joke,
                                       token = "ngrams",
                                       n = .x) %>%
                         mutate(ngram = .x,
                                token_id = row_number()) %>%
                         # remove tokens that are missing values
                         filter(!is.na(word)))
jokes_tokens
```

```
## # A tibble: 11,121,984 x 5
##    id     score word       ngram token_id
##    <chr>  <dbl> <chr>      <int>    <int>
##  1 1a7xnd    44 what's         1        1
##  2 1a7xnd    44 the            1        2
##  3 1a7xnd    44 difference     1        3
##  4 1a7xnd    44 between        1        4
##  5 1a7xnd    44 a              1        5
##  6 1a7xnd    44 hippie         1        6
##  7 1a7xnd    44 chick          1        7
##  8 1a7xnd    44 and            1        8
##  9 1a7xnd    44 a              1        9
## 10 1a7xnd    44 hockey         1       10
## # … with 11,121,974 more rows
```

```r
# remove stop words or n-grams beginning or ending with stop word
jokes_stop_words <- jokes_tokens %>%
  # separate ngrams into separate columns
  separate(col = word,
           into = c("word1", "word2", "word3", "word4", "word5"),
           sep = " ") %>%
  # find last word
  mutate(last = if_else(ngram == 5, word5,
                        if_else(ngram == 4, word4,
                                if_else(ngram == 3, word3,
                                        if_else(ngram == 2, word2, word1))))) %>%
  # remove tokens where the first or last word is a stop word
  filter(word1 %in% stop_words$word |
           last %in% stop_words$word) %>%
  select(ngram, token_id)
```

```
## Warning: Expected 5 pieces. Missing pieces filled with `NA` in 8997350
## rows [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
## 20, ...].
```

```r
# convert to dtm
jokes_dtm <- jokes_tokens %>%
  # remove stop word tokens
  anti_join(jokes_stop_words) %>%
  # get count of each token in each document
  count(id, word) %>%
  # create a document-term matrix with all features and tf weighting
  cast_dtm(document = id, term = word, value = n) %>%
  removeSparseTerms(sparse = .999)
```

```
## Joining, by = c("ngram", "token_id")
```

```r
# remove documents with no terms remaining
jokes_dtm <- jokes_dtm[unique(jokes_dtm$i),]
jokes_dtm
```

```
## <<DocumentTermMatrix (documents: 49283, terms: 2482)>>
## Non-/sparse entries: 443901/121876505
## Sparsity           : 100%
## Maximal term length: 23
## Weighting          : term frequency (tf)
```

## Selecting `\(k\)`

Remember that for LDA, you need to specify in advance the number of topics in the underlying topic structure.

### `\(k=4\)`

Let's estimate an LDA model for the `r/jokes` jokes, setting `\(k=4\)`.

> Warning: many jokes on `r/jokes` are NSFW and contain potentially offensive language/content.


```r
jokes_lda4 <- LDA(jokes_dtm, k = 4, control = list(seed = 123))
jokes_lda4
```

```
## A LDA_VEM topic model with 4 topics.
```

What do the top terms for each of these topics look like?


```r
jokes_lda4_td <- tidy(jokes_lda4)

top_terms <- jokes_lda4_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 2) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/jokes-4-topn-1.png" width="672" />

### `\(k=12\)`

What happens if we set `\(k=12\)`? How do our results change?


```r
jokes_lda12 <- LDA(jokes_dtm, k = 12, control = list(seed = 123))
jokes_lda12
```

```
## A LDA_VEM topic model with 12 topics.
```


```r
jokes_lda12_td <- tidy(jokes_lda12)

top_terms <- jokes_lda12_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 3) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/jokes-12-topn-1.png" width="672" />

Alas, this is the problem with LDA. Several different values for `\(k\)` may be plausible, but by increasing `\(k\)` we sacrifice clarity. Is there any statistical measure which will help us determine the optimal number of topics?

## Perplexity

Well, sort of. Some aspects of LDA are driven by gut-thinking (or perhaps [truthiness](http://www.cc.com/video-clips/63ite2/the-colbert-report-the-word---truthiness)). However we can have some help. [**Perplexity**](https://en.wikipedia.org/wiki/Perplexity) is a statistical measure of how well a probability model predicts a sample. As applied to LDA, for a given value of `\(k\)`, you estimate the LDA model. Then given the theoretical word distributions represented by the topics, compare that to the actual topic mixtures, or distribution of words in your documents.

`topicmodels` includes the function `perplexity()` which calculates this value for a given model.


```r
perplexity(jokes_lda12)
```

```
## [1] 1190.231
```

However, the statistic is somewhat meaningless on its own. The benefit of this statistic comes in comparing perplexity across different models with varying `\(k\)`s. The model with the lowest perplexity is generally considered the "best".

Let's estimate a series of LDA models on the `r/jokes` dataset. Here I make use of `purrr` and the `map()` functions to iteratively generate a series of LDA models for the corpus, using a different number of topics in each model.^[Note that LDA can quickly become CPU and memory intensive as you scale up the size of the corpus and number of topics. Replicating this analysis on your computer may take a long time (i.e. minutes or even hours). It is very possible you may not be able to replicate this analysis on your machine. If so, you need to reduce the amount of text, the number of models, or offload the analysis to the [Research Computing Center](https://rcc.uchicago.edu/).]


```r
n_topics <- c(2, 4, 10, 20, 50, 100)

# cache the models and only estimate if they don't already exist
if (file.exists(here("static", "extras", "jokes_lda_compare.Rdata"))) {
  load(file = here("static", "extras", "jokes_lda_compare.Rdata"))
} else {
  plan(multiprocess)

  tic()
  jokes_lda_compare <- n_topics %>%
    future_map(LDA, x = jokes_dtm, control = list(seed = 1234))
  toc()
  save(jokes_dtm, jokes_lda_compare, file = here("static", "extras", "jokes_lda_compare.Rdata"))
}
```


```r
tibble(k = n_topics,
       perplex = map_dbl(jokes_lda_compare, perplexity)) %>%
  ggplot(aes(k, perplex)) +
  geom_point() +
  geom_line() +
  labs(title = "Evaluating LDA topic models",
       subtitle = "Optimal number of topics (smaller is better)",
       x = "Number of topics",
       y = "Perplexity")
```

<img src="/notes/topic-modeling_files/figure-html/jokes_lda_compare_viz-1.png" width="672" />

It looks like the 100-topic model has the lowest perplexity score. What kind of topics does this generate? Let's look just at the first 12 topics produced by the model (`ggplot2` has difficulty rendering a graph for 100 separate facets):


```r
jokes_lda_td <- tidy(jokes_lda_compare[[6]])

top_terms <- jokes_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  filter(topic <= 12) %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free", ncol = 3) +
  coord_flip()
```

<img src="/notes/topic-modeling_files/figure-html/jokes-100-topn-1.png" width="672" />

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

Let's test it using the `\(k = 10\)` LDA topic model for the `AP`r/jokes` dataset.


```r
jokes_10_json <- topicmodels_json_ldavis(fitted = jokes_lda_compare[[3]],
                                       doc_term = jokes_dtm)
```


```r
serVis(jokes_10_json)
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
##  package     * version date       lib
##  assertthat    0.2.1   2019-03-21 [1]
##  backports     1.1.4   2019-04-10 [1]
##  blogdown      0.12    2019-05-01 [1]
##  bookdown      0.11    2019-05-28 [1]
##  broom         0.5.2   2019-04-07 [1]
##  callr         3.2.0   2019-03-15 [1]
##  cellranger    1.1.0   2016-07-27 [1]
##  cli           1.1.0   2019-03-19 [1]
##  codetools     0.2-16  2018-12-24 [1]
##  colorspace    1.4-1   2019-03-18 [1]
##  crayon        1.3.4   2017-09-16 [1]
##  desc          1.2.0   2018-05-01 [1]
##  devtools      2.0.2   2019-04-08 [1]
##  digest        0.6.19  2019-05-20 [1]
##  dplyr       * 0.8.1   2019-05-14 [1]
##  evaluate      0.14    2019-05-28 [1]
##  fansi         0.4.0   2018-10-05 [1]
##  forcats     * 0.4.0   2019-02-17 [1]
##  fs            1.3.1   2019-05-06 [1]
##  generics      0.0.2   2018-11-29 [1]
##  ggplot2     * 3.1.1   2019-04-07 [1]
##  glue          1.3.1   2019-03-12 [1]
##  gtable        0.3.0   2019-03-25 [1]
##  gutenbergr  * 0.1.4   2018-01-26 [1]
##  haven         2.1.0   2019-02-19 [1]
##  here        * 0.1     2017-05-28 [1]
##  highr         0.8     2019-03-20 [1]
##  hms           0.4.2   2018-03-10 [1]
##  htmltools     0.3.6   2017-04-28 [1]
##  httr          1.4.0   2018-12-11 [1]
##  janeaustenr   0.1.5   2017-06-10 [1]
##  jsonlite      1.6     2018-12-07 [1]
##  knitr         1.23    2019-05-18 [1]
##  labeling      0.3     2014-08-23 [1]
##  lattice       0.20-38 2018-11-04 [1]
##  lazyeval      0.2.2   2019-03-15 [1]
##  LDAvis      * 0.3.2   2015-10-24 [1]
##  LDAvisData  * 0.1     2019-06-10 [1]
##  lubridate     1.7.4   2018-04-11 [1]
##  magrittr      1.5     2014-11-22 [1]
##  Matrix        1.2-17  2019-03-22 [1]
##  memoise       1.1.0   2017-04-21 [1]
##  modelr        0.1.4   2019-02-18 [1]
##  modeltools    0.2-22  2018-07-16 [1]
##  munsell       0.5.0   2018-06-12 [1]
##  nlme          3.1-140 2019-05-12 [1]
##  NLP         * 0.2-0   2018-10-18 [1]
##  pillar        1.4.1   2019-05-28 [1]
##  pkgbuild      1.0.3   2019-03-20 [1]
##  pkgconfig     2.0.2   2018-08-16 [1]
##  pkgload       1.0.2   2018-10-29 [1]
##  plyr          1.8.4   2016-06-08 [1]
##  prettyunits   1.0.2   2015-07-13 [1]
##  processx      3.3.1   2019-05-08 [1]
##  ps            1.3.0   2018-12-21 [1]
##  purrr       * 0.3.2   2019-03-15 [1]
##  R6            2.4.0   2019-02-14 [1]
##  Rcpp          1.0.1   2019-03-17 [1]
##  readr       * 1.3.1   2018-12-21 [1]
##  readxl        1.3.1   2019-03-13 [1]
##  remotes       2.0.4   2019-04-10 [1]
##  reshape2      1.4.3   2017-12-11 [1]
##  rjson       * 0.2.20  2018-06-08 [1]
##  rlang         0.3.4   2019-04-07 [1]
##  rmarkdown     1.13    2019-05-22 [1]
##  rprojroot     1.3-2   2018-01-03 [1]
##  rstudioapi    0.10    2019-03-19 [1]
##  rvest         0.3.4   2019-05-15 [1]
##  scales        1.0.0   2018-08-09 [1]
##  sessioninfo   1.1.1   2018-11-05 [1]
##  slam        * 0.1-45  2019-02-26 [1]
##  SnowballC     0.6.0   2019-01-15 [1]
##  stringi       1.4.3   2019-03-12 [1]
##  stringr     * 1.4.0   2019-02-10 [1]
##  testthat      2.1.1   2019-04-23 [1]
##  tibble      * 2.1.3   2019-06-06 [1]
##  tictoc      * 1.0     2014-06-17 [1]
##  tidyr       * 0.8.3   2019-03-01 [1]
##  tidyselect    0.2.5   2018-10-11 [1]
##  tidytext    * 0.2.0   2018-10-17 [1]
##  tidyverse   * 1.2.1   2017-11-14 [1]
##  tm          * 0.7-6   2018-12-21 [1]
##  tokenizers    0.2.1   2018-03-29 [1]
##  topicmodels * 0.2-8   2018-12-21 [1]
##  usethis       1.5.0   2019-04-07 [1]
##  utf8          1.1.4   2018-05-24 [1]
##  vctrs         0.1.0   2018-11-29 [1]
##  withr         2.1.2   2018-03-15 [1]
##  xfun          0.7     2019-05-14 [1]
##  xml2          1.2.0   2018-01-24 [1]
##  yaml          2.2.0   2018-07-25 [1]
##  zeallot       0.1.0   2018-01-28 [1]
##  source                               
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  Github (cpsievert/LDAvisData@43dd263)
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
##  CRAN (R 3.6.0)                       
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
