---
title: "Writing API queries"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/webdata003_api_by_hand.html"]
categories: ["webdata"]

menu:
  notes:
    parent: Getting data from the web
    weight: 3
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

![](/img/ombd.png)

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

`httr` is yet another star in the `tidyverse`, this one designed to facilitate all things HTTP from within R. This includes the major HTTP verbs, most importantly GET. HTTP is the foundation for APIs; understanding how it works is the key to interacting with all the diverse APIs out there.^[An excellent beginning resource for APIs (including HTTP basics) is [this simple guide](https://zapier.com/learn/apis/).]

`httr` contains one function for every HTTP verb. The functions have the same names as the verbs (e.g. `GET()`, `POST()`). They have more informative outputs than simply using `curl`, and come with some nice convenience functions for working with the output.

To construct our query, we provide the **base URL** for the API. This is typically determined by reading the API's documentation. Additional search parameters are passed as a list object to the `query` argument. The name of each parameter is defined by the API. Here, we call these arguments `t`, `y`, and `apikey`.


```r
sharknado <- GET(url = "http://www.omdbapi.com/?",
    query = list(t = "Sharknado",
                 y = 2013,
                 apikey = omdb_key)
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
##     "Rated": "TV-14",
##     "Released": "11 Jul 2013",
##     "Runtime": "86 min",
##     "Genre": "Action, Adventure, Comedy, Horror, Sci-Fi, Thriller",
##     "Director": "Anthony C. Ferrante",
##     "Writer": "Thunder Levin",
##     "Actors": "Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo",
##     "Plot": "When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace.",
##     "Language": "English",
##     "Country": "USA",
##     "Awards": "1 win & 2 nominations.",
##     "Poster": "https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg",
##     "Ratings": [
##         {
##             "Source": "Internet Movie Database",
##             "Value": "3.3/10"
##         },
##         {
##             "Source": "Rotten Tomatoes",
##             "Value": "78%"
##         }
##     ],
##     "Metascore": "N/A",
##     "imdbRating": "3.3",
##     "imdbVotes": "46,218",
##     "imdbID": "tt2724064",
##     "Type": "movie",
##     "DVD": "N/A",
##     "BoxOffice": "N/A",
##     "Production": "The Asylum, Southward Films",
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
## # A tibble: 2 x 25
##   Title Year  Rated Released Runtime Genre Director Writer Actors Plot  Language
##   <chr> <chr> <chr> <chr>    <chr>   <chr> <chr>    <chr>  <chr>  <chr> <chr>   
## 1 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When… English 
## 2 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When… English 
## # … with 14 more variables: Country <chr>, Awards <chr>, Poster <chr>,
## #   Ratings <list>, Metascore <chr>, imdbRating <chr>, imdbVotes <chr>,
## #   imdbID <chr>, Type <chr>, DVD <chr>, BoxOffice <chr>, Production <chr>,
## #   Website <chr>, Response <chr>
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

Code^[[HTTP Status Codes](http://www.restapitutorial.com/httpstatuscodes.html)] | Status
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
omdb_api <- function(title, api_key){
  # send GET request
  response <- GET(url = "http://www.omdbapi.com/?",
    query = list(t = title,
                 apikey = api_key)
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
sharknados <- c("Sharknado", "Sharknado 2", "Sharknado 3",
                "Sharknado 4", "Sharknado 5")
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
## # A tibble: 10 x 25
##    Title Year  Rated Released Runtime Genre Director Writer Actors Plot 
##    <chr> <chr> <chr> <chr>    <chr>   <chr> <chr>    <chr>  <chr>  <chr>
##  1 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When…
##  2 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When…
##  3 Shar… 2014  TV-14 30 Jul … 95 min  Acti… Anthony… Thund… Ian Z… Fin …
##  4 Shar… 2014  TV-14 30 Jul … 95 min  Acti… Anthony… Thund… Ian Z… Fin …
##  5 Shar… 2015  TV-14 22 Jul … 93 min  Acti… Anthony… Thund… Ian Z… A mo…
##  6 Shar… 2015  TV-14 22 Jul … 93 min  Acti… Anthony… Thund… Ian Z… A mo…
##  7 Shar… 2016  TV-14 31 Jul … 95 min  Acti… Anthony… Thund… Ian Z… Fin,…
##  8 Shar… 2016  TV-14 31 Jul … 95 min  Acti… Anthony… Thund… Ian Z… Fin,…
##  9 Shar… 2017  TV-14 06 Aug … 93 min  Acti… Anthony… Thund… Ian Z… With…
## 10 Shar… 2017  TV-14 06 Aug … 93 min  Acti… Anthony… Thund… Ian Z… With…
## # … with 15 more variables: Language <chr>, Country <chr>, Awards <chr>,
## #   Poster <chr>, Ratings <list>, Metascore <chr>, imdbRating <chr>,
## #   imdbVotes <chr>, imdbID <chr>, Type <chr>, DVD <chr>, BoxOffice <chr>,
## #   Production <chr>, Website <chr>, Response <chr>
```

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).

- Iterative operation drawn from Rochelle Terman's [Collecting Data from the Web](https://plsc-31101.github.io/course/collecting-data-from-the-web.html)

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
##  broom         0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
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
##  httr        * 1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite    * 1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
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
