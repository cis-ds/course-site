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
  filter(!is.na(value)) %>%
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
  count(book, word) %>%
  # highest freq on top
  arrange(desc(n)) %>% 
  # identify rank within group
  group_by(book) %>% # 
  mutate(top = seq_along(word)) %>%
  # retain top 15 frequent words
  filter(top <= 15) %>%
  # create barplot
  ggplot(aes(x = -top, y = n, fill = book)) + 
  geom_col(color = "black") +
  # print words in plot instead of as axis labels
  geom_text(aes(label = word), hjust = "left", nudge_y = 100) +
  labs(title = "Most frequent words in Harry Potter",
       x = NULL,
       y = "Word count") +
  facet_wrap( ~ book) +
  coord_flip() +
  theme(legend.position = "none",
        # rotate x text
        axis.text.x = element_text(angle = 45, hjust = 1),
        # remove tick marks and text on y-axis
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank())
```

```
## Joining, by = "word"
```

<img src="/notes/harry-potter-exercise_files/figure-html/word-freq-1.png" width="672" />

## Estimate sentiment

## Generate data frame with sentiment derived from the NRC

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
(hp_nrc <- hp_words %>% 
  inner_join(get_sentiments("nrc")) %>%
  group_by(book, chapter, sentiment))
```

```
## Joining, by = "word"
```

```
## # A tibble: 264,705 x 4
## # Groups:   book, chapter, sentiment [2,000]
##    book               chapter word   sentiment   
##    <fct>                <int> <chr>  <chr>       
##  1 philosophers_stone       1 boy    disgust     
##  2 philosophers_stone       1 boy    negative    
##  3 philosophers_stone       1 proud  anticipation
##  4 philosophers_stone       1 proud  joy         
##  5 philosophers_stone       1 proud  positive    
##  6 philosophers_stone       1 proud  trust       
##  7 philosophers_stone       1 expect anticipation
##  8 philosophers_stone       1 expect positive    
##  9 philosophers_stone       1 expect surprise    
## 10 philosophers_stone       1 expect trust       
## # … with 264,695 more rows
```

  </p>
</details>

## Visualize which words in the NRC sentiment dictionary appear most frequently

Sometimes words which are defined in a general sentiment dictionary can be outliers in specific contexts. That is, an author may use a word without intending to convey a specific sentiment but the dictionary defines it in a certain way.

We can use a [**wordcloud**](http://tidytextmining.com/sentiment.html#wordclouds) as a quick check to see if there are any outliers in the context of *Harry Potter*, constructed using [`ggwordcloud`](https://lepennec.github.io/ggwordcloud/):


```r
library(ggwordcloud)

set.seed(123)   # ensure reproducibility of the wordcloud
hp_nrc %>%
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

As we can see, "harry" appears quite frequently in the books. In the vast majority of appearances, "harry" is used to refer to the main character and is not meant to convey a specific sentiment.


```r
get_sentiments("nrc") %>%
  filter(word == "harry")
```

```
## # A tibble: 3 x 2
##   word  sentiment
##   <chr> <chr>    
## 1 harry anger    
## 2 harry negative 
## 3 harry sadness
```

It would be best to remove this word from further sentiment analysis, treating it as if it were another stop word.


```r
hp_nrc <- hp_nrc %>%
  filter(word != "harry")

# wordcloud without harry
set.seed(123)   # ensure reproducibility of the wordcloud
hp_nrc %>%
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

## Visualize which words appear most frequently for each sentiment type

<details> 
  <summary>Click for a solution</summary>
  <p>
  

```r
hp_nrc %>%
  # summarize count per word
  ungroup %>%
  count(word, sentiment) %>%
  # highest freq on top
  arrange(desc(n)) %>% 
  # identify rank within group
  group_by(sentiment) %>% # 
  mutate(top = seq_along(word)) %>%
  # retain top 15 frequent words
  filter(top <= 15) %>%
  # create barplot
  ggplot(aes(x = -top, y = n, fill = sentiment)) + 
  geom_col(color = "black") +
  # print words in plot instead of as axis labels
  geom_text(aes(label = word), hjust = "left", nudge_y = 100) +
  labs(title = "Most frequent words in Harry Potter",
       x = NULL,
       y = "Word count") +
  facet_wrap( ~ sentiment, ncol = 5) +
  coord_flip() +
  theme(legend.position = "none",
        # rotate x text
        axis.text.x = element_text(angle = 45, hjust = 1),
        # remove tick marks and text on y-axis
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank())
```

<img src="/notes/harry-potter-exercise_files/figure-html/nrc-freq-1.png" width="672" />

  </p>
</details>

## Visualize the positive/negative sentiment for each book over time using the AFINN dictionary

<details> 
  <summary>Click for a solution</summary>
  <p>
  

```r
hp_words %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book, chapter) %>%
  summarize(score = sum(score)) %>%
  ggplot(aes(chapter, score, fill = book)) +
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
# cumulative score
hp_words %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book) %>%
  mutate(cumscore = cumsum(score)) %>%
  ggplot(aes(chapter, cumscore, fill = book)) +
  geom_step() +
  facet_wrap(~ book, scales = "free_x") +
  labs(title = "Emotional arc of Harry Potter books",
       subtitle = "AFINN sentiment dictionary",
       x = "Chapter",
       y = "Cumulative emotional score")
```

```
## Joining, by = "word"
```

<img src="/notes/harry-potter-exercise_files/figure-html/affin-over-time-2.png" width="672" />

  </p>
</details>

## Visualize the sentimental content of each chapter in each book using the NRC dictionary

<details> 
  <summary>Click for a solution</summary>
  <p>
  

```r
hp_nrc %>%
  count(sentiment, book, chapter) %>%
  filter(!(sentiment %in% c("positive", "negative"))) %>%
  # create area plot
  ggplot(aes(x = chapter, y = n)) +
  geom_col(aes(fill = sentiment)) + 
  # add black smoothing line without standard error
  geom_smooth(aes(fill = sentiment), method = "loess", se = F, col = 'black') + 
  theme(legend.position = 'none') +
  labs(x = "Chapter", y = "Emotion score", # add labels
       title = "Harry Plotter: Emotions during the saga",
       subtitle = "Using tidytext and the nrc sentiment dictionary") +
  # seperate plots per sentiment and book and free up x-axes
  facet_grid(sentiment ~ book, scales = "free")
```

<img src="/notes/harry-potter-exercise_files/figure-html/sentiment-over-time-1.png" width="672" />

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
##  version  R version 3.5.3 (2019-03-11)
##  os       macOS Mojave 10.14.5        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-06-06                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib
##  assertthat    0.2.1   2019-03-21 [2]
##  backports     1.1.4   2019-04-10 [2]
##  blogdown      0.12    2019-05-01 [1]
##  bookdown      0.10    2019-05-10 [1]
##  broom         0.5.2   2019-04-07 [2]
##  callr         3.2.0   2019-03-15 [2]
##  cellranger    1.1.0   2016-07-27 [2]
##  cli           1.1.0   2019-03-19 [1]
##  colorspace    1.4-1   2019-03-18 [2]
##  crayon        1.3.4   2017-09-16 [2]
##  desc          1.2.0   2018-05-01 [2]
##  devtools      2.0.2   2019-04-08 [1]
##  digest        0.6.19  2019-05-20 [1]
##  dplyr       * 0.8.1   2019-05-14 [1]
##  evaluate      0.13    2019-02-12 [2]
##  forcats     * 0.4.0   2019-02-17 [2]
##  fs            1.3.1   2019-05-06 [1]
##  generics      0.0.2   2018-11-29 [1]
##  ggplot2     * 3.1.1   2019-04-07 [1]
##  glue          1.3.1   2019-03-12 [2]
##  gtable        0.3.0   2019-03-25 [2]
##  harrypotter * 0.1.0   2019-05-17 [1]
##  haven         2.1.0   2019-02-19 [2]
##  here          0.1     2017-05-28 [2]
##  hms           0.4.2   2018-03-10 [2]
##  htmltools     0.3.6   2017-04-28 [1]
##  httr          1.4.0   2018-12-11 [2]
##  janeaustenr   0.1.5   2017-06-10 [2]
##  jsonlite      1.6     2018-12-07 [2]
##  knitr         1.22    2019-03-08 [2]
##  lattice       0.20-38 2018-11-04 [2]
##  lazyeval      0.2.2   2019-03-15 [2]
##  lubridate     1.7.4   2018-04-11 [2]
##  magrittr      1.5     2014-11-22 [2]
##  Matrix        1.2-17  2019-03-22 [2]
##  memoise       1.1.0   2017-04-21 [2]
##  modelr        0.1.4   2019-02-18 [2]
##  munsell       0.5.0   2018-06-12 [2]
##  nlme          3.1-140 2019-05-12 [2]
##  pillar        1.4.1   2019-05-28 [1]
##  pkgbuild      1.0.3   2019-03-20 [1]
##  pkgconfig     2.0.2   2018-08-16 [2]
##  pkgload       1.0.2   2018-10-29 [1]
##  plyr          1.8.4   2016-06-08 [2]
##  prettyunits   1.0.2   2015-07-13 [2]
##  processx      3.3.1   2019-05-08 [1]
##  ps            1.3.0   2018-12-21 [2]
##  purrr       * 0.3.2   2019-03-15 [2]
##  R6            2.4.0   2019-02-14 [1]
##  Rcpp          1.0.1   2019-03-17 [1]
##  readr       * 1.3.1   2018-12-21 [2]
##  readxl        1.3.1   2019-03-13 [2]
##  remotes       2.0.4   2019-04-10 [1]
##  rlang         0.3.4   2019-04-07 [1]
##  rmarkdown     1.12    2019-03-14 [1]
##  rprojroot     1.3-2   2018-01-03 [2]
##  rstudioapi    0.10    2019-03-19 [1]
##  rvest         0.3.4   2019-05-15 [2]
##  scales        1.0.0   2018-08-09 [1]
##  sessioninfo   1.1.1   2018-11-05 [1]
##  SnowballC     0.6.0   2019-01-15 [2]
##  stringi       1.4.3   2019-03-12 [1]
##  stringr     * 1.4.0   2019-02-10 [1]
##  testthat      2.1.1   2019-04-23 [2]
##  tibble      * 2.1.1   2019-03-16 [1]
##  tidyr       * 0.8.3   2019-03-01 [1]
##  tidyselect    0.2.5   2018-10-11 [1]
##  tidytext    * 0.2.0   2018-10-17 [1]
##  tidyverse   * 1.2.1   2017-11-14 [2]
##  tokenizers    0.2.1   2018-03-29 [2]
##  usethis       1.5.0   2019-04-07 [1]
##  withr         2.1.2   2018-03-15 [2]
##  xfun          0.7     2019-05-14 [1]
##  xml2          1.2.0   2018-01-24 [2]
##  yaml          2.2.0   2018-07-25 [2]
##  source                                     
##  CRAN (R 3.5.3)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  Github (bradleyboehmke/harrypotter@51f7146)
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.3)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.3)                             
##  CRAN (R 3.5.1)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.3)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.2)                             
##  CRAN (R 3.5.0)                             
##  CRAN (R 3.5.0)                             
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
