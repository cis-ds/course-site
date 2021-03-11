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
library(tidymodels)
library(tidytext)
library(textrecipes)
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

* Decide on the number of words $N$ the document will have
* Choose a topic mixture for the document (according to a [Dirichlet probability distribution](https://en.wikipedia.org/wiki/Dirichlet_distribution) over a fixed set of $K$ topics). For example, assuming that we have the two food and cute animal topics above, you might choose the document to consist of 1/3 food and 2/3 cute animals.
* Generate each word in the document by:
    * First picking a topic (according to the distribution that you sampled above; for example, you might pick the food topic with 1/3 probability and the cute animals topic with 2/3 probability).
    * Then using the topic to generate the word itself (according to the topic's multinomial distribution). For instance, the food topic might output the word "broccoli" with 30% probability, "bananas" with 15% probability, and so on.

Assuming this generative model for a collection of documents, LDA then tries to backtrack from the documents to find a set of topics that are likely to have generated the collection.

### Food and animals

How could we have generated the sentences in the previous example? When generating a document $D$:

* Decide that $D$ will be 1/2 about food and 1/2 about cute animals.
* Pick 5 to be the number of words in $D$.
* Pick the first word to come from the food topic, which then gives you the word "broccoli".
* Pick the second word to come from the cute animals topic, which gives you "panda".
* Pick the third word to come from the cute animals topic, giving you "adorable".
* Pick the fourth word to come from the food topic, giving you "cherries".
* Pick the fifth word to come from the food topic, giving you "eating".

So the document generated under the LDA model will be "broccoli panda adorable cherries eating" (remember that LDA uses a bag-of-words model).

## LDA with an unknown topic structure

Frequently when using LDA, you don't actually know the underlying topic structure of the documents. **Generally that is why you are using LDA to analyze the text in the first place**. LDA is useful in these instances, but we have to perform additional tests and analysis to confirm that the topic structure uncovered by LDA is a good structure.

## `r/jokes`

<blockquote class="reddit-card" data-card-created="1552319072"><a href="https://www.reddit.com/r/Jokes/comments/a593r0/twenty_years_from_now_kids_are_gonna_think_baby/">Twenty years from now, kids are gonna think "Baby it's cold outside" is really weird, and we're gonna have to explain that it has to be understood as a product of its time.</a> from <a href="http://www.reddit.com/r/Jokes">r/Jokes</a></blockquote>
<script async src="//embed.redditmedia.com/widgets/platform.js" charset="UTF-8"></script>

[`r/jokes`](https://www.reddit.com/r/Jokes/) is a subreddit for text-based jokes. Jokes can be up or down-voted depending on their popularity. [`joke-dataset`](https://github.com/taivop/joke-dataset/) contains a dataset of all joke submissions through February 2, 2017. We can obtain the JSON file storing these jokes and convert them into a document-term matrix.


```r
# obtain r/jokes and extract values from the JSON file
jokes_json <- fromJSON(file = "https://github.com/taivop/joke-dataset/raw/master/reddit_jokes.json")

jokes <- tibble(jokes = jokes_json) %>%
  unnest_wider(col = jokes)
```

```
## Warning in deparse(x, backtick = TRUE): NAs introduced by coercion to integer
## range
```

```r
glimpse(jokes)
```

```
## Rows: 194,553
## Columns: 4
## $ body  <chr> "Now I have to say \"Leroy can you please paint the fence?\"", "…
## $ id    <chr> "5tz52q", "5tz4dd", "5tz319", "5tz2wj", "5tz1pc", "5tz1o1", "5tz…
## $ score <dbl> 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 15, 0, 0, 3, 1, 0, 3, 2, 2, 3, 0, …
## $ title <chr> "I hate how you cant even say black paint anymore", "What's the …
```

Once we import the data, we can prepare it for the estimating the model. Unlike for [supervised text classification](/notes/supervised-text-classification/), we will use `recipes` to prepare the data, then convert it into a `DocumentTermMatrix` to fit the LDA model.

{{% callout alert %}}

Within the `tidymodels` framework, unsupervised learning is typically implemented as a `recipe` step as opposed to a model (remember that unlike supervised learning, unsupervised learning approaches have no outcome of interest to predict). `textrecipes` includes [`step_lda()`](https://textrecipes.tidymodels.org/reference/step_lda.html) which can be used to directly fit an LDA model as part of the recipe. Unfortunately it does not support deeper methods for exploring and interpreting the results of the model like we use below.

{{% /callout %}}


```r
set.seed(123) # set seed for random sampling

jokes_rec <- recipe(~., data = jokes) %>%
  step_sample(size = 1e04) %>%
  step_tokenize(title, body) %>%
  step_tokenmerge(title, body, prefix = "joke") %>%
  step_stopwords(joke) %>%
  step_ngram(joke, num_tokens = 5, min_num_tokens = 1) %>%
  step_tokenfilter(joke, max_tokens = 2500) %>%
  step_tf(joke)
```

- `recipe()` - initialize the recipe using the `jokes` data frame
- `step_sample()` - reduce the size of the dataset to a more manageable number of observations
- `step_tokenize()` - perform the tokenization of the text data. Note that here the text is stored in two separate columns. By default it tokenizes individual words.
- `step_tokenmerge()` - combine the two text columns into a single column which allows us to estimate a single LDA model for the entire joke.
- `step_stopwords()` - remove common stopwords (equivalent to `anti_join(stop_words)`)
- `step_ngram()` - calculates the $n$-grams based on the remaining tokens. `num_tokens` and `min_num_tokens` allows us to calculate all possible 1-grams, 2-grams, 3-grams, 4-grams, and 5-grams.
- `step_tokenfilter()` - dedensify the data set and keep only the most commonly used tokens. Here we will retain the top 2500 tokens. If we retained all unique tokens in the dataset, the LDA model could take an extremely long time to estimate even for a relatively small number of topics.
- `step_tf()` - calculate the term-frequency for each unique token in each document

Now that we created the recipe, we have to prepare it using the `jokes` data set and then convert it into a `DocumentTermMatrix`. `prep()` allows us to prepare the recipe, while `bake()` lets us extract the resulting data frame.


```r
jokes_prep <- prep(jokes_rec)

jokes_df <- bake(jokes_prep, new_data = NULL)
jokes_df %>%
  slice(1:5)
```

```
## # A tibble: 5 x 2,502
##   id    score tf_joke_0 tf_joke_1 tf_joke_10 tf_joke_100 tf_joke_1000 tf_joke_11
##   <fct> <dbl>     <dbl>     <dbl>      <dbl>       <dbl>        <dbl>      <dbl>
## 1 2tzi…    12         0         0          0           0            0          0
## 2 4zqp…     0         0         0          0           0            0          0
## 3 2lgw…    58         0         0          0           0            0          0
## 4 3qx3…     9         0         0          0           0            0          0
## 5 2x2z…     0         0         0          0           0            0          0
## # … with 2,494 more variables: tf_joke_12 <dbl>, tf_joke_13 <dbl>,
## #   tf_joke_14 <dbl>, tf_joke_15 <dbl>, tf_joke_16 <dbl>, tf_joke_18 <dbl>,
## #   tf_joke_1st <dbl>, tf_joke_2 <dbl>, tf_joke_20 <dbl>,
## #   tf_joke_20_years <dbl>, tf_joke_200 <dbl>, tf_joke_2015 <dbl>,
## #   tf_joke_25 <dbl>, tf_joke_3 <dbl>, tf_joke_30 <dbl>, tf_joke_3rd <dbl>,
## #   tf_joke_4 <dbl>, tf_joke_40 <dbl>, tf_joke_4th <dbl>, tf_joke_5 <dbl>,
## #   tf_joke_50 <dbl>, tf_joke_500 <dbl>, tf_joke_5th <dbl>, tf_joke_6 <dbl>,
## #   tf_joke_69 <dbl>, tf_joke_7 <dbl>, tf_joke_76561198082478987 <dbl>,
## #   tf_joke_76561198082478987_inventory <dbl>, tf_joke_7c <dbl>,
## #   tf_joke_8 <dbl>, tf_joke_9 <dbl>, tf_joke_9_11 <dbl>, tf_joke_90 <dbl>,
## #   tf_joke_99 <dbl>, tf_joke_able <dbl>, tf_joke_absolutely <dbl>,
## #   tf_joke_accent <dbl>, tf_joke_accept <dbl>, tf_joke_accident <dbl>,
## #   tf_joke_accidentally <dbl>, tf_joke_across <dbl>,
## #   tf_joke_across_street <dbl>, tf_joke_act <dbl>, tf_joke_action <dbl>,
## #   tf_joke_actually <dbl>, tf_joke_adam <dbl>, tf_joke_add <dbl>,
## #   tf_joke_added <dbl>, tf_joke_advice <dbl>, tf_joke_afford <dbl>,
## #   tf_joke_afraid <dbl>, tf_joke_africa <dbl>, tf_joke_african <dbl>,
## #   tf_joke_afternoon <dbl>, tf_joke_age <dbl>, tf_joke_agent <dbl>,
## #   tf_joke_ago <dbl>, tf_joke_agree <dbl>, tf_joke_agreed <dbl>,
## #   tf_joke_agreement <dbl>, tf_joke_agrees <dbl>, tf_joke_ah <dbl>,
## #   tf_joke_ahead <dbl>, tf_joke_ain't <dbl>, tf_joke_air <dbl>,
## #   tf_joke_airplane <dbl>, tf_joke_airport <dbl>, tf_joke_alcohol <dbl>,
## #   tf_joke_alien <dbl>, tf_joke_alive <dbl>, tf_joke_alley <dbl>,
## #   tf_joke_allow <dbl>, tf_joke_allowed <dbl>, tf_joke_almost <dbl>,
## #   tf_joke_alone <dbl>, tf_joke_along <dbl>, tf_joke_alphabet <dbl>,
## #   tf_joke_already <dbl>, tf_joke_alright <dbl>, tf_joke_also <dbl>,
## #   tf_joke_although <dbl>, tf_joke_always <dbl>, tf_joke_amazed <dbl>,
## #   tf_joke_amazing <dbl>, tf_joke_america <dbl>, tf_joke_american <dbl>,
## #   tf_joke_americans <dbl>, tf_joke_among <dbl>, tf_joke_amount <dbl>,
## #   tf_joke_anal <dbl>, tf_joke_angel <dbl>, tf_joke_angry <dbl>,
## #   tf_joke_animal <dbl>, tf_joke_animals <dbl>, tf_joke_anniversary <dbl>,
## #   tf_joke_annoyed <dbl>, tf_joke_another <dbl>, tf_joke_another_one <dbl>,
## #   tf_joke_answer <dbl>, tf_joke_answered <dbl>, …
```

The resulting data frame is one row per joke and one column per token. To convert it to a `DocumentTermMatrix`, we need to first convert it into a tidytext format (one-row-per-token), remove all rows with a frequency of 0 (that is, the token did not appear in the joke), then convert it to a DTM using `cast_dtm()`.


```r
jokes_dtm <- jokes_df %>%
  pivot_longer(cols = -c(id, score),
               names_to = "token",
               values_to = "n") %>%
  filter(n != 0) %>%
  # clean the token column so it just includes the token
  # drop empty levels from id - this includes jokes which did not
  # have any tokens retained after step_tokenfilter()
  mutate(token = str_remove(string = token, pattern = "tf_joke_"),
         id = fct_drop(f = id)) %>%
  cast_dtm(document = id, term = token, value = n)
jokes_dtm
```

```
## <<DocumentTermMatrix (documents: 9944, terms: 2500)>>
## Non-/sparse entries: 140880/24719120
## Sparsity           : 99%
## Maximal term length: 60
## Weighting          : term frequency (tf)
```

## Selecting $k$

Remember that for LDA, you need to specify in advance the number of topics in the underlying topic structure.

### $k=4$

Let's estimate an LDA model for the `r/jokes` jokes, setting $k=4$.

{{% callout warning %}}

Warning: many jokes on `r/jokes` are NSFW and contain potentially offensive language/content.

{{% /callout %}}


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
  mutate(topic = factor(topic),
         term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = topic)) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  scale_x_reordered() +
  facet_wrap(~ topic, scales = "free", ncol = 2) +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/jokes-4-topn-1.png" width="672" />

### $k=12$

What happens if we set $k=12$? How do our results change?


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
  mutate(topic = factor(topic),
         term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = topic)) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  scale_x_reordered() +
  facet_wrap(~ topic, scales = "free", ncol = 3) +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/jokes-12-topn-1.png" width="672" />

Alas, this is the problem with LDA. Several different values for $k$ may be plausible, but by increasing $k$ we sacrifice clarity. Is there any statistical measure which will help us determine the optimal number of topics?

## Perplexity

Well, sort of. Some aspects of LDA are driven by gut-thinking (or perhaps [truthiness](http://www.cc.com/video-clips/63ite2/the-colbert-report-the-word---truthiness)). However we can have some help. [**Perplexity**](https://en.wikipedia.org/wiki/Perplexity) is a statistical measure of how well a probability model predicts a sample. As applied to LDA, for a given value of $k$, you estimate the LDA model. Then given the theoretical word distributions represented by the topics, compare that to the actual topic mixtures, or distribution of words in your documents.

`topicmodels` includes the function `perplexity()` which calculates this value for a given model.


```r
perplexity(jokes_lda12)
```

```
## [1] 994.9667
```

However, the statistic is somewhat meaningless on its own. The benefit of this statistic comes in comparing perplexity across different models with varying $k$s. The model with the lowest perplexity is generally considered the "best".

Let's estimate a series of LDA models on the `r/jokes` dataset. Here I make use of `purrr` and the `map()` functions to iteratively generate a series of LDA models for the corpus, using a different number of topics in each model.^[Note that LDA can quickly become CPU and memory intensive as you scale up the size of the corpus and number of topics. Replicating this analysis on your computer may take a long time (i.e. minutes or even hours). It is very possible you may not be able to replicate this analysis on your machine. If so, you need to reduce the amount of text, the number of models, or offload the analysis to the [Research Computing Center](https://rcc.uchicago.edu/).]


```r
n_topics <- c(2, 4, 10, 20, 50, 100)

# cache the models and only estimate if they don't already exist
if (file.exists(here("static", "extras", "jokes_lda_compare.Rdata"))) {
  load(file = here("static", "extras", "jokes_lda_compare.Rdata"))
} else {
  library(furrr)
  plan(multiprocess)

  tic()
  jokes_lda_compare <- n_topics %>%
    future_map(LDA, x = jokes_dtm, control = list(seed = 123))
  toc()
  save(jokes_dtm, jokes_lda_compare, file = here("static", "extras", "jokes_lda_compare.Rdata"))
}
```

```
## Warning: Strategy 'multiprocess' is deprecated in future (>= 1.20.0). Instead,
## explicitly specify either 'multisession' or 'multicore'. In the current R
## session, 'multiprocess' equals 'multisession'.
```

```
## Warning in supportsMulticoreAndRStudio(...): [ONE-TIME WARNING] Forked
## processing ('multicore') is not supported when running R from RStudio
## because it is considered unstable. For more details, how to control forked
## processing or not, and how to silence this warning in future R sessions, see ?
## parallelly::supportsMulticore
```

```
## 1128.072 sec elapsed
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

<img src="{{< blogdown/postref >}}index_files/figure-html/jokes_lda_compare_viz-1.png" width="672" />

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
  mutate(topic = factor(topic),
         term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = topic)) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  scale_x_reordered() +
  facet_wrap(~ topic, scales = "free", ncol = 3) +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/jokes-100-topn-1.png" width="672" />

We are getting even more specific topics now. The question becomes how would we present these results and use them in an informative way? Not to mention perplexity was still dropping at $k=100$ - would $k=200$ generate an even lower perplexity score?^[I tried to estimate this model, but my computer was taking too long.]

Again, this is where your intuition and domain knowledge as a researcher is important. You can use perplexity as one data point in your decision process, but a lot of the time it helps to simply look at the topics themselves and the highest probability words associated with each one to determine if the structure makes sense. If you have a known topic structure you can compare it to (such as the books example above), this can also be useful.

## Interactive exploration of LDA model

The [`LDAvis`](https://github.com/cpsievert/LDAvis) allows you to interactively visualize an LDA topic model. The major graphical elements include:

1. Default topic circles - $K$ circles, one for each topic, whose areas are set to be proportional to the proportions of the topics across the $N$ total tokens in the corpus.
1. Red bars - represent the estimated number of times a given term was generated by a given topic.
1. Blue bars - represent the overall frequency of each term in the corpus
1. Topic-term circlues - $K \times W$ circles whose areas are set to be proportional to the frequencies with which a given term is estimated to have been generated by the topics.

To install the necessary packages, run the code below:

```r
install.packages("LDAvis")
devtools::install_github("cpsievert/LDAvisData")
```

### Example: This is Jeopardy!

Here we draw an example directly from the `LDAvis` package to visualize a $K = 100$ topic LDA model of 200,000+ Jeopardy! "answers" and categories. The model is pre-generated and relevant components from the `LDA()` function are already stored in a list for us. In order to visualize the model, we need to convert this to a JSON file using `createJSON()` and then pass this object to `serVis()`.


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

Let's test it using the $k = 100$ LDA topic model for the `r/jokes` dataset.


```r
jokes_100_json <- topicmodels_json_ldavis(fitted = jokes_lda_compare[[6]],
                                       doc_term = jokes_dtm)
```


```r
serVis(jokes_100_json)
```

## Acknowledgments

* This page is derived in part from ["Tidy Text Mining with R"](http://tidytextmining.com/) and licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 United States License](https://creativecommons.org/licenses/by-nc-sa/3.0/us/).
* This page is derived in part from ["What is a good explanation of Latent Dirichlet Allocation?"](https://www.quora.com/What-is-a-good-explanation-of-Latent-Dirichlet-Allocation)

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.4 (2021-02-15)
##  os       macOS Big Sur 10.16         
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-03-11                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version    date       lib source                               
##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.0)                       
##  backports     1.2.1      2020-12-09 [1] CRAN (R 4.0.2)                       
##  blogdown      1.2        2021-03-04 [1] CRAN (R 4.0.3)                       
##  bookdown      0.21       2020-10-13 [1] CRAN (R 4.0.2)                       
##  broom       * 0.7.5      2021-02-19 [1] CRAN (R 4.0.2)                       
##  bslib         0.2.4      2021-01-25 [1] CRAN (R 4.0.2)                       
##  cachem        1.0.4      2021-02-13 [1] CRAN (R 4.0.2)                       
##  callr         3.5.1      2020-10-13 [1] CRAN (R 4.0.2)                       
##  cellranger    1.1.0      2016-07-27 [1] CRAN (R 4.0.0)                       
##  class         7.3-18     2021-01-24 [1] CRAN (R 4.0.4)                       
##  cli           2.3.1      2021-02-23 [1] CRAN (R 4.0.3)                       
##  codetools     0.2-18     2020-11-04 [1] CRAN (R 4.0.4)                       
##  colorspace    2.0-0      2020-11-11 [1] CRAN (R 4.0.2)                       
##  crayon        1.4.1      2021-02-08 [1] CRAN (R 4.0.2)                       
##  DBI           1.1.1      2021-01-15 [1] CRAN (R 4.0.2)                       
##  dbplyr        2.1.0      2021-02-03 [1] CRAN (R 4.0.2)                       
##  debugme       1.1.0      2017-10-22 [1] CRAN (R 4.0.0)                       
##  desc          1.2.0      2018-05-01 [1] CRAN (R 4.0.0)                       
##  devtools      2.3.2      2020-09-18 [1] CRAN (R 4.0.2)                       
##  dials       * 0.0.9      2020-09-16 [1] CRAN (R 4.0.2)                       
##  DiceDesign    1.9        2021-02-13 [1] CRAN (R 4.0.2)                       
##  digest        0.6.27     2020-10-24 [1] CRAN (R 4.0.2)                       
##  dplyr       * 1.0.5      2021-03-05 [1] CRAN (R 4.0.3)                       
##  ellipsis      0.3.1      2020-05-15 [1] CRAN (R 4.0.0)                       
##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.0)                       
##  fansi         0.4.2      2021-01-15 [1] CRAN (R 4.0.2)                       
##  fastmap       1.1.0      2021-01-25 [1] CRAN (R 4.0.2)                       
##  forcats     * 0.5.1      2021-01-27 [1] CRAN (R 4.0.2)                       
##  foreach       1.5.1      2020-10-15 [1] CRAN (R 4.0.2)                       
##  fs            1.5.0      2020-07-31 [1] CRAN (R 4.0.2)                       
##  furrr       * 0.2.2      2021-01-29 [1] CRAN (R 4.0.2)                       
##  future      * 1.21.0     2020-12-10 [1] CRAN (R 4.0.2)                       
##  generics      0.1.0      2020-10-31 [1] CRAN (R 4.0.2)                       
##  ggplot2     * 3.3.3      2020-12-30 [1] CRAN (R 4.0.2)                       
##  globals       0.14.0     2020-11-22 [1] CRAN (R 4.0.2)                       
##  glue          1.4.2      2020-08-27 [1] CRAN (R 4.0.2)                       
##  gower         0.2.2      2020-06-23 [1] CRAN (R 4.0.2)                       
##  GPfit         1.0-8      2019-02-08 [1] CRAN (R 4.0.0)                       
##  gtable        0.3.0      2019-03-25 [1] CRAN (R 4.0.0)                       
##  haven         2.3.1      2020-06-01 [1] CRAN (R 4.0.0)                       
##  here        * 1.0.1      2020-12-13 [1] CRAN (R 4.0.2)                       
##  hms           1.0.0      2021-01-13 [1] CRAN (R 4.0.2)                       
##  htmltools     0.5.1.1    2021-01-22 [1] CRAN (R 4.0.2)                       
##  httr          1.4.2      2020-07-20 [1] CRAN (R 4.0.2)                       
##  infer       * 0.5.4      2021-01-13 [1] CRAN (R 4.0.2)                       
##  ipred         0.9-10     2021-03-04 [1] CRAN (R 4.0.2)                       
##  iterators     1.0.13     2020-10-15 [1] CRAN (R 4.0.2)                       
##  janeaustenr   0.1.5      2017-06-10 [1] CRAN (R 4.0.0)                       
##  jquerylib     0.1.3      2020-12-17 [1] CRAN (R 4.0.2)                       
##  jsonlite      1.7.2      2020-12-09 [1] CRAN (R 4.0.2)                       
##  knitr         1.31       2021-01-27 [1] CRAN (R 4.0.2)                       
##  lattice       0.20-41    2020-04-02 [1] CRAN (R 4.0.4)                       
##  lava          1.6.8.1    2020-11-04 [1] CRAN (R 4.0.2)                       
##  LDAvis      * 0.3.2      2015-10-24 [1] CRAN (R 4.0.0)                       
##  LDAvisData  * 0.1        2020-06-08 [1] Github (cpsievert/LDAvisData@43dd263)
##  lhs           1.1.1      2020-10-05 [1] CRAN (R 4.0.2)                       
##  lifecycle     1.0.0      2021-02-15 [1] CRAN (R 4.0.2)                       
##  listenv       0.8.0      2019-12-05 [1] CRAN (R 4.0.0)                       
##  lubridate     1.7.10     2021-02-26 [1] CRAN (R 4.0.2)                       
##  magrittr      2.0.1      2020-11-17 [1] CRAN (R 4.0.2)                       
##  MASS          7.3-53     2020-09-09 [1] CRAN (R 4.0.4)                       
##  Matrix        1.3-2      2021-01-06 [1] CRAN (R 4.0.4)                       
##  memoise       2.0.0      2021-01-26 [1] CRAN (R 4.0.2)                       
##  modeldata   * 0.1.0      2020-10-22 [1] CRAN (R 4.0.2)                       
##  modelr        0.1.8      2020-05-19 [1] CRAN (R 4.0.0)                       
##  modeltools    0.2-23     2020-03-05 [1] CRAN (R 4.0.0)                       
##  munsell       0.5.0      2018-06-12 [1] CRAN (R 4.0.0)                       
##  NLP         * 0.2-1      2020-10-14 [1] CRAN (R 4.0.2)                       
##  nnet          7.3-15     2021-01-24 [1] CRAN (R 4.0.4)                       
##  parallelly    1.23.0     2021-01-04 [1] CRAN (R 4.0.2)                       
##  parsnip     * 0.1.5      2021-01-19 [1] CRAN (R 4.0.2)                       
##  pillar        1.5.1      2021-03-05 [1] CRAN (R 4.0.3)                       
##  pkgbuild      1.2.0      2020-12-15 [1] CRAN (R 4.0.2)                       
##  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.0.0)                       
##  pkgload       1.2.0      2021-02-23 [1] CRAN (R 4.0.2)                       
##  plyr          1.8.6      2020-03-03 [1] CRAN (R 4.0.0)                       
##  prettyunits   1.1.1      2020-01-24 [1] CRAN (R 4.0.0)                       
##  pROC          1.17.0.1   2021-01-13 [1] CRAN (R 4.0.2)                       
##  processx      3.4.5      2020-11-30 [1] CRAN (R 4.0.2)                       
##  prodlim       2019.11.13 2019-11-17 [1] CRAN (R 4.0.0)                       
##  ps            1.6.0      2021-02-28 [1] CRAN (R 4.0.2)                       
##  purrr       * 0.3.4      2020-04-17 [1] CRAN (R 4.0.0)                       
##  R6            2.5.0      2020-10-28 [1] CRAN (R 4.0.2)                       
##  Rcpp          1.0.6      2021-01-15 [1] CRAN (R 4.0.2)                       
##  readr       * 1.4.0      2020-10-05 [1] CRAN (R 4.0.2)                       
##  readxl        1.3.1      2019-03-13 [1] CRAN (R 4.0.0)                       
##  recipes     * 0.1.15     2020-11-11 [1] CRAN (R 4.0.2)                       
##  remotes       2.2.0      2020-07-21 [1] CRAN (R 4.0.2)                       
##  reprex        1.0.0      2021-01-27 [1] CRAN (R 4.0.2)                       
##  rjson       * 0.2.20     2018-06-08 [1] CRAN (R 4.0.0)                       
##  rlang         0.4.10     2020-12-30 [1] CRAN (R 4.0.2)                       
##  rmarkdown     2.7        2021-02-19 [1] CRAN (R 4.0.2)                       
##  rpart         4.1-15     2019-04-12 [1] CRAN (R 4.0.4)                       
##  rprojroot     2.0.2      2020-11-15 [1] CRAN (R 4.0.2)                       
##  rsample     * 0.0.9      2021-02-17 [1] CRAN (R 4.0.2)                       
##  rstudioapi    0.13       2020-11-12 [1] CRAN (R 4.0.2)                       
##  rvest         0.3.6      2020-07-25 [1] CRAN (R 4.0.2)                       
##  sass          0.3.1      2021-01-24 [1] CRAN (R 4.0.2)                       
##  scales      * 1.1.1      2020-05-11 [1] CRAN (R 4.0.0)                       
##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.0)                       
##  slam        * 0.1-48     2020-12-03 [1] CRAN (R 4.0.2)                       
##  SnowballC     0.7.0      2020-04-01 [1] CRAN (R 4.0.0)                       
##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)                       
##  stringr     * 1.4.0      2019-02-10 [1] CRAN (R 4.0.0)                       
##  survival      3.2-7      2020-09-28 [1] CRAN (R 4.0.4)                       
##  testthat      3.0.2      2021-02-14 [1] CRAN (R 4.0.2)                       
##  textrecipes * 0.4.0      2020-11-12 [1] CRAN (R 4.0.2)                       
##  tibble      * 3.1.0      2021-02-25 [1] CRAN (R 4.0.2)                       
##  tictoc      * 1.0        2014-06-17 [1] CRAN (R 4.0.0)                       
##  tidymodels  * 0.1.2      2020-11-22 [1] CRAN (R 4.0.2)                       
##  tidyr       * 1.1.3      2021-03-03 [1] CRAN (R 4.0.2)                       
##  tidyselect    1.1.0      2020-05-11 [1] CRAN (R 4.0.0)                       
##  tidytext    * 0.3.0      2021-01-06 [1] CRAN (R 4.0.2)                       
##  tidyverse   * 1.3.0      2019-11-21 [1] CRAN (R 4.0.0)                       
##  timeDate      3043.102   2018-02-21 [1] CRAN (R 4.0.0)                       
##  tm          * 0.7-8      2020-11-18 [1] CRAN (R 4.0.2)                       
##  tokenizers    0.2.1      2018-03-29 [1] CRAN (R 4.0.0)                       
##  topicmodels * 0.2-12     2021-01-29 [1] CRAN (R 4.0.2)                       
##  tune        * 0.1.3      2021-02-28 [1] CRAN (R 4.0.2)                       
##  usethis       2.0.1      2021-02-10 [1] CRAN (R 4.0.2)                       
##  utf8          1.1.4      2018-05-24 [1] CRAN (R 4.0.0)                       
##  vctrs         0.3.6      2020-12-17 [1] CRAN (R 4.0.2)                       
##  withr         2.4.1      2021-01-26 [1] CRAN (R 4.0.2)                       
##  workflows   * 0.2.1      2020-10-08 [1] CRAN (R 4.0.2)                       
##  xfun          0.21       2021-02-10 [1] CRAN (R 4.0.2)                       
##  xml2          1.3.2      2020-04-23 [1] CRAN (R 4.0.0)                       
##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.0)                       
##  yardstick   * 0.0.7      2020-07-13 [1] CRAN (R 4.0.2)                       
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
