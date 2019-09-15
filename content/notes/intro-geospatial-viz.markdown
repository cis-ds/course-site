---
title: "Introduction to geospatial visualization"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/geoviz_intro.html"]
categories: ["dataviz", "geospatial"]

menu:
  notes:
    parent: Geospatial visualization
    weight: 1
---





**Geospatial visualizations** are one of the earliest forms of information visualizations. They were used historically for navigation and were essential tools before the modern technological era of humanity. Data maps were first popularized in the seventeenth century and have grown in complexity and detail since then. Consider [Google Maps](https://www.google.com/maps), the sheer volume of data depicted, and the analytical pathways available to its users. Of course geospatial data visualizations do not require computational skills to generate.

## John Snow and the Broad Street water pump

[![Original map made by John Snow in 1854. Cholera cases are highlighted in black. Source: Wikipedia.](https://upload.wikimedia.org/wikipedia/commons/2/27/Snow-cholera-map-1.jpg)](https://commons.wikimedia.org/wiki/File:Snow-cholera-map-1.jpg)

In the nineteenth century the theory of bacteria was not widely accepted by the medical community or the public.^[Drawn from [John Snow and the Broad Street Pump](http://www.ph.ucla.edu/epi/snow/snowcricketarticle.html)] A mother washed her baby's diaper in a well in 1854 in London, sparking an outbreak of **cholera**, an intestinal disease that causes vomiting, diarrhea, and eventually death. This disease had presented itself previously in London but its cause was still unknown.

Dr. John Snow lived in Soho, the suburb of London where the disease manifested in 1854, and wanted to understand how cholera spreads through a population (an early day epidemiologist). Snow recorded the location of individuals who contracted cholera, including their places of residence and employment. He used this information to draw a map of the region, recording the location of individuals who contracted the disease. They seemed to be clustered around the well pump along Broad Street. Snow used this map to deduce the source of the outbreak was the well, observing that almost all of the infected individuals lived near, and drank from, the well. Based on this information, the government removed the handle from the well pump so the public could not draw water from it. As a result, the cholera epidemic ended.

## *Carte figurative des pertes successives en hommes de l'Armée Française dans la campagne de Russie 1812-1813)*

[![Charles Minard's 1869 chart showing the number of men in Napoleon’s 1812 Russian campaign army, their movements, as well as the temperature they encountered on the return path. Source: Wikipedia.](https://upload.wikimedia.org/wikipedia/commons/2/29/Minard.png)](https://en.wikipedia.org/wiki/File:Minard.png)

[![English translation of Minard's map](https://upload.wikimedia.org/wikipedia/commons/e/e2/Minard_Update.png)](https://commons.wikimedia.org/wiki/File:Minard_Update.png)

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
* Mimimalistic in nature (avoids what we will later term "chart junk")

## Designing modern maps

Geometric visualizations are used to depict spatial features, and with the incorporation of data reveal additional attributes and information. The main features of a map are defined by its **scale** (the proportion between distances and sizes on the map), its **projection** (how the three-dimensional Earth is represented on a two-dimensional surface), and its **symbols** (how data is depicted and visualized on the map).

## Scale

**Scale** defines the proportion between distances and sizes on a map and their actual distances and sizes on Earth. Depending on the total geographic area for which you have data to visualize, you could create a **small-scale map** or a **large-scale map**. So for instance, a map of the United States would be considered large-scale:

<img src="/notes/intro-geospatial-viz_files/figure-html/large-scale-1.png" width="672" />

Whereas a map of Hyde Park would be small-scale:

<img src="/notes/intro-geospatial-viz_files/figure-html/small-scale-1.png" width="672" />

The smaller the scale, the easier it is to include additional details in the map.

## Projection

**Projection** is the process of taking a globe (i.e. a three-dimensional object)^[Assuming you are not a [flat-Earther](https://www.livescience.com/24310-flat-earth-belief.html).] and visualizing it on a two-dimensional picture. There is no 100% perfect method for doing this, as any projection method will have to distort some features of the map to achieve a two-dimensional representation. There are five properties to consider when defining a projection method:

1. Shape
1. Area
1. Angles
1. Distance
1. Direction

Projection methods typically maximize the accuracy of one or two of these properties, but no more. For instance, **conformal projections** such as the **mercator** projection preserves shape and local angles and is very useful for sea navigation, but distorts the area of landmasses.



<img src="/notes/intro-geospatial-viz_files/figure-html/mercator-1.png" width="672" />

The farther away from the equator one travels, the more distorted the size of the region.

Another family of projections called **equal-area projections** preserves area ratios, so that the relative size of areas on a map are proportional to their areas on the Earth.

<img src="/notes/intro-geospatial-viz_files/figure-html/equal-area-1.png" width="672" /><img src="/notes/intro-geospatial-viz_files/figure-html/equal-area-2.png" width="672" />

The downside is that equal-area projections tend to distory shapes heavily, so shapes of areas can become distorted. No method can be both conformal and equal-area simultaneously, but some methods such as the **Mollweide** projection achieve a trade-off between these sets of characteristics.

<img src="/notes/intro-geospatial-viz_files/figure-html/mollweide-1.png" width="672" />

## Symbols

Different types of symbols are used to denote different types of information on a spatial visualization. For instance, consider the following map of Hyde Park:

<img src="/notes/intro-geospatial-viz_files/figure-html/bb-hydepark-stamen-1.png" width="672" />

* Line are used to indicate roadways
* Fill is used to indicate type of land (grassland, water, urban, etc.)
* Symbols/shapes are used to locate buildings
* Text labels are used to indicate geographic locations

Data maps do not just encode geographic features on the visualization. They also plot quantitative and qualitative data on the mapping surface itself. Minard's drawing was not just of geographic coordinates and features - it also visualizes quantitative data such as troop deaths and temperature. Different symbols are used depending on the type of data you seek to visualize.

### Acknowledgments

* Cairo, A. (2016). *The truthful art: Data, charts, and maps for communication*. New Riders.
* Tufte, E., & Graves-Morris, P. (2001). *The visual display of quantitative information*. Graphics Press.

### Session Info



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
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  bitops        1.0-6   2013-08-17 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  class         7.3-15  2019-01-01 [1] CRAN (R 3.6.0)
##  classInt      0.4-1   2019-08-06 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  DBI           1.0.0   2018-05-02 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  e1071         1.7-2   2019-06-05 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggmap       * 3.0.0   2019-02-05 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here        * 0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jpeg          0.1-8   2014-01-23 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  KernSmooth    2.23-15 2015-06-29 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  plyr          1.8.4   2016-06-08 [1] CRAN (R 3.6.0)
##  png           0.1-7   2013-12-03 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  RgoogleMaps   1.4.3   2018-11-07 [1] CRAN (R 3.6.0)
##  rjson         0.2.20  2018-06-08 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  sf          * 0.7-7   2019-07-24 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  units         0.6-3   2019-05-03 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
