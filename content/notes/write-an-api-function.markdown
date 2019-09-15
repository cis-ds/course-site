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
library(curl)
library(jsonlite)
library(XML)
library(httr)

theme_set(theme_minimal())
```

What happens if someone has not already written a package for the API from which we want to obtain data? We have to write our own function! Fortunately you know how to [write functions](/notes/functions/) - now we need to use them to query an API to obtain data.

First we're going to examine the structure of API requests via the [Open Movie Database](http://www.omdbapi.com/). OMDb is very similar to IMDB, except it has a nice, simple API. We can go to the website, input some search parameters, and obtain both the XML query and the response from it. 

## Determining the shape of an API request

You can play around with the parameters on the OMDB website, and look at the resulting API call and the query you get back:

![](/img/ombd.png)

Let's experiment with different values of the `title` and `year` fields. Notice the pattern in the request. For example for Title = Sharknado and Year = 2013, we get:

``` http
http://www.omdbapi.com/?apikey=[apikey]&t=Sharknado&y=2013&plot=short&r=xml
```

Try pasting this link into the browser. Also experiment with `json` and `xml`.

> The OMDB API used to be free, however in the past year shifted to a private API key due to overwhelming traffic. See in class for a demo API key you can use.

How can we create this request in R?


```r
# retrieve API key from .RProfile
omdb_key <- getOption("omdb_key")

# create url
request <- str_c("http://www.omdbapi.com/?apikey=", omdb_key, "&", "t=", "Sharknado", "&", "y=", "2013", "&", "plot=", "short", "&", "r=", "xml")
request
```

```
## [1] "http://www.omdbapi.com/?apikey=775e324f&t=Sharknado&y=2013&plot=short&r=xml"
```

It works, but it's a bit ungainly. Lets try to abstract that into a function:


```r
omdb <- function(Key, Title, Year, Plot, Format){
  baseurl <- "http://www.omdbapi.com/?"
  params <- c("apikey=", "t=", "y=", "plot=", "r=")
  values <- c(Key, Title, Year, Plot, Format)
  param_values <- map2_chr(params, values, str_c)
  args <- str_c(param_values, collapse = "&")
  str_c(baseurl, args)
}

omdb(omdb_key, "Sharknado", "2013", "short", "xml")
```

```
## [1] "http://www.omdbapi.com/?apikey=775e324f&t=Sharknado&y=2013&plot=short&r=xml"
```

Now we have a handy function that returns the API query. We can paste in the link, but we can also obtain data from within R:


```r
request_sharknado <- omdb(omdb_key, "Sharknado", "2013", "short", "xml")
con <- curl(request_sharknado)
answer_xml <- readLines(con)
```

```
## Warning in readLines(con): incomplete final line found on 'http://
## www.omdbapi.com/?apikey=775e324f&t=Sharknado&y=2013&plot=short&r=xml'
```

```r
close(con)
answer_xml
```

```
## [1] "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root response=\"True\"><movie title=\"Sharknado\" year=\"2013\" rated=\"TV-14\" released=\"11 Jul 2013\" runtime=\"86 min\" genre=\"Action, Adventure, Comedy, Horror, Sci-Fi, Thriller\" director=\"Anthony C. Ferrante\" writer=\"Thunder Levin\" actors=\"Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo\" plot=\"When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace.\" language=\"English\" country=\"USA\" awards=\"1 win &amp; 2 nominations.\" poster=\"https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg\" metascore=\"N/A\" imdbRating=\"3.3\" imdbVotes=\"42,959\" imdbID=\"tt2724064\" type=\"movie\"/></root>"
```


```r
request_sharknado <- omdb(omdb_key, "Sharknado", "2013", "short", "json")
con <- curl(request_sharknado)
answer_json <- readLines(con)
close(con)
answer_json %>% 
  prettify()
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
##             "Value": "82%"
##         }
##     ],
##     "Metascore": "N/A",
##     "imdbRating": "3.3",
##     "imdbVotes": "42,959",
##     "imdbID": "tt2724064",
##     "Type": "movie",
##     "DVD": "03 Sep 2013",
##     "BoxOffice": "N/A",
##     "Production": "NCM Fathom",
##     "Website": "http://www.mtivideo.com/TitleView.aspx?TITLE_ID=728",
##     "Response": "True"
## }
## 
```

We have a form of data that is obviously structured. What is it?

## Intro to JSON and XML

These are the two common languages of web services: **J**ava**S**cript **O**bject **N**otation and e**X**tensible **M**arkup **L**anguage. 

Here's an example of JSON: from [this wonderful site](https://zapier.com/learn/apis/chapter-3-data-formats/)

```javascript
{
  "crust": "original",
  "toppings": ["cheese", "pepperoni", "garlic"],
  "status": "cooking",
  "customer": {
    "name": "Brian",
    "phone": "573-111-1111"
  }
}
```

And here is XML:

```XML
<order>
    <crust>original</crust>
    <toppings>
        <topping>cheese</topping>
        <topping>pepperoni</topping>
        <topping>garlic</topping>
    </toppings>
    <status>cooking</status>
</order>
```

You can see that both of these data structures are quite easy to read. They are "self-describing". In other words, they tell you how they are meant to be read.

There are easy means of taking these data types and creating R objects. Our JSON response above can be parsed using `jsonlite::fromJSON()`:


```r
answer_json %>% 
  fromJSON()
```

```
## $Title
## [1] "Sharknado"
## 
## $Year
## [1] "2013"
## 
## $Rated
## [1] "TV-14"
## 
## $Released
## [1] "11 Jul 2013"
## 
## $Runtime
## [1] "86 min"
## 
## $Genre
## [1] "Action, Adventure, Comedy, Horror, Sci-Fi, Thriller"
## 
## $Director
## [1] "Anthony C. Ferrante"
## 
## $Writer
## [1] "Thunder Levin"
## 
## $Actors
## [1] "Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo"
## 
## $Plot
## [1] "When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace."
## 
## $Language
## [1] "English"
## 
## $Country
## [1] "USA"
## 
## $Awards
## [1] "1 win & 2 nominations."
## 
## $Poster
## [1] "https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg"
## 
## $Ratings
##                    Source  Value
## 1 Internet Movie Database 3.3/10
## 2         Rotten Tomatoes    82%
## 
## $Metascore
## [1] "N/A"
## 
## $imdbRating
## [1] "3.3"
## 
## $imdbVotes
## [1] "42,959"
## 
## $imdbID
## [1] "tt2724064"
## 
## $Type
## [1] "movie"
## 
## $DVD
## [1] "03 Sep 2013"
## 
## $BoxOffice
## [1] "N/A"
## 
## $Production
## [1] "NCM Fathom"
## 
## $Website
## [1] "http://www.mtivideo.com/TitleView.aspx?TITLE_ID=728"
## 
## $Response
## [1] "True"
```

The output is a named list! A familiar and friendly R structure. Because data frames are lists, and because this list has no nested lists-within-lists,^[Because I strip it out. We'll see shortly how to handle nested lists-within-lists.] we can coerce it very simply:


```r
answer_json %>% 
  fromJSON() %>% 
  # remove ratings element for now
  list_modify(Ratings = NULL) %>%
  as_tibble()
```

```
## # A tibble: 1 x 24
##   Title Year  Rated Released Runtime Genre Director Writer Actors Plot 
##   <chr> <chr> <chr> <chr>    <chr>   <chr> <chr>    <chr>  <chr>  <chr>
## 1 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When…
## # … with 14 more variables: Language <chr>, Country <chr>, Awards <chr>,
## #   Poster <chr>, Metascore <chr>, imdbRating <chr>, imdbVotes <chr>,
## #   imdbID <chr>, Type <chr>, DVD <chr>, BoxOffice <chr>,
## #   Production <chr>, Website <chr>, Response <chr>
```

A similar process exists for XML formats:


```r
ans_xml_parsed <- xmlParse(answer_xml)
ans_xml_parsed
```

```
## <?xml version="1.0" encoding="UTF-8"?>
## <root response="True">
##   <movie title="Sharknado" year="2013" rated="TV-14" released="11 Jul 2013" runtime="86 min" genre="Action, Adventure, Comedy, Horror, Sci-Fi, Thriller" director="Anthony C. Ferrante" writer="Thunder Levin" actors="Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo" plot="When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace." language="English" country="USA" awards="1 win &amp; 2 nominations." poster="https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg" metascore="N/A" imdbRating="3.3" imdbVotes="42,959" imdbID="tt2724064" type="movie"/>
## </root>
## 
```

Not exactly the response we were hoping for! This shows us some of the XML document's structure: 

  * a `<root>` node with a single child, `<movie>`. 
  * the information we want is all stored as attributes

From [Nolan and Lang 2014](http://link.springer.com.proxy.uchicago.edu/book/10.1007%2F978-1-4614-7900-0):

> The `xmlRoot()` function returns an object of class `XMLInternalElementNode`. This is a regular
XML node and not specific to the root node, i.e., all XML nodes will appear in R with this class
or a more specific class. An object of class XMLInternalElementNode has four fields: name,
attributes, children and value, which we access with the methods xmlName(), xmlAttrs(), xmlChildren(), and xmlValue()

| field | method |
|:-----:|:------:|
| name  | `xmlName()` |
| attributes | `xmlAttrs()` |
| children  | `xmlChildren()` |
| value    | `xmlValue()`



```r
ans_xml_parsed_root <- xmlRoot(ans_xml_parsed)[["movie"]]  # could also use [[1]]
ans_xml_parsed_root
```

```
## <movie title="Sharknado" year="2013" rated="TV-14" released="11 Jul 2013" runtime="86 min" genre="Action, Adventure, Comedy, Horror, Sci-Fi, Thriller" director="Anthony C. Ferrante" writer="Thunder Levin" actors="Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo" plot="When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace." language="English" country="USA" awards="1 win &amp; 2 nominations." poster="https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg" metascore="N/A" imdbRating="3.3" imdbVotes="42,959" imdbID="tt2724064" type="movie"/>
```

```r
ans_xml_attrs <- xmlAttrs(ans_xml_parsed_root)
ans_xml_attrs
```

```
##                                                                                                                                                      title 
##                                                                                                                                                "Sharknado" 
##                                                                                                                                                       year 
##                                                                                                                                                     "2013" 
##                                                                                                                                                      rated 
##                                                                                                                                                    "TV-14" 
##                                                                                                                                                   released 
##                                                                                                                                              "11 Jul 2013" 
##                                                                                                                                                    runtime 
##                                                                                                                                                   "86 min" 
##                                                                                                                                                      genre 
##                                                                                                      "Action, Adventure, Comedy, Horror, Sci-Fi, Thriller" 
##                                                                                                                                                   director 
##                                                                                                                                      "Anthony C. Ferrante" 
##                                                                                                                                                     writer 
##                                                                                                                                            "Thunder Levin" 
##                                                                                                                                                     actors 
##                                                                                                     "Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo" 
##                                                                                                                                                       plot 
## "When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace." 
##                                                                                                                                                   language 
##                                                                                                                                                  "English" 
##                                                                                                                                                    country 
##                                                                                                                                                      "USA" 
##                                                                                                                                                     awards 
##                                                                                                                                   "1 win & 2 nominations." 
##                                                                                                                                                     poster 
##                       "https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg" 
##                                                                                                                                                  metascore 
##                                                                                                                                                      "N/A" 
##                                                                                                                                                 imdbRating 
##                                                                                                                                                      "3.3" 
##                                                                                                                                                  imdbVotes 
##                                                                                                                                                   "42,959" 
##                                                                                                                                                     imdbID 
##                                                                                                                                                "tt2724064" 
##                                                                                                                                                       type 
##                                                                                                                                                    "movie"
```


```r
ans_xml_attrs %>%
  t() %>%
  as_tibble()
```

```
## # A tibble: 1 x 19
##   title year  rated released runtime genre director writer actors plot 
##   <chr> <chr> <chr> <chr>    <chr>   <chr> <chr>    <chr>  <chr>  <chr>
## 1 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When…
## # … with 9 more variables: language <chr>, country <chr>, awards <chr>,
## #   poster <chr>, metascore <chr>, imdbRating <chr>, imdbVotes <chr>,
## #   imdbID <chr>, type <chr>
```

## Introducing the easy way: `httr`

`httr` is yet another star in the tidyverse, this one designed to facilitate all things HTTP from within R. This includes the major HTTP verbs, which are:^[[Source: HTTP made really easy](http://www.jmarshall.com/easy/http/)]

* **GET**: fetch an existing resource. The URL contains all the necessary information the server needs to locate and return the resource.
* **POST**: create a new resource. POST requests usually carry a payload that specifies the data for the new resource.
* **PUT**: update an existing resource. The payload may contain the updated data for the resource.
* **DELETE**: delete an existing resource.

HTTP is the foundation for APIs; understanding how it works is the key to interacting with all the diverse APIs out there. An excellent beginning resource for APIs (including HTTP basics) is [this simple guide](https://zapier.com/learn/apis/).

`httr` contains one function for every HTTP verb. The functions have the same names as the verbs (e.g. `GET()`, `POST()`). They have more informative outputs than simply using `curl`, and come with some nice convenience functions for working with the output:


```r
sharknado_json <- omdb(omdb_key, "Sharknado", "2013", "short", "json")
response_json <- GET(sharknado_json)
content(response_json, as = "parsed", type = "application/json")
```

```
## $Title
## [1] "Sharknado"
## 
## $Year
## [1] "2013"
## 
## $Rated
## [1] "TV-14"
## 
## $Released
## [1] "11 Jul 2013"
## 
## $Runtime
## [1] "86 min"
## 
## $Genre
## [1] "Action, Adventure, Comedy, Horror, Sci-Fi, Thriller"
## 
## $Director
## [1] "Anthony C. Ferrante"
## 
## $Writer
## [1] "Thunder Levin"
## 
## $Actors
## [1] "Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo"
## 
## $Plot
## [1] "When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of sharks terrorize the waterlogged populace."
## 
## $Language
## [1] "English"
## 
## $Country
## [1] "USA"
## 
## $Awards
## [1] "1 win & 2 nominations."
## 
## $Poster
## [1] "https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg"
## 
## $Ratings
## $Ratings[[1]]
## $Ratings[[1]]$Source
## [1] "Internet Movie Database"
## 
## $Ratings[[1]]$Value
## [1] "3.3/10"
## 
## 
## $Ratings[[2]]
## $Ratings[[2]]$Source
## [1] "Rotten Tomatoes"
## 
## $Ratings[[2]]$Value
## [1] "82%"
## 
## 
## 
## $Metascore
## [1] "N/A"
## 
## $imdbRating
## [1] "3.3"
## 
## $imdbVotes
## [1] "42,959"
## 
## $imdbID
## [1] "tt2724064"
## 
## $Type
## [1] "movie"
## 
## $DVD
## [1] "03 Sep 2013"
## 
## $BoxOffice
## [1] "N/A"
## 
## $Production
## [1] "NCM Fathom"
## 
## $Website
## [1] "http://www.mtivideo.com/TitleView.aspx?TITLE_ID=728"
## 
## $Response
## [1] "True"
```


```r
sharknado_xml <- omdb(omdb_key, "Sharknado", "2013", "short", "xml")
response_xml <- GET(sharknado_xml)
content(response_xml, as = "parsed")
```

```
## {xml_document}
## <root response="True">
## [1] <movie title="Sharknado" year="2013" rated="TV-14" released="11 Jul  ...
```

In addition, `httr` gives us access to lots of useful information about the quality of our response. For example, the header:


```r
headers(response_xml)
```

```
## $date
## [1] "Thu, 28 Mar 2019 18:00:57 GMT"
## 
## $`content-type`
## [1] "text/xml; charset=utf-8"
## 
## $`transfer-encoding`
## [1] "chunked"
## 
## $connection
## [1] "keep-alive"
## 
## $`cache-control`
## [1] "public, max-age=86400"
## 
## $expires
## [1] "Fri, 29 Mar 2019 18:00:57 GMT"
## 
## $`last-modified`
## [1] "Thu, 28 Mar 2019 18:00:57 GMT"
## 
## $vary
## [1] "*, Accept-Encoding"
## 
## $`x-aspnet-version`
## [1] "4.0.30319"
## 
## $`x-powered-by`
## [1] "ASP.NET"
## 
## $`access-control-allow-origin`
## [1] "*"
## 
## $`cf-cache-status`
## [1] "HIT"
## 
## $server
## [1] "cloudflare"
## 
## $`cf-ray`
## [1] "4beb81afcc7fc54a-ORD"
## 
## $`content-encoding`
## [1] "gzip"
## 
## attr(,"class")
## [1] "insensitive" "list"
```

And also a handy means to extract specifically the HTTP status code:


```r
status_code(response_xml)
```

```
## [1] 200
```

Code^[[HTTP Status Codes](http://www.restapitutorial.com/httpstatuscodes.html)] | Status
-------|--------|
1xx    | Informational
2xx    | Success
3xx    | Redirection
4xx    | Client error (you did something wrong)
5xx    | Server error (server did something wrong)

> [(Perhaps a more intuitive, cat-based explanation of error codes)](https://www.flickr.com/photos/girliemac/sets/72157628409467125).

In fact, we didn't need to create `omdb()` at all! `httr` provides a straightforward means of making an http request:


```r
sharknado_2 <- GET("http://www.omdbapi.com/?",
                   query = list(t = "Sharknado 2: The Second One",
                                y = 2014,
                                plot = "short",
                                r = "json",
                                apikey = omdb_key))

content(sharknado_2)
```

```
## $Title
## [1] "Sharknado 2: The Second One"
## 
## $Year
## [1] "2014"
## 
## $Rated
## [1] "TV-14"
## 
## $Released
## [1] "30 Jul 2014"
## 
## $Runtime
## [1] "95 min"
## 
## $Genre
## [1] "Action, Adventure, Comedy, Horror, Sci-Fi, Thriller"
## 
## $Director
## [1] "Anthony C. Ferrante"
## 
## $Writer
## [1] "Thunder Levin"
## 
## $Actors
## [1] "Ian Ziering, Tara Reid, Vivica A. Fox, Mark McGrath"
## 
## $Plot
## [1] "Fin and April are on their way to New York City, until a category seven hurricane spawns heavy rain, storm surges, and deadly Sharknadoes."
## 
## $Language
## [1] "English"
## 
## $Country
## [1] "USA"
## 
## $Awards
## [1] "N/A"
## 
## $Poster
## [1] "https://m.media-amazon.com/images/M/MV5BMjA0MTIxMDEwNF5BMl5BanBnXkFtZTgwMDk3ODIxMjE@._V1_SX300.jpg"
## 
## $Ratings
## $Ratings[[1]]
## $Ratings[[1]]$Source
## [1] "Internet Movie Database"
## 
## $Ratings[[1]]$Value
## [1] "4.1/10"
## 
## 
## $Ratings[[2]]
## $Ratings[[2]]$Source
## [1] "Rotten Tomatoes"
## 
## $Ratings[[2]]$Value
## [1] "59%"
## 
## 
## 
## $Metascore
## [1] "N/A"
## 
## $imdbRating
## [1] "4.1"
## 
## $imdbVotes
## [1] "16,503"
## 
## $imdbID
## [1] "tt3062074"
## 
## $Type
## [1] "movie"
## 
## $DVD
## [1] "07 Oct 2014"
## 
## $BoxOffice
## [1] "N/A"
## 
## $Production
## [1] "NCM Fathom"
## 
## $Website
## [1] "N/A"
## 
## $Response
## [1] "True"
```

We get the same answer as before! With `httr`, we are able to pass in the named arguments to the API call as a named list. We are also able to use spaces in movie names - `httr` encodes these in the URL before making the GET request.

The documentation for `httr` includes two useful vignettes:

* [`httr` quickstart guide](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html) - summarizes all the basic `httr` functions like above
* [Best practices for writing an API package](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html) - document outlining the key issues involved in writing API wrappers in R

## Applying `httr` to the Microsoft Emotion API

> This historic example is preserved as a demonstration of using `httr` to interact with deep learning models. Unfortunately Microsoft terminated this API and is no longer publicly usable. 😢

APIs can be used in conjunction with cloud computing and deep learning platforms that cannot be deployed on a local machine. Consider the [Microsoft Emotion API](https://azure.microsoft.com/en-us/services/cognitive-services/emotion/):

> The Emotion API takes a facial expression in an image as an input, and returns the confidence across a set of emotions for each face in the image, as well as bounding box for the face, using the Face API. If a user has already called the Face API, they can submit the face rectangle as an optional input.
    The emotions detected are anger, contempt, disgust, fear, happiness, neutral, sadness, and surprise. These emotions are understood to be cross-culturally and universally communicated with particular facial expressions.

Here is how we can use R and the `httr` package to send a request to the Microsoft Emotion API to analyze a video and retrieve the results.^[Based on [Analyzing Emotions using Facial Expressions in Video with Microsoft AI and R](https://blog.exploratory.io/analyzing-emotions-using-facial-expressions-in-video-with-microsoft-ai-and-r-8f7585dd0780), which is itself based on the original post [How to apply face recognition API technology to data journalism with R and python](https://benheubl.github.io/data%20analysis/fr/), which served as the basis for [The many debate faces of Donald Trump and Hillary Clinton](http://www.economist.com/blogs/graphicdetail/2016/10/daily-chart-12).] As our sample video, we'll use [a sample five minute video clip](https://www.dropbox.com/s/zfmaswf8s9c58om/blog2.mp4?dl=1%27) from the third 2016 U.S. presidential debate between Donald J. Trump and Hillary Clinton.


```r
# Set an endpoint for Emotion in Video API with "perFrame" output
apiUrl <- "https://api.projectoxford.ai/emotion/v1.0/recognizeInVideo?outputStyle=perFrame"

# Set URL for accessing the video
urlVideo <- "https://www.dropbox.com/s/zfmaswf8s9c58om/blog2.mp4?dl=1"

# Request Microsoft AI start processing the video via POST
faceEMO <- httr::POST(
  url = apiUrl,
  content_type("application/json"),
  add_headers(.headers = c("Ocp-Apim-Subscription-Key" = getOption("emotion_api"))),
  body = list(url = urlVideo),
  encode = "json"
)

# url to access the operation
operationLocation <- headers(faceEMO)[["operation-location"]]

# it can take awhile to process a long video
# use a while loop to wait for the processing to finish
# and retrieve the results
while(TRUE){
  # retrieve results and extract content
  ret <- GET(operationLocation,
             add_headers(.headers = c("Ocp-Apim-Subscription-Key" = getOption("emotion_api"))))
  
  con <- content(ret)
  
  # if the process is still running, print the progress and continue waiting
  if(is.null(con$status)){
    warning("Connection Error, retry after 1 minute")
    Sys.sleep(60)
  } else if (con$status == "Running" | con$status == "Uploading"){
    cat(paste0("status ", con$status, "\n"))
    cat(paste0("progress ", con$progress, "\n"))
    Sys.sleep(60)
  } else {
    # once the process is done, exit the loop
    cat(paste0("status ", con$status, "\n"))
    break()
  }
}

# extract data from the results
data <- (con$processingResult %>%
           fromJSON())$fragments

# data$events is list of events that has a data.frame column,
# so it has to be flattened using a series of map functions
data$events <- map(data$events, ~ .x %>%
    map(flatten) %>%
    bind_rows()
)

# print results
data

# clean up and save
emotion <- data %>%
  as_tibble %>%
  # unnest the list of data frames
  unnest(events) %>%
  # remove the moderator
  filter(id != 2) %>%
  # create a row id variable, use same row id for each set of speakers
  mutate(row_id = ceiling(row_number() / 2)) %>%
  # convert from wide to long, one row for each id-emotion
  gather(key, value, starts_with("scores")) %>%
  mutate(key = str_replace(key, "scores.", ""),
         id = recode(id, `0` = "Trump",
                     `1` = "Clinton")) %>%
  # remove neutral expressions and write to disk
  filter(key != "neutral") %>%
  write_rds("data/debate_emotion.rds")
```

This script requires you to [create your own API key](https://azure.microsoft.com/en-us/try/cognitive-services/my-apis/) for the Microsoft Emotion API and would take about an hour to process the video and retrieve the results. Instead, you can just use the prepped data frame stored in the `rcfss` package.


```r
# already ran the API and stored the data frame in the rcfss package
data("emotion", package = "rcfss")
emotion
```

```
## # A tibble: 128,688 x 11
##    start duration interval id        x     y width height row_id key  
##    <int>    <int>    <int> <chr> <dbl> <dbl> <dbl>  <dbl>  <dbl> <chr>
##  1     0    60060     1001 Trump 0.185 0.219 0.153  0.272      1 happ…
##  2     0    60060     1001 Clin… 0.718 0.296 0.139  0.246      1 happ…
##  3     0    60060     1001 Trump 0.184 0.217 0.155  0.276      2 happ…
##  4     0    60060     1001 Clin… 0.715 0.283 0.140  0.248      2 happ…
##  5     0    60060     1001 Trump 0.184 0.217 0.155  0.276      3 happ…
##  6     0    60060     1001 Clin… 0.712 0.276 0.140  0.248      3 happ…
##  7     0    60060     1001 Trump 0.184 0.217 0.155  0.276      4 happ…
##  8     0    60060     1001 Clin… 0.711 0.274 0.140  0.248      4 happ…
##  9     0    60060     1001 Trump 0.184 0.217 0.155  0.276      5 happ…
## 10     0    60060     1001 Clin… 0.708 0.265 0.142  0.252      5 happ…
## # … with 128,678 more rows, and 1 more variable: value <dbl>
```

> See `?emotion` for more documentation on the variables.

What could we do with this information? A simple analysis would be to visualize the emotions of each candidate over time:


```r
ggplot(emotion, aes(row_id, value, color = key)) +
  facet_wrap(~ id, nrow = 2) +
  geom_smooth(se = FALSE) +
  scale_color_brewer(type = "qual") +
  labs(title = "Candidate emotions during final 2016 U.S. presidential debate",
       subtitle = "Five-minute sample",
       x = "Frame",
       y = "Probability of emotion",
       color = "Emotion")
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="/notes/write-an-api-function_files/figure-html/emotion-viz-1.png" width="672" />

Hillary Clinton's facial expressions are marked predominantly by happiness, whereas Donald Trump's facial expressions are mostly sad.^[Not exactly predictive of the election results.]

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
* Microsoft Emotion API example drawn from [Analyzing Emotions using Facial Expressions in Video with Microsoft AI and R](https://blog.exploratory.io/analyzing-emotions-using-facial-expressions-in-video-with-microsoft-ai-and-r-8f7585dd0780)

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
##  package     * version    date       lib source                     
##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 3.6.0)             
##  backports     1.1.4      2019-04-10 [1] CRAN (R 3.6.0)             
##  blogdown      0.14       2019-07-13 [1] CRAN (R 3.6.0)             
##  bookdown      0.12       2019-07-11 [1] CRAN (R 3.6.0)             
##  broom         0.5.2      2019-04-07 [1] CRAN (R 3.6.0)             
##  callr         3.3.1      2019-07-18 [1] CRAN (R 3.6.0)             
##  cellranger    1.1.0      2016-07-27 [1] CRAN (R 3.6.0)             
##  cli           1.1.0      2019-03-19 [1] CRAN (R 3.6.0)             
##  colorspace    1.4-1      2019-03-18 [1] CRAN (R 3.6.0)             
##  crayon        1.3.4      2017-09-16 [1] CRAN (R 3.6.0)             
##  curl        * 4.0        2019-07-22 [1] CRAN (R 3.6.0)             
##  desc          1.2.0      2018-05-01 [1] CRAN (R 3.6.0)             
##  devtools      2.1.0      2019-07-06 [1] CRAN (R 3.6.0)             
##  digest        0.6.20     2019-07-04 [1] CRAN (R 3.6.0)             
##  dplyr       * 0.8.3      2019-07-04 [1] CRAN (R 3.6.0)             
##  emo           0.0.0.9000 2019-08-05 [1] Github (hadley/emo@02a5206)
##  evaluate      0.14       2019-05-28 [1] CRAN (R 3.6.0)             
##  forcats     * 0.4.0      2019-02-17 [1] CRAN (R 3.6.0)             
##  fs            1.3.1      2019-05-06 [1] CRAN (R 3.6.0)             
##  generics      0.0.2      2018-11-29 [1] CRAN (R 3.6.0)             
##  ggplot2     * 3.2.1      2019-08-10 [1] CRAN (R 3.6.0)             
##  glue          1.3.1      2019-03-12 [1] CRAN (R 3.6.0)             
##  gtable        0.3.0      2019-03-25 [1] CRAN (R 3.6.0)             
##  haven         2.1.1      2019-07-04 [1] CRAN (R 3.6.0)             
##  here          0.1        2017-05-28 [1] CRAN (R 3.6.0)             
##  hms           0.5.0      2019-07-09 [1] CRAN (R 3.6.0)             
##  htmltools     0.3.6      2017-04-28 [1] CRAN (R 3.6.0)             
##  httr        * 1.4.1      2019-08-05 [1] CRAN (R 3.6.0)             
##  jsonlite    * 1.6        2018-12-07 [1] CRAN (R 3.6.0)             
##  knitr         1.24       2019-08-08 [1] CRAN (R 3.6.0)             
##  lattice       0.20-38    2018-11-04 [1] CRAN (R 3.6.0)             
##  lazyeval      0.2.2      2019-03-15 [1] CRAN (R 3.6.0)             
##  lubridate     1.7.4      2018-04-11 [1] CRAN (R 3.6.0)             
##  magrittr      1.5        2014-11-22 [1] CRAN (R 3.6.0)             
##  memoise       1.1.0      2017-04-21 [1] CRAN (R 3.6.0)             
##  modelr        0.1.5      2019-08-08 [1] CRAN (R 3.6.0)             
##  munsell       0.5.0      2018-06-12 [1] CRAN (R 3.6.0)             
##  nlme          3.1-141    2019-08-01 [1] CRAN (R 3.6.0)             
##  pillar        1.4.2      2019-06-29 [1] CRAN (R 3.6.0)             
##  pkgbuild      1.0.4      2019-08-05 [1] CRAN (R 3.6.0)             
##  pkgconfig     2.0.2      2018-08-16 [1] CRAN (R 3.6.0)             
##  pkgload       1.0.2      2018-10-29 [1] CRAN (R 3.6.0)             
##  prettyunits   1.0.2      2015-07-13 [1] CRAN (R 3.6.0)             
##  processx      3.4.1      2019-07-18 [1] CRAN (R 3.6.0)             
##  ps            1.3.0      2018-12-21 [1] CRAN (R 3.6.0)             
##  purrr       * 0.3.2      2019-03-15 [1] CRAN (R 3.6.0)             
##  R6            2.4.0      2019-02-14 [1] CRAN (R 3.6.0)             
##  Rcpp          1.0.2      2019-07-25 [1] CRAN (R 3.6.0)             
##  readr       * 1.3.1      2018-12-21 [1] CRAN (R 3.6.0)             
##  readxl        1.3.1      2019-03-13 [1] CRAN (R 3.6.0)             
##  remotes       2.1.0      2019-06-24 [1] CRAN (R 3.6.0)             
##  rlang         0.4.0      2019-06-25 [1] CRAN (R 3.6.0)             
##  rmarkdown     1.14       2019-07-12 [1] CRAN (R 3.6.0)             
##  rprojroot     1.3-2      2018-01-03 [1] CRAN (R 3.6.0)             
##  rstudioapi    0.10       2019-03-19 [1] CRAN (R 3.6.0)             
##  rvest         0.3.4      2019-05-15 [1] CRAN (R 3.6.0)             
##  scales        1.0.0      2018-08-09 [1] CRAN (R 3.6.0)             
##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 3.6.0)             
##  stringi       1.4.3      2019-03-12 [1] CRAN (R 3.6.0)             
##  stringr     * 1.4.0      2019-02-10 [1] CRAN (R 3.6.0)             
##  testthat      2.2.1      2019-07-25 [1] CRAN (R 3.6.0)             
##  tibble      * 2.1.3      2019-06-06 [1] CRAN (R 3.6.0)             
##  tidyr       * 0.8.3      2019-03-01 [1] CRAN (R 3.6.0)             
##  tidyselect    0.2.5      2018-10-11 [1] CRAN (R 3.6.0)             
##  tidyverse   * 1.2.1      2017-11-14 [1] CRAN (R 3.6.0)             
##  usethis       1.5.1      2019-07-04 [1] CRAN (R 3.6.0)             
##  vctrs         0.2.0      2019-07-05 [1] CRAN (R 3.6.0)             
##  withr         2.1.2      2018-03-15 [1] CRAN (R 3.6.0)             
##  xfun          0.8        2019-06-25 [1] CRAN (R 3.6.0)             
##  XML         * 3.98-1.20  2019-06-06 [1] CRAN (R 3.6.0)             
##  xml2          1.2.2      2019-08-09 [1] CRAN (R 3.6.0)             
##  yaml          2.2.0      2018-07-25 [1] CRAN (R 3.6.0)             
##  zeallot       0.1.0      2018-01-28 [1] CRAN (R 3.6.0)             
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
