---
title: "Simplifying lists with purrr"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/webdata004_simplifying_lists.html"]
categories: ["webdata"]

menu:
  notes:
    parent: Getting data from the web
    weight: 4
---




```r
library(tidyverse)
library(jsonlite)
library(curl)
library(repurrrsive)
```

Not all lists are easily coerced into data frames by simply calling `fromJSON() %>% as_tibble()`. Unless your list is perfectly structured, this will not work. Recall the OMDB example:


```r
# omdb API function
omdb <- function(Key, Title, Year, Plot, Format){
  baseurl <- "http://www.omdbapi.com/?"
  params <- c("apikey=", "t=", "y=", "plot=", "r=")
  values <- c(Key, Title, Year, Plot, Format)
  param_values <- map2_chr(params, values, str_c)
  args <- str_c(param_values, collapse = "&")
  str_c(baseurl, args)
}

# use curl to execute the query
request_sharknado <- omdb(getOption("omdb_key"), "Sharknado", "2013", "short", "json")
con <- curl(request_sharknado)
answer_json <- readLines(con)
close(con)

# convert to data frame
answer_json %>% 
  fromJSON() %>% 
  as_tibble()
```

```
## # A tibble: 2 x 25
##   Title Year  Rated Released Runtime Genre Director Writer Actors Plot 
##   <chr> <chr> <chr> <chr>    <chr>   <chr> <chr>    <chr>  <chr>  <chr>
## 1 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When…
## 2 Shar… 2013  TV-14 11 Jul … 86 min  Acti… Anthony… Thund… Ian Z… When…
## # … with 16 more variables: Language <chr>, Country <chr>, Awards <chr>,
## #   Poster <chr>, Ratings$Source <chr>, $Value <chr>, Metascore <chr>,
## #   imdbRating <chr>, imdbVotes <chr>, imdbID <chr>, Type <chr>,
## #   DVD <chr>, BoxOffice <chr>, Production <chr>, Website <chr>,
## #   Response <chr>
```

Wait a minute, what happened? Look at the structure of `answer_json %>% fromJSON()`:


```r
sharknado <- answer_json %>% 
  fromJSON()

str(sharknado)
```

```
## List of 25
##  $ Title     : chr "Sharknado"
##  $ Year      : chr "2013"
##  $ Rated     : chr "TV-14"
##  $ Released  : chr "11 Jul 2013"
##  $ Runtime   : chr "86 min"
##  $ Genre     : chr "Action, Adventure, Comedy, Horror, Sci-Fi, Thriller"
##  $ Director  : chr "Anthony C. Ferrante"
##  $ Writer    : chr "Thunder Levin"
##  $ Actors    : chr "Ian Ziering, Tara Reid, John Heard, Cassandra Scerbo"
##  $ Plot      : chr "When a freak hurricane swamps Los Angeles, nature's deadliest killer rules sea, land, and air as thousands of s"| __truncated__
##  $ Language  : chr "English"
##  $ Country   : chr "USA"
##  $ Awards    : chr "1 win & 2 nominations."
##  $ Poster    : chr "https://m.media-amazon.com/images/M/MV5BODcwZWFiNTEtNDgzMC00ZmE2LWExMzYtNzZhZDgzNDc5NDkyXkEyXkFqcGdeQXVyMTQxNzM"| __truncated__
##  $ Ratings   :'data.frame':	2 obs. of  2 variables:
##   ..$ Source: chr [1:2] "Internet Movie Database" "Rotten Tomatoes"
##   ..$ Value : chr [1:2] "3.3/10" "82%"
##  $ Metascore : chr "N/A"
##  $ imdbRating: chr "3.3"
##  $ imdbVotes : chr "42,959"
##  $ imdbID    : chr "tt2724064"
##  $ Type      : chr "movie"
##  $ DVD       : chr "03 Sep 2013"
##  $ BoxOffice : chr "N/A"
##  $ Production: chr "NCM Fathom"
##  $ Website   : chr "http://www.mtivideo.com/TitleView.aspx?TITLE_ID=728"
##  $ Response  : chr "True"
```

Look at the `ratings` element: **it is a data frame**. Remember that data frames are just a special type of list, so what we have here is a list inside of a list (aka a **recursive list**). We cannot easily **flatten** this into a data frame, because the `ratings` element is not an atomic vector of length 1 like all the other elements in `sharknado`. Instead, we have to think of another way to convert it to a data frame.

## Load packages

We need to load two packages now: `repurrrsive` contains examples of recursive lists, and `listviewer` which provides an interactive method for viewing the structure of a list.

```r
devtools::install_github("jennybc/repurrrsive")
install.packages("listviewer")
```


```r
library(purrr)
library(repurrrsive)
```

## Inspecting and exploring lists

Before you can apply functions to a list, you should understand it. Especially when dealing with poorly documented APIs, you may not know in advance the structure of your list, or it may not be the same as the documentation. `str()` is the base R method for inspecting a list by printing the structure of the list to the console. If you have a large list, this will be a lot of output. `max.levels` and `list.len` can be used to print only a partial structure for this list.

> Alternatively, you can use [`listviewer::jsonedit()`](https://github.com/timelyportfolio/listviewer) to interactively view the list within RStudio.

Let's look at `got_chars`, which is a list of information on the 29 point-of-view characters from the first five books in *A Song of Ice and Fire* by George R.R. Martin.

> Spoiler alert - if you haven't read the series, you may not want to read too much into each list element. That said, the book series is over 20 years old now and the show *Game of Thrones* is incredibly popular, so you've had plenty of opportunity to learn this information by now.

Each element corresponds to one character and contains 18 sub-elements which are named atomic vectors of various lengths and types.


```r
str(got_chars, list.len = 3)
```

```
## List of 30
##  $ :List of 18
##   ..$ url        : chr "https://www.anapioficeandfire.com/api/characters/1022"
##   ..$ id         : int 1022
##   ..$ name       : chr "Theon Greyjoy"
##   .. [list output truncated]
##  $ :List of 18
##   ..$ url        : chr "https://www.anapioficeandfire.com/api/characters/1052"
##   ..$ id         : int 1052
##   ..$ name       : chr "Tyrion Lannister"
##   .. [list output truncated]
##  $ :List of 18
##   ..$ url        : chr "https://www.anapioficeandfire.com/api/characters/1074"
##   ..$ id         : int 1074
##   ..$ name       : chr "Victarion Greyjoy"
##   .. [list output truncated]
##   [list output truncated]
```

## Extract elements

##### Quick review of `purrr::map()`

* [Map functions in *R for Data Science*](http://r4ds.had.co.nz/iteration.html#the-map-functions)
* [Notes on map functions](/notes/iteration/#map-functions)

We can use `purrr::map()` to extract elements from lists.

## Name and position shortcuts

Let's extract the `name` element for each Game of Thrones character. To do this, we can use `map()` and extract list elements based on their name:


```r
map(got_chars[1:4], "name")
```

```
## [[1]]
## [1] "Theon Greyjoy"
## 
## [[2]]
## [1] "Tyrion Lannister"
## 
## [[3]]
## [1] "Victarion Greyjoy"
## 
## [[4]]
## [1] "Will"
```

A companion shortcut is to extract elements by their integer position in the list. For example, extract the 3rd element of each character's list like so:


```r
map(got_chars[5:8], 3)
```

```
## [[1]]
## [1] "Areo Hotah"
## 
## [[2]]
## [1] "Chett"
## 
## [[3]]
## [1] "Cressen"
## 
## [[4]]
## [1] "Arianne Martell"
```

To recap, here are two shortcuts for making the `.f` function that `map()` will apply:

* Provide "TEXT" to extract the element named "TEXT"
    * Equivalent to `function(x) x[["TEXT"]]`
* Provide `i` to extract the `i`-th element
    * Equivalent to `function(x) x[[i]]`
    
And as always, we can use `map()` with the pipe `%>%`:


```r
got_chars %>% 
  map("name")
got_chars %>% 
  map(3)
```
    
## Type-specific map

`map()` always returns a list, but if you know that the elements are all the same type (e.g. numeric, character, boolean) and are each of length one, you can use the `map_()` function appropriate for that type of vector.


```r
map_chr(got_chars[9:12], "name")
```

```
## [1] "Daenerys Targaryen" "Davos Seaworth"     "Arya Stark"        
## [4] "Arys Oakheart"
```

```r
map_chr(got_chars[13:16], 3)
```

```
## [1] "Asha Greyjoy"    "Barristan Selmy" "Varamyr"         "Brandon Stark"
```

## Extract multiple values

What if you want to retrieve elements? What if you want to know the character's name and gender? For a single user, we can use traditional [subsetting](http://r4ds.had.co.nz/vectors.html#subsetting-1):


```r
# Victarion element
got_chars[[3]]
```

```
## $url
## [1] "https://www.anapioficeandfire.com/api/characters/1074"
## 
## $id
## [1] 1074
## 
## $name
## [1] "Victarion Greyjoy"
## 
## $gender
## [1] "Male"
## 
## $culture
## [1] "Ironborn"
## 
## $born
## [1] "In 268 AC or before, at Pyke"
## 
## $died
## [1] ""
## 
## $alive
## [1] TRUE
## 
## $titles
## [1] "Lord Captain of the Iron Fleet" "Master of the Iron Victory"    
## 
## $aliases
## [1] "The Iron Captain"
## 
## $father
## [1] ""
## 
## $mother
## [1] ""
## 
## $spouse
## [1] ""
## 
## $allegiances
## [1] "House Greyjoy of Pyke"
## 
## $books
## [1] "A Game of Thrones" "A Clash of Kings"  "A Storm of Swords"
## 
## $povBooks
## [1] "A Feast for Crows"    "A Dance with Dragons"
## 
## $tvSeries
## [1] ""
## 
## $playedBy
## [1] ""
```

```r
# specific elements for Victarion
got_chars[[3]][c("name", "culture", "gender", "born")]
```

```
## $name
## [1] "Victarion Greyjoy"
## 
## $culture
## [1] "Ironborn"
## 
## $gender
## [1] "Male"
## 
## $born
## [1] "In 268 AC or before, at Pyke"
```

We use a single square bracket indexing and a character vector to index by name. To adapt this to the `map()` framework, recall:

```r
map(.x, .f, ...)
```

The function `.f` will be `[` and `...` will be the character vector identifying the names of the elements to extract.


```r
x <- map(got_chars, `[`, c("name", "culture", "gender", "born"))
str(x[16:17])
```

```
## List of 2
##  $ :List of 4
##   ..$ name   : chr "Brandon Stark"
##   ..$ culture: chr "Northmen"
##   ..$ gender : chr "Male"
##   ..$ born   : chr "In 290 AC, at Winterfell"
##  $ :List of 4
##   ..$ name   : chr "Brienne of Tarth"
##   ..$ culture: chr ""
##   ..$ gender : chr "Female"
##   ..$ born   : chr "In 280 AC"
```

Alternatively, we can use `magrittr::extract()` to do the same thing. It looks a bit more clean:


```r
library(magrittr)
```

```
## 
## Attaching package: 'magrittr'
```

```
## The following object is masked from 'package:purrr':
## 
##     set_names
```

```
## The following object is masked from 'package:tidyr':
## 
##     extract
```

```r
x <- map(got_chars, extract, c("name", "culture", "gender", "born"))
str(x[18:19])
```

```
## List of 2
##  $ :List of 4
##   ..$ name   : chr "Catelyn Stark"
##   ..$ culture: chr "Rivermen"
##   ..$ gender : chr "Female"
##   ..$ born   : chr "In 264 AC, at Riverrun"
##  $ :List of 4
##   ..$ name   : chr "Cersei Lannister"
##   ..$ culture: chr "Westerman"
##   ..$ gender : chr "Female"
##   ..$ born   : chr "In 266 AC, at Casterly Rock"
```

## Data frame output

Notice that even by extracting multiple elements at once, we are still left with a list. But we want a simplified data frame! Remember that the output of `map()` is always a list. To force the output to be a data frame, use `map_df()`:


```r
map_df(got_chars, extract, c("name", "culture", "gender", "id", "born", "alive"))
```

```
## # A tibble: 30 x 6
##    name            culture  gender    id born                         alive
##    <chr>           <chr>    <chr>  <int> <chr>                        <lgl>
##  1 Theon Greyjoy   Ironborn Male    1022 In 278 AC or 279 AC, at Pyke TRUE 
##  2 Tyrion Lannist… ""       Male    1052 In 273 AC, at Casterly Rock  TRUE 
##  3 Victarion Grey… Ironborn Male    1074 In 268 AC or before, at Pyke TRUE 
##  4 Will            ""       Male    1109 ""                           FALSE
##  5 Areo Hotah      Norvoshi Male    1166 In 257 AC or before, at Nor… TRUE 
##  6 Chett           ""       Male    1267 At Hag's Mire                FALSE
##  7 Cressen         ""       Male    1295 In 219 AC or 220 AC          FALSE
##  8 Arianne Martell Dornish  Female   130 In 276 AC, at Sunspear       TRUE 
##  9 Daenerys Targa… Valyrian Female  1303 In 284 AC, at Dragonstone    TRUE 
## 10 Davos Seaworth  Westeros Male    1319 In 260 AC or before, at Kin… TRUE 
## # … with 20 more rows
```

Now we have an automatically type converted data frame. It was quite simple to perform, however it is not very robust. It takes more code, but it is generally better to explicitly specify the type of each column to ensure the output is as you would expect:


```r
got_chars %>% {
  tibble(
    name = map_chr(., "name"),
    culture = map_chr(., "culture"),
    gender = map_chr(., "gender"),       
    id = map_int(., "id"),
    born = map_chr(., "born"),
    alive = map_lgl(., "alive")
  )
}
```

```
## # A tibble: 30 x 6
##    name            culture  gender    id born                         alive
##    <chr>           <chr>    <chr>  <int> <chr>                        <lgl>
##  1 Theon Greyjoy   Ironborn Male    1022 In 278 AC or 279 AC, at Pyke TRUE 
##  2 Tyrion Lannist… ""       Male    1052 In 273 AC, at Casterly Rock  TRUE 
##  3 Victarion Grey… Ironborn Male    1074 In 268 AC or before, at Pyke TRUE 
##  4 Will            ""       Male    1109 ""                           FALSE
##  5 Areo Hotah      Norvoshi Male    1166 In 257 AC or before, at Nor… TRUE 
##  6 Chett           ""       Male    1267 At Hag's Mire                FALSE
##  7 Cressen         ""       Male    1295 In 219 AC or 220 AC          FALSE
##  8 Arianne Martell Dornish  Female   130 In 276 AC, at Sunspear       TRUE 
##  9 Daenerys Targa… Valyrian Female  1303 In 284 AC, at Dragonstone    TRUE 
## 10 Davos Seaworth  Westeros Male    1319 In 260 AC or before, at Kin… TRUE 
## # … with 20 more rows
```

> The dot `.` above is the placeholder for the primary input: `got_chars` in this case. The curly braces `{}` surrounding the `tibble()` call prevent `got_chars` from being passed in as the first argument of `tibble()`.

## Exercise: simplify `gh_users`

`repurrsive` provides information on 6 GitHub users in a list named `gh_users`. It is a recursive list:

* One element for each of the 6 GitHub users
* Each element is, in turn, a list with information on the user

What is in the list? Let's take a look:


```r
str(gh_users, list.len = 3)
```

```
## List of 6
##  $ :List of 30
##   ..$ login              : chr "gaborcsardi"
##   ..$ id                 : int 660288
##   ..$ avatar_url         : chr "https://avatars.githubusercontent.com/u/660288?v=3"
##   .. [list output truncated]
##  $ :List of 30
##   ..$ login              : chr "jennybc"
##   ..$ id                 : int 599454
##   ..$ avatar_url         : chr "https://avatars.githubusercontent.com/u/599454?v=3"
##   .. [list output truncated]
##  $ :List of 30
##   ..$ login              : chr "jtleek"
##   ..$ id                 : int 1571674
##   ..$ avatar_url         : chr "https://avatars.githubusercontent.com/u/1571674?v=3"
##   .. [list output truncated]
##   [list output truncated]
```

Extract each user's real name, username, GitHub ID, location, date of account creation, and number of public repositories. Store this information in a tidy data frame.

<details> 
  <summary>Click for the solution</summary>
  <p>

Using the easy (non-robust method):


```r
map_df(gh_users, `[`, c("login", "name", "id", "location", "created_at", "public_repos"))
```

```
## # A tibble: 6 x 6
##   login    name               id location       created_at     public_repos
##   <chr>    <chr>           <int> <chr>          <chr>                 <int>
## 1 gaborcs… Gábor Csárdi   6.60e5 Chippenham, UK 2011-03-09T17…           52
## 2 jennybc  Jennifer (Je…  5.99e5 Vancouver, BC… 2011-02-03T22…          168
## 3 jtleek   Jeff L.        1.57e6 Baltimore,MD   2012-03-24T18…           67
## 4 juliasi… Julia Silge    1.25e7 Salt Lake Cit… 2015-05-19T02…           26
## 5 leeper   Thomas J. Le…  3.51e6 London, Unite… 2013-02-07T21…           99
## 6 masalmon Maëlle Salmon  8.36e6 Barcelona, Sp… 2014-08-05T08…           31
```

Using the longer (but robust) way:


```r
gh_users %>% {
  tibble(
    login = map_chr(., "login"),
    name = map_chr(., "name"),
    id = map_int(., "id"),
    location = map_chr(., "location"),
    created_at = map_chr(., "created_at") %>%
      lubridate::ymd_hms(),
    public_repos = map_int(., "public_repos")
  )
}
```

```
## # A tibble: 6 x 6
##   login   name             id location     created_at          public_repos
##   <chr>   <chr>         <int> <chr>        <dttm>                     <int>
## 1 gaborc… Gábor Csár…  6.60e5 Chippenham,… 2011-03-09 17:29:25           52
## 2 jennybc Jennifer (…  5.99e5 Vancouver, … 2011-02-03 22:37:41          168
## 3 jtleek  Jeff L.      1.57e6 Baltimore,MD 2012-03-24 18:16:43           67
## 4 julias… Julia Silge  1.25e7 Salt Lake C… 2015-05-19 02:51:23           26
## 5 leeper  Thomas J. …  3.51e6 London, Uni… 2013-02-07 21:07:00           99
## 6 masalm… Maëlle Sal…  8.36e6 Barcelona, … 2014-08-05 08:10:04           31
```

Also notice that because I extracted each element manually, I could easily convert `created_at` to a [datetime column](http://r4ds.had.co.nz/dates-and-times.html#from-strings).
    
  </p>
</details>

## List inside a data frame

`gh_users` has a single primary level of nesting, but you regularly will encounter even more levels. `gh_repos` is a list with:

* One element for each of the 6 GitHub users
* Each element is another list of that user's repositories (or the first 30 if the user has more)
* Several of the list elements are also a list


```r
str(gh_repos, list.len = 2)
```

```
## List of 6
##  $ :List of 30
##   ..$ :List of 68
##   .. ..$ id               : int 61160198
##   .. ..$ name             : chr "after"
##   .. .. [list output truncated]
##   ..$ :List of 68
##   .. ..$ id               : int 40500181
##   .. ..$ name             : chr "argufy"
##   .. .. [list output truncated]
##   .. [list output truncated]
##  $ :List of 30
##   ..$ :List of 68
##   .. ..$ id               : int 14756210
##   .. ..$ name             : chr "2013-11_sfu"
##   .. .. [list output truncated]
##   ..$ :List of 68
##   .. ..$ id               : int 14152301
##   .. ..$ name             : chr "2014-01-27-miami"
##   .. .. [list output truncated]
##   .. [list output truncated]
##   [list output truncated]
```

## Vector input to extraction shortcuts

Now we use the indexing shortcuts in a more complicated setting. Instead of providing a single name or position, we use a vector:

* the `j`-th element addresses the `j`-th level of the hierarchy
  
Here we get the full name (element 3) of the first repository listed for each user.


```r
gh_repos %>%
  map_chr(c(1, 3))
```

```
## [1] "gaborcsardi/after"   "jennybc/2013-11_sfu" "jtleek/advdatasci"  
## [4] "juliasilge/2016-14"  "leeper/ampolcourse"  "masalmon/aqi_pdf"
```

Note that this does NOT give elements 1 and 3 of `gh_repos`. It extracts the first repo for each user and, within that, the 3rd piece of information for the repo.

## Get it into a data frame

Our objective is to get a data frame with one row per repository, with variables identifying which GitHub user owns it, the repository name, etc.

### Create a data frame with usernames and `gh_repos`

First let's create a data frame with `gh_repos` as a list-column along with identifying GitHub usernames. To do this, we extract the user names using the approach outlined above, set them as the names on `gh_repos`, then convert the named list into a tibble:


```r
(unames <- map_chr(gh_repos, c(1, 4, 1)))
```

```
## [1] "gaborcsardi" "jennybc"     "jtleek"      "juliasilge"  "leeper"     
## [6] "masalmon"
```

```r
(udf <- gh_repos %>%
    set_names(unames) %>% 
    enframe("username", "gh_repos"))
```

```
## # A tibble: 6 x 2
##   username    gh_repos   
##   <chr>       <list>     
## 1 gaborcsardi <list [30]>
## 2 jennybc     <list [30]>
## 3 jtleek      <list [30]>
## 4 juliasilge  <list [26]>
## 5 leeper      <list [30]>
## 6 masalmon    <list [30]>
```

Next let's extract some basic piece of information from `gh_repos`. For instance, how many repos are associated with each user?


```r
udf %>% 
  mutate(n_repos = map_int(gh_repos, length))
```

```
## # A tibble: 6 x 3
##   username    gh_repos    n_repos
##   <chr>       <list>        <int>
## 1 gaborcsardi <list [30]>      30
## 2 jennybc     <list [30]>      30
## 3 jtleek      <list [30]>      30
## 4 juliasilge  <list [26]>      26
## 5 leeper      <list [30]>      30
## 6 masalmon    <list [30]>      30
```

### Practice on a single user

Before attempting to `map()` functions to the entire data frame, let's first practice on a single user.


```r
# one_user is a list of repos for one user
one_user <- udf$gh_repos[[1]]

# one_user[[1]] is a list of info for one repo
one_repo <- one_user[[1]]
str(one_repo, max.level = 1, list.len = 5)
```

```
## List of 68
##  $ id               : int 61160198
##  $ name             : chr "after"
##  $ full_name        : chr "gaborcsardi/after"
##  $ owner            :List of 17
##  $ private          : logi FALSE
##   [list output truncated]
```

```r
# a highly selective list of tibble-worthy info for one repo
one_repo[c("name", "fork", "open_issues")]
```

```
## $name
## [1] "after"
## 
## $fork
## [1] FALSE
## 
## $open_issues
## [1] 0
```

```r
# make a data frame of that info for all a user's repos
map_df(one_user, `[`, c("name", "fork", "open_issues"))
```

```
## # A tibble: 30 x 3
##    name        fork  open_issues
##    <chr>       <lgl>       <int>
##  1 after       FALSE           0
##  2 argufy      FALSE           6
##  3 ask         FALSE           4
##  4 baseimports FALSE           0
##  5 citest      TRUE            0
##  6 clisymbols  FALSE           0
##  7 cmaker      TRUE            0
##  8 cmark       TRUE            0
##  9 conditions  TRUE            0
## 10 crayon      FALSE           7
## # … with 20 more rows
```

```r
map_df(one_user, extract, c("name", "fork", "open_issues"))
```

```
## # A tibble: 30 x 3
##    name        fork  open_issues
##    <chr>       <lgl>       <int>
##  1 after       FALSE           0
##  2 argufy      FALSE           6
##  3 ask         FALSE           4
##  4 baseimports FALSE           0
##  5 citest      TRUE            0
##  6 clisymbols  FALSE           0
##  7 cmaker      TRUE            0
##  8 cmark       TRUE            0
##  9 conditions  TRUE            0
## 10 crayon      FALSE           7
## # … with 20 more rows
```

### Scale up to all users

Next let's scale this up to all the users in the data frame by executing a `map()` inside of a `map()`:


```r
udf %>% 
  mutate(repo_info = gh_repos %>%
           map(~ .x %>%
                 map_df(extract, c("name", "fork", "open_issues"))))
```

```
## # A tibble: 6 x 3
##   username    gh_repos    repo_info        
##   <chr>       <list>      <list>           
## 1 gaborcsardi <list [30]> <tibble [30 × 3]>
## 2 jennybc     <list [30]> <tibble [30 × 3]>
## 3 jtleek      <list [30]> <tibble [30 × 3]>
## 4 juliasilge  <list [26]> <tibble [26 × 3]>
## 5 leeper      <list [30]> <tibble [30 × 3]>
## 6 masalmon    <list [30]> <tibble [30 × 3]>
```

### Tidy the data frame

Now that we extracted our user-specific information, we want to make this a tidy data frame. All the info we want is in `repo_info`, so we can remove `gh_repos` and `unnest()` the data frame:


```r
(rdf <- udf %>% 
   mutate(
     repo_info = gh_repos %>%
       map(~ .x %>%
             map_df(extract, c("name", "fork", "open_issues")))
   ) %>% 
   select(-gh_repos) %>% 
   tidyr::unnest())
```

```
## # A tibble: 176 x 4
##    username    name        fork  open_issues
##    <chr>       <chr>       <lgl>       <int>
##  1 gaborcsardi after       FALSE           0
##  2 gaborcsardi argufy      FALSE           6
##  3 gaborcsardi ask         FALSE           4
##  4 gaborcsardi baseimports FALSE           0
##  5 gaborcsardi citest      TRUE            0
##  6 gaborcsardi clisymbols  FALSE           0
##  7 gaborcsardi cmaker      TRUE            0
##  8 gaborcsardi cmark       TRUE            0
##  9 gaborcsardi conditions  TRUE            0
## 10 gaborcsardi crayon      FALSE           7
## # … with 166 more rows
```

## Acknowledgments

* Examples and data files drawn from Jenny Bryan's [`purrr` tutorial](https://jennybc.github.io/purrr-tutorial/index.html)

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.5.3 (2019-03-11)
##  os       macOS Mojave 10.14.3        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-05-13                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.3   2018-12-14 [2] CRAN (R 3.5.0)
##  blogdown      0.11    2019-03-11 [1] CRAN (R 3.5.2)
##  bookdown      0.9     2018-12-21 [1] CRAN (R 3.5.0)
##  broom         0.5.1   2018-12-05 [2] CRAN (R 3.5.0)
##  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
##  cellranger    1.1.0   2016-07-27 [2] CRAN (R 3.5.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
##  colorspace    1.4-1   2019-03-18 [2] CRAN (R 3.5.2)
##  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
##  curl        * 3.3     2019-01-10 [2] CRAN (R 3.5.2)
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.1   2018-10-26 [1] CRAN (R 3.5.1)
##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr       * 0.8.0.1 2019-02-15 [1] CRAN (R 3.5.2)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  forcats     * 0.4.0   2019-02-17 [2] CRAN (R 3.5.2)
##  fs            1.2.7   2019-03-19 [1] CRAN (R 3.5.3)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2     * 3.1.0   2018-10-25 [1] CRAN (R 3.5.0)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  gtable        0.2.0   2016-02-26 [2] CRAN (R 3.5.0)
##  haven         2.1.0   2019-02-19 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite    * 1.6     2018-12-07 [2] CRAN (R 3.5.0)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  lattice       0.20-38 2018-11-04 [2] CRAN (R 3.5.3)
##  lazyeval      0.2.2   2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate     1.7.4   2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  modelr        0.1.4   2019-02-18 [2] CRAN (R 3.5.2)
##  munsell       0.5.0   2018-06-12 [2] CRAN (R 3.5.0)
##  nlme          3.1-137 2018-04-07 [2] CRAN (R 3.5.3)
##  pillar        1.3.1   2018-12-15 [2] CRAN (R 3.5.0)
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.5.3)
##  pkgconfig     2.0.2   2018-08-16 [2] CRAN (R 3.5.1)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
##  plyr          1.8.4   2016-06-08 [2] CRAN (R 3.5.0)
##  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.0   2019-03-10 [2] CRAN (R 3.5.2)
##  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
##  purrr       * 0.3.2   2019-03-15 [2] CRAN (R 3.5.2)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  readr       * 1.3.1   2018-12-21 [2] CRAN (R 3.5.0)
##  readxl        1.3.1   2019-03-13 [2] CRAN (R 3.5.2)
##  remotes       2.0.2   2018-10-30 [1] CRAN (R 3.5.0)
##  repurrrsive * 0.1.0   2017-09-08 [2] CRAN (R 3.5.0)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.5.3)
##  rvest         0.3.2   2016-06-17 [2] CRAN (R 3.5.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.5.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.0.1   2018-10-13 [2] CRAN (R 3.5.0)
##  tibble      * 2.1.1   2019-03-16 [2] CRAN (R 3.5.2)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.5.0)
##  tidyverse   * 1.2.1   2017-11-14 [2] CRAN (R 3.5.0)
##  usethis       1.4.0   2018-08-14 [1] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
