---
title: "Selecting optimal color palettes"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/geoviz_color.html"]
categories: ["dataviz", "geospatial"]

menu:
  notes:
    parent: Geospatial visualization
    weight: 5
---




```r
library(tidyverse)
library(sf)
library(tidycensus)
library(RColorBrewer)
library(patchwork)

# useful on MacOS to speed up rendering of geom_sf() objects
if (!identical(getOption("bitmapType"), "cairo") && isTRUE(capabilities()[["cairo"]])) {
  options(bitmapType = "cairo")
}

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

Selection of your **color palette** is perhaps the most important decision to make when drawing a choropleth. By default, `ggplot2` picks evenly spaced hues around the [Hue-Chroma-Luminance (HCL) color space](https://en.wikipedia.org/wiki/HCL_color_space):^[Check out chapter 6.6.2 in *`ggplot2`: Elegant Graphics for Data Analysis* for a much more thorough explanation of the theory behind this selection process]

<img src="{{< blogdown/postref >}}index_files/figure-html/color-wheel-1.png" width="672" />

`ggplot2` gives you many different ways of defining and customizing your `scale_color_` and `scale_fill_` palettes, but will not tell you if they are optimal for your specific usage in the graph.

## Color Brewer



[Color Brewer](http://colorbrewer2.org/) is a diagnostic tool for selecting optimal color palettes for maps with discrete variables. The authors have generated different color palettes designed to make differentiating between categories easy depending on the scaling of your variable. All you need to do is define the number of categories in the variable, the nature of your data (sequential, diverging, or qualitative), and a color scheme. There are also options to select palettes that are colorblind safe, print friendly, and photocopy safe. Depending on the combination of options, you may not find any color palette that matches your criteria. In such a case, consider reducing the number of data classes.

## Sequential

Sequential palettes work best with ordered data that progresses from a low to high value.


```r
display.brewer.all(type = "seq")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cb-seq-1.png" width="672" />

<img src="{{< blogdown/postref >}}index_files/figure-html/cb-seq-map-1.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/cb-seq-map-2.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/cb-seq-map-3.png" width="672" />

## Diverging

Diverging palettes work for variables with meaningful mid-range values, as well as extreme low and high values.


```r
display.brewer.all(type = "div")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cb-div-1.png" width="672" />

<img src="{{< blogdown/postref >}}index_files/figure-html/cb-div-map-1.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/cb-div-map-2.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/cb-div-map-3.png" width="672" />

## Qualitative

Qualitative palettes are best used for nominal data where there is no inherent ordering to the categories.


```r
display.brewer.all(type = "qual")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/cb-qual-1.png" width="672" />

<img src="{{< blogdown/postref >}}index_files/figure-html/cb-qual-map-1.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/cb-qual-map-2.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/cb-qual-map-3.png" width="672" />

## Viridis

The [`viridis`](https://cran.r-project.org/web/packages/viridis/) package imports several color palettes for continuous variables from the `matplotlib` package in Python. These palettes have been tested to be colorful, perceptually uniform, robust to colorblindness, and pretty. To use these with `ggplot2`, use `scale_color_viridis()` and `scale_fill_viridis()`:


```r
library(viridis)

viridis_base <- ggplot(state_inc) +
  geom_sf(aes(fill = estimate)) +
  labs(
    title = "Median household income, 2016",
    subtitle = "Palette: viridis",
    caption = "Source: 2016 American Community Survey",
    fill = NULL
  ) +
  scale_fill_viridis(labels = scales::dollar)

viridis_base
```

<img src="{{< blogdown/postref >}}index_files/figure-html/viridis-1.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "cividis", labels = scales::dollar) +
  labs(subtitle = "Palette: cividis")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/viridis-2.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "inferno", labels = scales::dollar) +
  labs(subtitle = "Palette: inferno")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/viridis-3.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "magma", labels = scales::dollar) +
  labs(subtitle = "Palette: magma")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/viridis-4.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "plasma", labels = scales::dollar) +
  labs(subtitle = "Palette: plasma")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/viridis-5.png" width="672" />

### Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.4 (2021-02-15)
##  os       macOS Big Sur 10.16         
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-05-25                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports      1.2.1   2020-12-09 [1] CRAN (R 4.0.2)
##  blogdown       1.3     2021-04-14 [1] CRAN (R 4.0.2)
##  bookdown       0.22    2021-04-22 [1] CRAN (R 4.0.2)
##  broom          0.7.6   2021-04-05 [1] CRAN (R 4.0.4)
##  bslib          0.2.5   2021-05-12 [1] CRAN (R 4.0.4)
##  cachem         1.0.5   2021-05-15 [1] CRAN (R 4.0.2)
##  callr          3.7.0   2021-04-20 [1] CRAN (R 4.0.2)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  class          7.3-19  2021-05-03 [1] CRAN (R 4.0.2)
##  classInt       0.4-3   2020-04-07 [1] CRAN (R 4.0.0)
##  cli            2.5.0   2021-04-26 [1] CRAN (R 4.0.2)
##  colorspace     2.0-1   2021-05-04 [1] CRAN (R 4.0.2)
##  crayon         1.4.1   2021-02-08 [1] CRAN (R 4.0.2)
##  DBI            1.1.1   2021-01-15 [1] CRAN (R 4.0.2)
##  dbplyr         2.1.1   2021-04-06 [1] CRAN (R 4.0.4)
##  desc           1.3.0   2021-03-05 [1] CRAN (R 4.0.2)
##  devtools       2.4.1   2021-05-05 [1] CRAN (R 4.0.2)
##  digest         0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
##  dplyr        * 1.0.6   2021-05-05 [1] CRAN (R 4.0.2)
##  e1071          1.7-6   2021-03-18 [1] CRAN (R 4.0.2)
##  ellipsis       0.3.2   2021-04-29 [1] CRAN (R 4.0.2)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi          0.4.2   2021-01-15 [1] CRAN (R 4.0.2)
##  fastmap        1.1.0   2021-01-25 [1] CRAN (R 4.0.2)
##  forcats      * 0.5.1   2021-01-27 [1] CRAN (R 4.0.2)
##  foreign        0.8-81  2020-12-22 [1] CRAN (R 4.0.4)
##  fs             1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  generics       0.1.0   2020-10-31 [1] CRAN (R 4.0.2)
##  ggplot2      * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)
##  glue           1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven          2.4.1   2021-04-23 [1] CRAN (R 4.0.2)
##  here           1.0.1   2020-12-13 [1] CRAN (R 4.0.2)
##  hms            1.1.0   2021-05-17 [1] CRAN (R 4.0.4)
##  htmltools      0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)
##  httr           1.4.2   2020-07-20 [1] CRAN (R 4.0.2)
##  jquerylib      0.1.4   2021-04-26 [1] CRAN (R 4.0.2)
##  jsonlite       1.7.2   2020-12-09 [1] CRAN (R 4.0.2)
##  KernSmooth     2.23-20 2021-05-03 [1] CRAN (R 4.0.2)
##  knitr          1.33    2021-04-24 [1] CRAN (R 4.0.2)
##  lattice        0.20-44 2021-05-02 [1] CRAN (R 4.0.2)
##  lifecycle      1.0.0   2021-02-15 [1] CRAN (R 4.0.2)
##  lubridate      1.7.10  2021-02-26 [1] CRAN (R 4.0.2)
##  magrittr       2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
##  maptools       1.1-1   2021-03-15 [1] CRAN (R 4.0.2)
##  memoise        2.0.0   2021-01-26 [1] CRAN (R 4.0.2)
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  patchwork    * 1.1.1   2020-12-17 [1] CRAN (R 4.0.2)
##  pillar         1.6.1   2021-05-16 [1] CRAN (R 4.0.4)
##  pkgbuild       1.2.0   2020-12-15 [1] CRAN (R 4.0.2)
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload        1.2.1   2021-04-06 [1] CRAN (R 4.0.2)
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx       3.5.2   2021-04-30 [1] CRAN (R 4.0.2)
##  proxy          0.4-25  2021-03-05 [1] CRAN (R 4.0.2)
##  ps             1.6.0   2021-02-28 [1] CRAN (R 4.0.2)
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6             2.5.0   2020-10-28 [1] CRAN (R 4.0.2)
##  rappdirs       0.3.3   2021-01-31 [1] CRAN (R 4.0.2)
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 4.0.0)
##  Rcpp           1.0.6   2021-01-15 [1] CRAN (R 4.0.2)
##  readr        * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes        2.3.0   2021-04-01 [1] CRAN (R 4.0.2)
##  reprex         2.0.0   2021-04-02 [1] CRAN (R 4.0.2)
##  rgdal          1.5-23  2021-02-03 [1] CRAN (R 4.0.2)
##  rlang          0.4.11  2021-04-30 [1] CRAN (R 4.0.2)
##  rmarkdown      2.8     2021-05-07 [1] CRAN (R 4.0.2)
##  rprojroot      2.0.2   2020-11-15 [1] CRAN (R 4.0.2)
##  rstudioapi     0.13    2020-11-12 [1] CRAN (R 4.0.2)
##  rvest          1.0.0   2021-03-09 [1] CRAN (R 4.0.2)
##  sass           0.4.0   2021-05-12 [1] CRAN (R 4.0.2)
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  sf           * 0.9-8   2021-03-17 [1] CRAN (R 4.0.2)
##  sp             1.4-5   2021-01-10 [1] CRAN (R 4.0.2)
##  stringi        1.6.1   2021-05-10 [1] CRAN (R 4.0.2)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat       3.0.2   2021-02-14 [1] CRAN (R 4.0.2)
##  tibble       * 3.1.1   2021-04-18 [1] CRAN (R 4.0.2)
##  tidycensus   * 0.11.4  2021-01-20 [1] CRAN (R 4.0.2)
##  tidyr        * 1.1.3   2021-03-03 [1] CRAN (R 4.0.2)
##  tidyselect     1.1.1   2021-04-30 [1] CRAN (R 4.0.2)
##  tidyverse    * 1.3.1   2021-04-15 [1] CRAN (R 4.0.2)
##  tigris         1.4     2021-05-16 [1] CRAN (R 4.0.4)
##  units          0.7-1   2021-03-16 [1] CRAN (R 4.0.2)
##  usethis        2.0.1   2021-02-10 [1] CRAN (R 4.0.2)
##  utf8           1.2.1   2021-03-12 [1] CRAN (R 4.0.2)
##  uuid           0.1-4   2020-02-26 [1] CRAN (R 4.0.0)
##  vctrs          0.3.8   2021-04-29 [1] CRAN (R 4.0.2)
##  withr          2.4.2   2021-04-18 [1] CRAN (R 4.0.2)
##  xfun           0.23    2021-05-15 [1] CRAN (R 4.0.2)
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
