---
title: "Practice generating layered graphics using ggplot2"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/dataviz_gapminder.html"]
categories: ["dataviz"]

menu:
  notes:
    parent: Data visualization
    weight: 4
---




```r
library(tidyverse)
```

Given your preparation for today's class, now let's practice generating layered graphics in R using data from [Gapminder World](https://www.gapminder.org/data/), which compiles country-level data on quality-of-life measures.

## Load the `gapminder` dataset

If you have not already installed the `gapminder` package and you try to load it using the following code, you will get an error:


```r
library(gapminder)
```

```
Error in library(gapminder) : there is no package called ‘gapminder’
```

If this happens, install the gapminder package by running `install.packages("gapminder")` in your console.

Once you've done this, run the following code to load the gapminder dataset, the `ggplot2` library, and a helper library for printing the contents of `gapminder`:


```r
library(gapminder)
library(ggplot2)
library(tibble)

glimpse(gapminder)
```

```
## Observations: 1,704
## Variables: 6
## $ country   <fct> Afghanistan, Afghanistan, Afghanistan, Afghanistan, Af…
## $ continent <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, …
## $ year      <int> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992, …
## $ lifeExp   <dbl> 28.8, 30.3, 32.0, 34.0, 36.1, 38.4, 39.9, 40.8, 41.7, …
## $ pop       <int> 8425333, 9240934, 10267083, 11537966, 13079460, 148803…
## $ gdpPercap <dbl> 779, 821, 853, 836, 740, 786, 978, 852, 649, 635, 727,…
```

> Run `?gapminder` in the console to open the help file for the data and definitions for each of the columns.

Using the grammar of graphics and your knowledge of the `ggplot2` library, generate a series of graphs that explore the relationships between specific variables.

## Generate a histogram of life expectancy

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder, mapping = aes(x = lifeExp)) +
  geom_histogram()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/notes/gapminder_files/figure-html/histo-1.png" width="672" />

  </p>
</details>

### Generate separate histograms of life expectancy for each continent

**Hint: think about how to [split your plots to show different subsets of data.](http://r4ds.had.co.nz/data-visualisation.html#facets)**

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder, mapping = aes(x = lifeExp)) +
  geom_histogram() +
  facet_wrap(~ continent)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="/notes/gapminder_files/figure-html/histo-facet-1.png" width="672" />

  </p>
</details>

## Compare the distribution of life expectancy, by continent by generating a boxplot

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder, mapping = aes(x = continent, y = lifeExp)) +
  geom_boxplot()
```

<img src="/notes/gapminder_files/figure-html/boxplot-1.png" width="672" />

  </p>
</details>

### Redraw the plot, but this time use a violin plot

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder, mapping = aes(x = continent, y = lifeExp)) +
  geom_violin()
```

<img src="/notes/gapminder_files/figure-html/violin-plot-1.png" width="672" />

  </p>
</details>

## Generate a scatterplot of the relationship between per capita GDP and life expectancy

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point()
```

<img src="/notes/gapminder_files/figure-html/scatter-1.png" width="672" />

  </p>
</details>

### Add a smoothing line to the scatterplot

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="/notes/gapminder_files/figure-html/scatter-smooth-1.png" width="672" />

  </p>
</details>

## Identify whether this relationship differs by continent

### Use the color aesthetic to identify differences

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder,
       mapping = aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="/notes/gapminder_files/figure-html/scatter-color-1.png" width="672" />

  </p>
</details>

### Use faceting to identify differences

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
# using facet_wrap()
ggplot(data = gapminder,
       mapping = aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~ continent)
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="/notes/gapminder_files/figure-html/scatter-facet-1.png" width="672" />

```r
# using facet_grid()
ggplot(data = gapminder,mapping = aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point() +
  geom_smooth() +
  facet_grid(. ~ continent)
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="/notes/gapminder_files/figure-html/scatter-facet-2.png" width="672" />

Why use `facet_grid()` here instead of `facet_wrap()`? Good question! Let's reframe it and instead ask, what is the difference between `facet_grid()` and `facet_wrap()`?^[Example drawn from [this StackOverflow thread](https://stackoverflow.com/questions/20457905/whats-the-difference-between-facet-wrap-and-facet-grid-in-ggplot2).]

The answer below refers to the case when you have 2 arguments in `facet_grid()` or `facet_wrap()`. `facet_grid(x ~ y)` will display `\(x \times y\)` plots even if some plots are empty. For example:


```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_grid(cyl ~ class)
```

<img src="/notes/gapminder_files/figure-html/facet-grid-1.png" width="672" />

There are 4 distinct `cyl` and 7 distinct `class` values. This plot  displays `\(4 \times 7 = 28\)` plots, even if some are empty (because some classes do not have corresponding cylinder values, like rows with `class = "midsize"` doesn't have any corresponding `cyl = 5` value ).

`facet_wrap(x ~ y)` displays only the plots having actual values.


```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(~ cyl + class)
```

<img src="/notes/gapminder_files/figure-html/facet-wrap-1.png" width="672" />

There are 19 plots displayed now, one for every combination of `cyl` and `class`. So for this exercise, I would use `facet_wrap()` because we are faceting on a single variable. If we faceted on multiple variables, `facet_grid()` may be more appropriate.
  </p>
</details>

## Bonus: Identify the outlying countries on the right-side of the graph by labeling each observation with the country name

<details> 
  <summary>Click for the solution</summary>
  <p>
  

```r
ggplot(data = gapminder,
       mapping = aes(x = gdpPercap, y = lifeExp, label = country)) +
  geom_smooth() +
  geom_text()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="/notes/gapminder_files/figure-html/text-1.png" width="672" />

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
