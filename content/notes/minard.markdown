---
title: "How to build a complicated, layered graphic"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/dataviz_minard.html"]
categories: ["dataviz"]

menu:
  notes:
    parent: Data visualization
    weight: 3
---




```r
library(tidyverse)
library(knitr)
library(here)
```

![["Carte figurative des pertes successives en hommes de l'Armee Français dans la campagne de Russe 1812–1813" by Charles Joseph Minard](https://en.wikipedia.org/wiki/Charles_Joseph_Minard)](https://upload.wikimedia.org/wikipedia/commons/2/29/Minard.png)

**Charles Minard's map of Napoleon's disastrous Russian campaign of 1812** is notable for its representation in two dimensions of six types of data: the number of Napoleon's troops; distance; temperature; the latitude and longitude; direction of travel; and location relative to specific dates.^[This exercise is drawn from [Wickham, Hadley. (2010) "A Layered Grammar of Graphics". *Journal of Computational and Graphical Statistics*, 19(1).](http://www.jstor.org.proxy.uchicago.edu/stable/25651297)]

## Building Minard's map in R


```r
# get data on troop movements and city names
troops <- here("static", "data", "minard-troops.txt") %>%
  read_table()
```

```
## Parsed with column specification:
## cols(
##   long = col_double(),
##   lat = col_double(),
##   survivors = col_double(),
##   direction = col_character(),
##   group = col_double()
## )
```

```r
cities <- here("static", "data", "minard-cities.txt") %>%
  read_table()
```

```
## Parsed with column specification:
## cols(
##   long = col_double(),
##   lat = col_double(),
##   city = col_character()
## )
```

```r
troops
```

```
## # A tibble: 51 x 5
##     long   lat survivors direction group
##    <dbl> <dbl>     <dbl> <chr>     <dbl>
##  1  24    54.9    340000 A             1
##  2  24.5  55      340000 A             1
##  3  25.5  54.5    340000 A             1
##  4  26    54.7    320000 A             1
##  5  27    54.8    300000 A             1
##  6  28    54.9    280000 A             1
##  7  28.5  55      240000 A             1
##  8  29    55.1    210000 A             1
##  9  30    55.2    180000 A             1
## 10  30.3  55.3    175000 A             1
## # … with 41 more rows
```

```r
cities
```

```
## # A tibble: 20 x 3
##     long   lat city          
##    <dbl> <dbl> <chr>         
##  1  24    55   Kowno         
##  2  25.3  54.7 Wilna         
##  3  26.4  54.4 Smorgoni      
##  4  26.8  54.3 Moiodexno     
##  5  27.7  55.2 Gloubokoe     
##  6  27.6  53.9 Minsk         
##  7  28.5  54.3 Studienska    
##  8  28.7  55.5 Polotzk       
##  9  29.2  54.4 Bobr          
## 10  30.2  55.3 Witebsk       
## 11  30.4  54.5 Orscha        
## 12  30.4  53.9 Mohilow       
## 13  32    54.8 Smolensk      
## 14  33.2  54.9 Dorogobouge   
## 15  34.3  55.2 Wixma         
## 16  34.4  55.5 Chjat         
## 17  36    55.5 Mojaisk       
## 18  37.6  55.8 Moscou        
## 19  36.6  55.3 Tarantino     
## 20  36.5  55   Malo-Jarosewii
```

### Exercise: Define the grammar of graphics for this graph

<details> 
  <summary>**Click here for solution**</summary>
  <p>
  
* Layer
    * Data - `troops`
    * Mapping
        * `\(x\)` and `\(y\)` - troop position (`lat` and `long`)
        * Size - `survivors`
        * Color - `direction`
    * Statistical transformation (stat) - `identity`
    * Geometric object (geom) - `path`
    * Position adjustment (position) - none
* Layer
    * Data - `cities`
    * Mapping
        * `\(x\)` and `\(y\)` - city position (`lat` and `long`)
        * Label - `city`
    * Statistical transformation (stat) - `identity`
    * Geometric object (geom) - `text`
    * Position adjustment (position) - none
* Scale
    * Size - range of widths for troop `path`
    * Color - colors to indicate advancing or retreating troops
* Coordinate system - map projection (Mercator or something else)
* Faceting - none

  </p>
</details>

## Write the R code

First we want to build the layer for the troop movement:


```r
plot_troops <- ggplot(data = troops, mapping = aes(x = long, y = lat)) +
  geom_path(aes(size = survivors,
                color = direction,
                group = group))
plot_troops
```

<img src="/notes/minard_files/figure-html/plot_troops-1.png" width="672" />

Next let's add the cities layer:


```r
plot_both <- plot_troops + 
  geom_text(data = cities, mapping = aes(label = city), size = 4)
plot_both
```

<img src="/notes/minard_files/figure-html/plot_cities-1.png" width="672" />

Now that the basic information is on there, we want to clean up the graph and polish the visualization by:

* Adjusting the size scale aesthetics for troop movement to better highlight the loss of troops over the campaign.
* Change the default colors to mimic Minard's original grey and tan palette.
* Change the coordinate system to a map-based system that draws the `\(x\)` and `\(y\)` axes at equal intervals.
* Give the map a title and remove the axis labels.


```r
plot_polished <- plot_both +
  scale_size(range = c(0, 12),
             breaks = c(10000, 20000, 30000),
             labels = c("10,000", "20,000", "30,000")) + 
  scale_color_manual(values = c("tan", "grey50")) +
  coord_map() +
  labs(title = "Map of Napoleon's Russian campaign of 1812",
       x = NULL,
       y = NULL)
plot_polished
```

<img src="/notes/minard_files/figure-html/plot_clean-1.png" width="672" />

Finally we can change the default `ggplot` theme to remove the background and grid lines, as well as the legend:


```r
plot_polished +
  theme_void() +
  theme(legend.position = "none")
```

<img src="/notes/minard_files/figure-html/plot_final-1.png" width="672" />

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
##  here        * 0.1     2017-05-28 [2] CRAN (R 3.5.0)
##  hms           0.4.2   2018-03-10 [2] CRAN (R 3.5.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
##  httr          1.4.0   2018-12-11 [2] CRAN (R 3.5.0)
##  jsonlite      1.6     2018-12-07 [2] CRAN (R 3.5.0)
##  knitr       * 1.22    2019-03-08 [2] CRAN (R 3.5.2)
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
