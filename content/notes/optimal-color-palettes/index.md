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
  labs(title = "Median household income, 2016",
       subtitle = "Palette: viridis",
       caption = "Source: 2016 American Community Survey",
       fill = NULL) +
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
##  package      * version date       lib source                              
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports      1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  blogdown       1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown       0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom          0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr          3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  class          7.3-17  2020-04-26 [1] CRAN (R 4.0.3)                      
##  classInt       0.4-3   2020-04-07 [1] CRAN (R 4.0.0)                      
##  cli            2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace     2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI            1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr         2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc           1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools       2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest         0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr        * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  e1071          1.7-4   2020-10-14 [1] CRAN (R 4.0.2)                      
##  ellipsis       0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi          0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats      * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  foreign        0.8-81  2020-12-22 [1] CRAN (R 4.0.2)                      
##  fs             1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics       0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggplot2      * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue           1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven          2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here           1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms            0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools      0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr           1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite       1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  KernSmooth     2.23-18 2020-10-29 [1] CRAN (R 4.0.2)                      
##  knitr          1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lattice        0.20-41 2020-04-02 [1] CRAN (R 4.0.3)                      
##  lifecycle      0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate      1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr       2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  maptools       1.0-2   2020-08-24 [1] CRAN (R 4.0.2)                      
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  patchwork    * 1.1.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  pillar         1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild       1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload        1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx       3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps             1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6             2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  rappdirs       0.3.1   2016-03-28 [1] CRAN (R 4.0.0)                      
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 4.0.0)                      
##  Rcpp           1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr        * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes        2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex         0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  rgdal          1.5-18  2020-10-13 [1] CRAN (R 4.0.2)                      
##  rlang          0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown      2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot      2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi     0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest          0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  sf           * 0.9-6   2020-09-13 [1] CRAN (R 4.0.2)                      
##  sp             1.4-4   2020-10-07 [1] CRAN (R 4.0.2)                      
##  stringi        1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat       3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble       * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidycensus   * 0.11    2020-12-14 [1] CRAN (R 4.0.2)                      
##  tidyr        * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect     1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse    * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  tigris         1.0     2020-07-13 [1] CRAN (R 4.0.2)                      
##  units          0.6-7   2020-06-13 [1] CRAN (R 4.0.2)                      
##  usethis        2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  uuid           0.1-4   2020-02-26 [1] CRAN (R 4.0.0)                      
##  vctrs          0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr          2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun           0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
