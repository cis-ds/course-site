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
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.1 (2019-07-05)
##  os       macOS Catalina 10.15.3      
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2020-02-18                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports      1.1.5   2019-10-02 [1] CRAN (R 3.6.0)
##  blogdown       0.17.1  2020-02-13 [1] local         
##  bookdown       0.17    2020-01-11 [1] CRAN (R 3.6.0)
##  broom          0.5.4   2020-01-27 [1] CRAN (R 3.6.0)
##  callr          3.4.2   2020-02-12 [1] CRAN (R 3.6.1)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  class          7.3-15  2019-01-01 [1] CRAN (R 3.6.1)
##  classInt       0.4-2   2019-10-17 [1] CRAN (R 3.6.0)
##  cli            2.0.1   2020-01-08 [1] CRAN (R 3.6.0)
##  colorspace     1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  DBI            1.1.0   2019-12-15 [1] CRAN (R 3.6.0)
##  dbplyr         1.4.2   2019-06-17 [1] CRAN (R 3.6.0)
##  desc           1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools       2.2.1   2019-09-24 [1] CRAN (R 3.6.0)
##  digest         0.6.23  2019-11-23 [1] CRAN (R 3.6.0)
##  dplyr        * 0.8.4   2020-01-31 [1] CRAN (R 3.6.0)
##  e1071          1.7-3   2019-11-26 [1] CRAN (R 3.6.0)
##  ellipsis       0.3.0   2019-09-20 [1] CRAN (R 3.6.0)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  fansi          0.4.1   2020-01-08 [1] CRAN (R 3.6.0)
##  forcats      * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  foreign        0.8-75  2020-01-20 [1] CRAN (R 3.6.0)
##  fs             1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics       0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2      * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue           1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven          2.2.0   2019-11-08 [1] CRAN (R 3.6.0)
##  here           0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms            0.5.3   2020-01-08 [1] CRAN (R 3.6.0)
##  htmltools      0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
##  httr           1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite       1.6.1   2020-02-02 [1] CRAN (R 3.6.0)
##  KernSmooth     2.23-16 2019-10-15 [1] CRAN (R 3.6.0)
##  knitr          1.28    2020-02-06 [1] CRAN (R 3.6.0)
##  lattice        0.20-38 2018-11-04 [1] CRAN (R 3.6.1)
##  lazyeval       0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lifecycle      0.1.0   2019-08-01 [1] CRAN (R 3.6.0)
##  lubridate      1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr       1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  maptools       0.9-9   2019-12-01 [1] CRAN (R 3.6.0)
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr         0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme           3.1-144 2020-02-06 [1] CRAN (R 3.6.0)
##  patchwork    * 1.0.0   2019-12-01 [1] CRAN (R 3.6.1)
##  pillar         1.4.3   2019-12-20 [1] CRAN (R 3.6.0)
##  pkgbuild       1.0.6   2019-10-09 [1] CRAN (R 3.6.0)
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 3.6.0)
##  pkgload        1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 3.6.0)
##  processx       3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps             1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr        * 0.3.3   2019-10-18 [1] CRAN (R 3.6.0)
##  R6             2.4.1   2019-11-12 [1] CRAN (R 3.6.0)
##  rappdirs       0.3.1   2016-03-28 [1] CRAN (R 3.6.0)
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 3.6.0)
##  Rcpp           1.0.3   2019-11-08 [1] CRAN (R 3.6.0)
##  readr        * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes        2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  reprex         0.3.0   2019-05-16 [1] CRAN (R 3.6.0)
##  rgdal          1.4-8   2019-11-27 [1] CRAN (R 3.6.0)
##  rlang          0.4.4   2020-01-28 [1] CRAN (R 3.6.0)
##  rmarkdown      2.1     2020-01-20 [1] CRAN (R 3.6.0)
##  rprojroot      1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi     0.11    2020-02-07 [1] CRAN (R 3.6.0)
##  rvest          0.3.5   2019-11-08 [1] CRAN (R 3.6.0)
##  scales         1.1.0   2019-11-18 [1] CRAN (R 3.6.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  sf           * 0.8-1   2020-01-28 [1] CRAN (R 3.6.0)
##  sp             1.3-2   2019-11-07 [1] CRAN (R 3.6.0)
##  stringi        1.4.5   2020-01-11 [1] CRAN (R 3.6.0)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat       2.3.1   2019-12-01 [1] CRAN (R 3.6.0)
##  tibble       * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidycensus   * 0.9.6   2020-01-25 [1] CRAN (R 3.6.0)
##  tidyr        * 1.0.2   2020-01-24 [1] CRAN (R 3.6.0)
##  tidyselect     1.0.0   2020-01-27 [1] CRAN (R 3.6.0)
##  tidyverse    * 1.3.0   2019-11-21 [1] CRAN (R 3.6.0)
##  tigris         0.9.2   2020-02-04 [1] CRAN (R 3.6.0)
##  units          0.6-5   2019-10-08 [1] CRAN (R 3.6.0)
##  usethis        1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  uuid           0.1-2   2015-07-28 [1] CRAN (R 3.6.0)
##  vctrs          0.2.2   2020-01-24 [1] CRAN (R 3.6.0)
##  withr          2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun           0.12    2020-01-13 [1] CRAN (R 3.6.0)
##  xml2           1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
