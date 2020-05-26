---
title: "Practicing tidytext with Hamilton"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: []
categories: ["text"]

menu:
  notes:
    parent: Text analysis
    weight: 3
---




```r
library(tidyverse)
library(tidytext)
library(ggtext)
library(here)

set.seed(123)
theme_set(theme_minimal())
```

About five months ago, my wife and I became addicted to Hamilton.

<div style="width:100%;height:0;padding-bottom:56%;position:relative;"><iframe src="https://giphy.com/embed/d4bmtcUmgA8ylgCk" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>

I admit, we were quite late to the party. I promise we did like it, but I wanted to wait and see the musical in-person before listening to the soundtrack. Alas, having three small children limits your free time to go out to the theater for an entire evening. So I finally caved and started listening to the soundtrack on Spotify. And it's amazing! My son's favorite song (he's four BTW) is My Shot.

<iframe src="https://open.spotify.com/embed/track/4cxvludVmQxryrnx1m9FqL" width="300" height="380" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe>

One of the nice things about the musical is that it is [sung-through](https://en.wikipedia.org/wiki/Sung-through), so the lyrics contain essentially all of the dialogue. This provides an interesting opportunity to use the `tidytext` package to analyze the lyrics.[^lyrics]




```r
hamilton <- read_csv(file = here("static", "data", "hamilton.csv")) %>%
  mutate(song_title = parse_factor(song_title))
```

```
## Parsed with column specification:
## cols(
##   song_number = col_double(),
##   song_title = col_character(),
##   line_num = col_double(),
##   line = col_character(),
##   speaker = col_character()
## )
```

```r
glimpse(hamilton)
```

```
## Observations: 3,544
## Variables: 5
## $ song_number <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
## $ song_title  <fct> Alexander Hamilton, Alexander Hamilton, Alexander Hamilto…
## $ line_num    <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17…
## $ line        <chr> "How does a bastard, orphan, son of a whore and a", "Scot…
## $ speaker     <chr> "Aaron Burr", "Aaron Burr", "Aaron Burr", "Aaron Burr", "…
```

Along with the lyrics, we also know the singer (`speaker`) of each line of dialogue. This will be helpful if we want to perform analysis on a subset of singers.

## Convert to tidytext format

Currently, `hamilton` is stored as one-row-per-line of lyrics. The definition of a single "line" is somewhat arbitrary. For substantial analysis, we will convert the corpus to a tidy-text data frame of one-row-per-token. Initially, we will use `unnest_tokens()` to tokenize all unigrams.


```r
hamilton_tidy <- hamilton %>%
  unnest_tokens(output = word, input = line)
hamilton_tidy
```

```
## # A tibble: 21,289 x 5
##    song_number song_title         line_num speaker    word   
##          <dbl> <fct>                 <dbl> <chr>      <chr>  
##  1           1 Alexander Hamilton        1 Aaron Burr how    
##  2           1 Alexander Hamilton        1 Aaron Burr does   
##  3           1 Alexander Hamilton        1 Aaron Burr a      
##  4           1 Alexander Hamilton        1 Aaron Burr bastard
##  5           1 Alexander Hamilton        1 Aaron Burr orphan 
##  6           1 Alexander Hamilton        1 Aaron Burr son    
##  7           1 Alexander Hamilton        1 Aaron Burr of     
##  8           1 Alexander Hamilton        1 Aaron Burr a      
##  9           1 Alexander Hamilton        1 Aaron Burr whore  
## 10           1 Alexander Hamilton        1 Aaron Burr and    
## # … with 21,279 more rows
```

Remember that by default, `unnest_tokens()` automatically converts all text to lowercase and strips out punctuation.

## Length of songs by words

An initial check reveals the length of each song in terms of the number of words in its lyrics.^[Though lyrics' length is not always [a good measure of a musical's pacing](https://fivethirtyeight.com/features/hamilton-is-the-very-model-of-a-modern-fast-paced-musical/).]


```r
ggplot(data = hamilton_tidy, mapping = aes(x = fct_rev(song_title))) +
  geom_bar() +
  coord_flip() +
  labs(
    title = "Length of songs in Hamilton",
    x = NULL,
    y = "Song length (in words)",
    caption = "Source: Genius API"
  )
```

<img src="/notes/hamilton_files/figure-html/song-length-1.png" width="672" />

As a function of number of words, My Shot is the longest song in the musical.


```r
hamilton_spotify <- spotifyr::get_album_tracks(id = "1kCHru7uhxBUdzkm4gzRQc", limit = 50) %>%
  # fix missing song from spotify info
  mutate(track_number = ifelse(name == "Non-Stop", 24, track_number),
         song_number = ifelse(disc_number == 2,
                              track_number + max(track_number[disc_number == 1]),
                              track_number))
hamilton_audio_features <- spotifyr::get_track_audio_features(ids = hamilton_spotify$id)
hamilton_audio <- bind_cols(hamilton_spotify, hamilton_audio_features) %>%
  as_tibble() %>%
  select(spotify_id = id, duration_ms, explicit, name, song_number, danceability:tempo, time_signature)
```


```r
hamilton_tidy %>%
  count(song_number, song_title) %>%
  left_join(hamilton_audio) %>%
  ggplot(mapping = aes(x = n, y = duration_ms / 1000)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  ggrepel::geom_text_repel(mapping = aes(label = song_title), alpha = .3, size = 3) +
  scale_y_time() +
  labs(
    x = "Number of words",
    y = "Length of song (duration)",
    caption = "Lyrics: Genius API\nDuration: Spotify API"
  )
```

```
## Joining, by = "song_number"
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

```
## Warning: Removed 1 rows containing missing values (geom_text_repel).
```

<img src="/notes/hamilton_files/figure-html/length-words-duration-1.png" width="672" />

## Stop words

Of course not all words are equally important. Consider the 10 most frequent words in the lyrics:


```r
hamilton_tidy %>%
  count(word) %>%
  arrange(desc(n))
```

```
## # A tibble: 2,976 x 2
##    word      n
##    <chr> <int>
##  1 the     854
##  2 i       642
##  3 you     582
##  4 to      547
##  5 a       473
##  6 and     384
##  7 in      320
##  8 it      296
##  9 of      277
## 10 my      259
## # … with 2,966 more rows
```

Not particularly informative. We can identify a list of stopwords using `get_stopwords()` then remove them via `anti_join()`.^[I told you filtering joins would be useful one day, but you didn't believe me!]


```r
# remove stop words
hamilton_tidy <- hamilton_tidy %>%
  anti_join(get_stopwords(source = "smart"))
```

```
## Joining, by = "word"
```

```r
hamilton_tidy %>%
  count(word) %>%
  top_n(20) %>%
  ggplot(aes(fct_reorder(word, n), n)) +
  geom_col() +
  coord_flip() + 
  theme_minimal() +
  labs(
    title = "Frequency of Hamilton lyrics",
    x = NULL,
    y = NULL
  )
```

```
## Selecting by n
```

<img src="/notes/hamilton_files/figure-html/stop-remove-1.png" width="672" />

Now the words seem more relevant to the specific story being told in the musical.

## Words used most by each cast member

Since we know which singer performs each line, we can examine the relative significance of different words to different characters. [**Term frequency-inverse document frequency** (tf-idf)](https://www.tidytextmining.com/tfidf.html) is a simple metric for measuring the importance of specific words to a corpus. Here let's calculate the top ten words for each member of the principal cast.


```r
# principal cast via Wikipedia
principal_cast <- c("Hamilton", "Eliza", "Burr", "Angelica", "Washington",
                    "Lafayette", "Jefferson", "Mulligan", "Madison",
                    "Laurens", "Philip", "Peggy", "Maria", "King George")

# calculate tf-idf scores for words sung by the principal cast
hamilton_tf_idf <- hamilton_tidy %>%
  filter(speaker %in% principal_cast) %>%
  mutate(speaker = parse_factor(x = speaker, levels = principal_cast)) %>%
  count(speaker, word) %>%
  bind_tf_idf(term = word, document = speaker, n = n)

# visualize the top N terms per character by tf-idf score
hamilton_tf_idf %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(speaker) %>%
  top_n(10) %>%
  # arbitrarily reduce to only 10 for characters with tied tf-idf
  slice(1:10) %>%
  ungroup() %>%
  # resolve ambiguities when same word appears for different characters
  mutate(word = reorder_within(x = word, by = tf_idf, within = speaker)) %>%
  ggplot(mapping = aes(x = word, y = tf_idf)) +
  geom_col(show.legend = FALSE) +
  scale_x_reordered() +
  labs(
    title = "Most important words in *Hamilton*",
    subtitle = "Principal cast only",
    x = NULL,
    y = "tf-idf",
    caption = "Source: Genius API"
  ) +
  facet_wrap(~speaker, scales = "free") +
  coord_flip() +
  theme(plot.title = element_markdown())
```

```
## Selecting by tf_idf
```

<img src="/notes/hamilton_files/figure-html/tf-idf-1.png" width="672" />

Again, some expected results stick out. Hamilton is always singing about not throwing away his shot, Eliza is helplessly in love with Alexander, while Burr regrets not being "in the room where it happens". And don't forget King George's love songs to his wayward children.

<div style="width:100%;height:0;padding-bottom:90%;position:relative;"><iframe src="https://giphy.com/embed/26u6duhyJTMmLGMAE" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>

## Sentiment analysis


```r
hamilton_afinn <- hamilton_tidy %>%
  inner_join(get_sentiments(lexicon = "afinn")) %>%
  mutate(cum_sent = cumsum(value),
         id = row_number())
```

```
## Joining, by = "word"
```

```r
hamilton_afinn %>%
  group_by(song_title) %>%
  summarize(sent = sum(value)) %>%
  ggplot(mapping = aes(x = fct_rev(song_title), y = sent, fill = sent)) +
  geom_col() +
  scale_fill_viridis_c() +
  coord_flip() +
  labs(
    x = NULL,
    y = "Summative sentiment",
    color = "Summative\nsentiment"
  )
```

<img src="/notes/hamilton_files/figure-html/sentiment-1.png" width="672" />

```r
ggplot(data = hamilton_afinn, mapping = aes(x = id, y = cum_sent)) +
  ggrepel::geom_text_repel(data = hamilton_afinn %>%
                             group_by(song_number) %>%
                             filter(id == min(id)),
                           mapping = aes(label = song_title),
                           size = 3,
                           alpha = .4) +
  geom_line() +
  scale_x_continuous(breaks = NULL) +
  labs(
    x = NULL,
    y = "Cumulative sentiment"
  )
```

<img src="/notes/hamilton_files/figure-html/sentiment-2.png" width="672" />

## Pairs of words


```r
library(widyr)
library(ggraph)

hamilton_pair <- hamilton %>%
  unnest_tokens(output = word, input = line, token = "ngrams", n = 2) %>%
  separate(col = word, into = c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% get_stopwords(source = "smart")$word,
         !word2 %in% get_stopwords(source = "smart")$word) %>%
  drop_na(word1, word2) %>%
  count(word1, word2, sort = TRUE)

# filter for only relatively common combinations
bigram_graph <- hamilton_pair %>%
  filter(n > 2) %>%
  igraph::graph_from_data_frame()

set.seed(1776) # New York City
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)
```

<img src="/notes/hamilton_files/figure-html/unnamed-chunk-1-1.png" width="672" />

```r
set.seed(1776) # New York City
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), show.legend = FALSE, alpha = .5) +
  geom_node_point(color = "#0052A5", size = 3, alpha = .5) +
  geom_node_text(aes(label = name), vjust = 1.5) +
  ggtitle("Word Network in Lin-Manuel Miranda's *Hamilton*") +
  theme_void() +
  theme(plot.title = element_markdown())
```

<img src="/notes/hamilton_files/figure-html/unnamed-chunk-1-2.png" width="672" />

## Acknowledgments

* This page is derived in part from [A Sentiment Analysis of Hamilton: The broom Where it Happens / When are these #rcatladies gonna rise up?](https://seankross.com/2016/08/30/A-Sentiment-Analysis-of-Hamilton.html) and licensed under a [Creative Commons Attribution 4.0 International (CC BY 4.0) License](https://creativecommons.org/licenses/by/4.0/).
* This page is derived in part from [Alexander Hamilton: The Breakdown](https://rstudio-pubs-static.s3.amazonaws.com/516633_c5ceb17730f7453fb3422884d55b5144.html).
* This page is derived in part from [Tidytext Analysis](https://www2.stat.duke.edu/courses/Spring19/sta199.001/slides/lec-slides/14b-text-analysis.html#1) and licensed under a [Creative Commons Attribution 4.0 International (CC BY 4.0) License](https://creativecommons.org/licenses/by/4.0/).

[^lyrics]: There are a number of ways to obtain the lyrics for the entire soundtrack. [One approach](https://seankross.com/2016/08/30/A-Sentiment-Analysis-of-Hamilton.html) is to use [`rvest` and web scraping](/notes/web-scraping/) to extract the lyrics from sources online. However here I used the Genius API and [`geniusr`](https://ewenme.github.io/geniusr/) to systematically collect the lyrics from an authoritative (and legal) source. The code below was used to obtain the lyrics for all the songs. Note that you need to [authenticate using an API token](https://ewenme.github.io/geniusr/articles/geniusr.html#auth) in order to use this code.

    
    ```r
    library(geniusr)
    
    # Genius album ID number
    hamilton_id <- 131575
    
    # retrieve track list
    hamilton_tracks <- get_album_tracklist_id(album_id = hamilton_id)
    
    # retrieve song lyrics
    hamilton_lyrics <- hamilton_tracks %>%
      mutate(lyrics = map(.x = song_lyrics_url, get_lyrics_url))
    
    # unnest and clean-up
    hamilton <- hamilton_lyrics %>%
      unnest(cols = lyrics, names_repair = "universal") %>%
      select(song_number, song_title, line, section_name, song_name) %>%
      group_by(song_number) %>%
      # add line number
      mutate(line_num = row_number()) %>%
      # reorder columns and convert speaker to title case
      select(song_number, song_title, line_num, line, speaker = section_name) %>%
      mutate(speaker = str_to_title(speaker),
             line = str_replace_all(line, "’", "'")) %>%
      # write to disk
      write_csv(path = here("static", "data", "hamilton.csv"))
    ```
    
    ```
    ## New names:
    ## * song_lyrics_url -> song_lyrics_url...3
    ## * artist_name -> artist_name...7
    ## * artist_name -> artist_name...13
    ## * song_lyrics_url -> song_lyrics_url...14
    ```
    
## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.3 (2020-02-29)
##  os       macOS Catalina 10.15.4      
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-05-25                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version    date       lib source                          
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 3.6.0)                  
##  backports      1.1.7      2020-05-13 [1] CRAN (R 3.6.2)                  
##  blogdown       0.18.1     2020-04-28 [1] local                           
##  bookdown       0.18       2020-03-05 [1] CRAN (R 3.6.0)                  
##  broom          0.5.5      2020-02-29 [1] CRAN (R 3.6.0)                  
##  callr          3.4.3      2020-03-28 [1] CRAN (R 3.6.2)                  
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 3.6.0)                  
##  cli            2.0.2      2020-02-28 [1] CRAN (R 3.6.0)                  
##  codetools      0.2-16     2018-12-24 [1] CRAN (R 3.6.3)                  
##  colorspace     1.4-1      2019-03-18 [1] CRAN (R 3.6.0)                  
##  crayon         1.3.4      2017-09-16 [1] CRAN (R 3.6.0)                  
##  curl           4.3        2019-12-02 [1] CRAN (R 3.6.0)                  
##  DBI            1.1.0      2019-12-15 [1] CRAN (R 3.6.0)                  
##  dbplyr         1.4.2      2019-06-17 [1] CRAN (R 3.6.0)                  
##  desc           1.2.0      2018-05-01 [1] CRAN (R 3.6.0)                  
##  devtools       2.2.2      2020-02-17 [1] CRAN (R 3.6.0)                  
##  digest         0.6.25     2020-02-23 [1] CRAN (R 3.6.0)                  
##  dplyr        * 0.8.5      2020-03-07 [1] CRAN (R 3.6.0)                  
##  ellipsis       0.3.1      2020-05-15 [1] CRAN (R 3.6.2)                  
##  evaluate       0.14       2019-05-28 [1] CRAN (R 3.6.0)                  
##  fansi          0.4.1      2020-01-08 [1] CRAN (R 3.6.0)                  
##  farver         2.0.3      2020-01-16 [1] CRAN (R 3.6.0)                  
##  forcats      * 0.5.0      2020-03-01 [1] CRAN (R 3.6.0)                  
##  fs             1.3.2      2020-03-05 [1] CRAN (R 3.6.0)                  
##  generics       0.0.2      2018-11-29 [1] CRAN (R 3.6.0)                  
##  geniusr      * 1.2.0      2020-04-13 [1] CRAN (R 3.6.2)                  
##  ggforce        0.3.1      2019-08-20 [1] CRAN (R 3.6.0)                  
##  ggplot2      * 3.3.0      2020-03-05 [1] CRAN (R 3.6.0)                  
##  ggraph       * 2.0.2      2020-03-17 [1] CRAN (R 3.6.0)                  
##  ggrepel        0.8.2      2020-03-08 [1] CRAN (R 3.6.3)                  
##  ggtext       * 0.1.0      2020-05-21 [1] Github (wilkelab/ggtext@e978034)
##  glue           1.4.1      2020-05-13 [1] CRAN (R 3.6.2)                  
##  graphlayouts   0.6.0      2020-03-09 [1] CRAN (R 3.6.0)                  
##  gridExtra      2.3        2017-09-09 [1] CRAN (R 3.6.0)                  
##  gridtext       0.1.1      2020-02-24 [1] CRAN (R 3.6.0)                  
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 3.6.0)                  
##  haven          2.2.0      2019-11-08 [1] CRAN (R 3.6.0)                  
##  here         * 0.1        2017-05-28 [1] CRAN (R 3.6.0)                  
##  hms            0.5.3      2020-01-08 [1] CRAN (R 3.6.0)                  
##  htmltools      0.4.0      2019-10-04 [1] CRAN (R 3.6.0)                  
##  httr           1.4.1      2019-08-05 [1] CRAN (R 3.6.0)                  
##  igraph       * 1.2.5      2020-03-19 [1] CRAN (R 3.6.0)                  
##  janeaustenr    0.1.5      2017-06-10 [1] CRAN (R 3.6.0)                  
##  jsonlite       1.6.1      2020-02-02 [1] CRAN (R 3.6.0)                  
##  knitr          1.28       2020-02-06 [1] CRAN (R 3.6.0)                  
##  labeling       0.3        2014-08-23 [1] CRAN (R 3.6.0)                  
##  lattice        0.20-40    2020-02-19 [1] CRAN (R 3.6.0)                  
##  lifecycle      0.2.0      2020-03-06 [1] CRAN (R 3.6.0)                  
##  lubridate      1.7.8      2020-04-06 [1] CRAN (R 3.6.2)                  
##  magrittr       1.5        2014-11-22 [1] CRAN (R 3.6.0)                  
##  markdown       1.1        2019-08-07 [1] CRAN (R 3.6.0)                  
##  MASS           7.3-51.5   2019-12-20 [1] CRAN (R 3.6.3)                  
##  Matrix         1.2-18     2019-11-27 [1] CRAN (R 3.6.3)                  
##  memoise        1.1.0      2017-04-21 [1] CRAN (R 3.6.0)                  
##  modelr         0.1.6      2020-02-22 [1] CRAN (R 3.6.0)                  
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 3.6.0)                  
##  nlme           3.1-145    2020-03-04 [1] CRAN (R 3.6.0)                  
##  pillar         1.4.4      2020-05-05 [1] CRAN (R 3.6.2)                  
##  pkgbuild       1.0.8      2020-05-07 [1] CRAN (R 3.6.2)                  
##  pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 3.6.0)                  
##  pkgload        1.0.2      2018-10-29 [1] CRAN (R 3.6.0)                  
##  polyclip       1.10-0     2019-03-14 [1] CRAN (R 3.6.0)                  
##  prettyunits    1.1.1      2020-01-24 [1] CRAN (R 3.6.0)                  
##  processx       3.4.2      2020-02-09 [1] CRAN (R 3.6.0)                  
##  ps             1.3.3      2020-05-08 [1] CRAN (R 3.6.2)                  
##  purrr        * 0.3.4      2020-04-17 [1] CRAN (R 3.6.2)                  
##  R6             2.4.1      2019-11-12 [1] CRAN (R 3.6.0)                  
##  Rcpp           1.0.4      2020-03-17 [1] CRAN (R 3.6.0)                  
##  readr        * 1.3.1      2018-12-21 [1] CRAN (R 3.6.0)                  
##  readxl         1.3.1      2019-03-13 [1] CRAN (R 3.6.0)                  
##  remotes        2.1.1      2020-02-15 [1] CRAN (R 3.6.0)                  
##  reprex         0.3.0      2019-05-16 [1] CRAN (R 3.6.0)                  
##  rlang          0.4.6.9000 2020-05-21 [1] Github (r-lib/rlang@691b5a8)    
##  rmarkdown      2.1        2020-01-20 [1] CRAN (R 3.6.0)                  
##  rprojroot      1.3-2      2018-01-03 [1] CRAN (R 3.6.0)                  
##  rstudioapi     0.11       2020-02-07 [1] CRAN (R 3.6.0)                  
##  rvest          0.3.5      2019-11-08 [1] CRAN (R 3.6.0)                  
##  scales         1.1.1      2020-05-11 [1] CRAN (R 3.6.2)                  
##  selectr        0.4-2      2019-11-20 [1] CRAN (R 3.6.0)                  
##  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 3.6.0)                  
##  SnowballC      0.6.0      2019-01-15 [1] CRAN (R 3.6.0)                  
##  stringi        1.4.6      2020-02-17 [1] CRAN (R 3.6.0)                  
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 3.6.0)                  
##  testthat       2.3.2      2020-03-02 [1] CRAN (R 3.6.0)                  
##  tibble       * 3.0.1      2020-04-20 [1] CRAN (R 3.6.2)                  
##  tidygraph      1.1.2      2019-02-18 [1] CRAN (R 3.6.0)                  
##  tidyr        * 1.1.0      2020-05-20 [1] CRAN (R 3.6.2)                  
##  tidyselect     1.1.0      2020-05-11 [1] CRAN (R 3.6.2)                  
##  tidytext     * 0.2.3      2020-03-04 [1] CRAN (R 3.6.0)                  
##  tidyverse    * 1.3.0      2019-11-21 [1] CRAN (R 3.6.0)                  
##  tokenizers     0.2.1      2018-03-29 [1] CRAN (R 3.6.0)                  
##  tweenr         1.0.1      2018-12-14 [1] CRAN (R 3.6.0)                  
##  usethis        1.5.1      2019-07-04 [1] CRAN (R 3.6.0)                  
##  vctrs          0.3.0.9000 2020-05-21 [1] Github (r-lib/vctrs@f476e06)    
##  viridis        0.5.1      2018-03-29 [1] CRAN (R 3.6.0)                  
##  viridisLite    0.3.0      2018-02-01 [1] CRAN (R 3.6.0)                  
##  widyr        * 0.1.2      2019-09-09 [1] CRAN (R 3.6.0)                  
##  withr          2.2.0      2020-04-20 [1] CRAN (R 3.6.2)                  
##  xfun           0.14       2020-05-20 [1] CRAN (R 3.6.2)                  
##  xml2           1.3.2      2020-04-23 [1] CRAN (R 3.6.2)                  
##  yaml           2.2.1      2020-02-01 [1] CRAN (R 3.6.0)                  
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
