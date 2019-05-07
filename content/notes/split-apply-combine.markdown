---
title: "Split-apply-combine and parallel computing"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/distrib002_sac.html"]
categories: ["distributed-computing"]

menu:
  notes:
    parent: Distributed computing
    weight: 2
---




```r
library(tidyverse)
library(gapminder)
library(stringr)
set.seed(1234)

theme_set(theme_minimal())
```

A common analytical pattern is to

* **Split** data into pieces,
* **Apply** some function to each piece,
* **Combine** the results back together again.

We have used this technique many times so far without explicitly identifying it as such.

## `dplyr::group_by()` {#group-by}


```r
gapminder %>%
  group_by(continent) %>%
  summarize(n = n())
```

```
## # A tibble: 5 x 2
##   continent     n
##   <fct>     <int>
## 1 Africa      624
## 2 Americas    300
## 3 Asia        396
## 4 Europe      360
## 5 Oceania      24
```

```r
gapminder %>%
  group_by(continent) %>%
  summarize(avg_lifeExp = mean(lifeExp))
```

```
## # A tibble: 5 x 2
##   continent avg_lifeExp
##   <fct>           <dbl>
## 1 Africa           48.9
## 2 Americas         64.7
## 3 Asia             60.1
## 4 Europe           71.9
## 5 Oceania          74.3
```

## `for` loops {#for-loops}


```r
countries <- unique(gapminder$country)
lifeExp_models <- vector("list", length(countries))
names(lifeExp_models) <- countries

for(i in seq_along(countries)){
  lifeExp_models[[i]] <- lm(lifeExp ~ year,
                            data = filter(gapminder,
                                          country == countries[[i]]))
}
head(lifeExp_models)
```

```
## $Afghanistan
## 
## Call:
## lm(formula = lifeExp ~ year, data = filter(gapminder, country == 
##     countries[[i]]))
## 
## Coefficients:
## (Intercept)         year  
##   -507.5343       0.2753  
## 
## 
## $Albania
## 
## Call:
## lm(formula = lifeExp ~ year, data = filter(gapminder, country == 
##     countries[[i]]))
## 
## Coefficients:
## (Intercept)         year  
##   -594.0725       0.3347  
## 
## 
## $Algeria
## 
## Call:
## lm(formula = lifeExp ~ year, data = filter(gapminder, country == 
##     countries[[i]]))
## 
## Coefficients:
## (Intercept)         year  
##  -1067.8590       0.5693  
## 
## 
## $Angola
## 
## Call:
## lm(formula = lifeExp ~ year, data = filter(gapminder, country == 
##     countries[[i]]))
## 
## Coefficients:
## (Intercept)         year  
##   -376.5048       0.2093  
## 
## 
## $Argentina
## 
## Call:
## lm(formula = lifeExp ~ year, data = filter(gapminder, country == 
##     countries[[i]]))
## 
## Coefficients:
## (Intercept)         year  
##   -389.6063       0.2317  
## 
## 
## $Australia
## 
## Call:
## lm(formula = lifeExp ~ year, data = filter(gapminder, country == 
##     countries[[i]]))
## 
## Coefficients:
## (Intercept)         year  
##   -376.1163       0.2277
```

## `nest()` and `map()` {#nest-map}


```r
# function to estimate linear model for gapminder subsets
le_vs_yr <- function(df) {
  lm(lifeExp ~ year, data = df)
}

# split data into nests
(gap_nested <- gapminder %>% 
   group_by(continent, country) %>% 
   nest())
```

```
## # A tibble: 142 x 3
##    continent country     data             
##    <fct>     <fct>       <list>           
##  1 Asia      Afghanistan <tibble [12 × 4]>
##  2 Europe    Albania     <tibble [12 × 4]>
##  3 Africa    Algeria     <tibble [12 × 4]>
##  4 Africa    Angola      <tibble [12 × 4]>
##  5 Americas  Argentina   <tibble [12 × 4]>
##  6 Oceania   Australia   <tibble [12 × 4]>
##  7 Europe    Austria     <tibble [12 × 4]>
##  8 Asia      Bahrain     <tibble [12 × 4]>
##  9 Asia      Bangladesh  <tibble [12 × 4]>
## 10 Europe    Belgium     <tibble [12 × 4]>
## # … with 132 more rows
```

```r
# apply a linear model to each nested data frame
(gap_nested <- gap_nested %>% 
   mutate(fit = map(data, le_vs_yr)))
```

```
## # A tibble: 142 x 4
##    continent country     data              fit     
##    <fct>     <fct>       <list>            <list>  
##  1 Asia      Afghanistan <tibble [12 × 4]> <S3: lm>
##  2 Europe    Albania     <tibble [12 × 4]> <S3: lm>
##  3 Africa    Algeria     <tibble [12 × 4]> <S3: lm>
##  4 Africa    Angola      <tibble [12 × 4]> <S3: lm>
##  5 Americas  Argentina   <tibble [12 × 4]> <S3: lm>
##  6 Oceania   Australia   <tibble [12 × 4]> <S3: lm>
##  7 Europe    Austria     <tibble [12 × 4]> <S3: lm>
##  8 Asia      Bahrain     <tibble [12 × 4]> <S3: lm>
##  9 Asia      Bangladesh  <tibble [12 × 4]> <S3: lm>
## 10 Europe    Belgium     <tibble [12 × 4]> <S3: lm>
## # … with 132 more rows
```

```r
# combine the results back into a single data frame
library(broom)
(gap_nested <- gap_nested %>% 
  mutate(tidy = map(fit, tidy)))
```

```
## # A tibble: 142 x 5
##    continent country     data              fit      tidy            
##    <fct>     <fct>       <list>            <list>   <list>          
##  1 Asia      Afghanistan <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  2 Europe    Albania     <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  3 Africa    Algeria     <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  4 Africa    Angola      <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  5 Americas  Argentina   <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  6 Oceania   Australia   <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  7 Europe    Austria     <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  8 Asia      Bahrain     <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
##  9 Asia      Bangladesh  <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
## 10 Europe    Belgium     <tibble [12 × 4]> <S3: lm> <tibble [2 × 5]>
## # … with 132 more rows
```

```r
(gap_coefs <- gap_nested %>% 
   select(continent, country, tidy) %>% 
   unnest(tidy))
```

```
## # A tibble: 284 x 7
##    continent country     term         estimate std.error statistic  p.value
##    <fct>     <fct>       <chr>           <dbl>     <dbl>     <dbl>    <dbl>
##  1 Asia      Afghanistan (Intercept)  -508.     40.5        -12.5  1.93e- 7
##  2 Asia      Afghanistan year            0.275   0.0205      13.5  9.84e- 8
##  3 Europe    Albania     (Intercept)  -594.     65.7         -9.05 3.94e- 6
##  4 Europe    Albania     year            0.335   0.0332      10.1  1.46e- 6
##  5 Africa    Algeria     (Intercept) -1068.     43.8        -24.4  3.07e-10
##  6 Africa    Algeria     year            0.569   0.0221      25.7  1.81e-10
##  7 Africa    Angola      (Intercept)  -377.     46.6         -8.08 1.08e- 5
##  8 Africa    Angola      year            0.209   0.0235       8.90 4.59e- 6
##  9 Americas  Argentina   (Intercept)  -390.      9.68       -40.3  2.14e-12
## 10 Americas  Argentina   year            0.232   0.00489     47.4  4.22e-13
## # … with 274 more rows
```

## Parallel computing

![From [An introduction to parallel programming using Python's multiprocessing module](http://sebastianraschka.com/Articles/2014_multiprocessing.html)](https://sebastianraschka.com/images/blog/2014/multiprocessing_intro/multiprocessing_scheme.png)

**Parallel computing** (or processing) is a type of computation whereby many calculations or processes are carried out simultaneously.^[["Parallel computing"](https://en.wikipedia.org/wiki/Parallel_computing)] Rather than processing problems in **serial** (or sequential) order, the computer splits the task up into smaller parts that can be processed simultaneously using multiple processors. This is also called **multithreading**. By spliting the job up into simultaneous operations running in **parallel**, you complete your operation quicker, making the code more efficient. This approach works great with split-apply-combine because all the applied operations can be run independently. Why wait for the first chunk to complete if you can perform the operation on the second chunk at the same time?

### Why use parallel computing

* Parallel computing **imitates real life** - in the real world, people use their brains to think in parallel - we multitask all the time without even thinking about it. Institutions are structured to process information in parallel, rather than in serial.
* It can be **more efficient** - by throwing more resources at a problem you can shorten the time to completion.
* You can **tackle larger problems** - more resources enables you to scale up the amount of data you process and potentially solve a larger problem.
* **Distributed resources** are cheaper than upgrading your own equipment. Why spend thousands of dollars beefing up your own laptop when you can instead rent computing resources from Google or Amazon for mere pennies?

### Why not to use parallel computing

* **Limits to efficiency gains** - [Amdahl's law](https://en.wikipedia.org/wiki/Amdahl's_law) defines theoretical limits to how much you can speed up computations via parallel computing. Because of this, you achieve diminishing returns over time.

    ![Amdahl's Law from [Wikipedia](https://en.wikipedia.org/wiki/Amdahl's_law)](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/AmdahlsLaw.svg/768px-AmdahlsLaw.svg.png)
    
* **Complexity** - writing parallel code can be more complicated than writing serial code, especially in R because it does not natively implement parallel computing - you have to explicitly build it into your script.
* **Dependencies** - your computation may rely on the output from the first set of tasks to perform the second tasks. If you compute the problem in parallel fashion, the individual chunks do not communicate with one another.
* **Parallel slowdown** - parallel computing speeds up computations at a price. Once the problem is broken into separate threads, reading and writing data from the threads to memory or the hard drive takes time. Some tasks are not improved by spliting the process into parallel operations.

## `multidplyr` {#multidplyr}

[`multidplyr`](https://github.com/hadley/multidplyr) is a work-in-progress package that implements parallel computing locally using `dplyr`. Rather than performing computations using a single core or processor, it spreads the computation across multiple cores. The basic sequence of steps is:

1. Call `partition()` to split the dataset across multiple cores. This makes a partitioned data frame, or a `party df` for short.
1. Each `dplyr` verb applied to a `party df` performs the operation independently on each core. It leaves each result on each core, and returns another `party df`.
1. When you're done with the expensive operations that need to be done on each core, you call `collect()` to retrieve the data and bring it back to you local computer.

### `nycflights13::flights` {#flights}

Install `multidplyr` if you don't have it already.

```r
devtools::install_github("hadley/multidplyr")
```


```r
library(multidplyr)
library(nycflights13)
```

Next, partition the flights data by flight number, compute the average delay per flight, and then collect the results:


```r
flights1 <- partition(flights, flight)
flights2 <- summarize(flights1, dep_delay = mean(dep_delay, na.rm = TRUE))
flights3 <- collect(flights2)
```

The `dplyr` code looks the same as usual, but behind the scenes things are very different. `flights1` and `flights2` are `party df`s. These look like normal data frames, but have an additional attribute: the number of shards. In this example, it tells us that `flights2` is spread across three nodes, and the size on each node varies from 1275 to 1286 rows. `partition()` always makes sure a group is kept together on one node.


```r
flights2
```

```
## Source: party_df [3,844 x 2]
## Shards: 3 [1,237--1,304 rows]
## 
## # Description: S3: party_df
##    flight dep_delay
##     <int>     <dbl>
##  1      2    -0.569
##  2      3     3.67 
##  3      4     7.52 
##  4      6     8.50 
##  5      8     6.94 
##  6     10    24.3  
##  7     11     6.82 
##  8     12    28.3  
##  9     15    10.3  
## 10     19    10.0  
## # … with 3,834 more rows
```

### Performance

For this size of data, using a local cluster actually makes performance slower.


```r
system.time({
  flights %>% 
    partition() %>%
    summarise(mean(dep_delay, na.rm = TRUE)) %>% 
    collect()
})
```

```
##    user  system elapsed 
##   0.471   0.044   0.665
```

```r
system.time({
  flights %>% 
    group_by() %>%
    summarise(mean(dep_delay, na.rm = TRUE))
})
```

```
##    user  system elapsed 
##   0.006   0.000   0.006
```

That's because there's some overhead associated with sending the data to each node and retrieving the results at the end. For basic `dplyr` verbs, `multidplyr` is unlikely to give you significant speed ups unless you have 10s or 100s of millions of data points. It might however, if you're doing more complex things.

### `gapminder` {#gapminder}

Let's now return to `gapminder` and estimate separate linear regression models of life expectancy based on year for each country. We will use `multidplyr` to split the work across multiple cores. Note that we need to use `cluster_library()` to load the `purrr` package on every node.


```r
# split data into nests
gap_nested <- gapminder %>% 
  group_by(continent, country) %>% 
  nest()

# partition gap_nested across the cores
gap_nested_part <- gap_nested %>%
  partition(country)

# apply a linear model to each nested data frame
cluster_library(gap_nested_part, "purrr")

system.time({
  gap_nested_part %>% 
    mutate(fit = map(data, function(df) lm(lifeExp ~ year, data = df)))
})
```

```
##    user  system elapsed 
##   0.002   0.000   0.054
```

Compared to how long running it locally?


```r
system.time({
  gap_nested %>% 
    mutate(fit = map(data, function(df) lm(lifeExp ~ year, data = df)))
})
```

```
##    user  system elapsed 
##   0.082   0.004   0.087
```

So it's roughly 2 times faster to run in parallel. Admittedly you saved only a fraction of a second. In relative terms this is great, but in absolute terms it doesn't mean much. This demonstrates it doesn't always make sense to parallelize operations - only do so if you can make significant gains in computation speed. If each country had thousands of observations, the efficiency gains would have been more dramatic.

### Acknowledgments

* [Parallel Algorithms Advantages and Disadvantages](http://www.slideshare.net/lucky43/parallel-computing-advantages-and-disadvantages)

### Session Info



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
##  date     2019-05-07                  
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
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.1   2018-10-26 [1] CRAN (R 3.5.1)
##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr       * 0.8.0.1 2019-02-15 [1] CRAN (R 3.5.2)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  forcats     * 0.4.0   2019-02-17 [2] CRAN (R 3.5.2)
##  fs            1.2.7   2019-03-19 [1] CRAN (R 3.5.3)
##  gapminder   * 0.3.0   2017-10-31 [1] CRAN (R 3.5.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2     * 3.1.0   2018-10-25 [1] CRAN (R 3.5.0)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  gtable        0.2.0   2016-02-26 [2] CRAN (R 3.5.0)
##  haven         2.1.0   2019-02-19 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite      1.6     2018-12-07 [2] CRAN (R 3.5.0)
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
