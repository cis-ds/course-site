---
title: "Practice drawing raster maps"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["dataviz", "geospatial"]

menu:
  notes:
    parent: Geospatial visualization
    weight: 2
---




```r
library(tidyverse)
library(ggmap)
library(RColorBrewer)
library(here)

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

## Chicago 311 data

The city of Chicago has [an excellent data portal](https://data.cityofchicago.org/) publishing a large volume of public records. Here we'll look at a subset of the [311 service requests](https://data.cityofchicago.org/Service-Requests/311-Service-Requests/v6vf-nfxy). I used `RSocrata` and the data portal's [API](/notes/application-program-interface/) to retrieve a portion of the data set.

{{% alert note %}}

If you are copying-and-pasting code from this demonstration, use `chi_311 <- read_csv("https://cfss.uchicago.edu/data/chi-311.csv")` to download the file from the course website.

{{% /alert %}}




```r
glimpse(chi_311)
```

```
## Observations: 97,611
## Variables: 8
## $ sr_number      <chr> "SR19-01209373", "SR19-01129184", "SR19-01130159"…
## $ sr_type        <chr> "Dead Animal Pick-Up Request", "Dead Animal Pick-…
## $ sr_short_code  <chr> "SGQ", "SGQ", "SGQ", "SGQ", "SGQ", "SGQ", "SGQ", …
## $ created_date   <chr> "2019-03-23T17:13:05Z", "2019-03-09T01:37:26Z", "…
## $ community_area <dbl> 58, 40, 40, 67, 59, 59, 2, 59, 59, 64, 59, 25, 25…
## $ ward           <dbl> 12, 20, 20, 17, 12, 12, 40, 12, 12, 13, 12, 29, 2…
## $ latitude       <dbl> 41.8, 41.8, 41.8, 41.8, 41.8, 41.8, 42.0, 41.8, 4…
## $ longitude      <dbl> -87.7, -87.6, -87.6, -87.7, -87.7, -87.7, -87.7, …
```

## Exercise: Visualize the 311 data

1. Obtain map tiles using `ggmap` for the city of Chicago.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    # store bounding box coordinates
    chi_bb <- c(left = -87.936287,
                bottom = 41.679835,
                right = -87.447052,
                top = 42.000835)
    
    # retrieve bounding box
    chicago <- get_stamenmap(bbox = chi_bb,
                             zoom = 11)
    
    # plot the raster map
    ggmap(chicago)
    ```
    
    <img src="/notes/raster-maps-practice_files/figure-html/bb-chicago-1.png" width="672" />
        
      </p>
    </details>

1. Generate a scatterplot of complaints about potholes in streets.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    # initialize map
    ggmap(chicago) +
      # add layer with scatterplot
      # use alpha to show density of points
      geom_point(data = filter(chi_311, sr_type == "Pothole in Street Complaint"),
                 mapping = aes(x = longitude,
                               y = latitude),
                 size = .25,
                 alpha = .05)
    ```
    
    <img src="/notes/raster-maps-practice_files/figure-html/potholes-point-1.png" width="672" />
        
      </p>
    </details>

1. Generate a heatmap of complaints about potholes in streets. Do you see any unusual patterns or clusterings?

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    # initialize the map
    ggmap(chicago) +
      # add the heatmap
      stat_density_2d(data = filter(chi_311, sr_type == "Pothole in Street Complaint"),
                      mapping = aes(x = longitude,
                                    y = latitude,
                                    fill = stat(level)),
                      alpha = .1,
                      bins = 50,
                      geom = "polygon") +
      # customize the color gradient
      scale_fill_gradientn(colors = brewer.pal(9, "YlOrRd"))
    ```
    
    <img src="/notes/raster-maps-practice_files/figure-html/potholes-heatmap-1.png" width="672" />
        
    Seems to be clustered on the north side. Also looks to occur along major arterial routes for commuting traffic. Makes sense because they receive the most wear and tear.
        
      </p>
    </details>

1. Obtain map tiles for Hyde Park.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    # store bounding box coordinates
    hp_bb <- c(left = -87.608221,
               bottom = 41.783249,
               right = -87.577643,
               top = 41.803038)
    
    # retrieve bounding box
    hyde_park <- get_stamenmap(bbox = hp_bb,
                               zoom = 15)
    
    # plot the raster map
    ggmap(hyde_park)
    ```
    
    <img src="/notes/raster-maps-practice_files/figure-html/bb-hyde-park-1.png" width="672" />
        
      </p>
    </details>

1. Generate a scatterplot of requests to pick up dead animals in Hyde Park.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    # initialize the map
    ggmap(hyde_park) +
      # add a scatterplot layer
      geom_point(data = filter(chi_311, sr_type == "Dead Animal Pick-Up Request"),
                 mapping = aes(x = longitude,
                               y = latitude))
    ```
    
    <img src="/notes/raster-maps-practice_files/figure-html/dead-animals-point-1.png" width="672" />
        
      </p>
    </details>

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
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports      1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  bitops         1.0-6   2013-08-17 [1] CRAN (R 3.6.0)
##  blogdown       0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown       0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom          0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr          3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli            1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace     1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc           1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools       2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest         0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr        * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats      * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs             1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics       0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggmap        * 3.0.0   2019-02-05 [1] CRAN (R 3.6.0)
##  ggplot2      * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue           1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven          2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here         * 0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms            0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools      0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr           1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jpeg           0.1-8   2014-01-23 [1] CRAN (R 3.6.0)
##  jsonlite       1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr          1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice        0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval       0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate      1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr       1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr         0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme           3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar         1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild       1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig      2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload        1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  plyr           1.8.4   2016-06-08 [1] CRAN (R 3.6.0)
##  png            0.1-7   2013-12-03 [1] CRAN (R 3.6.0)
##  prettyunits    1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx       3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps             1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr        * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6             2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 3.6.0)
##  Rcpp           1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr        * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes        2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  RgoogleMaps    1.4.3   2018-11-07 [1] CRAN (R 3.6.0)
##  rjson          0.2.20  2018-06-08 [1] CRAN (R 3.6.0)
##  rlang          0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown      1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot      1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi     0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest          0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales         1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi        1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat       2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble       * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr        * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect     0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse    * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis        1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs          0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr          2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun           0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2           1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml           2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot        0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
