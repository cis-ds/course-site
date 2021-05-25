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

{{% callout note %}}

If you are copying-and-pasting code from this demonstration, use `chi_311 <- read_csv("https://cfss.uchicago.edu/data/chi-311.csv")` to download the file from the course website.

{{% /callout %}}




```r
glimpse(chi_311)
```

```
## Rows: 165,982
## Columns: 8
## $ sr_number      <chr> "SR19-01209373", "SR19-01129184", "SR19-01130159", "SR1…
## $ sr_type        <chr> "Dead Animal Pick-Up Request", "Dead Animal Pick-Up Req…
## $ sr_short_code  <chr> "SGQ", "SGQ", "SGQ", "SGQ", "SGQ", "SGQ", "SGQ", "SGQ",…
## $ created_date   <dttm> 2019-03-23 12:13:05, 2019-03-08 19:37:26, 2019-03-09 0…
## $ community_area <dbl> 58, 40, 40, 67, 59, 59, 2, 59, 59, 64, 59, 25, 25, 59, …
## $ ward           <dbl> 12, 20, 20, 17, 12, 12, 40, 12, 12, 13, 12, 29, 28, 12,…
## $ latitude       <dbl> 41.8, 41.8, 41.8, 41.8, 41.8, 41.8, 42.0, 41.8, 41.8, 4…
## $ longitude      <dbl> -87.7, -87.6, -87.6, -87.7, -87.7, -87.7, -87.7, -87.7,…
```

## Exercise: Visualize the 311 data

1. Obtain map tiles using `ggmap` for the city of Chicago.

    {{< spoiler text="Click for the solution" >}}


```r
# store bounding box coordinates
chi_bb <- c(
  left = -87.936287,
  bottom = 41.679835,
  right = -87.447052,
  top = 42.000835
)

# retrieve bounding box
chicago <- get_stamenmap(
  bbox = chi_bb,
  zoom = 11
)

# plot the raster map
ggmap(chicago)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/bb-chicago-1.png" width="672" />

    {{< /spoiler >}}

1. Generate a scatterplot of complaints about potholes in streets.

    {{< spoiler text="Click for the solution" >}}


```r
# initialize map
ggmap(chicago) +
  # add layer with scatterplot
  # use alpha to show density of points
  geom_point(
    data = filter(chi_311, sr_type == "Pothole in Street Complaint"),
    mapping = aes(
      x = longitude,
      y = latitude
    ),
    size = .25,
    alpha = .05
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/potholes-point-1.png" width="672" />

    {{< /spoiler >}}

1. Generate a heatmap of complaints about potholes in streets. Do you see any unusual patterns or clusterings?

    {{< spoiler text="Click for the solution" >}}


```r
# initialize the map
ggmap(chicago) +
  # add the heatmap
  stat_density_2d(
    data = filter(chi_311, sr_type == "Pothole in Street Complaint"),
    mapping = aes(
      x = longitude,
      y = latitude,
      fill = stat(level)
    ),
    alpha = .1,
    bins = 50,
    geom = "polygon"
  ) +
  # customize the color gradient
  scale_fill_gradientn(colors = brewer.pal(9, "YlOrRd"))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/potholes-heatmap-1.png" width="672" />

    Seems to be clustered on the north side. Also looks to occur along major arterial routes for commuting traffic. Makes sense because they receive the most wear and tear.

    {{< /spoiler >}}

1. Obtain map tiles for Hyde Park.

    {{< spoiler text="Click for the solution" >}}


```r
# store bounding box coordinates
hp_bb <- c(
  left = -87.608221,
  bottom = 41.783249,
  right = -87.577643,
  top = 41.803038
)

# retrieve bounding box
hyde_park <- get_stamenmap(
  bbox = hp_bb,
  zoom = 15
)

# plot the raster map
ggmap(hyde_park)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/bb-hyde-park-1.png" width="672" />

    {{< /spoiler >}}

1. Generate a scatterplot of requests to pick up dead animals in Hyde Park.

    {{< spoiler text="Click for the solution" >}}


```r
# initialize the map
ggmap(hyde_park) +
  # add a scatterplot layer
  geom_point(
    data = filter(chi_311, sr_type == "Dead Animal Pick-Up Request"),
    mapping = aes(
      x = longitude,
      y = latitude
    )
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/dead-animals-point-1.png" width="672" />

    {{< /spoiler >}}

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
##  bitops         1.0-7   2021-04-24 [1] CRAN (R 4.0.2)
##  blogdown       1.3     2021-04-14 [1] CRAN (R 4.0.2)
##  bookdown       0.22    2021-04-22 [1] CRAN (R 4.0.2)
##  broom          0.7.6   2021-04-05 [1] CRAN (R 4.0.4)
##  bslib          0.2.5   2021-05-12 [1] CRAN (R 4.0.4)
##  cachem         1.0.5   2021-05-15 [1] CRAN (R 4.0.2)
##  callr          3.7.0   2021-04-20 [1] CRAN (R 4.0.2)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli            2.5.0   2021-04-26 [1] CRAN (R 4.0.2)
##  colorspace     2.0-1   2021-05-04 [1] CRAN (R 4.0.2)
##  crayon         1.4.1   2021-02-08 [1] CRAN (R 4.0.2)
##  DBI            1.1.1   2021-01-15 [1] CRAN (R 4.0.2)
##  dbplyr         2.1.1   2021-04-06 [1] CRAN (R 4.0.4)
##  desc           1.3.0   2021-03-05 [1] CRAN (R 4.0.2)
##  devtools       2.4.1   2021-05-05 [1] CRAN (R 4.0.2)
##  digest         0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
##  dplyr        * 1.0.6   2021-05-05 [1] CRAN (R 4.0.2)
##  ellipsis       0.3.2   2021-04-29 [1] CRAN (R 4.0.2)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi          0.4.2   2021-01-15 [1] CRAN (R 4.0.2)
##  fastmap        1.1.0   2021-01-25 [1] CRAN (R 4.0.2)
##  forcats      * 0.5.1   2021-01-27 [1] CRAN (R 4.0.2)
##  fs             1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  generics       0.1.0   2020-10-31 [1] CRAN (R 4.0.2)
##  ggmap        * 3.0.0   2019-02-05 [1] CRAN (R 4.0.0)
##  ggplot2      * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)
##  glue           1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven          2.4.1   2021-04-23 [1] CRAN (R 4.0.2)
##  here         * 1.0.1   2020-12-13 [1] CRAN (R 4.0.2)
##  hms            1.1.0   2021-05-17 [1] CRAN (R 4.0.4)
##  htmltools      0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)
##  httr           1.4.2   2020-07-20 [1] CRAN (R 4.0.2)
##  jpeg           0.1-8.1 2019-10-24 [1] CRAN (R 4.0.0)
##  jquerylib      0.1.4   2021-04-26 [1] CRAN (R 4.0.2)
##  jsonlite       1.7.2   2020-12-09 [1] CRAN (R 4.0.2)
##  knitr          1.33    2021-04-24 [1] CRAN (R 4.0.2)
##  lattice        0.20-44 2021-05-02 [1] CRAN (R 4.0.2)
##  lifecycle      1.0.0   2021-02-15 [1] CRAN (R 4.0.2)
##  lubridate      1.7.10  2021-02-26 [1] CRAN (R 4.0.2)
##  magrittr       2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
##  memoise        2.0.0   2021-01-26 [1] CRAN (R 4.0.2)
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  pillar         1.6.1   2021-05-16 [1] CRAN (R 4.0.4)
##  pkgbuild       1.2.0   2020-12-15 [1] CRAN (R 4.0.2)
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload        1.2.1   2021-04-06 [1] CRAN (R 4.0.2)
##  plyr           1.8.6   2020-03-03 [1] CRAN (R 4.0.0)
##  png            0.1-7   2013-12-03 [1] CRAN (R 4.0.0)
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx       3.5.2   2021-04-30 [1] CRAN (R 4.0.2)
##  ps             1.6.0   2021-02-28 [1] CRAN (R 4.0.2)
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6             2.5.0   2020-10-28 [1] CRAN (R 4.0.2)
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 4.0.0)
##  Rcpp           1.0.6   2021-01-15 [1] CRAN (R 4.0.2)
##  readr        * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes        2.3.0   2021-04-01 [1] CRAN (R 4.0.2)
##  reprex         2.0.0   2021-04-02 [1] CRAN (R 4.0.2)
##  RgoogleMaps    1.4.5.3 2020-02-12 [1] CRAN (R 4.0.0)
##  rjson          0.2.20  2018-06-08 [1] CRAN (R 4.0.0)
##  rlang          0.4.11  2021-04-30 [1] CRAN (R 4.0.2)
##  rmarkdown      2.8     2021-05-07 [1] CRAN (R 4.0.2)
##  rprojroot      2.0.2   2020-11-15 [1] CRAN (R 4.0.2)
##  rstudioapi     0.13    2020-11-12 [1] CRAN (R 4.0.2)
##  rvest          1.0.0   2021-03-09 [1] CRAN (R 4.0.2)
##  sass           0.4.0   2021-05-12 [1] CRAN (R 4.0.2)
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  sp             1.4-5   2021-01-10 [1] CRAN (R 4.0.2)
##  stringi        1.6.1   2021-05-10 [1] CRAN (R 4.0.2)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat       3.0.2   2021-02-14 [1] CRAN (R 4.0.2)
##  tibble       * 3.1.1   2021-04-18 [1] CRAN (R 4.0.2)
##  tidyr        * 1.1.3   2021-03-03 [1] CRAN (R 4.0.2)
##  tidyselect     1.1.1   2021-04-30 [1] CRAN (R 4.0.2)
##  tidyverse    * 1.3.1   2021-04-15 [1] CRAN (R 4.0.2)
##  usethis        2.0.1   2021-02-10 [1] CRAN (R 4.0.2)
##  utf8           1.2.1   2021-03-12 [1] CRAN (R 4.0.2)
##  vctrs          0.3.8   2021-04-29 [1] CRAN (R 4.0.2)
##  withr          2.4.2   2021-04-18 [1] CRAN (R 4.0.2)
##  xfun           0.23    2021-05-15 [1] CRAN (R 4.0.2)
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
