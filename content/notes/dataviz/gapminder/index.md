---
title: "Practice generating layered graphics using ggplot2"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/dataviz_gapminder.html", "/notes/gapminder/"]
categories: ["dataviz"]

weight: 24
---




```r
library(tidyverse)
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("cis-ds/grammar-of-graphics")
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
## $ country   <fct> "Afghanistan", "Afghanistan", "Afghanistan", "Afghanistan", …
## $ continent <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, …
## $ year      <int> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992, 1997, …
## $ lifeExp   <dbl> 28.8, 30.3, 32.0, 34.0, 36.1, 38.4, 39.9, 40.8, 41.7, 41.8, …
## $ pop       <int> 8425333, 9240934, 10267083, 11537966, 13079460, 14880372, 12…
## $ gdpPercap <dbl> 779, 821, 853, 836, 740, 786, 978, 852, 649, 635, 727, 975, …
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
  facet_wrap(facets = vars(continent))
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
ggplot(
  data = gapminder,
  mapping = aes(x = gdpPercap, y = lifeExp, color = continent)
) +
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
ggplot(
  data = gapminder,
  mapping = aes(x = gdpPercap, y = lifeExp, color = continent)
) +
  geom_point() +
  geom_smooth() +
  facet_wrap(facets = vars(continent))
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-facet-1.png" width="672" />

```r
# using facet_grid()
ggplot(data = gapminder, mapping = aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point() +
  geom_smooth() +
  facet_grid(cols = vars(continent))
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="{{< blogdown/postref >}}index_files/figure-html/scatter-facet-2.png" width="672" />

Why use `facet_grid()` here instead of `facet_wrap()`? Good question! Let's reframe it and instead ask, what is the difference between `facet_grid()` and `facet_wrap()`?[^example]

The answer below refers to the case when you have 2 arguments in `facet_grid()` or `facet_wrap()`. `facet_grid(rows = vars(x), cols = vars(y))` will display $y \times x$ plots even if some plots are empty. For example:


```r
library(palmerpenguins)

ggplot(data = penguins, aes(x = bill_length_mm, y = body_mass_g)) +
  geom_point() +
  facet_grid(rows = vars(species), cols = vars(island))
```

```
## Warning: Removed 2 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/facet-grid-1.png" width="672" />

There are 3 distinct `species` and `island` values. This plot displays $3 \times 3 = 9$ plots, even if some are empty (for example, Chinstrap penguins were not observed on Biscoe Island).

`facet_wrap(facets = vars(species, island))` displays only the plots having actual values.


```r
ggplot(data = penguins, aes(x = bill_length_mm, y = body_mass_g)) +
  geom_point() +
  facet_wrap(facets = vars(species, island))
```

```
## Warning: Removed 2 rows containing missing values (geom_point).
```

<img src="{{< blogdown/postref >}}index_files/figure-html/facet-wrap-1.png" width="672" />

There are 5 plots displayed now, one for every combination of `species` and `island`. So for this exercise, I would use `facet_wrap()` because we are faceting on a single variable. If we faceted on multiple variables, `facet_grid()` may be more appropriate.

{{< /spoiler >}}

## Bonus: Identify the outlying countries on the right-side of the graph by labeling each observation with the country name

{{< spoiler text="Click for the solution" >}}


```r
ggplot(
  data = gapminder,
  mapping = aes(x = gdpPercap, y = lifeExp, label = country)
) +
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
sessioninfo::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.2.1 (2022-06-23)
##  os       macOS Monterey 12.3
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/New_York
##  date     2022-08-22
##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  assertthat      0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown        1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  cli             3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs              1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2       * 3.3.6      2022-05-03 [2] CRAN (R 4.2.0)
##  glue            1.6.2      2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive     2.0.0      2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4   1.0.0      2021-07-21 [2] CRAN (R 4.2.0)
##  gtable          0.3.0      2019-03-25 [2] CRAN (R 4.2.0)
##  haven           2.5.0      2022-04-15 [2] CRAN (R 4.2.0)
##  here            1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  hms             1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools       0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr            1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr           1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate       1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr          0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6              2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  readr         * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl          1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex          2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  rlang           1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown       2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest           1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo     1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  stringi         1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  utf8            1.2.2      2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs           0.4.1      2022-04-13 [2] CRAN (R 4.2.0)
##  withr           2.5.0      2022-03-03 [2] CRAN (R 4.2.0)
##  xfun            0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2            1.3.3      2021-11-30 [2] CRAN (R 4.2.0)
##  yaml            2.3.5      2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```

[^example]: Example drawn from [this StackOverflow thread](https://stackoverflow.com/questions/20457905/whats-the-difference-between-facet-wrap-and-facet-grid-in-ggplot2).
