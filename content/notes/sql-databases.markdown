---
title: "Accessing databases using dbplyr"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/distrib001_database.html"]
categories: ["distributed-computing"]

menu:
  notes:
    parent: Distributed computing
    weight: 1
---




```r
library(tidyverse)
set.seed(1234)

theme_set(theme_minimal())
```

So far we've only worked with data stored locally in-memory as **data frames**. However there are also situations where you want to work with data stored in an external **database**. Databases are generally stored remotely on-disk, as opposed to in memory. If your data is already stored in a database, or if you have too much data to fit it all into memory simultaneously, you need a way to access it. Fortunately for you, `dplyr` offers support for on-disk databases through `dbplyr`.

## SQL

**Structured Query Language** (SQL) is a means of communicating with a relational database management system. There are different types of SQL databases which offer varying functionality:

* [SQLite](https://www.sqlite.org/)
* [MySQL](https://www.mysql.com/)
* [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2016)
* [PostgreSQL](https://www.postgresql.org/)
* [BigQuery](https://cloud.google.com/bigquery/)

Databases can also be stored across many platforms. Some types of databases (such as SQLite) can be stored as a single file and loaded in-memory like a data frame. However for large or extremely complex databases, a local computer is insufficient. Instead, one uses a distributed computing platform to store their database in the cloud. Examples include the [UChicago Research Computing Center (RCC)](https://rcc.uchicago.edu/), [Amazon Web Services](https://aws.amazon.com/), and [Google Cloud Platform](https://cloud.google.com/). Note that hosting platforms not typically free (though you can request an account with RCC as a student).

## Getting started with SQLite

First you need to install `dbplyr`:

```r
install.packages("dbplyr")
```

Depending on the type of database, you also need to install the appropriate **database interface** (DBI) package. The DBI package provides the necessary interface between the database and `dplyr`. Five commonly used backends are:

* [`RMySQL`](https://github.com/rstats-db/RMySQL#readme) connects to MySQL and MariaDB
* [`RPostgreSQL`](https://CRAN.R-project.org/package=RPostgreSQL) connects to Postgres and Redshift.
* [`RSQLite`](https://github.com/rstats-db/RSQLite) embeds a SQLite database.
* [`odbc`](https://github.com/rstats-db/odbc#odbc) connects to many commercial databases via the open database connectivity protocol.
* [`bigrquery`](https://github.com/rstats-db/bigrquery) connects to Google's BigQuery.

## Connecting to the database

Let's create a local SQLite database using the `flights` data.


```r
library(dbplyr)
my_db <- DBI::dbConnect(RSQLite::SQLite(), path = ":memory:")
```

The first argument to `DBI::dbConnect()` is the database backend. SQLite only requires one other argument: the path to the database. Here, we use `:memory:` to create a temporary in-memory database.

To add data to the database, use `copy_to()`. Let's stock the database with `nycflights13::flights`:


```r
library(nycflights13)
copy_to(my_db,
        flights,
        temporary = FALSE,
        indexes = list(
          c("year", "month", "day"),
          "carrier",
          "tailnum"
        )
)
```

Now that we copied the data, we can use `tbl()` to reference a specific table inside the database:


```r
flights_db <- tbl(my_db, "flights")
flights_db
```

```
## # Source:   table<flights> [?? x 19]
## # Database: sqlite 3.22.0 []
##     year month   day dep_time sched_dep_time dep_delay arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>
##  1  2013     1     1      517            515         2      830
##  2  2013     1     1      533            529         4      850
##  3  2013     1     1      542            540         2      923
##  4  2013     1     1      544            545        -1     1004
##  5  2013     1     1      554            600        -6      812
##  6  2013     1     1      554            558        -4      740
##  7  2013     1     1      555            600        -5      913
##  8  2013     1     1      557            600        -3      709
##  9  2013     1     1      557            600        -3      838
## 10  2013     1     1      558            600        -2      753
## # … with more rows, and 12 more variables: sched_arr_time <int>,
## #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
## #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
## #   minute <dbl>, time_hour <dbl>
```

## Basic verbs


```r
select(flights_db, year:day, dep_delay, arr_delay)
```

```
## # Source:   lazy query [?? x 5]
## # Database: sqlite 3.22.0 []
##     year month   day dep_delay arr_delay
##    <int> <int> <int>     <dbl>     <dbl>
##  1  2013     1     1         2        11
##  2  2013     1     1         4        20
##  3  2013     1     1         2        33
##  4  2013     1     1        -1       -18
##  5  2013     1     1        -6       -25
##  6  2013     1     1        -4        12
##  7  2013     1     1        -5        19
##  8  2013     1     1        -3       -14
##  9  2013     1     1        -3        -8
## 10  2013     1     1        -2         8
## # … with more rows
```

```r
filter(flights_db, dep_delay > 240)
```

```
## # Source:   lazy query [?? x 19]
## # Database: sqlite 3.22.0 []
##     year month   day dep_time sched_dep_time dep_delay arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>
##  1  2013     1     1      848           1835       853     1001
##  2  2013     1     1     1815           1325       290     2120
##  3  2013     1     1     1842           1422       260     1958
##  4  2013     1     1     2115           1700       255     2330
##  5  2013     1     1     2205           1720       285       46
##  6  2013     1     1     2343           1724       379      314
##  7  2013     1     2     1332            904       268     1616
##  8  2013     1     2     1412            838       334     1710
##  9  2013     1     2     1607           1030       337     2003
## 10  2013     1     2     2131           1512       379     2340
## # … with more rows, and 12 more variables: sched_arr_time <int>,
## #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
## #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
## #   minute <dbl>, time_hour <dbl>
```

```r
arrange(flights_db, year, month, day)
```

```
## # Source:     table<flights> [?? x 19]
## # Database:   sqlite 3.22.0 []
## # Ordered by: year, month, day
##     year month   day dep_time sched_dep_time dep_delay arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>
##  1  2013     1     1      517            515         2      830
##  2  2013     1     1      533            529         4      850
##  3  2013     1     1      542            540         2      923
##  4  2013     1     1      544            545        -1     1004
##  5  2013     1     1      554            600        -6      812
##  6  2013     1     1      554            558        -4      740
##  7  2013     1     1      555            600        -5      913
##  8  2013     1     1      557            600        -3      709
##  9  2013     1     1      557            600        -3      838
## 10  2013     1     1      558            600        -2      753
## # … with more rows, and 12 more variables: sched_arr_time <int>,
## #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
## #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
## #   minute <dbl>, time_hour <dbl>
```

```r
mutate(flights_db, speed = air_time / distance)
```

```
## # Source:   lazy query [?? x 20]
## # Database: sqlite 3.22.0 []
##     year month   day dep_time sched_dep_time dep_delay arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>
##  1  2013     1     1      517            515         2      830
##  2  2013     1     1      533            529         4      850
##  3  2013     1     1      542            540         2      923
##  4  2013     1     1      544            545        -1     1004
##  5  2013     1     1      554            600        -6      812
##  6  2013     1     1      554            558        -4      740
##  7  2013     1     1      555            600        -5      913
##  8  2013     1     1      557            600        -3      709
##  9  2013     1     1      557            600        -3      838
## 10  2013     1     1      558            600        -2      753
## # … with more rows, and 13 more variables: sched_arr_time <int>,
## #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
## #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
## #   minute <dbl>, time_hour <dbl>, speed <dbl>
```

```r
summarise(flights_db, delay = mean(dep_time))
```

```
## # Source:   lazy query [?? x 1]
## # Database: sqlite 3.22.0 []
##   delay
##   <dbl>
## 1 1349.
```

The commands are generally the same as you would use in `dplyr`. The only difference is that `dplyr` converts your R commands into SQL syntax:


```r
select(flights_db, year:day, dep_delay, arr_delay) %>%
  show_query()
```

```
## <SQL>
## SELECT `year`, `month`, `day`, `dep_delay`, `arr_delay`
## FROM `flights`
```

`dbplyr` is also lazy:

* It never pulls data into R unless you explicitly ask for it
* It delays doing any work until the last possible moment: it collects together everything you want to do and then sends it to the database in one step.


```r
c1 <- filter(flights_db, year == 2013, month == 1, day == 1)
c2 <- select(c1, year, month, day, carrier, dep_delay, air_time, distance)
c3 <- mutate(c2, speed = distance / air_time * 60)
c4 <- arrange(c3, year, month, day, carrier)
```

Nothing has actually gone to the database yet.


```r
c4
```

```
## # Source:     lazy query [?? x 8]
## # Database:   sqlite 3.22.0 []
## # Ordered by: year, month, day, carrier
##     year month   day carrier dep_delay air_time distance speed
##    <int> <int> <int> <chr>       <dbl>    <dbl>    <dbl> <dbl>
##  1  2013     1     1 9E              0      189     1029  327.
##  2  2013     1     1 9E             -9       57      228  240 
##  3  2013     1     1 9E             -3       68      301  266.
##  4  2013     1     1 9E             -6       57      209  220 
##  5  2013     1     1 9E             -8       66      264  240 
##  6  2013     1     1 9E              0       40      184  276 
##  7  2013     1     1 9E              6      146      740  304.
##  8  2013     1     1 9E              0      139      665  287.
##  9  2013     1     1 9E             -8      150      765  306 
## 10  2013     1     1 9E             -6       41      187  274.
## # … with more rows
```

Now we finally communicate with the database, but only retrieved the first 10 rows (notice the `??` in `query [?? x 8]`). This is a built-in feature to avoid downloading an extremely large data frame our machine cannot handle. To obtain the full results, use `collect()`:


```r
collect(c4)
```

```
## # A tibble: 842 x 8
##     year month   day carrier dep_delay air_time distance speed
##    <int> <int> <int> <chr>       <dbl>    <dbl>    <dbl> <dbl>
##  1  2013     1     1 9E              0      189     1029  327.
##  2  2013     1     1 9E             -9       57      228  240 
##  3  2013     1     1 9E             -3       68      301  266.
##  4  2013     1     1 9E             -6       57      209  220 
##  5  2013     1     1 9E             -8       66      264  240 
##  6  2013     1     1 9E              0       40      184  276 
##  7  2013     1     1 9E              6      146      740  304.
##  8  2013     1     1 9E              0      139      665  287.
##  9  2013     1     1 9E             -8      150      765  306 
## 10  2013     1     1 9E             -6       41      187  274.
## # … with 832 more rows
```

## Google Bigquery

[**Google Bigquery**](https://cloud.google.com/bigquery/) is a distributed cloud platform for data warehousing and analytics. It can scan terabytes of data in seconds and petabytes in minutes. It has flexible pricing that scales depending on your demand on their resources, and could cost as little as pennies, though depending on your computation may cost more.

## Interacting with Google Bigquery via `dplyr`

Google Bigquery hosts several public (and free) datasets. One is the [NYC Taxi and Limousine Trips](https://cloud.google.com/bigquery/public-data/nyc-tlc-trips) dataset, which contains trip records from all trips completed in yellow and green taxis in NYC from 2009 to 2015. Records include fields capturing pick-up and drop-off dates/times, pick-up and drop-off locations, trip distances, itemized fares, rate types, payment types, and driver-reported passenger counts. The dataset itself is hundreds of gigabytes and could never be loaded on a desktop machine. But fortunately we can harness the power of the cloud.

To connect to the database, we use the `bigrquery` library and `bigrquery::bigquery()`:


```r
library(bigrquery)

taxi <- DBI::dbConnect(bigrquery::bigquery(),
                       project = "nyc-tlc",
                       dataset = "yellow",
                       billing = getOption("bigquery_id"))
taxi
```

```
## <BigQueryConnection>
##   Dataset: nyc-tlc.yellow
##   Billing: cfss-149820
```

* `project` - the project that is hosting the data
* `dataset` - the specific database to be accessed
* `billing` - your unique id to access the data (and be charged if you run too many queries or use to much computing power). You need to [create an account](https://cloud.google.com/bigquery/quickstart-web-ui#before-you-begin) in order to use BigQuery, even if you want to access the free datasets. I stored mine in `.Rprofile` using `options()`.^[This may not make sense to you. You will learn more about storing credentials next week in our unit on accessing data from the web.]

First lets determine in 2014, how many trips per taken each month in yellow cabs? The SQL syntax is:

```sql
SELECT
  LEFT(STRING(pickup_datetime), 7) month,
  COUNT(*) trips
FROM
  [nyc-tlc:yellow.trips]
WHERE
  YEAR(pickup_datetime) = 2014
GROUP BY
  1
ORDER BY
  1
```

In `dbplyr`, we use:


```r
system.time({
  trips_by_month <- taxi %>%
    tbl("trips") %>%
    filter(year(pickup_datetime) == 2014) %>%
    mutate(month = month(pickup_datetime)) %>%
    count(month) %>%
    arrange(month) %>%
    collect()
})
trips_by_month
```

What about the average speed per hour of day in yellow cabs?


```r
system.time({
  speed_per_hour <- taxi %>%
    tbl("trips") %>%
    mutate(hour = hour(pickup_datetime),
           trip_duration = (dropoff_datetime - pickup_datetime) /
             3600000000) %>%
    mutate(speed = trip_distance / trip_duration) %>%
    filter(fare_amount / trip_distance >= 2,
           fare_amount / trip_distance <= 10) %>%
    group_by(hour) %>%
    summarize(speed = mean(speed)) %>%
    arrange(hour) %>%
    collect()
})

ggplot(speed_per_hour, aes(hour, speed)) +
  geom_line() +
  labs(title = "Average Speed of NYC Yellow Taxis",
       x = "Hour of day",
       y = "Average speed, in MPH")
```

Finally, what is the average speed by day of the week?


```r
system.time({
  speed_per_day <- taxi %>%
    tbl("trips") %>%
    mutate(hour = hour(pickup_datetime),
           day = dayofweek(pickup_datetime),
           trip_duration = (dropoff_datetime - pickup_datetime) /
             3600000000) %>%
    mutate(speed = trip_distance / trip_duration) %>%
    filter(fare_amount / trip_distance >= 2,
           fare_amount / trip_distance <= 10,
           hour >= 8,
           hour <= 18) %>%
    group_by(day) %>%
    summarize(speed = mean(speed)) %>%
    arrange(day) %>%
    collect()
})
speed_per_day
```

### Acknowledgments

* [Introduction to `dbplyr`](https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html)

### Session Info



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
##  bit           1.1-14  2018-05-29 [1] CRAN (R 3.6.0)
##  bit64         0.9-7   2017-05-08 [1] CRAN (R 3.6.0)
##  blob          1.2.0   2019-07-09 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  DBI           1.0.0   2018-05-02 [1] CRAN (R 3.6.0)
##  dbplyr      * 1.4.2   2019-06-17 [1] CRAN (R 3.6.0)
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
##  RSQLite       2.1.2   2019-07-24 [1] CRAN (R 3.6.0)
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
