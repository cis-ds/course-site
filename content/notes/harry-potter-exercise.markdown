---
title: "Practicing sentiment analysis with Harry Potter"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/text003_harry_potter_exercise.html"]
categories: ["text"]

menu:
  notes:
    parent: Text analysis
    weight: 3
---




```r
library(tidyverse)
library(tidytext)
library(harrypotter)

set.seed(1234)
theme_set(theme_minimal())
```

## Load Harry Potter text

{{% alert note %}}

Run the following code to download the [`harrypotter`](https://github.com/bradleyboehmke/harrypotter) package:

```r
devtools::install_github("bradleyboehmke/harrypotter")
```

Note that there is a different package available on CRAN also called [`harrypotter`](https://cran.r-project.org/web/packages/harrypotter/index.html). This is an entirely different package. If you just run `install.packages("harrypotter")`, you will get an error.

{{% /alert %}}



```r
library(harrypotter)

# names of each book
hp_books <- c("philosophers_stone", "chamber_of_secrets",
              "prisoner_of_azkaban", "goblet_of_fire",
              "order_of_the_phoenix", "half_blood_prince",
              "deathly_hallows")

# combine books into a list
hp_words <- list(
  philosophers_stone,
  chamber_of_secrets,
  prisoner_of_azkaban,
  goblet_of_fire,
  order_of_the_phoenix,
  half_blood_prince,
  deathly_hallows
) %>%
  # name each list element
  set_names(hp_books) %>%
  # convert each book to a data frame and merge into a single data frame
  map_df(as_tibble, .id = "book") %>%
  # convert book to a factor
  mutate(book = factor(book, levels = hp_books)) %>%
  # remove empty chapters
  drop_na(value) %>%
  # create a chapter id column
  group_by(book) %>%
  mutate(chapter = row_number(book)) %>%
  # tokenize the data frame
  unnest_tokens(word, value)

hp_words
```

```
## # A tibble: 1,089,386 x 3
## # Groups:   book [7]
##    book               chapter word   
##    <fct>                <int> <chr>  
##  1 philosophers_stone       1 the    
##  2 philosophers_stone       1 boy    
##  3 philosophers_stone       1 who    
##  4 philosophers_stone       1 lived  
##  5 philosophers_stone       1 mr     
##  6 philosophers_stone       1 and    
##  7 philosophers_stone       1 mrs    
##  8 philosophers_stone       1 dursley
##  9 philosophers_stone       1 of     
## 10 philosophers_stone       1 number 
## # … with 1,089,376 more rows
```

## Most frequent words, by book

Remove stop words.


```r
hp_words %>%
  # delete stopwords
  anti_join(stop_words) %>%
  # summarize count per word per book
  count(book, word, sort = TRUE) %>%
  # get top 15 words per book
  group_by(book) %>%
  top_n(15) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, book)) %>%
  # create barplot
  ggplot(aes(x = word, y = n, fill = book)) + 
  geom_col(color = "black") +
  scale_x_reordered() +
  labs(title = "Most frequent words in Harry Potter",
       x = NULL,
       y = "Word count") +
  facet_wrap(~ book, scales = "free") +
  coord_flip() +
  theme(legend.position = "none")
```

```
## Joining, by = "word"
```

```
## Selecting by n
```

<img src="/notes/harry-potter-exercise_files/figure-html/word-freq-1.png" width="672" />

## Estimate sentiment

## Generate data frame with sentiment derived from the Bing dictionary

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
(hp_bing <- hp_words %>% 
  inner_join(get_sentiments("bing")))
```

```
## Joining, by = "word"
```

```
## # A tibble: 65,094 x 4
## # Groups:   book [7]
##    book               chapter word       sentiment
##    <fct>                <int> <chr>      <chr>    
##  1 philosophers_stone       1 proud      positive 
##  2 philosophers_stone       1 perfectly  positive 
##  3 philosophers_stone       1 thank      positive 
##  4 philosophers_stone       1 strange    negative 
##  5 philosophers_stone       1 mysterious negative 
##  6 philosophers_stone       1 nonsense   negative 
##  7 philosophers_stone       1 useful     positive 
##  8 philosophers_stone       1 finer      positive 
##  9 philosophers_stone       1 greatest   positive 
## 10 philosophers_stone       1 fear       negative 
## # … with 65,084 more rows
```

  </p>
</details>

## Visualize the most frequent positive/negative words in the entire series using the Bing dictionary, and then separately for each book

{{% alert note %}}

Check out [this blog post](https://juliasilge.com/blog/reorder-within/) which introduces the `reorder_within()` and `scale_x_reordered()` functions for sorting bar charts within each facet.

{{% /alert %}}

<details> 
  <summary>Click for a solution</summary>
  <p>
  

```r
# all series
hp_bing %>%
  # generate frequency count for each word and sentiment
  group_by(sentiment) %>%
  count(word, sort = TRUE) %>%
  # extract 10 most frequent pos/neg words
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  # prep data for sorting each word independently by facet
  mutate(word = reorder_within(word, n, sentiment)) %>%
  # generate the bar plot
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  # used with reorder_within() to label the axis tick marks
  scale_x_reordered() +
  facet_wrap(~ sentiment, scales = "free_y") +
  labs(title = "Sentimental words used in the Harry Potter series",
       x = NULL,
       y = "Number of occurences in all seven books") +
  coord_flip()
```

```
## Selecting by n
```

<img src="/notes/harry-potter-exercise_files/figure-html/pos-neg-all-series-1.png" width="672" />

```r
# per book
hp_pos_neg_book <- hp_bing %>%
  # generate frequency count for each book, word, and sentiment
  group_by(book, sentiment) %>%
  count(word, sort = TRUE) %>%
  # extract 10 most frequent pos/neg words per book
  group_by(book, sentiment) %>%
  top_n(10) %>%
  ungroup()
```

```
## Selecting by n
```

```r
## positive words
hp_pos_neg_book %>%
  filter(sentiment == "positive") %>%
  mutate(word = reorder_within(word, n, book)) %>%
  ggplot(aes(word, n)) +
  geom_col(show.legend = FALSE) +
  scale_x_reordered() +
  facet_wrap(~ book, scales = "free_y") +
  labs(title = "Positive words used in the Harry Potter series",
       x = NULL,
       y = "Number of occurences") +
  coord_flip()
```

<img src="/notes/harry-potter-exercise_files/figure-html/pos-neg-all-series-2.png" width="672" />

```r
## negative words
hp_pos_neg_book %>%
  filter(sentiment == "negative") %>%
  mutate(word = reorder_within(word, n, book)) %>%
  ggplot(aes(word, n)) +
  geom_col(show.legend = FALSE) +
  scale_x_reordered() +
  facet_wrap(~ book, scales = "free_y") +
  labs(title = "Negative words used in the Harry Potter series",
       x = NULL,
       y = "Number of occurences") +
  coord_flip()
```

<img src="/notes/harry-potter-exercise_files/figure-html/pos-neg-all-series-3.png" width="672" />

  </p>
</details>

## Generate data frame with sentiment derived from the AFINN dictionary

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
(hp_afinn <- hp_words %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book, chapter))
```

```
## Joining, by = "word"
```

```
## # A tibble: 56,311 x 4
## # Groups:   book, chapter [200]
##    book               chapter word      value
##    <fct>                <int> <chr>     <dbl>
##  1 philosophers_stone       1 proud         2
##  2 philosophers_stone       1 perfectly     3
##  3 philosophers_stone       1 thank         2
##  4 philosophers_stone       1 strange      -1
##  5 philosophers_stone       1 nonsense     -2
##  6 philosophers_stone       1 big           1
##  7 philosophers_stone       1 useful        2
##  8 philosophers_stone       1 no           -1
##  9 philosophers_stone       1 greatest      3
## 10 philosophers_stone       1 fear         -2
## # … with 56,301 more rows
```

  </p>
</details>

## Visualize which words in the AFINN sentiment dictionary appear most frequently

Sometimes words which are defined in a general sentiment dictionary can be outliers in specific contexts. That is, an author may use a word without intending to convey a specific sentiment but the dictionary defines it in a certain way.

We can use a [**wordcloud**](http://tidytextmining.com/sentiment.html#wordclouds) as a quick check to see if there are any outliers in the context of *Harry Potter*, constructed using [`ggwordcloud`](https://lepennec.github.io/ggwordcloud/):


```r
library(ggwordcloud)

set.seed(123)   # ensure reproducibility of the wordcloud
hp_afinn %>%
  # count word frequency across books
  group_by(word) %>%
  count(sort = TRUE) %>%
  # keep only top 150 words for wordcloud
  ungroup() %>%
  top_n(n = 150, wt = n) %>%
  mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(70, 30))) %>%
  ggplot(aes(label = word, size = n, angle = angle)) +
  geom_text_wordcloud_area(rm_outside = TRUE) +
  scale_size(range = c(2, 15)) +
  ggtitle("Most frequent tokens in Harry Potter") +
  theme_minimal()
```

<img src="/notes/harry-potter-exercise_files/figure-html/sentiment-outliers-1.png" width="672" />

As we can see, "moody" appears quite frequently in the books. In the vast majority of appearances, "moody" is used to refer to the character Alastor "Mad-Eye" Moody and is not meant to convey a specific sentiment.

<div style="width:100%;height:0;padding-bottom:38%;position:relative;"><iframe src="https://giphy.com/embed/lirn1IJDukVLq" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>


```r
hp_afinn %>%
  filter(word == "moody")
```

```
## # A tibble: 422 x 4
## # Groups:   book, chapter [48]
##    book               chapter word  value
##    <fct>                <int> <chr> <dbl>
##  1 chamber_of_secrets      13 moody    -1
##  2 goblet_of_fire          11 moody    -1
##  3 goblet_of_fire          11 moody    -1
##  4 goblet_of_fire          11 moody    -1
##  5 goblet_of_fire          12 moody    -1
##  6 goblet_of_fire          12 moody    -1
##  7 goblet_of_fire          12 moody    -1
##  8 goblet_of_fire          12 moody    -1
##  9 goblet_of_fire          12 moody    -1
## 10 goblet_of_fire          12 moody    -1
## # … with 412 more rows
```

It would be best to remove this word from further sentiment analysis, treating it as if it were another stop word.


```r
hp_afinn <- hp_afinn %>%
  filter(word != "moody")

# wordcloud without harry
set.seed(123)   # ensure reproducibility of the wordcloud
hp_afinn %>%
  # count word frequency across books
  group_by(word) %>%
  count(sort = TRUE) %>%
  # keep only top 150 words for wordcloud
  ungroup() %>%
  top_n(n = 150, wt = n) %>%
  mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(70, 30))) %>%
  ggplot(aes(label = word, size = n, angle = angle)) +
  geom_text_wordcloud_area(rm_outside = TRUE) +
  scale_size(range = c(1, 15)) +
  labs(title = "Most frequent tokens in Harry Potter",
       subtitle = "Except for 'Harry'") +
  theme_minimal()
```

<img src="/notes/harry-potter-exercise_files/figure-html/sentiment-outlier-remove-1.png" width="672" />

## Visualize the positive/negative sentiment for each book over time using the AFINN dictionary

<details> 
  <summary>Click for a solution</summary>
  <p>
  

```r
hp_words %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book, chapter) %>%
  summarize(value = sum(value)) %>%
  ggplot(aes(chapter, value, fill = book)) +
  geom_col() +
  facet_wrap(~ book, scales = "free_x") +
  labs(title = "Emotional arc of Harry Potter books",
       subtitle = "AFINN sentiment dictionary",
       x = "Chapter",
       y = "Emotional score") +
  theme(legend.position = "none")
```

```
## Joining, by = "word"
```

<img src="/notes/harry-potter-exercise_files/figure-html/affin-over-time-1.png" width="672" />

```r
# cumulative value
hp_words %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book) %>%
  mutate(cumvalue = cumsum(value)) %>%
  ggplot(aes(chapter, cumvalue, fill = book)) +
  geom_step() +
  facet_wrap(~ book, scales = "free_x") +
  labs(title = "Emotional arc of Harry Potter books",
       subtitle = "AFINN sentiment dictionary",
       x = "Chapter",
       y = "Cumulative emotional value")
```

```
## Joining, by = "word"
```

<img src="/notes/harry-potter-exercise_files/figure-html/affin-over-time-2.png" width="672" />

  </p>
</details>

## Acknowledgments

* This page is derived in part from [Harry Plotter: Celebrating the 20 year anniversary with `tidytext` and the `tidyverse` in R](https://paulvanderlaken.com/2017/08/03/harry-plotter-celebrating-the-20-year-anniversary-with-tidytext-the-tidyverse-and-r/) and licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-09-15                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib
##  assertthat    0.2.1   2019-03-21 [1]
##  backports     1.1.4   2019-04-10 [1]
##  blogdown      0.14    2019-07-13 [1]
##  bookdown      0.12    2019-07-11 [1]
##  broom         0.5.2   2019-04-07 [1]
##  callr         3.3.1   2019-07-18 [1]
##  cellranger    1.1.0   2016-07-27 [1]
##  cli           1.1.0   2019-03-19 [1]
##  colorspace    1.4-1   2019-03-18 [1]
##  crayon        1.3.4   2017-09-16 [1]
##  desc          1.2.0   2018-05-01 [1]
##  devtools      2.1.0   2019-07-06 [1]
##  digest        0.6.20  2019-07-04 [1]
##  dplyr       * 0.8.3   2019-07-04 [1]
##  evaluate      0.14    2019-05-28 [1]
##  forcats     * 0.4.0   2019-02-17 [1]
##  fs            1.3.1   2019-05-06 [1]
##  generics      0.0.2   2018-11-29 [1]
##  ggplot2     * 3.2.1   2019-08-10 [1]
##  glue          1.3.1   2019-03-12 [1]
##  gtable        0.3.0   2019-03-25 [1]
##  harrypotter * 0.1.0   2019-06-10 [1]
##  haven         2.1.1   2019-07-04 [1]
##  here          0.1     2017-05-28 [1]
##  hms           0.5.0   2019-07-09 [1]
##  htmltools     0.3.6   2017-04-28 [1]
##  httr          1.4.1   2019-08-05 [1]
##  janeaustenr   0.1.5   2017-06-10 [1]
##  jsonlite      1.6     2018-12-07 [1]
##  knitr         1.24    2019-08-08 [1]
##  lattice       0.20-38 2018-11-04 [1]
##  lazyeval      0.2.2   2019-03-15 [1]
##  lubridate     1.7.4   2018-04-11 [1]
##  magrittr      1.5     2014-11-22 [1]
##  Matrix        1.2-17  2019-03-22 [1]
##  memoise       1.1.0   2017-04-21 [1]
##  modelr        0.1.5   2019-08-08 [1]
##  munsell       0.5.0   2018-06-12 [1]
##  nlme          3.1-141 2019-08-01 [1]
##  pillar        1.4.2   2019-06-29 [1]
##  pkgbuild      1.0.4   2019-08-05 [1]
##  pkgconfig     2.0.2   2018-08-16 [1]
##  pkgload       1.0.2   2018-10-29 [1]
##  prettyunits   1.0.2   2015-07-13 [1]
##  processx      3.4.1   2019-07-18 [1]
##  ps            1.3.0   2018-12-21 [1]
##  purrr       * 0.3.2   2019-03-15 [1]
##  R6            2.4.0   2019-02-14 [1]
##  Rcpp          1.0.2   2019-07-25 [1]
##  readr       * 1.3.1   2018-12-21 [1]
##  readxl        1.3.1   2019-03-13 [1]
##  remotes       2.1.0   2019-06-24 [1]
##  rlang         0.4.0   2019-06-25 [1]
##  rmarkdown     1.14    2019-07-12 [1]
##  rprojroot     1.3-2   2018-01-03 [1]
##  rstudioapi    0.10    2019-03-19 [1]
##  rvest         0.3.4   2019-05-15 [1]
##  scales        1.0.0   2018-08-09 [1]
##  sessioninfo   1.1.1   2018-11-05 [1]
##  SnowballC     0.6.0   2019-01-15 [1]
##  stringi       1.4.3   2019-03-12 [1]
##  stringr     * 1.4.0   2019-02-10 [1]
##  testthat      2.2.1   2019-07-25 [1]
##  tibble      * 2.1.3   2019-06-06 [1]
##  tidyr       * 0.8.3   2019-03-01 [1]
##  tidyselect    0.2.5   2018-10-11 [1]
##  tidytext    * 0.2.2   2019-07-29 [1]
##  tidyverse   * 1.2.1   2017-11-14 [1]
##  tokenizers    0.2.1   2018-03-29 [1]
##  usethis       1.5.1   2019-07-04 [1]
##  vctrs         0.2.0   2019-07-05 [1]
##  withr         2.1.2   2018-03-15 [1]
##  xfun          0.8     2019-06-25 [1]
##  xml2          1.2.2   2019-08-09 [1]
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
##  Github (bradleyboehmke/harrypotter@51f7146)
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
