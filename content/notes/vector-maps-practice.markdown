---
title: "Practice drawing vector maps"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["dataviz", "geospatial"]

menu:
  notes:
    parent: Geospatial visualization
    weight: 4
---




```r
library(tidyverse)
library(sf)
library(tidycensus)
library(viridis)

# useful on MacOS to speed up rendering of geom_sf() objects
if(!identical(getOption("bitmapType"), "cairo") && isTRUE(capabilities()[["cairo"]])){
  options(bitmapType = "cairo")
}

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

## American Community Survey

The U.S. Census Bureau conducts the [American Community Survey](https://www.census.gov/programs-surveys/acs) which gathers detailed information on topics such as demographics, employment, educational attainment, etc. They make a vast portion of their data available through an [application programming interface (API)](/notes/application-program-interface/), which can be accessed intuitively through R via the [`tidycensus` package](https://walkerke.github.io/tidycensus/index.html). We previously discussed how to use this package to [obtain statistical data from the decennial census](/notes/application-program-interface/#census-data-with-tidycensus). However the Census Bureau also has detailed information on political and geographic boundaries which we can combine with their statistical measures to easily construct geospatial visualizations.

> If you have not already, [obtain an API key](https://api.census.gov/data/key_signup.html) and [store it securely](https://api.census.gov/data/key_signup.html) on your computer.

## Exercise: Visualize income data

1. Obtain information on median household income in 2017 for Cook County, IL at the tract-level using the ACS. To retrieve the geographic features for each tract, set `geometry = TRUE` in your function.

    > You can use `load_variables(year = 2017, dataset = "acs5")` to retrieve the list of variables available and search to find the correct variable name.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    cook_inc <- get_acs(state = "IL",
                        county = "Cook",
                        geography = "tract", 
                        variables = c(medincome = "B19013_001"), 
                        year = 2017,
                        geometry = TRUE)
    ```
    
    
    ```r
    cook_inc
    ```
    
    ```
    ## Simple feature collection with 1319 features and 5 fields (with 1 geometry empty)
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: -88.3 ymin: 41.5 xmax: -87.5 ymax: 42.2
    ## epsg (SRID):    4269
    ## proj4string:    +proj=longlat +datum=NAD83 +no_defs
    ## First 10 features:
    ##          GEOID                                       NAME  variable
    ## 1  17031010100    Census Tract 101, Cook County, Illinois medincome
    ## 2  17031010201 Census Tract 102.01, Cook County, Illinois medincome
    ## 3  17031010202 Census Tract 102.02, Cook County, Illinois medincome
    ## 4  17031010300    Census Tract 103, Cook County, Illinois medincome
    ## 5  17031010400    Census Tract 104, Cook County, Illinois medincome
    ## 6  17031010501 Census Tract 105.01, Cook County, Illinois medincome
    ## 7  17031010502 Census Tract 105.02, Cook County, Illinois medincome
    ## 8  17031010503 Census Tract 105.03, Cook County, Illinois medincome
    ## 9  17031010600    Census Tract 106, Cook County, Illinois medincome
    ## 10 17031010701 Census Tract 107.01, Cook County, Illinois medincome
    ##    estimate   moe                       geometry
    ## 1     33750 10701 MULTIPOLYGON (((-87.7 42, -...
    ## 2     40841  7069 MULTIPOLYGON (((-87.7 42, -...
    ## 3     36563  8731 MULTIPOLYGON (((-87.7 42, -...
    ## 4     36870  3386 MULTIPOLYGON (((-87.7 42, -...
    ## 5     39634  8452 MULTIPOLYGON (((-87.7 42, -...
    ## 6     31985 10336 MULTIPOLYGON (((-87.7 42, -...
    ## 7     33721  2977 MULTIPOLYGON (((-87.7 42, -...
    ## 8     19671  7134 MULTIPOLYGON (((-87.7 42, -...
    ## 9     40576  8381 MULTIPOLYGON (((-87.7 42, -...
    ## 10    60798 12257 MULTIPOLYGON (((-87.7 42, -...
    ```
        
      </p>
    </details>

1. Draw a choropleth using the median household income data. Use a continuous color gradient to identify each tract's median household income.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    ggplot(data = cook_inc) +
      # use fill and color to avoid gray boundary lines
      geom_sf(aes(fill = estimate, color = estimate)) +
      # increase interpretability of graph
      scale_color_continuous(labels = scales::dollar) +
      scale_fill_continuous(labels = scales::dollar) +
      labs(title = "Median household income in Cook County, IL",
           subtitle = "In 2017",
           color = NULL,
           fill = NULL,
           caption = "Source: American Community Survey")
    ```
    
    <img src="/notes/vector-maps-practice_files/figure-html/income-cook-map-1.png" width="672" />
        
      </p>
    </details>

## Exercise: Customize your maps

1. Draw the same choropleth for Cook County, but convert median household income into a discrete variable with 6 levels.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    * Using `cut_interval()`:
    
        
        ```r
        cook_inc %>%
          mutate(inc_cut = cut_interval(estimate, n = 6)) %>%
          ggplot() +
          # use fill and color to avoid gray boundary lines
          geom_sf(aes(fill = inc_cut, color = inc_cut)) +
          # increase interpretability of graph
          labs(title = "Median household income in Cook County, IL",
               subtitle = "In 2017",
               color = NULL,
               fill = NULL,
               caption = "Source: American Community Survey")
        ```
        
        <img src="/notes/vector-maps-practice_files/figure-html/cut-interval-1.png" width="672" />
            
    * Using `cut_number()`:
    
        
        ```r
        cook_inc %>%
          mutate(inc_cut = cut_number(estimate, n = 6)) %>%
          ggplot() +
          # use fill and color to avoid gray boundary lines
          geom_sf(aes(fill = inc_cut, color = inc_cut)) +
          # increase interpretability of graph
          labs(title = "Median household income in Cook County, IL",
               subtitle = "In 2017",
               color = NULL,
               fill = NULL,
               caption = "Source: American Community Survey")
        ```
        
        <img src="/notes/vector-maps-practice_files/figure-html/cut-number-1.png" width="672" />
            
      </p>
    </details>

1. Draw the same choropleth for Cook County using the discrete variable, but select an appropriate color palette using [Color Brewer](/notes/optimal-color-palettes/#color-brewer).

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    * Using `cut_interval()` and the Blue-Green palette:
    
        
        ```r
        cook_inc %>%
          mutate(inc_cut = cut_interval(estimate, n = 6)) %>%
          ggplot() +
          # use fill and color to avoid gray boundary lines
          geom_sf(aes(fill = inc_cut, color = inc_cut)) +
          scale_fill_brewer(type = "seq", palette = "BuGn") +
          scale_color_brewer(type = "seq", palette = "BuGn") +
          # increase interpretability of graph
          labs(title = "Median household income in Cook County, IL",
               subtitle = "In 2017",
               color = NULL,
               fill = NULL,
               caption = "Source: American Community Survey")
        ```
        
        <img src="/notes/vector-maps-practice_files/figure-html/cut-interval-optimal-1.png" width="672" />
        
    * Using `cut_number()` and the Blue-Green palette:
    
        
        ```r
        cook_inc %>%
          mutate(inc_cut = cut_number(estimate, n = 6)) %>%
          ggplot() +
          # use fill and color to avoid gray boundary lines
          geom_sf(aes(fill = inc_cut, color = inc_cut)) +
          scale_fill_brewer(type = "seq", palette = "BuGn") +
          scale_color_brewer(type = "seq", palette = "BuGn") +
         # increase interpretability of graph
          labs(title = "Median household income in Cook County, IL",
               subtitle = "In 2017",
               color = NULL,
               fill = NULL,
               caption = "Source: American Community Survey")
        ```
        
        <img src="/notes/vector-maps-practice_files/figure-html/cut-number-optimal-1.png" width="672" />
        
        
    You can choose any palette that is for sequential data.
    
      </p>
    </details>

1. Use the [`viridis` color palette](/notes/optimal-color-palettes/#viridis) for the Cook County map drawn using the continuous measure.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    ggplot(data = cook_inc) +
      # use fill and color to avoid gray boundary lines
      geom_sf(aes(fill = estimate, color = estimate)) +
      # increase interpretability of graph
      scale_color_viridis(labels = scales::dollar) +
      scale_fill_viridis(labels = scales::dollar) +
      labs(title = "Median household income in Cook County, IL",
           subtitle = "In 2017",
           color = NULL,
           fill = NULL,
           caption = "Source: American Community Survey")
    ```
    
    <img src="/notes/vector-maps-practice_files/figure-html/income-cook-map-viridis-1.png" width="672" />
        
      </p>
    </details>
    
### Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.5.3 (2019-03-11)
##  os       macOS Mojave 10.14.5        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-05-22                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
##  backports     1.1.4   2019-04-10 [2] CRAN (R 3.5.2)
##  blogdown      0.12    2019-05-01 [1] CRAN (R 3.5.2)
##  bookdown      0.10    2019-05-10 [1] CRAN (R 3.5.2)
##  broom         0.5.2   2019-04-07 [2] CRAN (R 3.5.2)
##  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
##  cellranger    1.1.0   2016-07-27 [2] CRAN (R 3.5.0)
##  class         7.3-15  2019-01-01 [2] CRAN (R 3.5.3)
##  classInt      0.3-3   2019-04-26 [2] CRAN (R 3.5.2)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
##  colorspace    1.4-1   2019-03-18 [2] CRAN (R 3.5.2)
##  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
##  DBI           1.0.0   2018-05-02 [2] CRAN (R 3.5.0)
##  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
##  devtools      2.0.2   2019-04-08 [1] CRAN (R 3.5.2)
##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
##  dplyr       * 0.8.1   2019-05-14 [1] CRAN (R 3.5.2)
##  e1071         1.7-1   2019-03-19 [1] CRAN (R 3.5.2)
##  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
##  forcats     * 0.4.0   2019-02-17 [2] CRAN (R 3.5.2)
##  foreign       0.8-71  2018-07-20 [2] CRAN (R 3.5.3)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.5.2)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.5.0)
##  ggplot2     * 3.1.1   2019-04-07 [1] CRAN (R 3.5.2)
##  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
##  gridExtra     2.3     2017-09-09 [2] CRAN (R 3.5.0)
##  gtable        0.3.0   2019-03-25 [2] CRAN (R 3.5.2)
##  haven         2.1.0   2019-02-19 [2] CRAN (R 3.5.2)
##  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite      1.6     2018-12-07 [2] CRAN (R 3.5.0)
##  KernSmooth    2.23-15 2015-06-29 [2] CRAN (R 3.5.3)
##  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
##  lattice       0.20-38 2018-11-04 [2] CRAN (R 3.5.3)
##  lazyeval      0.2.2   2019-03-15 [2] CRAN (R 3.5.2)
##  lubridate     1.7.4   2018-04-11 [2] CRAN (R 3.5.0)
##  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
##  maptools      0.9-5   2019-02-18 [1] CRAN (R 3.5.2)
##  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
##  modelr        0.1.4   2019-02-18 [2] CRAN (R 3.5.2)
##  munsell       0.5.0   2018-06-12 [2] CRAN (R 3.5.0)
##  nlme          3.1-140 2019-05-12 [2] CRAN (R 3.5.2)
##  pillar        1.4.0   2019-05-11 [2] CRAN (R 3.5.2)
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.5.3)
##  pkgconfig     2.0.2   2018-08-16 [2] CRAN (R 3.5.1)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
##  plyr          1.8.4   2016-06-08 [2] CRAN (R 3.5.0)
##  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
##  processx      3.3.1   2019-05-08 [1] CRAN (R 3.5.2)
##  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
##  purrr       * 0.3.2   2019-03-15 [2] CRAN (R 3.5.2)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
##  rappdirs      0.3.1   2016-03-28 [2] CRAN (R 3.5.0)
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.2)
##  readr       * 1.3.1   2018-12-21 [2] CRAN (R 3.5.0)
##  readxl        1.3.1   2019-03-13 [2] CRAN (R 3.5.2)
##  remotes       2.0.4   2019-04-10 [1] CRAN (R 3.5.2)
##  rgdal         1.4-3   2019-03-14 [1] CRAN (R 3.5.2)
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.5.2)
##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
##  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.5.3)
##  rvest         0.3.4   2019-05-15 [2] CRAN (R 3.5.2)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.5.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
##  sf          * 0.7-4   2019-04-25 [1] CRAN (R 3.5.2)
##  sp            1.3-1   2018-06-05 [2] CRAN (R 3.5.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.2)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
##  testthat      2.1.1   2019-04-23 [2] CRAN (R 3.5.2)
##  tibble      * 2.1.1   2019-03-16 [2] CRAN (R 3.5.2)
##  tidycensus  * 0.9     2019-01-09 [1] CRAN (R 3.5.2)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.5.2)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.5.0)
##  tidyverse   * 1.2.1   2017-11-14 [2] CRAN (R 3.5.0)
##  tigris        0.7     2018-04-14 [1] CRAN (R 3.5.0)
##  units         0.6-3   2019-05-03 [1] CRAN (R 3.5.2)
##  usethis       1.5.0   2019-04-07 [1] CRAN (R 3.5.2)
##  uuid          0.1-2   2015-07-28 [2] CRAN (R 3.5.0)
##  viridis     * 0.5.1   2018-03-29 [2] CRAN (R 3.5.0)
##  viridisLite * 0.3.0   2018-02-01 [2] CRAN (R 3.5.0)
##  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
##  xfun          0.7     2019-05-14 [1] CRAN (R 3.5.2)
##  xml2          1.2.0   2018-01-24 [2] CRAN (R 3.5.0)
##  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
## 
## [1] /Users/soltoffbc/Library/R/3.5/library
## [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```
