---
title: "Iteration"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/program_iteration.html"]
categories: ["programming"]

menu:
  notes:
    parent: Programming elements
    weight: 5
---




```r
library(tidyverse)
set.seed(1234)
theme_set(theme_minimal())
```

## Writing `for` loops

Functions are one method of reducing duplication in your code. Another tool for reducing duplication is **iteration**, which lets you do the same thing to multiple inputs.

## Example `for` loop


```r
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
```

Let's say we want to compute the median for each column.


```r
median(df$a)
```

```
## [1] -0.5555419
```

```r
median(df$b)
```

```
## [1] -0.4941011
```

```r
median(df$c)
```

```
## [1] -0.4656169
```

```r
median(df$d)
```

```
## [1] -0.605349
```

Boo! We've copied-and-pasted `median()` three times. We don't want to do that. Instead, we can use a `for` loop:


```r
output <- vector(mode = "double", length = ncol(df))
for (i in seq_along(df)) {
  output[[i]] <- median(df[[i]])
}
output
```

```
## [1] -0.5555419 -0.4941011 -0.4656169 -0.6053490
```

Let's review the three components of every `for` loop.

## Output

`output <- vector("double", length = ncol(df))`
    
Before you start a loop, you need to create an empty vector to store the output of the loop. Preallocating space for your output is much more efficient than creating space as you move through the loop. The `vector()` function allows you to create an empty vector of any type. The first argument `mode` defines the type of vector ("logical", "integer", "double", "character", etc.) and the second argument `length` defines the length of the vector.
    
Numeric vectors are initialized to `0`, logical vectors are initialized to `FALSE`, character vectors are initialized to `""`, and list elements to `NULL`.
    

```r
vector(mode = "double", length = ncol(df))
```

```
## [1] 0 0 0 0
```

```r
vector(mode = "logical", length = ncol(df))
```

```
## [1] FALSE FALSE FALSE FALSE
```

```r
vector(mode = "character", length = ncol(df))
```

```
## [1] "" "" "" ""
```

```r
vector(mode = "list", length = ncol(df))
```

```
## [[1]]
## NULL
## 
## [[2]]
## NULL
## 
## [[3]]
## NULL
## 
## [[4]]
## NULL
```

## Sequence

`i in seq_along(df)`
    
This component determines what to loop over. During each iteration through the `for` loop, a new value will be assigned to `i` based on the the defined sequence. Here, the sequence is `seq_along(df)` which creates a numeric vector for a sequence of numbers beginning at 1 and continuing until it reaches the length of `df` (the length here is the number of columns in `df`).
    

```r
seq_along(df)
```

```
## [1] 1 2 3 4
```
    
## Body

`output[[i]] <- median(df[[i]])`
    
This is the code that actually performs the desired calculations. It runs multiple times for every value of `i`. We use `[[` notation to reference each column of `df` and store it in the appropriate element in `output`.

## Why we preallocate space for the output

If you don't preallocate space for the output, each time the `for` loop iterates, it makes a copy of the output and appends the new value at the end. Copying data takes time and memory. If the output is preallocated space, the loop simply fills in the slots with the correct values.


```r
x <- rnorm(1000, mean = 0, sd = 1)
str(x)
```

```
##  num [1:1000] 1.449 -1.069 -0.855 -0.281 -0.994 ...
```

```r
# load microbenchmark library to time code
library(microbenchmark)

microbenchmark(
  # don't preallocate
  `No preallocation` = {
    output <- vector("numeric", 0)
    
    for (i in seq_along(x)) {
      output <- c(output, x[[i]] + 1)
    }
  },
  # preallocate
  `Preallocation` = {
    output <- vector("numeric", length(x))
    
    for (i in seq_along(x)) {
      output[[i]] <- x[[i]] + 1
    }
  }) %>%
  autoplot +
  scale_y_log10(breaks = c(2, 4, 8, 16, 32)) +
  labs(y = "Time [milliseconds]")
```

```
## Coordinate system already present. Adding new coordinate system, which will replace the existing one.
```

```
## Scale for 'y' is already present. Adding another scale for 'y', which
## will replace the existing scale.
```

<img src="/notes/iteration_files/figure-html/preallocate-1.png" width="672" />

Here, preallocating space for the vector cuts the computation time by a factor of 3.

## Exercise: write a `for` loop

### Mean of columns in `mtcars`

Write a `for` loop that calculates the arithmetic mean for every column in `mtcars`.


```r
as_tibble(mtcars)
```

```
## # A tibble: 32 x 11
##      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
##  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
##  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
##  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
##  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
##  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
##  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
##  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
##  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
##  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
## 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
## # … with 22 more rows
```

Before you write the `for` loop, identify the three components you need:

* Output
* Sequence
* Body

<details> 
  <summary>Click for the solution</summary>
  <p>

* Output - a numeric vector of length 11
* Sequence - `i in seq_along(mtcars)`
* Body - calculate the `mean()` of the `\(i\)`th column, store the new value as the `\(i\)`th element of the vector `output`


```r
output <- vector("numeric", ncol(mtcars))

for(i in seq_along(mtcars)){
  output[[i]] <- mean(mtcars[[i]], na.rm = TRUE)
}

output
```

```
##  [1]  20.090625   6.187500 230.721875 146.687500   3.596563   3.217250
##  [7]  17.848750   0.437500   0.406250   3.687500   2.812500
```
    
  </p>
</details>

### Maximum value in each column of `diamonds`

Write a `for` loop that calculates the maximum value in each column of `diamonds`.


```r
diamonds
```

```
## # A tibble: 53,940 x 10
##    carat cut       color clarity depth table price     x     y     z
##    <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
##  1 0.23  Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
##  2 0.21  Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
##  3 0.23  Good      E     VS1      56.9    65   327  4.05  4.07  2.31
##  4 0.290 Premium   I     VS2      62.4    58   334  4.2   4.23  2.63
##  5 0.31  Good      J     SI2      63.3    58   335  4.34  4.35  2.75
##  6 0.24  Very Good J     VVS2     62.8    57   336  3.94  3.96  2.48
##  7 0.24  Very Good I     VVS1     62.3    57   336  3.95  3.98  2.47
##  8 0.26  Very Good H     SI1      61.9    55   337  4.07  4.11  2.53
##  9 0.22  Fair      E     VS2      65.1    61   337  3.87  3.78  2.49
## 10 0.23  Very Good H     VS1      59.4    61   338  4     4.05  2.39
## # … with 53,930 more rows
```

Before you write the `for` loop, identify the three components you need:

* Output
* Sequence
* Body

<details> 
  <summary>Click for the solution</summary>
  <p>

* Output - a vector of length 10
* Sequence - `i in seq_along(diamonds)`
* Body - get the maximum value of the `\(i\)`th column of the data frame `diamonds`, store the new value as the `\(i\)`th element of the list `output`


```r
output <- vector("numeric", ncol(diamonds))

for(i in seq_along(diamonds)){
  output[i] <- max(diamonds[[i]])
}

output
```

```
##  [1]     5.01     5.00     7.00     8.00    79.00    95.00 18823.00
##  [8]    10.74    58.90    31.80
```

To preserve the name attributes from `diamonds`, use the `names()` function to extract the names of each column in `diamonds` and apply them as the names to the `output` vector:


```r
# get the names of the columns in diamonds
names(diamonds)
```

```
##  [1] "carat"   "cut"     "color"   "clarity" "depth"   "table"   "price"  
##  [8] "x"       "y"       "z"
```

```r
# assign the names of the diamonds columns to output
names(output) <- names(diamonds)
output
```

```
##    carat      cut    color  clarity    depth    table    price        x 
##     5.01     5.00     7.00     8.00    79.00    95.00 18823.00    10.74 
##        y        z 
##    58.90    31.80
```

> Notice that all the columns have a maximum value, even the apparently text-based columns. This is because `cut`, `color`, and `clarity` are all stored as factor columns. Remember that [factor vectors are built on top of integers](http://r4ds.had.co.nz/vectors.html#factors-1), so the underlying values are numeric. As a result we can apply `max()` to a factor vector and still retrieve a (partially) meaningful result.

  </p>
</details>

## Map functions

You will frequently need to iterate over vectors or data frames, perform an operation on each element, and save the results somewhere. `for` loops are not the devil. At first, they may seem more intuitive to use because you are explicitly identifying each component of the process. However the downside is that they focus on a lot of non-essential stuff. You have to track the value on which you are iterating, you need to explicitly create a vector to store the output, you have to assign the output of each iteration to the appropriate element in the output vector, etc.

`tidyverse` is all about focusing on **verbs**, not **nouns**. That is, focus on the operation being performed (e.g. `mean()`, `median()`, `max()`), not all the extra code needed to make the operation work. The `purrr` library provides a family of functions that mirrors `for` loops. They:

* Loop over a vector
* Do something to each element
* Save the results

There is one function for each type of output:

* `map()` makes a list.
* `map_lgl()` makes a logical vector.
* `map_int()` makes an integer vector.
* `map_dbl()` makes a double vector.
* `map_chr()` makes a character vector.


```r
map_dbl(df, mean)
```

```
##          a          b          c          d 
## -0.3831574 -0.1181707 -0.3879468 -0.7661931
```

```r
map_dbl(df, median)
```

```
##          a          b          c          d 
## -0.5555419 -0.4941011 -0.4656169 -0.6053490
```

```r
map_dbl(df, sd)
```

```
##         a         b         c         d 
## 0.9957875 1.0673376 0.6660013 0.8942458
```

Just like all of our functions in the `tidyverse`, the first argument is always the data object, and the second argument is the function to be applied. Additional arguments for the function to be applied can be specified like this:


```r
map_dbl(df, mean, na.rm = TRUE)
```

```
##          a          b          c          d 
## -0.3831574 -0.1181707 -0.3879468 -0.7661931
```

Or data can be piped:


```r
df %>%
  map_dbl(mean, na.rm = TRUE)
```

```
##          a          b          c          d 
## -0.3831574 -0.1181707 -0.3879468 -0.7661931
```

## Exercise: rewrite our `for` loops using a `map()` function

### Mean of columns in `mtcars`

Write a `map()` function that calculates the arithmetic mean for every column in `mtcars`.


```r
as_tibble(mtcars)
```

```
## # A tibble: 32 x 11
##      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
##  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
##  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
##  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
##  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
##  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
##  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
##  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
##  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
##  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
## 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
## # … with 22 more rows
```

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
map_dbl(mtcars, mean)
```

```
##        mpg        cyl       disp         hp       drat         wt 
##  20.090625   6.187500 230.721875 146.687500   3.596563   3.217250 
##       qsec         vs         am       gear       carb 
##  17.848750   0.437500   0.406250   3.687500   2.812500
```
    
  </p>
</details>

### Maximum value in each column of `diamonds`

Write a `map()` function that calculates the maximum value in each column of `diamonds`.


```r
diamonds
```

```
## # A tibble: 53,940 x 10
##    carat cut       color clarity depth table price     x     y     z
##    <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
##  1 0.23  Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
##  2 0.21  Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
##  3 0.23  Good      E     VS1      56.9    65   327  4.05  4.07  2.31
##  4 0.290 Premium   I     VS2      62.4    58   334  4.2   4.23  2.63
##  5 0.31  Good      J     SI2      63.3    58   335  4.34  4.35  2.75
##  6 0.24  Very Good J     VVS2     62.8    57   336  3.94  3.96  2.48
##  7 0.24  Very Good I     VVS1     62.3    57   336  3.95  3.98  2.47
##  8 0.26  Very Good H     SI1      61.9    55   337  4.07  4.11  2.53
##  9 0.22  Fair      E     VS2      65.1    61   337  3.87  3.78  2.49
## 10 0.23  Very Good H     VS1      59.4    61   338  4     4.05  2.39
## # … with 53,930 more rows
```

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
map_dbl(diamonds, max)
```

```
##    carat      cut    color  clarity    depth    table    price        x 
##     5.01     5.00     7.00     8.00    79.00    95.00 18823.00    10.74 
##        y        z 
##    58.90    31.80
```

  </p>
</details>

## Scoped verbs

Frequently when working with data frames you may wish to apply a specific function to multiple columns. For instance, calculating the average value of each column in `mtcars`. If we wanted to calculate the average of a single column, it would be pretty simple using just `tidyverse` functions:


```r
mtcars %>%
  summarize(mpg = mean(mpg))
```

```
##        mpg
## 1 20.09062
```

If we want to calculate the mean for all of them, we'd have to duplicate this code many times over:


```r
mtcars %>%
  summarize(mpg = mean(mpg),
            cyl = mean(cyl),
            disp = mean(disp),
            hp = mean(hp),
            drat = mean(drat),
            wt = mean(wt),
            qsec = mean(qsec),
            vs = mean(vs),
            am = mean(am),
            gear = mean(gear),
            carb = mean(carb))
```

```
##        mpg    cyl     disp       hp     drat      wt     qsec     vs
## 1 20.09062 6.1875 230.7219 146.6875 3.596563 3.21725 17.84875 0.4375
##        am   gear   carb
## 1 0.40625 3.6875 2.8125
```

But this is very repetitive and prone to mistakes - I cannot tell you how many typos I originally had in this code when I first wrote it. We've seen how to use loops and `map()` functions to solve this task - let's check out one final method: **scoped verbs**.

Scoped verbs allow you to use standard **verbs** (or functions) in `dplyr` that affect multiple variables at once, combining both elements of repetition and (in some cases) conditional expressions:

* `_if` allows you to pick variables based on a predicate function like `is.numeric()` or `is.character()`
* `_at` allows you to pick variables using the same syntax as `select()`
* `_all` operates on all variables

## summarize

### `summarize_all()`

`summarize_all()` takes a tibble and a function and applies that function to each column:


```r
summarize_all(mtcars, .funs = mean)
```

```
##        mpg    cyl     disp       hp     drat      wt     qsec     vs
## 1 20.09062 6.1875 230.7219 146.6875 3.596563 3.21725 17.84875 0.4375
##        am   gear   carb
## 1 0.40625 3.6875 2.8125
```

If you want to apply multiple summaries, use store the functions in a `list()`:


```r
summarize_all(mtcars, .funs = list(min, max))
```

```
##   mpg_fn1 cyl_fn1 disp_fn1 hp_fn1 drat_fn1 wt_fn1 qsec_fn1 vs_fn1 am_fn1
## 1    10.4       4     71.1     52     2.76  1.513     14.5      0      0
##   gear_fn1 carb_fn1 mpg_fn2 cyl_fn2 disp_fn2 hp_fn2 drat_fn2 wt_fn2
## 1        3        1    33.9       8      472    335     4.93  5.424
##   qsec_fn2 vs_fn2 am_fn2 gear_fn2 carb_fn2
## 1     22.9      1      1        5        8
```

And as always, you could combine this with `group_by()` to calculate group-level summary statistics:


```r
mtcars %>%
  group_by(gear) %>%
  summarize_all(.funs = mean)
```

```
## # A tibble: 3 x 11
##    gear   mpg   cyl  disp    hp  drat    wt  qsec    vs    am  carb
##   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
## 1     3  16.1  7.47  326. 176.   3.13  3.89  17.7 0.2   0      2.67
## 2     4  24.5  4.67  123.  89.5  4.04  2.62  19.0 0.833 0.667  2.33
## 3     5  21.4  6     202. 196.   3.92  2.63  15.6 0.2   1      4.4
```

### `summarize_at()`

`summarize_at()` allows you to pick columns in the same way as `select()`, that is, based on their names. There is one small difference: you need to wrap the complete selection with the `vars()` helper (this avoids ambiguity).


```r
summarize_at(mtcars, .vars = vars(-mpg), .funs = mean)
```

```
##      cyl     disp       hp     drat      wt     qsec     vs      am   gear
## 1 6.1875 230.7219 146.6875 3.596563 3.21725 17.84875 0.4375 0.40625 3.6875
##     carb
## 1 2.8125
```

By default, the newly created columns have the shortest names needed to uniquely identify the output.


```r
summarize_at(mtcars, .vars = vars(mpg), .funs = list(min, max))
```

```
##    fn1  fn2
## 1 10.4 33.9
```

```r
summarize_at(mtcars, .vars = vars(mpg, wt), .funs = min)
```

```
##    mpg    wt
## 1 10.4 1.513
```

```r
summarize_at(mtcars, .vars = vars(-mpg), .funs = list(min, max))
```

```
##   cyl_fn1 disp_fn1 hp_fn1 drat_fn1 wt_fn1 qsec_fn1 vs_fn1 am_fn1 gear_fn1
## 1       4     71.1     52     2.76  1.513     14.5      0      0        3
##   carb_fn1 cyl_fn2 disp_fn2 hp_fn2 drat_fn2 wt_fn2 qsec_fn2 vs_fn2 am_fn2
## 1        1       8      472    335     4.93  5.424     22.9      1      1
##   gear_fn2 carb_fn2
## 1        5        8
```

### `summarize_if()`

`summarize_at()` allows you to pick variables to summarize based on their name, whereas `summarize_if()` allows you to pick variables to summarize based on some property of the column. Typically this is their type because you want to (e.g.) apply a numeric summary function only to numeric columns:


```r
starwars
```

```
## # A tibble: 87 x 13
##    name  height  mass hair_color skin_color eye_color birth_year gender
##    <chr>  <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
##  1 Luke…    172    77 blond      fair       blue            19   male  
##  2 C-3PO    167    75 <NA>       gold       yellow         112   <NA>  
##  3 R2-D2     96    32 <NA>       white, bl… red             33   <NA>  
##  4 Dart…    202   136 none       white      yellow          41.9 male  
##  5 Leia…    150    49 brown      light      brown           19   female
##  6 Owen…    178   120 brown, gr… light      blue            52   male  
##  7 Beru…    165    75 brown      light      blue            47   female
##  8 R5-D4     97    32 <NA>       white, red red             NA   <NA>  
##  9 Bigg…    183    84 black      light      brown           24   male  
## 10 Obi-…    182    77 auburn, w… fair       blue-gray       57   male  
## # … with 77 more rows, and 5 more variables: homeworld <chr>,
## #   species <chr>, films <list>, vehicles <list>, starships <list>
```

```r
starwars %>%
  group_by(species) %>%
  summarize_if(.predicate = is.numeric, .funs = mean, na.rm = TRUE)
```

```
## # A tibble: 38 x 4
##    species   height  mass birth_year
##    <chr>      <dbl> <dbl>      <dbl>
##  1 <NA>         160  48         62  
##  2 Aleena        79  15        NaN  
##  3 Besalisk     198 102        NaN  
##  4 Cerean       198  82         92  
##  5 Chagrian     196 NaN        NaN  
##  6 Clawdite     168  55        NaN  
##  7 Droid        140  69.8       53.3
##  8 Dug          112  40        NaN  
##  9 Ewok          88  20          8  
## 10 Geonosian    183  80        NaN  
## # … with 28 more rows
```

(Note that `na.rm = TRUE` is passed on to `mean()` in the same way as in `purrr::map()`.)

## Mutate

`mutate_all()`, `mutate_if()` and `mutate_at()` work in a similar way to their summarize equivalents.


```r
mutate_all(mtcars, .funs = log10)
```

```
##         mpg       cyl     disp       hp      drat        wt     qsec   vs
## 1  1.322219 0.7781513 2.204120 2.041393 0.5910646 0.4183013 1.216430 -Inf
## 2  1.322219 0.7781513 2.204120 2.041393 0.5910646 0.4586378 1.230960 -Inf
## 3  1.357935 0.6020600 2.033424 1.968483 0.5854607 0.3654880 1.269746    0
## 4  1.330414 0.7781513 2.411620 2.041393 0.4885507 0.5071810 1.288696    0
## 5  1.271842 0.9030900 2.556303 2.243038 0.4983106 0.5365584 1.230960 -Inf
## 6  1.257679 0.7781513 2.352183 2.021189 0.4409091 0.5390761 1.305781    0
## 7  1.155336 0.9030900 2.556303 2.389166 0.5065050 0.5526682 1.199755 -Inf
## 8  1.387390 0.6020600 2.166430 1.792392 0.5670264 0.5037907 1.301030    0
## 9  1.357935 0.6020600 2.148603 1.977724 0.5932861 0.4983106 1.359835    0
## 10 1.283301 0.7781513 2.224274 2.089905 0.5932861 0.5365584 1.262451    0
## 11 1.250420 0.7781513 2.224274 2.089905 0.5932861 0.5365584 1.276462    0
## 12 1.214844 0.9030900 2.440594 2.255273 0.4871384 0.6095944 1.240549 -Inf
## 13 1.238046 0.9030900 2.440594 2.255273 0.4871384 0.5717088 1.245513 -Inf
## 14 1.181844 0.9030900 2.440594 2.255273 0.4871384 0.5774918 1.255273 -Inf
## 15 1.017033 0.9030900 2.673942 2.311754 0.4668676 0.7201593 1.254790 -Inf
## 16 1.017033 0.9030900 2.662758 2.332438 0.4771213 0.7343197 1.250908 -Inf
## 17 1.167317 0.9030900 2.643453 2.361728 0.5092025 0.7279477 1.241048 -Inf
## 18 1.510545 0.6020600 1.895975 1.819544 0.6106602 0.3424227 1.289366    0
## 19 1.482874 0.6020600 1.879096 1.716003 0.6928469 0.2081725 1.267641    0
## 20 1.530200 0.6020600 1.851870 1.812913 0.6253125 0.2636361 1.298853    0
## 21 1.332438 0.6020600 2.079543 1.986772 0.5682017 0.3918169 1.301247    0
## 22 1.190332 0.9030900 2.502427 2.176091 0.4409091 0.5465427 1.227115 -Inf
## 23 1.181844 0.9030900 2.482874 2.176091 0.4983106 0.5359267 1.238046 -Inf
## 24 1.123852 0.9030900 2.544068 2.389166 0.5717088 0.5843312 1.187803 -Inf
## 25 1.283301 0.9030900 2.602060 2.243038 0.4885507 0.5848963 1.231724 -Inf
## 26 1.436163 0.6020600 1.897627 1.819544 0.6106602 0.2866810 1.276462    0
## 27 1.414973 0.6020600 2.080266 1.959041 0.6464037 0.3304138 1.222716 -Inf
## 28 1.482874 0.6020600 1.978181 2.053078 0.5763414 0.1798389 1.227887    0
## 29 1.198657 0.9030900 2.545307 2.421604 0.6253125 0.5010593 1.161368 -Inf
## 30 1.294466 0.7781513 2.161368 2.243038 0.5587086 0.4424798 1.190332 -Inf
## 31 1.176091 0.9030900 2.478566 2.525045 0.5490033 0.5526682 1.164353 -Inf
## 32 1.330414 0.6020600 2.082785 2.037426 0.6138418 0.4440448 1.269513    0
##      am      gear      carb
## 1     0 0.6020600 0.6020600
## 2     0 0.6020600 0.6020600
## 3     0 0.6020600 0.0000000
## 4  -Inf 0.4771213 0.0000000
## 5  -Inf 0.4771213 0.3010300
## 6  -Inf 0.4771213 0.0000000
## 7  -Inf 0.4771213 0.6020600
## 8  -Inf 0.6020600 0.3010300
## 9  -Inf 0.6020600 0.3010300
## 10 -Inf 0.6020600 0.6020600
## 11 -Inf 0.6020600 0.6020600
## 12 -Inf 0.4771213 0.4771213
## 13 -Inf 0.4771213 0.4771213
## 14 -Inf 0.4771213 0.4771213
## 15 -Inf 0.4771213 0.6020600
## 16 -Inf 0.4771213 0.6020600
## 17 -Inf 0.4771213 0.6020600
## 18    0 0.6020600 0.0000000
## 19    0 0.6020600 0.3010300
## 20    0 0.6020600 0.0000000
## 21 -Inf 0.4771213 0.0000000
## 22 -Inf 0.4771213 0.3010300
## 23 -Inf 0.4771213 0.3010300
## 24 -Inf 0.4771213 0.6020600
## 25 -Inf 0.4771213 0.3010300
## 26    0 0.6020600 0.0000000
## 27    0 0.6989700 0.3010300
## 28    0 0.6989700 0.3010300
## 29    0 0.6989700 0.6020600
## 30    0 0.6989700 0.7781513
## 31    0 0.6989700 0.9030900
## 32    0 0.6020600 0.3010300
```

## Filter

`filter_all()` is the most useful of the three `filter()` variants. You use it conjunction with `all_vars()` or `any_vars()` depending on whether or not you want rows where all variables meet the criterion, or where just one variable meets it.

It's particularly useful finding missing values:


```r
library(nycflights13)

# Rows where any value is missing
filter_all(weather, .vars_predicate = any_vars(is.na(.)))
```

```
## # A tibble: 21,135 x 15
##    origin  year month   day  hour  temp  dewp humid wind_dir wind_speed
##    <chr>  <dbl> <dbl> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>
##  1 EWR     2013     1     1     1  39.0  26.1  59.4      270      10.4 
##  2 EWR     2013     1     1     2  39.0  27.0  61.6      250       8.06
##  3 EWR     2013     1     1     3  39.0  28.0  64.4      240      11.5 
##  4 EWR     2013     1     1     4  39.9  28.0  62.2      250      12.7 
##  5 EWR     2013     1     1     5  39.0  28.0  64.4      260      12.7 
##  6 EWR     2013     1     1     6  37.9  28.0  67.2      240      11.5 
##  7 EWR     2013     1     1     7  39.0  28.0  64.4      240      15.0 
##  8 EWR     2013     1     1     8  39.9  28.0  62.2      250      10.4 
##  9 EWR     2013     1     1     9  39.9  28.0  62.2      260      15.0 
## 10 EWR     2013     1     1    10  41    28.0  59.6      260      13.8 
## # … with 21,125 more rows, and 5 more variables: wind_gust <dbl>,
## #   precip <dbl>, pressure <dbl>, visib <dbl>, time_hour <dttm>
```

```r
# Rows where all wind variables are missing
filter_at(weather, .vars = vars(starts_with("wind")),
          .vars_predicate = all_vars(is.na(.)))
```

```
## # A tibble: 4 x 15
##   origin  year month   day  hour  temp  dewp humid wind_dir wind_speed
##   <chr>  <dbl> <dbl> <int> <int> <dbl> <dbl> <dbl>    <dbl>      <dbl>
## 1 EWR     2013     3    27    17  52.0  19.0  27.0       NA         NA
## 2 JFK     2013     5    22    10  62.1  59    93.8       NA         NA
## 3 JFK     2013     7     4     6  73.0  71.1  93.5       NA         NA
## 4 JFK     2013     7    20     6  81.0  71.1  71.9       NA         NA
## # … with 5 more variables: wind_gust <dbl>, precip <dbl>, pressure <dbl>,
## #   visib <dbl>, time_hour <dttm>
```

## Acknowledgments

* Scoped verbs based on [Scoped verbs by the Data Challenge Lab](https://dcl-2017-04.github.io/curriculum/manip-scoped.html)

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
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
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
