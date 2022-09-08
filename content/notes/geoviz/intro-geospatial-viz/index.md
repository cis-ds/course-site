---
title: "Introduction to geospatial visualization"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/geoviz_intro.html", "/notes/intro-geospatial-viz/"]
categories: ["dataviz", "geospatial"]

weight: 51
---





**Geospatial visualizations** are one of the earliest forms of information visualizations. They were used historically for navigation and were essential tools before the modern technological era of humanity. Data maps were first popularized in the seventeenth century and have grown in complexity and detail since then. Consider [Google Maps](https://www.google.com/maps), the sheer volume of data depicted, and the analytical pathways available to its users. Of course geospatial data visualizations do not require computational skills to generate.

## John Snow and the Broad Street water pump

{{< figure src="Snow-cholera-map-1.jpeg" caption="[Original map made by John Snow in 1854. Cholera cases are highlighted in black. Source: Wikipedia.](https://commons.wikimedia.org/wiki/File:Snow-cholera-map-1.jpg)" >}}

In the nineteenth century the theory of bacteria was not widely accepted by the medical community or the public.[^snow] A mother washed her baby's diaper in a well in 1854 in London, sparking an outbreak of **cholera**, an intestinal disease that causes vomiting, diarrhea, and eventually death. This disease had presented itself previously in London but its cause was still unknown.

Dr. John Snow lived in Soho, the suburb of London where the disease manifested in 1854, and wanted to understand how cholera spreads through a population (an early day epidemiologist). Snow recorded the location of individuals who contracted cholera, including their places of residence and employment. He used this information to draw a map of the region, recording the location of individuals who contracted the disease. They seemed to be clustered around the well pump along Broad Street. Snow used this map to deduce the source of the outbreak was the well, observing that almost all of the infected individuals lived near, and drank from, the well. Based on this information, the government removed the handle from the well pump so the public could not draw water from it. As a result, the cholera epidemic ended.

## *Carte figurative des pertes successives en hommes de l'Armée Française dans la campagne de Russie 1812-1813)*

{{< figure src="https://upload.wikimedia.org/wikipedia/commons/2/29/Minard.png" caption="[Charles Minard's 1869 chart showing the number of men in Napoleon’s 1812 Russian campaign army, their movements, as well as the temperature they encountered on the return path. Source: Wikipedia.](https://en.wikipedia.org/wiki/File:Minard.png)" >}}

{{< figure src="https://upload.wikimedia.org/wikipedia/commons/e/e2/Minard_Update.png" caption="[English translation of Minard's map](https://commons.wikimedia.org/wiki/File:Minard_Update.png)" >}}

This illustration is identified in Edward Tufte's **The Visual Display of Quantitative Information** as one of "the best statistical drawings ever created". It also demonstrates a very important rule of warfare: [never invade Russia in the winter](https://en.wikipedia.org/wiki/Russian_Winter).

In 1812, Napoleon ruled most of Europe. He wanted to seize control of the British islands, but could not overcome the UK defenses. He decided to impose an embargo to weaken the nation in preparation for invasion, but Russia refused to participate. Angered at this decision, Napoleon launched an invasion of Russia with over 400,000 troops in the summer of 1812. Russia was unable to defeat Napoleon in battle, but instead waged a war of attrition. The Russian army was in near constant retreat, burning or destroying anything of value along the way to deny France usable resources. While Napoleon's army maintained the military advantage, his lack of food and the emerging European winter decimated his forces. He left France with an army of approximately 422,000 soldiers; he returned to France with just 10,000.

Charles Minard's map is a stunning achievement for his era. It incorporates data across six dimensions to tell the story of Napoleon's failure. The graph depicts:

* Size of the army
* Location in two physical dimensions (latitude and longitude)
* Direction of the army's movement
* Temperature on dates during Napoleon's retreat

What makes this such an effective visualization?[^minard]

* Forces visual comparisons (colored bands for advancing and retreating)
* Shows causality (temperature chart)
* Captures multivariate complexity
* Integrates text and graphic into a coherent whole (perhaps the first infographic, and done well!)
* Illustrates high quality content (based on reliable data)
* Places comparisons adjacent to each other (all on the same page, no jumping back and forth between pages)
* Mimimalistic in nature (avoids what we will later term "chart junk")

## Designing modern maps

Geometric visualizations are used to depict spatial features, and with the incorporation of data reveal additional attributes and information. The main features of a map are defined by its **scale** (the proportion between distances and sizes on the map), its **projection** (how the three-dimensional Earth is represented on a two-dimensional surface), and its **symbols** (how data is depicted and visualized on the map).

## Scale

**Scale** defines the proportion between distances and sizes on a map and their actual distances and sizes on Earth. Depending on the total geographic area for which you have data to visualize, you could create a **small-scale map** or a **large-scale map**. So for instance, a map of the United States would be considered large-scale:

<img src="{{< blogdown/postref >}}index_files/figure-html/large-scale-1.png" width="672" />

Whereas a map of Ithaca would be small-scale:

<img src="{{< blogdown/postref >}}index_files/figure-html/small-scale-1.png" width="672" />

The smaller the scale, the easier it is to include additional details in the map.

## Projection

**Projection** is the process of taking a globe (i.e. a three-dimensional object)[^flat] and visualizing it on a two-dimensional picture. There is no 100% perfect method for doing this, as any projection method will have to distort some features of the map to achieve a two-dimensional representation. There are five properties to consider when defining a projection method:

1. Shape
1. Area
1. Angles
1. Distance
1. Direction

Projection methods typically maximize the accuracy of one or two of these properties, but no more. For instance, **conformal projections** such as the **mercator** projection preserves shape and local angles and is very useful for sea navigation, but distorts the area of landmasses.



<img src="{{< blogdown/postref >}}index_files/figure-html/mercator-1.png" width="672" />

The farther away from the equator one travels, the more distorted the size of the region.

Another family of projections called **equal-area projections** preserves area ratios, so that the relative size of areas on a map are proportional to their areas on the Earth.

<img src="{{< blogdown/postref >}}index_files/figure-html/equal-area-1.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/equal-area-2.png" width="672" />

The downside is that equal-area projections tend to distory shapes heavily, so shapes of areas can become distorted. No method can be both conformal and equal-area simultaneously, but some methods such as the **Mollweide** projection achieve a trade-off between these sets of characteristics.

<img src="{{< blogdown/postref >}}index_files/figure-html/mollweide-1.png" width="672" />

## Symbols

Different types of symbols are used to denote different types of information on a spatial visualization. For instance, consider the following map of Cornell's engineering and biology quads:

<img src="{{< blogdown/postref >}}index_files/figure-html/bb-cornell-stamen-1.png" width="672" />

* Line are used to indicate roadways
* Fill is used to indicate type of land (grassland, water, urban, etc.)
* Symbols/shapes are used to locate buildings
* Text labels are used to indicate geographic locations

Data maps do not just encode geographic features on the visualization. They also plot quantitative and qualitative data on the mapping surface itself. Minard's drawing was not just of geographic coordinates and features - it also visualizes quantitative data such as troop deaths and temperature. Different symbols are used depending on the type of data you seek to visualize.

## Acknowledgments

* Cairo, A. (2016). *The truthful art: Data, charts, and maps for communication*. New Riders.
* Tufte, E., & Graves-Morris, P. (2001). *The visual display of quantitative information*. Graphics Press.

### Session Info



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
##  date     2022-09-01
##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  assertthat      0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  bitops          1.0-7      2021-04-24 [2] CRAN (R 4.2.0)
##  blogdown        1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  class           7.3-20     2022-01-16 [2] CRAN (R 4.2.1)
##  classInt        0.4-7      2022-06-10 [2] CRAN (R 4.2.0)
##  cli             3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  codetools       0.2-18     2020-11-04 [2] CRAN (R 4.2.1)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  curl            4.3.2      2021-06-23 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  e1071           1.7-11     2022-06-07 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  farver          2.1.1      2022-07-06 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs              1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggmap         * 3.0.0      2019-02-05 [2] CRAN (R 4.2.0)
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
##  jpeg            0.1-9      2021-07-24 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  KernSmooth      2.23-20    2021-05-03 [2] CRAN (R 4.2.1)
##  knitr           1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  labeling        0.4.2      2020-10-20 [2] CRAN (R 4.2.0)
##  lattice         0.20-45    2021-09-22 [2] CRAN (R 4.2.1)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate       1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr          0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  plyr            1.8.7      2022-03-24 [2] CRAN (R 4.2.0)
##  png             0.1-7      2013-12-03 [2] CRAN (R 4.2.0)
##  proxy           0.4-27     2022-06-09 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6              2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  Rcpp            1.0.9      2022-07-08 [2] CRAN (R 4.2.0)
##  readr         * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl          1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex          2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  RgoogleMaps     1.4.5.3    2020-02-12 [2] CRAN (R 4.2.0)
##  rjson           0.2.21     2022-01-09 [2] CRAN (R 4.2.0)
##  rlang           1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown       2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rnaturalearth * 0.1.0      2017-03-21 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest           1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo     1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  sf            * 1.0-8      2022-07-14 [2] CRAN (R 4.2.0)
##  sp              1.5-0      2022-06-05 [2] CRAN (R 4.2.0)
##  stringi         1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  units           0.8-0      2022-02-05 [2] CRAN (R 4.2.0)
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

[^snow]: Drawn from [John Snow and the Broad Street Pump](http://www.ph.ucla.edu/epi/snow/snowcricketarticle.html)
[^minard]: Source: [Dataviz History: Charles Minard's Flow Map of Napoleon's Russian Campaign of 1812](https://datavizblog.com/2013/05/26/dataviz-history-charles-minards-flow-map-of-napoleons-russian-campaign-of-1812-part-5/).
[^flat]: Assuming you are not a [flat-Earther](https://www.livescience.com/24310-flat-earth-belief.html).
