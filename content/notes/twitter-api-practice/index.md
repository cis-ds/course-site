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

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/getting-data-from-the-web-api-access")
```

{{% /callout %}}

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

{{% callout warning %}}

Students using the [RStudio Server](/setup/r-server/) will not be able to follow this authentication process since you cannot run an interactive session of R that connects to your web browser. Instead, I will provide you with a script during class that you can run to create your token.

{{% /callout %}}

## Searching tweets

To find 3000 recent tweets using the "rstats" hashtag:


```r
rt <- search_tweets(
  q = "#rstats",
  n = 3000,
  include_rts = FALSE
)
rt
```

```
## # A tibble: 2,998 x 90
##    user_id status_id created_at          screen_name text  source
##    <chr>   <chr>     <dttm>              <chr>       <chr> <chr> 
##  1 120362… 13389047… 2020-12-15 17:52:12 icymi_r     "✍️🖥… OneUp…
##  2 120362… 13383791… 2020-12-14 07:03:43 icymi_r     "✍️🚲… OneUp…
##  3 120362… 13375125… 2020-12-11 21:40:15 icymi_r     "✍️ … OneUp…
##  4 120362… 13381597… 2020-12-13 16:32:07 icymi_r     "📦 \… OneUp…
##  5 120362… 13378834… 2020-12-12 22:14:06 icymi_r     "✍️📊… OneUp…
##  6 120362… 13382856… 2020-12-14 00:52:09 icymi_r     "📦🗣️… OneUp…
##  7 120362… 13379146… 2020-12-13 00:18:08 icymi_r     "📦👥 … OneUp…
##  8 120362… 13375744… 2020-12-12 01:46:14 icymi_r     "✍️🗺… OneUp…
##  9 120362… 13380384… 2020-12-13 08:30:10 icymi_r     "✍️\… OneUp…
## 10 120362… 13376977… 2020-12-12 09:56:07 icymi_r     "✍️ … OneUp…
## # … with 2,988 more rows, and 84 more variables: display_text_width <dbl>,
## #   reply_to_status_id <chr>, reply_to_user_id <chr>,
## #   reply_to_screen_name <chr>, is_quote <lgl>, is_retweet <lgl>,
## #   favorite_count <int>, retweet_count <int>, quote_count <int>,
## #   reply_count <int>, hashtags <list>, symbols <list>, urls_url <list>,
## #   urls_t.co <list>, urls_expanded_url <list>, media_url <list>,
## #   media_t.co <list>, media_expanded_url <list>, media_type <list>,
## #   ext_media_url <list>, ext_media_t.co <list>, ext_media_expanded_url <list>,
## #   ext_media_type <chr>, mentions_user_id <list>, mentions_screen_name <list>,
## #   lang <chr>, quoted_status_id <chr>, quoted_text <chr>,
## #   quoted_created_at <dttm>, quoted_source <chr>, quoted_favorite_count <int>,
## #   quoted_retweet_count <int>, quoted_user_id <chr>, quoted_screen_name <chr>,
## #   quoted_name <chr>, quoted_followers_count <int>,
## #   quoted_friends_count <int>, quoted_statuses_count <int>,
## #   quoted_location <chr>, quoted_description <chr>, quoted_verified <lgl>,
## #   retweet_status_id <chr>, retweet_text <chr>, retweet_created_at <dttm>,
## #   retweet_source <chr>, retweet_favorite_count <int>,
## #   retweet_retweet_count <int>, retweet_user_id <chr>,
## #   retweet_screen_name <chr>, retweet_name <chr>,
## #   retweet_followers_count <int>, retweet_friends_count <int>,
## #   retweet_statuses_count <int>, retweet_location <chr>,
## #   retweet_description <chr>, retweet_verified <lgl>, place_url <chr>,
## #   place_name <chr>, place_full_name <chr>, place_type <chr>, country <chr>,
## #   country_code <chr>, geo_coords <list>, coords_coords <list>,
## #   bbox_coords <list>, status_url <chr>, name <chr>, location <chr>,
## #   description <chr>, url <chr>, protected <lgl>, followers_count <int>,
## #   friends_count <int>, listed_count <int>, statuses_count <int>,
## #   favourites_count <int>, account_created_at <dttm>, verified <lgl>,
## #   profile_url <chr>, profile_expanded_url <chr>, account_lang <lgl>,
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
## # A tibble: 1,000 x 90
##    user_id status_id created_at          screen_name text  source
##    <chr>   <chr>     <dttm>              <chr>       <chr> <chr> 
##  1 555129… 13388802… 2020-12-15 16:14:49 CountVonCo… Two … Count…
##  2 555129… 13385933… 2020-12-14 21:14:48 CountVonCo… Two … Count…
##  3 555129… 13382762… 2020-12-14 00:14:46 CountVonCo… Two … Count…
##  4 555129… 13381101… 2020-12-13 13:14:46 CountVonCo… Two … Count…
##  5 555129… 13379440… 2020-12-13 02:14:45 CountVonCo… Two … Count…
##  6 555129… 13377930… 2020-12-12 16:14:44 CountVonCo… Two … Count…
##  7 555129… 13375514… 2020-12-12 00:14:43 CountVonCo… Two … Count…
##  8 555129… 13374910… 2020-12-11 20:14:43 CountVonCo… Two … Count…
##  9 555129… 13373853… 2020-12-11 13:14:42 CountVonCo… Two … Count…
## 10 555129… 13372041… 2020-12-11 01:14:42 CountVonCo… Two … Count…
## # … with 990 more rows, and 84 more variables: display_text_width <dbl>,
## #   reply_to_status_id <lgl>, reply_to_user_id <lgl>,
## #   reply_to_screen_name <lgl>, is_quote <lgl>, is_retweet <lgl>,
## #   favorite_count <int>, retweet_count <int>, quote_count <int>,
## #   reply_count <int>, hashtags <list>, symbols <list>, urls_url <list>,
## #   urls_t.co <list>, urls_expanded_url <list>, media_url <list>,
## #   media_t.co <list>, media_expanded_url <list>, media_type <list>,
## #   ext_media_url <list>, ext_media_t.co <list>, ext_media_expanded_url <list>,
## #   ext_media_type <chr>, mentions_user_id <list>, mentions_screen_name <list>,
## #   lang <chr>, quoted_status_id <chr>, quoted_text <chr>,
## #   quoted_created_at <dttm>, quoted_source <chr>, quoted_favorite_count <int>,
## #   quoted_retweet_count <int>, quoted_user_id <chr>, quoted_screen_name <chr>,
## #   quoted_name <chr>, quoted_followers_count <int>,
## #   quoted_friends_count <int>, quoted_statuses_count <int>,
## #   quoted_location <chr>, quoted_description <chr>, quoted_verified <lgl>,
## #   retweet_status_id <chr>, retweet_text <chr>, retweet_created_at <dttm>,
## #   retweet_source <chr>, retweet_favorite_count <int>,
## #   retweet_retweet_count <int>, retweet_user_id <chr>,
## #   retweet_screen_name <chr>, retweet_name <chr>,
## #   retweet_followers_count <int>, retweet_friends_count <int>,
## #   retweet_statuses_count <int>, retweet_location <chr>,
## #   retweet_description <chr>, retweet_verified <lgl>, place_url <chr>,
## #   place_name <chr>, place_full_name <chr>, place_type <chr>, country <chr>,
## #   country_code <chr>, geo_coords <list>, coords_coords <list>,
## #   bbox_coords <list>, status_url <chr>, name <chr>, location <chr>,
## #   description <chr>, url <lgl>, protected <lgl>, followers_count <int>,
## #   friends_count <int>, listed_count <int>, statuses_count <int>,
## #   favourites_count <int>, account_created_at <dttm>, verified <lgl>,
## #   profile_url <chr>, profile_expanded_url <chr>, account_lang <lgl>,
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

<img src="{{< blogdown/postref >}}index_files/figure-html/rstats-freq-1.png" width="672" />

The `by` argument allows us to aggregate over different lengths of time.


```r
ts_plot(rt, by = "1 hours")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/rstats-freq-day-1.png" width="672" />

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

<img src="{{< blogdown/postref >}}index_files/figure-html/rstats-freq-clean-1.png" width="672" />

## Exercise: Practice using `rtweet`

1. Find the 1000 most recent tweets by [Katy Perry](https://twitter.com/katyperry), [Kim Kardashian West](https://twitter.com/KimKardashian), and [Ariana Grande](https://twitter.com/ArianaGrande).
1. Visualize their tweet frequency by week. Who posts most often? Who posts least often?

    {{< spoiler text="Click for the solution" >}}


```r
popstars <- get_timelines(
  user = c("katyperry", "KimKardashian", "ArianaGrande"),
  n = 1000
)

popstars %>%
  group_by(screen_name) %>%
  ts_plot(by = "week")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/twitter-popstars-1.png" width="672" />

    {{< /spoiler >}}

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
* OAuth token storage derived from ["Obtaining and using access tokens"](http://rtweet.info/articles/auth.html).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.3 (2020-10-10)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-01-21                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source                              
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports     1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown      1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown      0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom       * 0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  cli           2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace    2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr        2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr       * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics      0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2     * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools     0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate     1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  pillar        1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx      3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps            1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  Rcpp          1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr       * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes       2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown     2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest         0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat      3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble      * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr       * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis       2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun          0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
