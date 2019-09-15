---
title: "Practice getting data from the Twitter API"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/webdata002_twitter_exercise.html"]
categories: ["webdata"]

menu:
  notes:
    parent: Getting data from the web
    weight: 2
---




```r
library(tidyverse)
library(broom)

set.seed(1234)
theme_set(theme_minimal())
```

There are several packages for R for accessing and searching Twitter. Twitter actually has two separate APIs:

1. The **REST** API - this allows you programmatic access to read and write Twitter data. For research purposes, this allows you to search the recent history of tweets and look up specific users.
1. The **Streaming** API - this allows you to access the public data flowing through Twitter in real-time. It requires your R session to be running continuously, but allows you to capture a much larger sample of tweets while avoiding rate limits for the REST API.

Popular packages for the Twitter API in R include:

* [`twitteR`](https://cran.rstudio.com/web/packages/twitteR/index.html) is the most popular package for R, but it only allows you to access the REST API. It is also deprecated (not actively updated), in lieu of a new up-and-coming package (identified below)
* [`streamR`](https://cran.rstudio.com/web/packages/streamR/index.html) is more complicated, but allows you to query the Streaming API from R. It is ancient in computational terms (last updated in January 2014), but does what it needs to do.
* [`rtweet`](http://rtweet.info/) is a relatively recent addition to the R package universe that allows you to access both the REST and streaming APIs.

## Using `rtweet`

Here, we are going to practice using the `rtweet` package to search Twitter.

```r
install.packages("rtweet")
```


```r
library(rtweet)
```

```
## 
## Attaching package: 'rtweet'
```

```
## The following object is masked from 'package:purrr':
## 
##     flatten
```

## OAuth authentication

All you need is a **Twitter account** (user name and password) and you can be up in running in minutes!

Simply send a request to Twitter's API (with a function like `search_tweets()`, `get_timeline()`, `get_followers()`, `get_favorites()`, etc.) during an interactive session of R, authorize the embedded **`rstats2twitter`** app (approve the browser popup), and your token will be created and saved/stored (for future sessions) for you!

{{% alert note %}}

According to the developer of `rtweet`, it is no longer necessary to obtain a developer account and create your own Twitter application to use Twitter's API. You do need a regular Twitter account, but should not have to create your own developer account unless you intend to heavily use the Twitter API. To setup your own developer account and store your API credentials, [view the documentation.](https://rtweet.info/articles/auth.html)

{{% /alert %}}

## Searching tweets

To find 3000 recent tweets using the "rstats" hashtag:


```r
rt <- search_tweets(
  q = "#rstats",
  n = 3000,
  include_rts = FALSE
)
```

```
## Searching for tweets...
```

```
## Finished collecting tweets!
```

```r
rt
```

```
## # A tibble: 2,943 x 88
##    user_id status_id created_at          screen_name text  source
##    <chr>   <chr>     <dttm>              <chr>       <chr> <chr> 
##  1 619751… 11113265… 2019-03-28 17:57:48 azzyazal    Cool… Twitt…
##  2 469367… 11113252… 2019-03-28 17:52:41 ebovee09    If y… Twitt…
##  3 887318… 11113250… 2019-03-28 17:52:03 geospacedm… Asth… Twitt…
##  4 887318… 11090213… 2019-03-22 09:17:54 geospacedm… In m… Twitt…
##  5 174434… 11113248… 2019-03-28 17:51:12 tjmahr      dply… Twitt…
##  6 174434… 11087644… 2019-03-21 16:16:50 tjmahr      "I t… Twitt…
##  7 174434… 11091554… 2019-03-22 18:10:41 tjmahr      I've… Twitt…
##  8 174434… 11087684… 2019-03-21 16:32:56 tjmahr      "# g… Twitt…
##  9 343389… 11109362… 2019-03-27 16:06:51 datavisFri… @_Co… Twitt…
## 10 343389… 11113238… 2019-03-28 17:47:19 datavisFri… Anot… Twitt…
## # … with 2,933 more rows, and 82 more variables: display_text_width <dbl>,
## #   reply_to_status_id <chr>, reply_to_user_id <chr>,
## #   reply_to_screen_name <chr>, is_quote <lgl>, is_retweet <lgl>,
## #   favorite_count <int>, retweet_count <int>, hashtags <list>,
## #   symbols <list>, urls_url <list>, urls_t.co <list>,
## #   urls_expanded_url <list>, media_url <list>, media_t.co <list>,
## #   media_expanded_url <list>, media_type <list>, ext_media_url <list>,
## #   ext_media_t.co <list>, ext_media_expanded_url <list>,
## #   ext_media_type <chr>, mentions_user_id <list>,
## #   mentions_screen_name <list>, lang <chr>, quoted_status_id <chr>,
## #   quoted_text <chr>, quoted_created_at <dttm>, quoted_source <chr>,
## #   quoted_favorite_count <int>, quoted_retweet_count <int>,
## #   quoted_user_id <chr>, quoted_screen_name <chr>, quoted_name <chr>,
## #   quoted_followers_count <int>, quoted_friends_count <int>,
## #   quoted_statuses_count <int>, quoted_location <chr>,
## #   quoted_description <chr>, quoted_verified <lgl>,
## #   retweet_status_id <chr>, retweet_text <chr>,
## #   retweet_created_at <dttm>, retweet_source <chr>,
## #   retweet_favorite_count <int>, retweet_retweet_count <int>,
## #   retweet_user_id <chr>, retweet_screen_name <chr>, retweet_name <chr>,
## #   retweet_followers_count <int>, retweet_friends_count <int>,
## #   retweet_statuses_count <int>, retweet_location <chr>,
## #   retweet_description <chr>, retweet_verified <lgl>, place_url <chr>,
## #   place_name <chr>, place_full_name <chr>, place_type <chr>,
## #   country <chr>, country_code <chr>, geo_coords <list>,
## #   coords_coords <list>, bbox_coords <list>, status_url <chr>,
## #   name <chr>, location <chr>, description <chr>, url <chr>,
## #   protected <lgl>, followers_count <int>, friends_count <int>,
## #   listed_count <int>, statuses_count <int>, favourites_count <int>,
## #   account_created_at <dttm>, verified <lgl>, profile_url <chr>,
## #   profile_expanded_url <chr>, account_lang <chr>,
## #   profile_banner_url <chr>, profile_background_url <chr>,
## #   profile_image_url <chr>
```

* `q` - the search query
* `n` - maximum number of tweets to be returned
* `include_rts = FALSE` - exclude retweets generated by Twitter's built-in "retweet" function. We only want original tweets.

The resulting object is a `tibble` data frame with one row for each tweet. The data frame contains the full text of the tweet (`text`), the username of the poster (`screen_name`), as well as a wealth of metadata.

Note that the Twitter REST API limits all searches to the past 6-9 days. **You will not retrieve any earlier results.**

## Searching users

Use `get_timeline()` or `get_timelines()` to retrieve tweets from one or more specified Twitter users. This only works for users with public profiles or those that have authorized your app.


```r
countvoncount <- get_timeline(user = "countvoncount", n = 1000)
countvoncount
```

```
## # A tibble: 1,000 x 88
##    user_id status_id created_at          screen_name text  source
##    <chr>   <chr>     <dttm>              <chr>       <chr> <chr> 
##  1 555129… 10969201… 2019-02-16 23:52:00 CountVonCo… Two … Count…
##  2 555129… 10968597… 2019-02-16 19:51:59 CountVonCo… Two … Count…
##  3 555129… 10965575… 2019-02-15 23:51:03 CountVonCo… Two … Count…
##  4 555129… 10961514… 2019-02-14 20:57:24 CountVonCo… Two … Count…
##  5 555129… 10960910… 2019-02-14 16:57:23 CountVonCo… Two … Count…
##  6 555129… 10957986… 2019-02-13 21:35:28 CountVonCo… Two … Count…
##  7 555129… 10954232… 2019-02-12 20:43:53 CountVonCo… Two … Count…
##  8 555129… 10953628… 2019-02-12 16:43:52 CountVonCo… Two … Count…
##  9 555129… 10951245… 2019-02-12 00:56:53 CountVonCo… Two … Count…
## 10 555129… 10949886… 2019-02-11 15:56:52 CountVonCo… Two … Count…
## # … with 990 more rows, and 82 more variables: display_text_width <dbl>,
## #   reply_to_status_id <lgl>, reply_to_user_id <lgl>,
## #   reply_to_screen_name <lgl>, is_quote <lgl>, is_retweet <lgl>,
## #   favorite_count <int>, retweet_count <int>, hashtags <list>,
## #   symbols <list>, urls_url <list>, urls_t.co <list>,
## #   urls_expanded_url <list>, media_url <list>, media_t.co <list>,
## #   media_expanded_url <list>, media_type <list>, ext_media_url <list>,
## #   ext_media_t.co <list>, ext_media_expanded_url <list>,
## #   ext_media_type <chr>, mentions_user_id <list>,
## #   mentions_screen_name <list>, lang <chr>, quoted_status_id <chr>,
## #   quoted_text <chr>, quoted_created_at <dttm>, quoted_source <chr>,
## #   quoted_favorite_count <int>, quoted_retweet_count <int>,
## #   quoted_user_id <chr>, quoted_screen_name <chr>, quoted_name <chr>,
## #   quoted_followers_count <int>, quoted_friends_count <int>,
## #   quoted_statuses_count <int>, quoted_location <chr>,
## #   quoted_description <chr>, quoted_verified <lgl>,
## #   retweet_status_id <chr>, retweet_text <chr>,
## #   retweet_created_at <dttm>, retweet_source <chr>,
## #   retweet_favorite_count <int>, retweet_retweet_count <int>,
## #   retweet_user_id <chr>, retweet_screen_name <chr>, retweet_name <chr>,
## #   retweet_followers_count <int>, retweet_friends_count <int>,
## #   retweet_statuses_count <int>, retweet_location <chr>,
## #   retweet_description <chr>, retweet_verified <lgl>, place_url <chr>,
## #   place_name <chr>, place_full_name <chr>, place_type <chr>,
## #   country <chr>, country_code <chr>, geo_coords <list>,
## #   coords_coords <list>, bbox_coords <list>, status_url <chr>,
## #   name <chr>, location <chr>, description <chr>, url <lgl>,
## #   protected <lgl>, followers_count <int>, friends_count <int>,
## #   listed_count <int>, statuses_count <int>, favourites_count <int>,
## #   account_created_at <dttm>, verified <lgl>, profile_url <chr>,
## #   profile_expanded_url <chr>, account_lang <chr>,
## #   profile_banner_url <chr>, profile_background_url <chr>,
## #   profile_image_url <chr>
```

With `get_timelines()`, you are not limited to only the most recent 6-9 days of tweets.

## Visualizing tweets

Because the resulting objects are data frames, you can perform standard data transformation, summarization, and visualization on the underlying data.

`rtweet` includes the `ts_plot()` function which automates some common time series visualization methods. For example, we can quickly visualize the frequency of `#rstats` tweets:


```r
ts_plot(rt, by = "3 hours")
```

<img src="/notes/twitter-api-practice_files/figure-html/rstats-freq-1.png" width="672" />

The `by` argument allows us to aggregate over different lengths of time.


```r
ts_plot(rt, by = "1 hours")
```

<img src="/notes/twitter-api-practice_files/figure-html/rstats-freq-day-1.png" width="672" />

And because `ts_plot()` uses `ggplot2`, we can modify the graphs using familiar `ggplot2` functions:


```r
ts_plot(rt, by = "3 hours") +
  theme(plot.title = element_text(face = "bold")) +
  labs(
    x = NULL, y = NULL,
    title = "Frequency of #rstats Twitter statuses from past 9 days",
    subtitle = "Twitter status (tweet) counts aggregated using three-hour intervals",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )
```

<img src="/notes/twitter-api-practice_files/figure-html/rstats-freq-clean-1.png" width="672" />

## Exercise: Practice using `rtweet`

1. Create a new R project on your computer. You can use Git or not - it is just for practice in class today
1. Find the 1000 most recent tweets by [Katy Perry](https://twitter.com/katyperry), [Kim Kardashian West](https://twitter.com/KimKardashian), and [Ariana Grande](https://twitter.com/ArianaGrande).
1. Visualize their tweet frequency by week. Who posts most often? Who posts least often?

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
popstars <- get_timelines(
  user = c("katyperry", "KimKardashian", "ArianaGrande"),
  n = 1000
)

popstars %>%
  group_by(screen_name) %>%
  ts_plot(by = "week")
```

<img src="/notes/twitter-api-practice_files/figure-html/twitter-popstars-1.png" width="672" />
    
  </p>
</details>

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
* OAuth token storage derived from ["Obtaining and using access tokens"](http://rtweet.info/articles/auth.html).

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
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom       * 0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
