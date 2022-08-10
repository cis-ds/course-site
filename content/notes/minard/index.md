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

<div class="figure">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Minard.png/1024px-Minard.png" alt="Charles Minard's 1869 chart showing the number of men in Napoleon’s 1812 Russian campaign army, their movements, as well as the temperature they encountered on the return path. Source: &lt;a href = 'https://en.wikipedia.org/wiki/File:Minard.png'&gt;Wikipedia&lt;/a&gt;." width="100%" />
<p class="caption">Figure 1: Charles Minard's 1869 chart showing the number of men in Napoleon’s 1812 Russian campaign army, their movements, as well as the temperature they encountered on the return path. Source: <a href = 'https://en.wikipedia.org/wiki/File:Minard.png'>Wikipedia</a>.</p>
</div>

<div class="figure">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Minard_Update.png/1024px-Minard_Update.png" alt="&lt;a href = 'https://commons.wikimedia.org/wiki/File:Minard_Update.png'&gt;English translation of Minard's map&lt;/a&gt;" width="100%" />
<p class="caption">Figure 2: <a href = 'https://commons.wikimedia.org/wiki/File:Minard_Update.png'>English translation of Minard's map</a></p>
</div>

This illustration is identifed in Edward Tufte's **The Visual Display of Quantitative Information** as one of "the best statistical drawings ever created". It also demonstrates a very important rule of warfare: [never invade Russia in the winter](https://en.wikipedia.org/wiki/Russian_Winter).

In 1812, Napoleon ruled most of Europe. He wanted to seize control of the British islands, but could not overcome the UK defenses. He decided to impose an embargo to weaken the nation in preparation for invasion, but Russia refused to participate. Angered at this decision, Napoleon launched an invasion of Russia with over 400,000 troops in the summer of 1812. Russia was unable to defeat Napoleon in battle, but instead waged a war of attrition. The Russian army was in near constant retreat, burning or destroying anything of value along the way to deny France usable resources. While Napoleon's army maintained the military advantage, his lack of food and the emerging European winter decimated his forces. He left France with an army of approximately 422,000 soldiers; he returned to France with just 10,000.

Charles Minard's map is a stunning achievement for his era. It incorporates data across six dimensions to tell the story of Napoleon's failure. The graph depicts:

* Size of the army
* Location in two physical dimensions (latitude and longitude)
* Direction of the army's movement
* Temperature on dates during Napoleon's retreat

What makes this such an effective visualization?^[Source: [Dataviz History: Charles Minard's Flow Map of Napoleon's Russian Campaign of 1812](https://datavizblog.com/2013/05/26/dataviz-history-charles-minards-flow-map-of-napoleons-russian-campaign-of-1812-part-5/)]

* Forces visual comparisons (colored bands for advancing and retreating)
* Shows causality (temperature chart)
* Captures multivariate complexity
* Integrates text and graphic into a coherent whole (perhaps the first infographic, and done well!)
* Illustrates high quality content (based on reliable data)
* Places comparisons adjacent to each other (all on the same page, no jumping back and forth between pages)

## Building Minard's map in R

We can reconstruct this map using `ggplot()` and the [grammar of graphics](/notes/grammar-of-graphics/).^[This exercise is drawn from [Wickham, Hadley. (2010) "A Layered Grammar of Graphics". *Journal of Computational and Graphical Statistics*, 19(1).](hhttps://www.tandfonline.com/doi/pdf/10.1198/jcgs.2009.07098)] Here we will focus just on the upper portion including the map depicting the troop movements.


```r
# get data on troop movements and city names
troops <- here("static", "data", "minard-troops.txt") %>%
  read_table()
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
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
## 
## ── Column specification ────────────────────────────────────────────────────────
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
## # A tibble: 51 × 5
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
## # ℹ Use `print(n = ...)` to see more rows
```

```r
cities
```

```
## # A tibble: 20 × 3
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

Recall the major elements of the grammar of graphics:

* Layer
    * Data
    * Mapping
    * Statistical transformation (stat)
    * Geometric object (geom)
    * Position adjustment (position)
* Scale
* Coordinate system
* Faceting

And here we have two data frames containing the following variables:

* Troops
    * Latitude
    * Longitude
    * Survivors
    * Advance/retreat
* Cities
    * Latitude
    * Longitude
    * City name

Use this information to define the **grammar of graphics** to recreate Minard's map.^[Ignore the temperature line graph, just focus on the map portion.]

{{< spoiler text="Click for the solution" >}}

* Layer
    * Data - `troops`
    * Mapping
        * $x$ and $y$ - troop position (`lat` and `long`)
        * Size - `survivors`
        * Color - `direction`
    * Statistical transformation (stat) - `identity`
    * Geometric object (geom) - `path`
    * Position adjustment (position) - none
* Layer
    * Data - `cities`
    * Mapping
        * $x$ and $y$ - city position (`lat` and `long`)
        * Label - `city`
    * Statistical transformation (stat) - `identity`
    * Geometric object (geom) - `text`
    * Position adjustment (position) - none
* Scale
    * Size - range of widths for troop `path`
    * Color - colors to indicate advancing or retreating troops
* Coordinate system - map projection (Mercator or something else)
* Faceting - none

{{< /spoiler >}}

## Write the R code

First we want to build the layer for the troop movement:


```r
plot_troops <- ggplot(data = troops, mapping = aes(x = long, y = lat)) +
  geom_path(mapping = aes(
    size = survivors,
    color = direction,
    group = group
  ))
plot_troops
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot_troops-1.png" width="672" />

Next let's add the cities layer:


```r
plot_both <- plot_troops +
  geom_text(data = cities, mapping = aes(label = city), size = 4)
plot_both
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot_cities-1.png" width="672" />

Now that the basic information is on there, we want to clean up the graph and polish the visualization by:

* Adjusting the size scale aesthetics for troop movement to better highlight the loss of troops over the campaign.
* Change the default colors to mimic Minard's original grey and tan palette.
* Change the coordinate system to a map-based system that draws the $x$ and $y$ axes at equal intervals.
* Give the map a title and remove the axis labels.


```r
plot_polished <- plot_both +
  scale_size(
    range = c(0, 12),
    breaks = c(10000, 20000, 30000),
    labels = c("10,000", "20,000", "30,000")
  ) +
  scale_color_manual(values = c("tan", "grey50")) +
  coord_map() +
  labs(
    title = "Map of Napoleon's Russian campaign of 1812",
    x = NULL,
    y = NULL
  )
plot_polished
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot_clean-1.png" width="672" />

Finally we can change the default `ggplot` theme to remove the background and grid lines, as well as the legend:


```r
plot_polished +
  theme_void() +
  theme(legend.position = "none")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot_final-1.png" width="672" />

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
##  date     2022-08-10
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
##  codetools       0.2-18     2020-11-04 [2] CRAN (R 4.2.1)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  farver          2.1.1      2022-07-06 [2] CRAN (R 4.2.0)
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
##  here          * 1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  highr           0.9        2021-04-16 [2] CRAN (R 4.2.0)
##  hms             1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools       0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr            1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr         * 1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  labeling        0.4.2      2020-10-20 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate       1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  mapproj         1.2.8      2022-01-12 [2] CRAN (R 4.2.0)
##  maps            3.4.0      2021-09-25 [2] CRAN (R 4.2.0)
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
