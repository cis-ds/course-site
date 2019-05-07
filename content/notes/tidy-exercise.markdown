---
title: "Practice tidying data"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/datawrangle_tidy_exercise.html"]
categories: ["datawrangle"]

menu:
  notes:
    parent: Data wrangling
    weight: 8
---




```r
library(tidyverse)
```

For each exercise, tidy the data frame. Before you write any code examine the structure of the data frame and mentally (or with pen-and-paper) sketch out what you think the tidy data structure should be.

## Race data


```r
library(rcfss)
race
```

```
## # A tibble: 4 x 8
##   Name   `50` `100` `150` `200` `250` `300` `350`
##   <fct> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
## 1 Carla   1.2   1.8   2.2   2.3   3     2.5   1.8
## 2 Mace    1.5   1.1   1.9   2     3.6   3     2.5
## 3 Lea     1.7   1.6   2.3   2.7   2.6   2.2   2.6
## 4 Karen   1.3   1.7   1.9   2.2   3.2   1.5   1.9
```

Important info:

* `Name` - pretty obvious
* `50`:`350` - column names define different lengths of time
* Cell values are scores associated with each name and length of time

<details> 
  <summary>Click for a hint</summary>
  <p>
  
**Tidy data structure**


```
## # A tibble: 28 x 3
##    Name   Time Score
##    <fct> <int> <dbl>
##  1 Carla    50   1.2
##  2 Carla   100   1.8
##  3 Carla   150   2.2
##  4 Carla   200   2.3
##  5 Carla   250   3  
##  6 Carla   300   2.5
##  7 Carla   350   1.8
##  8 Karen    50   1.3
##  9 Karen   100   1.7
## 10 Karen   150   1.9
## # … with 18 more rows
```

  </p>
</details>

<details> 
  <summary>Click for the solution</summary>
  <p>

This is essentially a gathering operation. Except for the `Name` column, the remaining columns are actually one variable spread across multiple columns. The column names are a distinct variable, and the columns' values are another variable. We want to gather these columns. The `key` will tell us the original column name, and the `value` will give us the values in the cells. Because the column names are actually numeric values, we set `convert = TRUE` to coerce the new `Time` column into a numeric column (or vector). (The last line isn't necessary, but sorts the data frame in a consistent manner.)


```r
race %>%
  gather(key = Time, value = Score, -Name, convert = TRUE) %>%
  arrange(Name, Time)
```

```
## # A tibble: 28 x 3
##    Name   Time Score
##    <fct> <int> <dbl>
##  1 Carla    50   1.2
##  2 Carla   100   1.8
##  3 Carla   150   2.2
##  4 Carla   200   2.3
##  5 Carla   250   3  
##  6 Carla   300   2.5
##  7 Carla   350   1.8
##  8 Karen    50   1.3
##  9 Karen   100   1.7
## 10 Karen   150   1.9
## # … with 18 more rows
```

  </p>
</details>

## Clinical trials


```r
results
```

```
## # A tibble: 20 x 3
##    Ind   Treatment value
##    <chr> <chr>     <int>
##  1 Ind1  Treat         1
##  2 Ind2  Treat         2
##  3 Ind3  Treat         3
##  4 Ind4  Treat         4
##  5 Ind5  Treat         5
##  6 Ind6  Treat         6
##  7 Ind7  Treat         7
##  8 Ind8  Treat         8
##  9 Ind9  Treat         9
## 10 Ind10 Treat        10
## 11 Ind1  Cont         11
## 12 Ind2  Cont         12
## 13 Ind3  Cont         13
## 14 Ind4  Cont         14
## 15 Ind5  Cont         15
## 16 Ind6  Cont         16
## 17 Ind7  Cont         17
## 18 Ind8  Cont         18
## 19 Ind9  Cont         19
## 20 Ind10 Cont         20
```

Important info:

* `Ind` - individual participating in the experiment
* `Treatment` - trial type (`Treat` or `Cont`)
* `value` - result of experiment

<details> 
  <summary>Click for a hint</summary>
  <p>
  
**Tidy data structure**


```
## # A tibble: 10 x 3
##    Ind    Cont Treat
##    <chr> <int> <int>
##  1 Ind1     11     1
##  2 Ind10    20    10
##  3 Ind2     12     2
##  4 Ind3     13     3
##  5 Ind4     14     4
##  6 Ind5     15     5
##  7 Ind6     16     6
##  8 Ind7     17     7
##  9 Ind8     18     8
## 10 Ind9     19     9
```

  </p>
</details>

<details> 
  <summary>Click for the solution</summary>
  <p>

This dataset is not tidy because observations are spread across multiple rows. There only needs to be one row for each individual. Then `Treat` and `Cont` can be stored in separate columns.


```r
results %>%
  spread(key = Treatment, value = value)
```

```
## # A tibble: 10 x 3
##    Ind    Cont Treat
##    <chr> <int> <int>
##  1 Ind1     11     1
##  2 Ind10    20    10
##  3 Ind2     12     2
##  4 Ind3     13     3
##  5 Ind4     14     4
##  6 Ind5     15     5
##  7 Ind6     16     6
##  8 Ind7     17     7
##  9 Ind8     18     8
## 10 Ind9     19     9
```

  </p>
</details>

## Grades


```r
grades
```

```
## # A tibble: 12 x 6
##       ID  Test  Year  Fall Spring Winter
##    <int> <int> <int> <int>  <int>  <int>
##  1     1     1  2008    15     16     19
##  2     1     1  2009    12     13     27
##  3     1     2  2008    22     22     24
##  4     1     2  2009    10     14     20
##  5     2     1  2008    12     13     25
##  6     2     1  2009    16     14     21
##  7     2     2  2008    13     11     29
##  8     2     2  2009    23     20     26
##  9     3     1  2008    11     12     22
## 10     3     1  2009    13     11     27
## 11     3     2  2008    17     12     23
## 12     3     2  2009    14      9     31
```

This one is a bit tougher. Important info:

* **The unit of analysis is ID-Year-Quarter.** That is, in the tidy formulation each observation represents one individual during one quarter in a given year.
* **Each test is unique.** As in they should be treated as two separate variables.

<details> 
  <summary>Click for a hint</summary>
  <p>

**Tidy data structure**


```
## # A tibble: 18 x 5
##       ID  Year Quarter Test1 Test2
##    <int> <int> <chr>   <int> <int>
##  1     1  2008 Fall       15    22
##  2     1  2008 Spring     16    22
##  3     1  2008 Winter     19    24
##  4     1  2009 Fall       12    10
##  5     1  2009 Spring     13    14
##  6     1  2009 Winter     27    20
##  7     2  2008 Fall       12    13
##  8     2  2008 Spring     13    11
##  9     2  2008 Winter     25    29
## 10     2  2009 Fall       16    23
## 11     2  2009 Spring     14    20
## 12     2  2009 Winter     21    26
## 13     3  2008 Fall       11    17
## 14     3  2008 Spring     12    12
## 15     3  2008 Winter     22    23
## 16     3  2009 Fall       13    14
## 17     3  2009 Spring     11     9
## 18     3  2009 Winter     27    31
```

  </p>
</details>

<details> 
  <summary>Click for the solution</summary>
  <p>

In this example, the basic unit of observation is the test. Each individual takes two separate tests (labeled `1` and `2`) at multiple points in time: during each quarter (`Fall`, `Winter`, `Spring`) as well as in multiple years (`2008` and `2009`). So our final data frame should contain five columns: `ID` (identifying the student), `Year` (year the test was taken), `Quarter` (quarter in which the test was taken), `Test1` (score on the first test), and `Test2` (score on the second test).

Let's start with the gathering operation: we want to gather `Fall`, `Winter`, and `Spring` into a single column (we can use the inclusive select function `:` to gather these three columns):


```r
grades %>%
  gather(key = Quarter, value = Score, Fall:Winter)
```

```
## # A tibble: 36 x 5
##       ID  Test  Year Quarter Score
##    <int> <int> <int> <chr>   <int>
##  1     1     1  2008 Fall       15
##  2     1     1  2009 Fall       12
##  3     1     2  2008 Fall       22
##  4     1     2  2009 Fall       10
##  5     2     1  2008 Fall       12
##  6     2     1  2009 Fall       16
##  7     2     2  2008 Fall       13
##  8     2     2  2009 Fall       23
##  9     3     1  2008 Fall       11
## 10     3     1  2009 Fall       13
## # … with 26 more rows
```

Good, but now we spread observations across multiple rows. Remember that we want each test to be a separate variable. To do that, we can spread those values across two columns.


```r
grades %>%
  gather(key = Quarter, value = Score, Fall:Winter) %>%
  spread(key = Test, value = Score)
```

```
## # A tibble: 18 x 5
##       ID  Year Quarter   `1`   `2`
##    <int> <int> <chr>   <int> <int>
##  1     1  2008 Fall       15    22
##  2     1  2008 Spring     16    22
##  3     1  2008 Winter     19    24
##  4     1  2009 Fall       12    10
##  5     1  2009 Spring     13    14
##  6     1  2009 Winter     27    20
##  7     2  2008 Fall       12    13
##  8     2  2008 Spring     13    11
##  9     2  2008 Winter     25    29
## 10     2  2009 Fall       16    23
## 11     2  2009 Spring     14    20
## 12     2  2009 Winter     21    26
## 13     3  2008 Fall       11    17
## 14     3  2008 Spring     12    12
## 15     3  2008 Winter     22    23
## 16     3  2009 Fall       13    14
## 17     3  2009 Spring     11     9
## 18     3  2009 Winter     27    31
```

This is an acceptable solution, but look what happened to the column names for each test: they're labeled as numbers (`1` and `2`). We'd rather give columns text labels, since those are easier to reference in our code. We can use a function called `str_c()` from the `stringr` library to add text to the `Test` column before we spread it. `str_c()` combines two or more values together to create a single value:[^unite]


```r
library(stringr)

grades %>%
  gather(key = Quarter, value = Score, Fall:Winter) %>%
  mutate(Test = str_c("Test", Test))
```

```
## # A tibble: 36 x 5
##       ID Test   Year Quarter Score
##    <int> <chr> <int> <chr>   <int>
##  1     1 Test1  2008 Fall       15
##  2     1 Test1  2009 Fall       12
##  3     1 Test2  2008 Fall       22
##  4     1 Test2  2009 Fall       10
##  5     2 Test1  2008 Fall       12
##  6     2 Test1  2009 Fall       16
##  7     2 Test2  2008 Fall       13
##  8     2 Test2  2009 Fall       23
##  9     3 Test1  2008 Fall       11
## 10     3 Test1  2009 Fall       13
## # … with 26 more rows
```

```r
grades %>%
  gather(key = Quarter, value = Score, Fall:Winter) %>%
  mutate(Test = str_c("Test", Test)) %>%
  spread(key = Test, value = Score)
```

```
## # A tibble: 18 x 5
##       ID  Year Quarter Test1 Test2
##    <int> <int> <chr>   <int> <int>
##  1     1  2008 Fall       15    22
##  2     1  2008 Spring     16    22
##  3     1  2008 Winter     19    24
##  4     1  2009 Fall       12    10
##  5     1  2009 Spring     13    14
##  6     1  2009 Winter     27    20
##  7     2  2008 Fall       12    13
##  8     2  2008 Spring     13    11
##  9     2  2008 Winter     25    29
## 10     2  2009 Fall       16    23
## 11     2  2009 Spring     14    20
## 12     2  2009 Winter     21    26
## 13     3  2008 Fall       11    17
## 14     3  2008 Spring     12    12
## 15     3  2008 Winter     22    23
## 16     3  2009 Fall       13    14
## 17     3  2009 Spring     11     9
## 18     3  2009 Winter     27    31
```

If we're cleaning up the data frame, let's also arrange it in a logical order:


```r
grades %>%
  gather(key = Quarter, value = Score, Fall:Winter) %>%
  mutate(Test = str_c("Test", Test)) %>%
  spread(key = Test, value = Score) %>%
  arrange(ID, Year, Quarter)
```

```
## # A tibble: 18 x 5
##       ID  Year Quarter Test1 Test2
##    <int> <int> <chr>   <int> <int>
##  1     1  2008 Fall       15    22
##  2     1  2008 Spring     16    22
##  3     1  2008 Winter     19    24
##  4     1  2009 Fall       12    10
##  5     1  2009 Spring     13    14
##  6     1  2009 Winter     27    20
##  7     2  2008 Fall       12    13
##  8     2  2008 Spring     13    11
##  9     2  2008 Winter     25    29
## 10     2  2009 Fall       16    23
## 11     2  2009 Spring     14    20
## 12     2  2009 Winter     21    26
## 13     3  2008 Fall       11    17
## 14     3  2008 Spring     12    12
## 15     3  2008 Winter     22    23
## 16     3  2009 Fall       13    14
## 17     3  2009 Spring     11     9
## 18     3  2009 Winter     27    31
```

[^unite]: You might think to use the `unite()` function here, but it won't work unless you first create a column which only contains the value `Test`, like so:

    
    ```r
    grades %>%
      gather(key = Quarter, value = Score, Fall:Winter) %>%
      mutate(test_label = "Test") %>%
      unite(col = Test, test_label, Test)
    ```
    
    ```
    ## # A tibble: 36 x 5
    ##       ID Test    Year Quarter Score
    ##    <int> <chr>  <int> <chr>   <int>
    ##  1     1 Test_1  2008 Fall       15
    ##  2     1 Test_1  2009 Fall       12
    ##  3     1 Test_2  2008 Fall       22
    ##  4     1 Test_2  2009 Fall       10
    ##  5     2 Test_1  2008 Fall       12
    ##  6     2 Test_1  2009 Fall       16
    ##  7     2 Test_2  2008 Fall       13
    ##  8     2 Test_2  2009 Fall       23
    ##  9     3 Test_1  2008 Fall       11
    ## 10     3 Test_1  2009 Fall       13
    ## # … with 26 more rows
    ```
    
    This works, but requires two lines of code instead of one.
    
  </p>
</details>

## Activities


```r
activities
```

```
## # A tibble: 10 x 8
##    id    trt   work.T1 play.T1 talk.T1 work.T2 play.T2 talk.T2
##    <chr> <chr>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
##  1 x1    tr     0.652    0.865  0.536   0.275    0.354  0.0319
##  2 x2    cnt    0.568    0.615  0.0931  0.229    0.936  0.114 
##  3 x3    cnt    0.114    0.775  0.170   0.0144   0.246  0.469 
##  4 x4    tr     0.596    0.356  0.900   0.729    0.473  0.397 
##  5 x5    cnt    0.358    0.406  0.423   0.250    0.192  0.834 
##  6 x6    cnt    0.429    0.707  0.748   0.161    0.583  0.761 
##  7 x7    cnt    0.0519   0.838  0.823   0.0170   0.459  0.573 
##  8 x8    cnt    0.264    0.240  0.955   0.486    0.467  0.448 
##  9 x9    tr     0.399    0.771  0.685   0.103    0.400  0.0838
## 10 x10   cnt    0.836    0.356  0.501   0.802    0.505  0.219
```

This one is also pretty difficult, but if you think it through conceptually it is doable. The unit of analysis is a single individual (identified by `id`) observed at two different times (`T1` and `T2`) performing different actions (`work`, `play`, `talk`, and `total` - note that `total` is not merely the sum of the first three values). Individuals in this experiment were assigned to either treatment or control (`trt`) and this information should be preserved in the final data frame.

<details> 
  <summary>Click for a hint</summary>
  <p>
  
**Tidy data structure**


```
## # A tibble: 20 x 6
##    id    trt   time   play   talk   work
##    <chr> <chr> <chr> <dbl>  <dbl>  <dbl>
##  1 x1    tr    T1    0.865 0.536  0.652 
##  2 x1    tr    T2    0.354 0.0319 0.275 
##  3 x10   cnt   T1    0.356 0.501  0.836 
##  4 x10   cnt   T2    0.505 0.219  0.802 
##  5 x2    cnt   T1    0.615 0.0931 0.568 
##  6 x2    cnt   T2    0.936 0.114  0.229 
##  7 x3    cnt   T1    0.775 0.170  0.114 
##  8 x3    cnt   T2    0.246 0.469  0.0144
##  9 x4    tr    T1    0.356 0.900  0.596 
## 10 x4    tr    T2    0.473 0.397  0.729 
## 11 x5    cnt   T1    0.406 0.423  0.358 
## 12 x5    cnt   T2    0.192 0.834  0.250 
## 13 x6    cnt   T1    0.707 0.748  0.429 
## 14 x6    cnt   T2    0.583 0.761  0.161 
## 15 x7    cnt   T1    0.838 0.823  0.0519
## 16 x7    cnt   T2    0.459 0.573  0.0170
## 17 x8    cnt   T1    0.240 0.955  0.264 
## 18 x8    cnt   T2    0.467 0.448  0.486 
## 19 x9    tr    T1    0.771 0.685  0.399 
## 20 x9    tr    T2    0.400 0.0838 0.103
```

  </p>
</details>

<details> 
  <summary>Click for the solution</summary>
  <p>

This is a more complex operation. The basic problem is that we have variables stored in multiple columns (location, with possible values of `work`, `play`, and `talk`). We need to gather these columns into a single column for each variable. But what happens if we just gather them?


```r
activities %>%
  gather(key = key, value = value, -id, -trt)
```

```
## # A tibble: 60 x 4
##    id    trt   key      value
##    <chr> <chr> <chr>    <dbl>
##  1 x1    tr    work.T1 0.652 
##  2 x2    cnt   work.T1 0.568 
##  3 x3    cnt   work.T1 0.114 
##  4 x4    tr    work.T1 0.596 
##  5 x5    cnt   work.T1 0.358 
##  6 x6    cnt   work.T1 0.429 
##  7 x7    cnt   work.T1 0.0519
##  8 x8    cnt   work.T1 0.264 
##  9 x9    tr    work.T1 0.399 
## 10 x10   cnt   work.T1 0.836 
## # … with 50 more rows
```

We've created a new problem! Actually, two problems:

1. We have a single observation stored across multiple rows: we want a single row for each `id` x `trt` pairing
2. We have two variables stored in a single column: `key` contains the information on both location (`work`, `play`, and `talk`) as well as when the measurement was taken (`T1` or `T2`)

The best approach is to fix the second problem by separating the columns, then spreading the different types of measurements back into their own columns.


```r
activities %>%
  gather(key = key, value = value, -id, -trt) %>%
  separate(col = key, into = c("location", "time"))
```

```
## # A tibble: 60 x 5
##    id    trt   location time   value
##    <chr> <chr> <chr>    <chr>  <dbl>
##  1 x1    tr    work     T1    0.652 
##  2 x2    cnt   work     T1    0.568 
##  3 x3    cnt   work     T1    0.114 
##  4 x4    tr    work     T1    0.596 
##  5 x5    cnt   work     T1    0.358 
##  6 x6    cnt   work     T1    0.429 
##  7 x7    cnt   work     T1    0.0519
##  8 x8    cnt   work     T1    0.264 
##  9 x9    tr    work     T1    0.399 
## 10 x10   cnt   work     T1    0.836 
## # … with 50 more rows
```

```r
activities %>%
  gather(key = key, value = value, -id, -trt) %>%
  separate(col = key, into = c("location", "time")) %>%
  spread(key = location, value = value)
```

```
## # A tibble: 20 x 6
##    id    trt   time   play   talk   work
##    <chr> <chr> <chr> <dbl>  <dbl>  <dbl>
##  1 x1    tr    T1    0.865 0.536  0.652 
##  2 x1    tr    T2    0.354 0.0319 0.275 
##  3 x10   cnt   T1    0.356 0.501  0.836 
##  4 x10   cnt   T2    0.505 0.219  0.802 
##  5 x2    cnt   T1    0.615 0.0931 0.568 
##  6 x2    cnt   T2    0.936 0.114  0.229 
##  7 x3    cnt   T1    0.775 0.170  0.114 
##  8 x3    cnt   T2    0.246 0.469  0.0144
##  9 x4    tr    T1    0.356 0.900  0.596 
## 10 x4    tr    T2    0.473 0.397  0.729 
## 11 x5    cnt   T1    0.406 0.423  0.358 
## 12 x5    cnt   T2    0.192 0.834  0.250 
## 13 x6    cnt   T1    0.707 0.748  0.429 
## 14 x6    cnt   T2    0.583 0.761  0.161 
## 15 x7    cnt   T1    0.838 0.823  0.0519
## 16 x7    cnt   T2    0.459 0.573  0.0170
## 17 x8    cnt   T1    0.240 0.955  0.264 
## 18 x8    cnt   T2    0.467 0.448  0.486 
## 19 x9    tr    T1    0.771 0.685  0.399 
## 20 x9    tr    T2    0.400 0.0838 0.103
```

The whole operation in a single chain (with an `arrange()` thrown in to sort the data frame):


```r
activities %>%
  gather(key = key, value = value, -id, -trt) %>%
  separate(key, into = c("location", "time")) %>%
  arrange(id, trt, time) %>%
  spread(key = location, value = value)
```

```
## # A tibble: 20 x 6
##    id    trt   time   play   talk   work
##    <chr> <chr> <chr> <dbl>  <dbl>  <dbl>
##  1 x1    tr    T1    0.865 0.536  0.652 
##  2 x1    tr    T2    0.354 0.0319 0.275 
##  3 x10   cnt   T1    0.356 0.501  0.836 
##  4 x10   cnt   T2    0.505 0.219  0.802 
##  5 x2    cnt   T1    0.615 0.0931 0.568 
##  6 x2    cnt   T2    0.936 0.114  0.229 
##  7 x3    cnt   T1    0.775 0.170  0.114 
##  8 x3    cnt   T2    0.246 0.469  0.0144
##  9 x4    tr    T1    0.356 0.900  0.596 
## 10 x4    tr    T2    0.473 0.397  0.729 
## 11 x5    cnt   T1    0.406 0.423  0.358 
## 12 x5    cnt   T2    0.192 0.834  0.250 
## 13 x6    cnt   T1    0.707 0.748  0.429 
## 14 x6    cnt   T2    0.583 0.761  0.161 
## 15 x7    cnt   T1    0.838 0.823  0.0519
## 16 x7    cnt   T2    0.459 0.573  0.0170
## 17 x8    cnt   T1    0.240 0.955  0.264 
## 18 x8    cnt   T2    0.467 0.448  0.486 
## 19 x9    tr    T1    0.771 0.685  0.399 
## 20 x9    tr    T2    0.400 0.0838 0.103
```

  </p>
</details>

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
