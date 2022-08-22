---
title: "Writing API queries"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/webdata003_api_by_hand.html", "/notes/write-an-api-function/"]
categories: ["webdata"]

weight: 63
---




```r
library(tidyverse)
library(stringr)
library(jsonlite)
library(httr)

theme_set(theme_minimal())
```

What happens if someone has not already written a package for the API from which we want to obtain data? We have to write our own function!

First we're going to examine the structure of API requests via the [Open Movie Database](http://www.omdbapi.com/). OMDb is very similar to IMDB, except it has a nice, simple API. We can go to the website, input some search parameters, and obtain both the JSON query and the response from it. 

## Constructing the API GET Request

Likely the most challenging part of using web APIs is learning how to format your GET request URLs. While there are common architectures for such URLs, each API has its own unique quirks. For this reason, carefully reviewing the API documentation is critical.

Most GET request URLs for API querying have three or four components:

1. **Authentication Key/Token**: A user-specific character string appended to a base URL telling the server who is making the query; allows servers to efficiently manage database access.
1. **Base URL**: A link stub that will be at the beginning of all calls to a given API; points the server to the location of an entire database.
1. **Search Parameters**: A character string appended to a base URL that tells the server what to extract from the database; basically a series of filters used to point to specific parts of a database.
1. **Response Format**: A character string indicating how the response should be formatted; usually one of `.csv`, `.json`, or `.xml`.

## Determining the shape of the API request

You can play around with the parameters on the [OMDB website](http://www.omdbapi.com/), and look at the resulting API call and the query you get back:

{{< figure src="ombd.png" caption="" >}}

Let's experiment with different values of the `title` and `year` fields. Notice the pattern in the request. For example let's consider the 2013 television disaster thriller *Sharknado*:

{{< youtube 9LmAEVdPhl4 >}}

Given the Title "Sharknado" and the release year "2013", we get:

``` http
http://www.omdbapi.com/?apikey=[apikey]&t=Sharknado&y=2013
```

{{% callout note %}}

The OMDB API used to be free, however in the past year shifted to a private API key due to overwhelming traffic. See in class for a demo API key you can use.

{{% /callout %}}


```r
omdb_key <- getOption("omdb_key")
```

How can we create this request in R?

## `httr::GET()`

`httr` is yet another star in the `tidyverse`, this one designed to facilitate all things HTTP from within R. This includes the major HTTP verbs, most importantly GET. HTTP is the foundation for APIs; understanding how it works is the key to interacting with all the diverse APIs out there.[^api-guide]

`httr` contains one function for every HTTP verb. The functions have the same names as the verbs (e.g. `GET()`, `POST()`). They have more informative outputs than simply using `curl`, and come with some nice convenience functions for working with the output.

To construct our query, we provide the **base URL** for the API. This is typically determined by reading the API's documentation. Additional search parameters are passed as a list object to the `query` argument. The name of each parameter is defined by the API. Here, we call these arguments `t`, `y`, and `apikey`.


```r
sharknado <- GET(
  url = "http://www.omdbapi.com/?",
  query = list(
    t = "Sharknado",
    y = 2013,
    apikey = omdb_key
  )
)
```

## Parsing the result

We can read the content of the server's response using the `content()` function:


```r
content(sharknado, type = "text") %>%
  # print the contents in a clear structure
  prettify()
```

```
## No encoding supplied: defaulting to UTF-8.
```

```
## {
##     "Title": "Sharknado",
##     "Year": "2013",
##     "Rated": "Not Rated",
##     "Released": "11 Jul 2013",
##     "Runtime": "86 min",
##     "Genre": "Action, Adventure, Comedy",
##     "Director": "Anthony C. Ferrante",
##     "Writer": "Thunder Levin",
##     "Actors": "Ian Ziering, Tara Reid, John Heard",
##     "Plot": "When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace.",
##     "Language": "English",
##     "Country": "United States",
##     "Awards": "1 win & 2 nominations",
##     "Poster": "https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg",
##     "Ratings": [
##         {
##             "Source": "Internet Movie Database",
##             "Value": "3.3/10"
##         },
##         {
##             "Source": "Rotten Tomatoes",
##             "Value": "74%"
##         }
##     ],
##     "Metascore": "N/A",
##     "imdbRating": "3.3",
##     "imdbVotes": "49,549",
##     "imdbID": "tt2724064",
##     "Type": "movie",
##     "DVD": "03 Sep 2013",
##     "BoxOffice": "N/A",
##     "Production": "N/A",
##     "Website": "N/A",
##     "Response": "True"
## }
## 
```

What you can see here is **J**ava**S**cript **O**bject **N**otation and e**X**tensible **M**arkup **L**anguage (JSON) text encoded as plain text. JSON is a format for storing data like a nested array (list) built on key/value pairs.

We want to convert the results from JSON format to something easier to work with - notably a data frame. For relatively simple API queries, one can use `as_tibble()` to convert the output to a data frame:


```r
sharknado_df <- content(sharknado) %>%
  as_tibble()
sharknado_df
```

```
## # A tibble: 2 × 25
##   Title    Year  Rated Relea…¹ Runtime Genre Direc…² Writer Actors Plot  Langu…³
##   <chr>    <chr> <chr> <chr>   <chr>   <chr> <chr>   <chr>  <chr>  <chr> <chr>  
## 1 Sharkna… 2013  Not … 11 Jul… 86 min  Acti… Anthon… Thund… Ian Z… When… English
## 2 Sharkna… 2013  Not … 11 Jul… 86 min  Acti… Anthon… Thund… Ian Z… When… English
## # … with 14 more variables: Country <chr>, Awards <chr>, Poster <chr>,
## #   Ratings <list>, Metascore <chr>, imdbRating <chr>, imdbVotes <chr>,
## #   imdbID <chr>, Type <chr>, DVD <chr>, BoxOffice <chr>, Production <chr>,
## #   Website <chr>, Response <chr>, and abbreviated variable names ¹​Released,
## #   ²​Director, ³​Language
## # ℹ Use `colnames()` to see all variable names
```

{{% callout note %}}

Note there are two rows of observations when we would have expected a single row (only one movie). [We'll get to this shortly.](/notes/simplify-nested-lists)

{{% /callout %}}

## Additional information from `GET()`

In addition, `GET()` gives us access to lots of useful information about the quality of our response. For example, the URL that was constructed to generate the query:


```r
sharknado$url
```


```
## [1] "http://www.omdbapi.com/?t=Sharknado&y=2013&apikey=[apikey]"
```

We can also extract the HTTP status code from the query:


```r
status_code(sharknado)
```

```
## [1] 200
```

Status codes are useful indications of how the query was handled by the server and are important for troubleshooting issues when you do not receive the intended response.

Code[^status] | Status
-------|--------|
1xx    | Informational
2xx    | Success
3xx    | Redirection
4xx    | Client error (you did something wrong)
5xx    | Server error (server did something wrong)

{{% callout note %}}

[(Perhaps a more intuitive, cat-based explanation of error codes)](https://www.flickr.com/photos/girliemac/sets/72157628409467125).

{{% /callout %}}

## Iteration through a set of movies

What if we want to obtain results for multiple movies? Consider the entire Sharknado franchise which contains five films. How can we search iteratively over all of these films?

First let's write a function that passes a search term and returns a data frame of the OMDB results:


```r
omdb_api <- function(title, api_key) {
  # send GET request
  response <- GET(
    url = "http://www.omdbapi.com/?",
    query = list(
      t = title,
      apikey = api_key
    )
  )

  # parse response to JSON
  response_df <- content(response) %>%
    as_tibble()

  # print a message to track progress
  message(glue::glue("Scraping {title}..."))

  return(response_df)
}
```

Now we need to construct the list of movies to search over.


```r
sharknados <- c(
  "Sharknado", "Sharknado 2", "Sharknado 3",
  "Sharknado 4", "Sharknado 5"
)
```

Finally we can apply the function to each film. To avoid overwhelming the server with too many queries, we can slow down the iteration using `slowly()`.


```r
# modify function to delay by one second
omdb_api_slow <- slowly(f = omdb_api, rate = rate_delay(1))

# iterate over all the films
sharknados_df <- map_dfr(.x = sharknados, .f = omdb_api_slow, api_key = getOption("omdb_key"))
```

```
## Scraping Sharknado...
```

```
## Scraping Sharknado 2...
```

```
## Scraping Sharknado 3...
```

```
## Scraping Sharknado 4...
```

```
## Scraping Sharknado 5...
```

```r
sharknados_df
```

```
## # A tibble: 10 × 25
##    Title   Year  Rated Relea…¹ Runtime Genre Direc…² Writer Actors Plot  Langu…³
##    <chr>   <chr> <chr> <chr>   <chr>   <chr> <chr>   <chr>  <chr>  <chr> <chr>  
##  1 Sharkn… 2013  Not … 11 Jul… 86 min  Acti… Anthon… Thund… Ian Z… When… English
##  2 Sharkn… 2013  Not … 11 Jul… 86 min  Acti… Anthon… Thund… Ian Z… When… English
##  3 Sharkn… 2014  TV-14 30 Jul… 95 min  Acti… Anthon… Thund… Ian Z… Fin … English
##  4 Sharkn… 2014  TV-14 30 Jul… 95 min  Acti… Anthon… Thund… Ian Z… Fin … English
##  5 Sharkn… 2015  TV-14 22 Jul… 93 min  Acti… Anthon… Thund… Ian Z… A mo… English
##  6 Sharkn… 2015  TV-14 22 Jul… 93 min  Acti… Anthon… Thund… Ian Z… A mo… English
##  7 Sharkn… 2016  TV-14 31 Jul… 95 min  Acti… Anthon… Thund… Ian Z… Fin,… English
##  8 Sharkn… 2016  TV-14 31 Jul… 95 min  Acti… Anthon… Thund… Ian Z… Fin,… English
##  9 Sharkn… 2017  TV-14 06 Aug… 93 min  Acti… Anthon… Thund… Ian Z… With… English
## 10 Sharkn… 2017  TV-14 06 Aug… 93 min  Acti… Anthon… Thund… Ian Z… With… English
## # … with 14 more variables: Country <chr>, Awards <chr>, Poster <chr>,
## #   Ratings <list>, Metascore <chr>, imdbRating <chr>, imdbVotes <chr>,
## #   imdbID <chr>, Type <chr>, DVD <chr>, BoxOffice <chr>, Production <chr>,
## #   Website <chr>, Response <chr>, and abbreviated variable names ¹​Released,
## #   ²​Director, ³​Language
## # ℹ Use `colnames()` to see all variable names
```

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).

- Iterative operation drawn from Rochelle Terman's [Collecting Data from the Web](https://plsc-31101.github.io/course/collecting-data-from-the-web.html)

## Session Info



```r
sessioninfo::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.2.1 (2022-06-23)
##  os       macOS Monterey 12.3
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/New_York
##  date     2022-08-22
##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  assertthat      0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown        1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  cli             3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs              1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2       * 3.3.6      2022-05-03 [2] CRAN (R 4.2.0)
##  glue            1.6.2      2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive     2.0.0      2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4   1.0.0      2021-07-21 [2] CRAN (R 4.2.0)
##  gtable          0.3.0      2019-03-25 [2] CRAN (R 4.2.0)
##  haven           2.5.0      2022-04-15 [2] CRAN (R 4.2.0)
##  here            1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  hms             1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools       0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr          * 1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite      * 1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr           1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate       1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr          0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6              2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  readr         * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl          1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex          2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  rlang           1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown       2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest           1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo     1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  stringi         1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  utf8            1.2.2      2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs           0.4.1      2022-04-13 [2] CRAN (R 4.2.0)
##  withr           2.5.0      2022-03-03 [2] CRAN (R 4.2.0)
##  xfun            0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2            1.3.3      2021-11-30 [2] CRAN (R 4.2.0)
##  yaml            2.3.5      2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```

[^api-guide]: An excellent beginning resource for APIs (including HTTP basics) is [this simple guide](https://zapier.com/learn/apis/).
[^status]: [HTTP Status Codes](http://www.restapitutorial.com/httpstatuscodes.html).
