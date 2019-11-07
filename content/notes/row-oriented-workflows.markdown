---
title: "Row-oriented workflows"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["project-management"]

menu:
  notes:
    parent: Project management
    weight: 6
---




```r
library(tidyverse)
library(gapminder)
library(rcfss)

set.seed(1234)
theme_set(theme_minimal())
```

The data frame is an important data structure in R. In fact, virtually all of the analysis we've done up until this point utilizes a data frame. Given the [tidy data format](/notes/tidy-data/) with variables stored in columns, most of our operations are performed column-wise. But what about row-oriented work? Operations in R can be performed row-wise, but are sometimes more awkward to implement. Here we examine multiple methods for implementing row-wise operations using the `tidyverse`.

## Don't create odd little excerpts and copies of your data

Code style that results from (I speculate) minimizing the number of key presses.


```r
# prep gapminder for the examples to come
gapminder <- gapminder %>%
  arrange(continent) %>%
  as.data.frame()
```


```r
life_exp <- gapminder[1:624, 4]
gdp_per_cap <- gapminder[1:624, 6]
plot(gdp_per_cap ~ life_exp)
```

<img src="/notes/row-oriented-workflows_files/figure-html/split-data-1.png" width="672" />

This clutters the workspace with "loose parts", `life_exp` and `gdp_per_cap`. Very soon, you are likely to forget what they are, which countries of `gapminder` they represent, and what the relationship between them is.

## Leave the data *in situ* and reveal intent in your code

More verbose code conveys intent. Eliminating the Magic Numbers makes the code less likely to be, or become, wrong.

Here's one way to do same in a `tidyverse` style:


```r
ggplot(
  data = filter(gapminder, continent == "Africa"),
  mapping = aes(x = lifeExp, y = gdpPercap)
) +
  geom_point()
```

<img src="/notes/row-oriented-workflows_files/figure-html/plot-no-split-1.png" width="672" />

Another `tidyverse` approach, this time using the pipe operator, `%>%`


```r
gapminder %>%
  filter(continent == "Africa") %>%
  ggplot(mapping = aes(x = lifeExp, y = gdpPercap)) +
  geom_point()
```

<img src="/notes/row-oriented-workflows_files/figure-html/plot-no-split-pipe-1.png" width="672" />

A base solution that still follows the principles of

* Leave the data in data frame
* Convey intent


```r
plot(
  gdpPercap ~ lifeExp,
  data = subset(gapminder, subset = continent == "Africa")
)
```

<img src="/notes/row-oriented-workflows_files/figure-html/plot-no-split-base-1.png" width="672" />

## Add or modify a variable


```r
# Function to produce a fresh example data frame
new_people <- function() {
  tribble(
    ~name, ~age,
    "Reed", 14L,
    "Wesley", 12L,
    "Eli", 12L,
    "Toby", 1L
  )
}
```

## The `df$var <- ...` syntax

How to create or modify a variable is a fairly low stakes matter, i.e. really a matter of taste. That said, I think there are arguments in favor of a tidy approach to modifying or creating columns inside of data frames.

Of course, `df$var <- ...` absolutely works for creating new variables or modifying existing ones. But there are downsides:

* Silent recycling is a risk.
* `df` is not special. It's not the implied place to look first for things,
so you must be explicit. This can be a drag.
* I have aesthetic concerns. YMMV.


```r
people <- new_people()
people$eyes <- 2L
people$snack <- c("chips", "cheese")
people$uname <- toupper(people$name)
people
```

```
## # A tibble: 4 x 5
##   name     age  eyes snack  uname 
##   <chr>  <int> <int> <chr>  <chr> 
## 1 Reed      14     2 chips  REED  
## 2 Wesley    12     2 cheese WESLEY
## 3 Eli       12     2 chips  ELI   
## 4 Toby       1     2 cheese TOBY
```

## `dplyr::mutate()` works "inside the box"

`dplyr::mutate()` is the `tidyverse` way to work on a variable. If I'm working in a script-y style and the `tidyverse` packages are already available, I generally prefer this method of adding or modifying a variable.

* Only a length one input can be recycled.
* `people` is the first place to look for things. It turns out that making a
new variable out of existing variables is very, very common, so it's nice
when this is easy.
* This is pipe-friendly, so I can easily combine with a few other logical
data manipuluations that need to happen around the same point.
* I like the way this looks. YMMV.


```r
new_people() %>%
  mutate(
    eyes = 2L,
    snack = c("chips", "cheese"),
    uname = toupper(name)
  )
```

```
## Error: Column `snack` must be length 4 (the number of rows) or one, not 2
```

Oops! I did not provide enough snacks!


```r
new_people() %>%
  mutate(
    eyes = 2L,
    snack = c("chips", "cheese", "mixed nuts", "dried peas"),
    uname = str_to_upper(name)
  )
```

```
## # A tibble: 4 x 5
##   name     age  eyes snack      uname 
##   <chr>  <int> <int> <chr>      <chr> 
## 1 Reed      14     2 chips      REED  
## 2 Wesley    12     2 cheese     WESLEY
## 3 Eli       12     2 mixed nuts ELI   
## 4 Toby       1     2 dried peas TOBY
```

## Are you absolutely sure that you, personally, need to iterate over rows?

Sometimes it's easy to fixate on one (unfavorable) way of accomplishing something, because it feels like a natural extension of a successful small-scale experiment.

Let's create a string from row 1 of the data frame.


```r
people <- new_people()
paste(people$name[1], "is", people$age[1], "years old")
```

```
## [1] "Reed is 14 years old"
```

I want to scale up, therefore I obviously must ... loop over all rows!


```r
n_people <- nrow(people)
s <- vector(mode = "character", length = n_people)
for (i in seq_len(n_people)) {
  s[i] <- paste(people$name[i], "is", people$age[i], "years old")
}
s
```

```
## [1] "Reed is 14 years old"   "Wesley is 12 years old"
## [3] "Eli is 12 years old"    "Toby is 1 years old"
```

Or even better, write a `map()` function!


```r
map2_chr(people$name, people$age, ~ paste(.x, "is", .y, "years old"))
```

```
## [1] "Reed is 14 years old"   "Wesley is 12 years old"
## [3] "Eli is 12 years old"    "Toby is 1 years old"
```

HOLD ON. What if I told you `paste()` is already vectorized over its arguments?


```r
paste(people$name, "is", people$age, "years old")
```

```
## [1] "Reed is 14 years old"   "Wesley is 12 years old"
## [3] "Eli is 12 years old"    "Toby is 1 years old"
```

A surprising number of "iterate over rows" problems can be eliminated by exploiting functions that are already vectorized and by making your own functions vectorized over the primary argument.

Writing an explicit loop in your code is not necessarily bad, but it should always give you pause. Has someone already written this loop for you? Ideally in C or C++ and inside a package that's being regularly checked, with high test coverage. That is usually the better choice.

## Don't forget to work "inside the box"

For this string interpolation task, we can even work with a vectorized function that is happy to do lookup inside a data frame. The [`glue` package](https://glue.tidyverse.org) is doing the work under the hood here, but many of its functions are now re-exported by `stringr`, which we already attached via `library(tidyverse)`.


```r
str_glue_data(people, "{name} is {age} years old")
```

```
## Reed is 14 years old
## Wesley is 12 years old
## Eli is 12 years old
## Toby is 1 years old
```

You can use the simpler form, `str_glue()`, inside `dplyr::mutate()`, because
the other variables in `df` are automatically available for use.


```r
people %>%
  mutate(sentence = str_glue("{name} is {age} years old"))
```

```
## # A tibble: 4 x 3
##   name     age sentence              
##   <chr>  <int> <glue>                
## 1 Reed      14 Reed is 14 years old  
## 2 Wesley    12 Wesley is 12 years old
## 3 Eli       12 Eli is 12 years old   
## 4 Toby       1 Toby is 1 years old
```

The `tidyverse` style is to manage data holistically in a data frame and provide a user interface that encourages self-explaining code with low "syntactical noise".

## `purrr::map()` for functions that are not vectorized


```r
df_list <- list(
  mass_shootings,
  gun_deaths
)
df_list
```

```
## [[1]]
## # A tibble: 114 x 14
##    case   year month   day location summary fatalities injured
##    <chr> <dbl> <chr> <int> <chr>    <chr>        <dbl>   <dbl>
##  1 Dayt…  2019 Aug       4 Dayton,… PENDING          9      27
##  2 El P…  2019 Aug       3 El Paso… PENDING         20      26
##  3 Gilr…  2019 Jul      28 Gilroy,… "Santi…          3      12
##  4 Virg…  2019 May      31 Virgini… "DeWay…         12       4
##  5 Harr…  2019 Feb      15 Aurora,… Gary M…          5       6
##  6 Penn…  2019 Jan      24 State C… Jordan…          3       1
##  7 SunT…  2019 Jan      23 Sebring… "Zephe…          5       0
##  8 Merc…  2018 Nov      19 Chicago… Juan L…          3       0
##  9 Thou…  2018 Nov       7 Thousan… Ian Da…         12      22
## 10 Tree…  2018 Oct      27 Pittsbu… "Rober…         11       6
## # … with 104 more rows, and 6 more variables: total_victims <dbl>,
## #   location_type <chr>, male <lgl>, age_of_shooter <dbl>, race <chr>,
## #   prior_mental_illness <chr>
## 
## [[2]]
## # A tibble: 100,798 x 10
##       id  year month intent   police sex     age race      place  education
##    <dbl> <dbl> <chr> <chr>     <dbl> <chr> <dbl> <chr>     <chr>  <fct>    
##  1     1  2012 Jan   Suicide       0 M        34 Asian/Pa… Home   <NA>     
##  2     2  2012 Jan   Suicide       0 F        21 White     Street <NA>     
##  3     3  2012 Jan   Suicide       0 M        60 White     Other… <NA>     
##  4     4  2012 Feb   Suicide       0 M        64 White     Home   <NA>     
##  5     5  2012 Feb   Suicide       0 M        31 White     Other… <NA>     
##  6     6  2012 Feb   Suicide       0 M        17 Native A… Home   <NA>     
##  7     7  2012 Feb   Undeter…      0 M        48 White     Home   <NA>     
##  8     8  2012 Mar   Suicide       0 M        41 Native A… Home   <NA>     
##  9     9  2012 Feb   Acciden…      0 M        50 White     Other… <NA>     
## 10    10  2012 Feb   Suicide       0 M        NA Black     Home   <NA>     
## # … with 100,788 more rows
```

This does not work. `nrow()` expects a single data frame as input.


```r
nrow(df_list)
```

```
## NULL
```

`purrr::map()` applies `nrow()` to each element of `df_list`.


```r
library(purrr)
map(df_list, nrow)
```

```
## [[1]]
## [1] 114
## 
## [[2]]
## [1] 100798
```

Different calling styles make sense in more complicated situations. Hard to justify in this simple example.


```r
map(df_list, ~ nrow(.x))
```

```
## [[1]]
## [1] 114
## 
## [[2]]
## [1] 100798
```

```r
df_list %>%
  map(nrow)
```

```
## [[1]]
## [1] 114
## 
## [[2]]
## [1] 100798
```

If you know what the return type is (or *should* be), use a type-specific variant of `map()`.


```r
map_int(df_list, ~ nrow(.x))
```

```
## [1]    114 100798
```

## Attack via rows or columns?

If you must sweat, compare row-wise work vs. column-wise work

The approach you use in that first example is not always the one that scales up the best.


```r
veggies <- list(
  list(name = "sue", number = 1, veg = c("onion", "carrot")),
  list(name = "doug", number = 2, veg = c("potato", "beet"))
)
veggies
```

```
## [[1]]
## [[1]]$name
## [1] "sue"
## 
## [[1]]$number
## [1] 1
## 
## [[1]]$veg
## [1] "onion"  "carrot"
## 
## 
## [[2]]
## [[2]]$name
## [1] "doug"
## 
## [[2]]$number
## [1] 2
## 
## [[2]]$veg
## [1] "potato" "beet"
```

If we want to combine these into rows in a data frame, how can we do this?


```r
bind_rows(veggies)
```

```
## Error: Argument 3 must be length 1, not 2
```

```r
map_dfr(veggies, ~.x)
```

```
## Error: Argument 3 must be length 1, not 2
```

```r
map_dfr(veggies, ~ .x[c("name", "number")])
```

```
## # A tibble: 2 x 2
##   name  number
##   <chr>  <dbl>
## 1 sue        1
## 2 doug       2
```

Sometimes it is simpler to attack the problem column-wise, rather than row-wise.


```r
tibble(
  name = map_chr(veggies, "name"),
  number = map_dbl(veggies, "number"),
  veg = map(veggies, "veg")
)
```

```
## # A tibble: 2 x 3
##   name  number veg      
##   <chr>  <dbl> <list>   
## 1 sue        1 <chr [2]>
## 2 doug       2 <chr [2]>
```

## Work on groups of rows via `dplyr::group_by()` + `summarize()`

What if you need to work on groups of rows? Such as the groups induced by the levels of a factor.

You do not need to split the data frame into mini-data-frames, loop over them, and glue it all back together.

Instead, use `dplyr::group_by()`, followed by `dplyr::summarize()`, to compute group-wise summaries.


```r
gapminder %>%
  group_by(continent) %>%
  summarize(
    life_exp_avg = mean(lifeExp),
    gdp_per_cap_avg = mean(gdpPercap)
  )
```

```
## # A tibble: 5 x 3
##   continent life_exp_avg gdp_per_cap_avg
##   <fct>            <dbl>           <dbl>
## 1 Africa            48.9           2194.
## 2 Americas          64.7           7136.
## 3 Asia              60.1           7902.
## 4 Europe            71.9          14469.
## 5 Oceania           74.3          18622.
```

What if you want to return summaries that are not just a single number? This does not "just work":


```r
gapminder %>%
  group_by(continent) %>%
  summarize(life_exp_qtile = quantile(lifeExp, c(0.25, 0.5, 0.75)))
```

```
## Error: Column `life_exp_qtile` must be length 1 (a summary value), not 3
```

Solution: package as a length-1 `list()` that contains 3 values, creating a **list-column**.


```r
gapminder %>%
  group_by(continent) %>%
  summarize(life_exp_qtile = list(quantile(lifeExp, c(0.25, 0.5, 0.75))))
```

```
## # A tibble: 5 x 2
##   continent life_exp_qtile
##   <fct>     <list>        
## 1 Africa    <dbl [3]>     
## 2 Americas  <dbl [3]>     
## 3 Asia      <dbl [3]>     
## 4 Europe    <dbl [3]>     
## 5 Oceania   <dbl [3]>
```

{{< tweet 983997363298717696 >}}

Solution: you can `map()` `tibble::enframe()` on the new list column, to convert each entry from named list to a two-column data frame. Then use `tidyr::unnest()` to get rid of the list column and return to a simple data frame and, if you like, convert `quantile` into a factor.


```r
gapminder %>%
  group_by(continent) %>%
  summarize(life_exp_qtile = list(quantile(lifeExp, c(0.25, 0.5, 0.75)))) %>%
  mutate(life_exp_qtile = map(life_exp_qtile, enframe, name = "quantile")) %>%
  unnest(life_exp_qtile) %>%
  mutate(quantile = factor(quantile))
```

```
## # A tibble: 15 x 3
##    continent quantile value
##    <fct>     <fct>    <dbl>
##  1 Africa    25%       42.4
##  2 Africa    50%       47.8
##  3 Africa    75%       54.4
##  4 Americas  25%       58.4
##  5 Americas  50%       67.0
##  6 Americas  75%       71.7
##  7 Asia      25%       51.4
##  8 Asia      50%       61.8
##  9 Asia      75%       69.5
## 10 Europe    25%       69.6
## 11 Europe    50%       72.2
## 12 Europe    75%       75.5
## 13 Oceania   25%       71.2
## 14 Oceania   50%       73.7
## 15 Oceania   75%       77.6
```

If something like this comes up a lot in an analysis, you could package the key "moves" in a function, like so:


```r
enquantile <- function(.var, ...) {
  qtile <- enframe(quantile(.var, ...), name = "quantile")
  qtile$quantile <- factor(qtile$quantile)
  list(qtile)
}
```

This makes repeated downstream usage more concise.


```r
gapminder %>%
  group_by(continent) %>%
  summarize(life_exp_qtile = enquantile(lifeExp, c(0.25, 0.5, 0.75))) %>%
  unnest(life_exp_qtile)
```

```
## # A tibble: 15 x 3
##    continent quantile value
##    <fct>     <fct>    <dbl>
##  1 Africa    25%       42.4
##  2 Africa    50%       47.8
##  3 Africa    75%       54.4
##  4 Americas  25%       58.4
##  5 Americas  50%       67.0
##  6 Americas  75%       71.7
##  7 Asia      25%       51.4
##  8 Asia      50%       61.8
##  9 Asia      75%       69.5
## 10 Europe    25%       69.6
## 11 Europe    50%       72.2
## 12 Europe    75%       75.5
## 13 Oceania   25%       71.2
## 14 Oceania   50%       73.7
## 15 Oceania   75%       77.6
```

## Acknowledgments

* Substantial material drawn from [Row-oriented workflows in R with the tidyverse
](https://github.com/jennybc/row-oriented-workflows) by Jenny Bryan. Licensed under the licensed under the [CC BY-SA 4.0 Creative Commons License](https://creativecommons.org/licenses/by-sa/4.0/).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.1 (2019-07-05)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-11-07                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.15    2019-08-21 [1] CRAN (R 3.6.0)
##  bookdown      0.13    2019-08-21 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 3.6.1)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.2.0   2019-09-07 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  DT            0.8     2019-08-07 [1] CRAN (R 3.6.0)
##  ellipsis      0.2.0.1 2019-07-02 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  fansi         0.4.0   2018-10-05 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  gapminder   * 0.3.0   2017-10-31 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.1   2019-08-23 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  htmlwidgets   1.3     2018-09-30 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.1)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lifecycle     0.1.0   2019-08-01 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-140 2019-05-12 [1] CRAN (R 3.6.1)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.5   2019-08-26 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  rcfss       * 0.1.8   2019-10-22 [1] local         
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.15    2019-08-21 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 1.0.0   2019-09-11 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  utf8          1.1.4   2018-05-24 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.9     2019-08-21 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
