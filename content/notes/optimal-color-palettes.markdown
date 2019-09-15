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
if(!identical(getOption("bitmapType"), "cairo") && isTRUE(capabilities()[["cairo"]])){
  options(bitmapType = "cairo")
}

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

Selection of your **color palette** is perhaps the most important decision to make when drawing a choropleth. By default, `ggplot2` picks evenly spaced hues around the [Hue-Chroma-Luminance (HCL) color space](https://en.wikipedia.org/wiki/HCL_color_space):^[Check out chapter 6.6.2 in *`ggplot2`: Elegant Graphics for Data Analysis* for a much more thorough explanation of the theory behind this selection process]

<img src="/notes/optimal-color-palettes_files/figure-html/color-wheel-1.png" width="672" />

`ggplot2` gives you many different ways of defining and customizing your `scale_color_` and `scale_fill_` palettes, but will not tell you if they are optimal for your specific usage in the graph.

## Color Brewer



[Color Brewer](http://colorbrewer2.org/) is a diagnostic tool for selecting optimal color palettes for maps with discrete variables. The authors have generated different color palettes designed to make differentiating between categories easy depending on the scaling of your variable. All you need to do is define the number of categories in the variable, the nature of your data (sequential, diverging, or qualitative), and a color scheme. There are also options to select palettes that are colorblind safe, print friendly, and photocopy safe. Depending on the combination of options, you may not find any color palette that matches your criteria. In such a case, consider reducing the number of data classes.

## Sequential

Sequential palettes work best with ordered data that progresses from a low to high value.


```r
display.brewer.all(type = "seq")
```

<img src="/notes/optimal-color-palettes_files/figure-html/cb-seq-1.png" width="672" />

<img src="/notes/optimal-color-palettes_files/figure-html/cb-seq-map-1.png" width="672" /><img src="/notes/optimal-color-palettes_files/figure-html/cb-seq-map-2.png" width="672" /><img src="/notes/optimal-color-palettes_files/figure-html/cb-seq-map-3.png" width="672" />

## Diverging

Diverging palettes work for variables with meaningful mid-range values, as well as extreme low and high values.


```r
display.brewer.all(type = "div")
```

<img src="/notes/optimal-color-palettes_files/figure-html/cb-div-1.png" width="672" />

<img src="/notes/optimal-color-palettes_files/figure-html/cb-div-map-1.png" width="672" /><img src="/notes/optimal-color-palettes_files/figure-html/cb-div-map-2.png" width="672" /><img src="/notes/optimal-color-palettes_files/figure-html/cb-div-map-3.png" width="672" />

## Qualitative

Qualitative palettes are best used for nominal data where there is no inherent ordering to the categories.


```r
display.brewer.all(type = "qual")
```

<img src="/notes/optimal-color-palettes_files/figure-html/cb-qual-1.png" width="672" />

<img src="/notes/optimal-color-palettes_files/figure-html/cb-qual-map-1.png" width="672" /><img src="/notes/optimal-color-palettes_files/figure-html/cb-qual-map-2.png" width="672" /><img src="/notes/optimal-color-palettes_files/figure-html/cb-qual-map-3.png" width="672" />

## Viridis

The [`viridis`](https://cran.r-project.org/web/packages/viridis/) package imports several color palettes for continuous variables from the `matplotlib` package in Python. These palettes have been tested to be colorful, perceptually uniform, robust to colorblindness, and pretty. To use these with `ggplot2`, use `scale_color_viridis()` and `scale_fill_viridis()`:


```r
library(viridis)

viridis_base <- ggplot(state_inc) +
  geom_sf(aes(fill = estimate)) +
  labs(title = "Median household income, 2016",
       subtitle = "Palette: viridis",
       caption = "Source: 2016 American Community Survey",
       fill = NULL) +
  scale_fill_viridis(labels = scales::dollar)

viridis_base
```

<img src="/notes/optimal-color-palettes_files/figure-html/viridis-1.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "cividis", labels = scales::dollar) +
  labs(subtitle = "Palette: cividis")
```

<img src="/notes/optimal-color-palettes_files/figure-html/viridis-2.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "inferno", labels = scales::dollar) +
  labs(subtitle = "Palette: inferno")
```

<img src="/notes/optimal-color-palettes_files/figure-html/viridis-3.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "magma", labels = scales::dollar) +
  labs(subtitle = "Palette: magma")
```

<img src="/notes/optimal-color-palettes_files/figure-html/viridis-4.png" width="672" />

```r
viridis_base +
  scale_fill_viridis(option = "plasma", labels = scales::dollar) +
  labs(subtitle = "Palette: plasma")
```

<img src="/notes/optimal-color-palettes_files/figure-html/viridis-5.png" width="672" />

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
##  package      * version date       lib
##  assertthat     0.2.1   2019-03-21 [1]
##  backports      1.1.4   2019-04-10 [1]
##  blogdown       0.14    2019-07-13 [1]
##  bookdown       0.12    2019-07-11 [1]
##  broom          0.5.2   2019-04-07 [1]
##  callr          3.3.1   2019-07-18 [1]
##  cellranger     1.1.0   2016-07-27 [1]
##  class          7.3-15  2019-01-01 [1]
##  classInt       0.4-1   2019-08-06 [1]
##  cli            1.1.0   2019-03-19 [1]
##  colorspace     1.4-1   2019-03-18 [1]
##  crayon         1.3.4   2017-09-16 [1]
##  DBI            1.0.0   2018-05-02 [1]
##  desc           1.2.0   2018-05-01 [1]
##  devtools       2.1.0   2019-07-06 [1]
##  digest         0.6.20  2019-07-04 [1]
##  dplyr        * 0.8.3   2019-07-04 [1]
##  e1071          1.7-2   2019-06-05 [1]
##  evaluate       0.14    2019-05-28 [1]
##  forcats      * 0.4.0   2019-02-17 [1]
##  foreign        0.8-72  2019-08-02 [1]
##  fs             1.3.1   2019-05-06 [1]
##  generics       0.0.2   2018-11-29 [1]
##  ggplot2      * 3.2.1   2019-08-10 [1]
##  glue           1.3.1   2019-03-12 [1]
##  gtable         0.3.0   2019-03-25 [1]
##  haven          2.1.1   2019-07-04 [1]
##  here           0.1     2017-05-28 [1]
##  hms            0.5.0   2019-07-09 [1]
##  htmltools      0.3.6   2017-04-28 [1]
##  httr           1.4.1   2019-08-05 [1]
##  jsonlite       1.6     2018-12-07 [1]
##  KernSmooth     2.23-15 2015-06-29 [1]
##  knitr          1.24    2019-08-08 [1]
##  lattice        0.20-38 2018-11-04 [1]
##  lazyeval       0.2.2   2019-03-15 [1]
##  lubridate      1.7.4   2018-04-11 [1]
##  magrittr       1.5     2014-11-22 [1]
##  maptools       0.9-5   2019-02-18 [1]
##  memoise        1.1.0   2017-04-21 [1]
##  modelr         0.1.5   2019-08-08 [1]
##  munsell        0.5.0   2018-06-12 [1]
##  nlme           3.1-141 2019-08-01 [1]
##  patchwork    * 0.0.1   2019-06-10 [1]
##  pillar         1.4.2   2019-06-29 [1]
##  pkgbuild       1.0.4   2019-08-05 [1]
##  pkgconfig      2.0.2   2018-08-16 [1]
##  pkgload        1.0.2   2018-10-29 [1]
##  prettyunits    1.0.2   2015-07-13 [1]
##  processx       3.4.1   2019-07-18 [1]
##  ps             1.3.0   2018-12-21 [1]
##  purrr        * 0.3.2   2019-03-15 [1]
##  R6             2.4.0   2019-02-14 [1]
##  rappdirs       0.3.1   2016-03-28 [1]
##  RColorBrewer * 1.1-2   2014-12-07 [1]
##  Rcpp           1.0.2   2019-07-25 [1]
##  readr        * 1.3.1   2018-12-21 [1]
##  readxl         1.3.1   2019-03-13 [1]
##  remotes        2.1.0   2019-06-24 [1]
##  rgdal          1.4-4   2019-05-29 [1]
##  rlang          0.4.0   2019-06-25 [1]
##  rmarkdown      1.14    2019-07-12 [1]
##  rprojroot      1.3-2   2018-01-03 [1]
##  rstudioapi     0.10    2019-03-19 [1]
##  rvest          0.3.4   2019-05-15 [1]
##  scales         1.0.0   2018-08-09 [1]
##  sessioninfo    1.1.1   2018-11-05 [1]
##  sf           * 0.7-7   2019-07-24 [1]
##  sp             1.3-1   2018-06-05 [1]
##  stringi        1.4.3   2019-03-12 [1]
##  stringr      * 1.4.0   2019-02-10 [1]
##  testthat       2.2.1   2019-07-25 [1]
##  tibble       * 2.1.3   2019-06-06 [1]
##  tidycensus   * 0.9.2   2019-06-12 [1]
##  tidyr        * 0.8.3   2019-03-01 [1]
##  tidyselect     0.2.5   2018-10-11 [1]
##  tidyverse    * 1.2.1   2017-11-14 [1]
##  tigris         0.8.2   2019-06-12 [1]
##  units          0.6-3   2019-05-03 [1]
##  usethis        1.5.1   2019-07-04 [1]
##  uuid           0.1-2   2015-07-28 [1]
##  vctrs          0.2.0   2019-07-05 [1]
##  withr          2.1.2   2018-03-15 [1]
##  xfun           0.8     2019-06-25 [1]
##  xml2           1.2.2   2019-08-09 [1]
##  yaml           2.2.0   2018-07-25 [1]
##  zeallot        0.1.0   2018-01-28 [1]
##  source                              
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  Github (thomasp85/patchwork@fd7958b)
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
##  CRAN (R 3.6.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
