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

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/grammar-of-graphics")
```

{{% /callout %}}

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
## Rows: 1,704
## Columns: 6
## $ country   <fct> Afghanistan, Afghanistan, Afghanistan, Afghanistan, Afghani…
## $ continent <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia,…
## $ year      <int> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992, 1997,…
## $ lifeExp   <dbl> 28.8, 30.3, 32.0, 34.0, 36.1, 38.4, 39.9, 40.8, 41.7, 41.8,…
## $ pop       <int> 8425333, 9240934, 10267083, 11537966, 13079460, 14880372, 1…
## $ gdpPercap <dbl> 779, 821, 853, 836, 740, 786, 978, 852, 649, 635, 727, 975,…
```

{{% callout note %}}

Run `?gapminder` in the console to open the help file for the data and definitions for each of the columns.

{{% /callout %}}

Using the grammar of graphics and your knowledge of the `ggplot2` library, generate a series of graphs that explore the relationships between specific variables.

## Generate a histogram of life expectancy

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder, mapping = aes(x = lifeExp)) +
  geom_histogram()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="{{< blogdown/postref >}}index_files/figure-html/histo-1.png" width="672" />

{{< /spoiler >}}

### Generate separate histograms of life expectancy for each continent

**Hint: think about how to [split your plots to show different subsets of data.](http://r4ds.had.co.nz/data-visualisation.html#facets)**

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder, mapping = aes(x = lifeExp)) +
  geom_histogram() +
  facet_wrap(~ continent)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="{{< blogdown/postref >}}index_files/figure-html/histo-facet-1.png" width="672" />

{{< /spoiler >}}

## Compare the distribution of life expectancy, by continent by generating a boxplot

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder, mapping = aes(x = continent, y = lifeExp)) +
  geom_boxplot()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/boxplot-1.png" width="672" />

{{< /spoiler >}}

### Redraw the plot, but this time use a violin plot

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder, mapping = aes(x = continent, y = lifeExp)) +
  geom_violin()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/violin-plot-1.png" width="672" />

{{< /spoiler >}}

## Generate a scatterplot of the relationship between per capita GDP and life expectancy

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-1.png" width="672" />

{{< /spoiler >}}

### Add a smoothing line to the scatterplot

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-smooth-1.png" width="672" />

{{< /spoiler >}}

## Identify whether this relationship differs by continent

### Use the color aesthetic to identify differences

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder,
       mapping = aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point() +
  geom_smooth()
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-color-1.png" width="672" />

{{< /spoiler >}}

### Use faceting to identify differences

{{< spoiler text="Click for the solution" >}}


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

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-facet-1.png" width="672" />

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

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-facet-2.png" width="672" />

Why use `facet_grid()` here instead of `facet_wrap()`? Good question! Let's reframe it and instead ask, what is the difference between `facet_grid()` and `facet_wrap()`?^[Example drawn from [this StackOverflow thread](https://stackoverflow.com/questions/20457905/whats-the-difference-between-facet-wrap-and-facet-grid-in-ggplot2).]

The answer below refers to the case when you have 2 arguments in `facet_grid()` or `facet_wrap()`. `facet_grid(x ~ y)` will display $x \times y$ plots even if some plots are empty. For example:


```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_grid(cyl ~ class)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/facet-grid-1.png" width="672" />

There are 4 distinct `cyl` and 7 distinct `class` values. This plot  displays $4 \times 7 = 28$ plots, even if some are empty (because some classes do not have corresponding cylinder values, like rows with `class = "midsize"` doesn't have any corresponding `cyl = 5` value ).

`facet_wrap(x ~ y)` displays only the plots having actual values.


```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(~ cyl + class)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/facet-wrap-1.png" width="672" />

There are 19 plots displayed now, one for every combination of `cyl` and `class`. So for this exercise, I would use `facet_wrap()` because we are faceting on a single variable. If we faceted on multiple variables, `facet_grid()` may be more appropriate.

{{< /spoiler >}}

## Bonus: Identify the outlying countries on the right-side of the graph by labeling each observation with the country name

{{< spoiler text="Click for the solution" >}}


```r
ggplot(data = gapminder,
       mapping = aes(x = gdpPercap, y = lifeExp, label = country)) +
  geom_smooth() +
  geom_text()
```

```
## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```

<img src="{{< blogdown/postref >}}index_files/figure-html/text-1.png" width="672" />

{{< /spoiler >}}

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
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
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
