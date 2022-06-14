---
title: "Why visualize data?"
date: 2019-03-01

type: docs
toc: false
draft: false
aliases: ["/dataviz_why.html"]
categories: ["dataviz"]

menu:
  notes:
    parent: Data visualization
    weight: 1
---





Research methods classes in graduate school generally teach important skills such as probability and statistical theory, regression, analysis of variance (ANOVA), maximum likelihood estimation (MLE), etc. While these are important methods for analyzing data and assessing research questions, sometimes drawing a picture (aka **visualization**) can be more precise than conventional statistical computations.^[Example drawn from [*The Datasaurus Dozen* by Justin Matejka and George Fitzmaurice](https://www.autodeskresearch.com/publications/samestats).]

Consider the following 13 data sets. What are the corresponding relationships between $X$ and $Y$? Using traditional metrics, the relationships appear identical across the samples:


| ID| $N$| $\bar{X}$| $\bar{Y}$| $\sigma_{X}$| $\sigma_{Y}$|    $R$|
|--:|---:|---------:|---------:|------------:|------------:|------:|
|  1| 142|      54.3|      47.8|         16.8|         26.9| -0.064|
|  2| 142|      54.3|      47.8|         16.8|         26.9| -0.069|
|  3| 142|      54.3|      47.8|         16.8|         26.9| -0.068|
|  4| 142|      54.3|      47.8|         16.8|         26.9| -0.064|
|  5| 142|      54.3|      47.8|         16.8|         26.9| -0.060|
|  6| 142|      54.3|      47.8|         16.8|         26.9| -0.062|
|  7| 142|      54.3|      47.8|         16.8|         26.9| -0.069|
|  8| 142|      54.3|      47.8|         16.8|         26.9| -0.069|
|  9| 142|      54.3|      47.8|         16.8|         26.9| -0.069|
| 10| 142|      54.3|      47.8|         16.8|         26.9| -0.063|
| 11| 142|      54.3|      47.8|         16.8|         26.9| -0.069|
| 12| 142|      54.3|      47.8|         16.8|         26.9| -0.067|
| 13| 142|      54.3|      47.8|         16.8|         26.9| -0.066|

$X$ and $Y$ have the same mean and standard deviation in each dataset, and the correlation coefficient (Pearson's $r$) is virtually identical. If we estimated linear regression models for each dataset, we would obtain virtually identical coefficients (again suggesting the relationships are identical):

<img src="{{< blogdown/postref >}}index_files/figure-html/datasaurus-lm-1.png" width="672" />

But what happens if we draw a picture?^[Source code from [Recreating the Datasaurus Dozen Using `tweenr` and `ggplot2`](https://www.wjakethompson.com/post/datasaurus-dozen/) and [Reanimating the Datasaurus](https://r-mageddon.netlify.com/post/reanimating-the-datasaurus/).]

![](index_files/figure-html/datasaurus-graph-1.gif)<!-- -->

<img src="{{< blogdown/postref >}}index_files/figure-html/datasaurus-graph-static-1.png" width="768" />

Remarkably each of the datasets have the same summary statistics and linear relationships, yet they are drastically different in appearance! A good picture tells the reader much more than any table or text can provide.

# Session Info



```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.2.0 (2022-04-22)
##  os       macOS Monterey 12.2.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/Chicago
##  date     2022-06-14
##  pandoc   2.17.1.1 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version    date (UTC) lib source
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 4.2.0)
##  backports      1.4.1      2021-12-13 [1] CRAN (R 4.2.0)
##  blogdown       1.10       2022-05-10 [1] CRAN (R 4.2.0)
##  bookdown       0.26       2022-04-15 [1] CRAN (R 4.2.0)
##  brio           1.1.3      2021-11-30 [1] CRAN (R 4.2.0)
##  broom        * 0.8.0      2022-04-13 [1] CRAN (R 4.2.0)
##  bslib          0.3.1      2021-10-06 [1] CRAN (R 4.2.0)
##  cachem         1.0.6      2021-08-19 [1] CRAN (R 4.2.0)
##  callr          3.7.0      2021-04-20 [1] CRAN (R 4.2.0)
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 4.2.0)
##  class          7.3-20     2022-01-16 [1] CRAN (R 4.2.0)
##  cli            3.3.0      2022-04-25 [1] CRAN (R 4.2.0)
##  codetools      0.2-18     2020-11-04 [1] CRAN (R 4.2.0)
##  colorspace   * 2.0-3      2022-02-21 [1] CRAN (R 4.2.0)
##  crayon         1.5.1      2022-03-26 [1] CRAN (R 4.2.0)
##  datasauRus   * 0.1.6      2022-05-04 [1] CRAN (R 4.2.0)
##  DBI            1.1.2      2021-12-20 [1] CRAN (R 4.2.0)
##  dbplyr         2.2.0      2022-06-05 [1] CRAN (R 4.2.0)
##  desc           1.4.1      2022-03-06 [1] CRAN (R 4.2.0)
##  devtools       2.4.3      2021-11-30 [1] CRAN (R 4.2.0)
##  dials          0.1.1      2022-04-06 [1] CRAN (R 4.2.0)
##  DiceDesign     1.9        2021-02-13 [1] CRAN (R 4.2.0)
##  digest         0.6.29     2021-12-01 [1] CRAN (R 4.2.0)
##  dplyr        * 1.0.9      2022-04-28 [1] CRAN (R 4.2.0)
##  ellipsis       0.3.2      2021-04-29 [1] CRAN (R 4.2.0)
##  evaluate       0.15       2022-02-18 [1] CRAN (R 4.2.0)
##  fansi          1.0.3      2022-03-24 [1] CRAN (R 4.2.0)
##  farver         2.1.0      2021-02-28 [1] CRAN (R 4.2.0)
##  fastmap        1.1.0      2021-01-25 [1] CRAN (R 4.2.0)
##  forcats      * 0.5.1      2021-01-27 [1] CRAN (R 4.2.0)
##  foreach        1.5.2      2022-02-02 [1] CRAN (R 4.2.0)
##  fs             1.5.2      2021-12-08 [1] CRAN (R 4.2.0)
##  furrr          0.3.0      2022-05-04 [1] CRAN (R 4.2.0)
##  future         1.26.1     2022-05-27 [1] CRAN (R 4.2.0)
##  future.apply   1.9.0      2022-04-25 [1] CRAN (R 4.2.0)
##  generics       0.1.2      2022-01-31 [1] CRAN (R 4.2.0)
##  gganimate    * 1.0.7      2020-10-15 [1] CRAN (R 4.2.0)
##  ggplot2      * 3.3.6      2022-05-03 [1] CRAN (R 4.2.0)
##  gifski         1.6.6-1    2022-04-05 [1] CRAN (R 4.2.0)
##  globals        0.15.0     2022-05-09 [1] CRAN (R 4.2.0)
##  glue           1.6.2      2022-02-24 [1] CRAN (R 4.2.0)
##  gower          1.0.0      2022-02-03 [1] CRAN (R 4.2.0)
##  GPfit          1.0-8      2019-02-08 [1] CRAN (R 4.2.0)
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 4.2.0)
##  hardhat        1.0.0      2022-06-01 [1] CRAN (R 4.2.0)
##  haven          2.5.0      2022-04-15 [1] CRAN (R 4.2.0)
##  here           1.0.1      2020-12-13 [1] CRAN (R 4.2.0)
##  highr          0.9        2021-04-16 [1] CRAN (R 4.2.0)
##  hms            1.1.1      2021-09-26 [1] CRAN (R 4.2.0)
##  htmltools      0.5.2      2021-08-25 [1] CRAN (R 4.2.0)
##  httr           1.4.3      2022-05-04 [1] CRAN (R 4.2.0)
##  ipred          0.9-13     2022-06-02 [1] CRAN (R 4.2.0)
##  iterators      1.0.14     2022-02-05 [1] CRAN (R 4.2.0)
##  jquerylib      0.1.4      2021-04-26 [1] CRAN (R 4.2.0)
##  jsonlite       1.8.0      2022-02-22 [1] CRAN (R 4.2.0)
##  knitr        * 1.39       2022-04-26 [1] CRAN (R 4.2.0)
##  labeling       0.4.2      2020-10-20 [1] CRAN (R 4.2.0)
##  lattice        0.20-45    2021-09-22 [1] CRAN (R 4.2.0)
##  lava           1.6.10     2021-09-02 [1] CRAN (R 4.2.0)
##  lhs            1.1.5      2022-03-22 [1] CRAN (R 4.2.0)
##  lifecycle      1.0.1      2021-09-24 [1] CRAN (R 4.2.0)
##  listenv        0.8.0      2019-12-05 [1] CRAN (R 4.2.0)
##  lubridate      1.8.0      2021-10-07 [1] CRAN (R 4.2.0)
##  magrittr       2.0.3      2022-03-30 [1] CRAN (R 4.2.0)
##  MASS           7.3-56     2022-03-23 [1] CRAN (R 4.2.0)
##  Matrix         1.4-1      2022-03-23 [1] CRAN (R 4.2.0)
##  memoise        2.0.1      2021-11-26 [1] CRAN (R 4.2.0)
##  modelr         0.1.8      2020-05-19 [1] CRAN (R 4.2.0)
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 4.2.0)
##  nnet           7.3-17     2022-01-16 [1] CRAN (R 4.2.0)
##  parallelly     1.32.0     2022-06-07 [1] CRAN (R 4.2.0)
##  parsnip        0.2.1      2022-03-17 [1] CRAN (R 4.2.0)
##  pillar         1.7.0      2022-02-01 [1] CRAN (R 4.2.0)
##  pkgbuild       1.3.1      2021-12-20 [1] CRAN (R 4.2.0)
##  pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.2.0)
##  pkgload        1.2.4      2021-11-30 [1] CRAN (R 4.2.0)
##  prettyunits    1.1.1      2020-01-24 [1] CRAN (R 4.2.0)
##  processx       3.5.3      2022-03-25 [1] CRAN (R 4.2.0)
##  prodlim        2019.11.13 2019-11-17 [1] CRAN (R 4.2.0)
##  progress       1.2.2      2019-05-16 [1] CRAN (R 4.2.0)
##  ps             1.7.0      2022-04-23 [1] CRAN (R 4.2.0)
##  purrr        * 0.3.4      2020-04-17 [1] CRAN (R 4.2.0)
##  R6             2.5.1      2021-08-19 [1] CRAN (R 4.2.0)
##  Rcpp           1.0.8.3    2022-03-17 [1] CRAN (R 4.2.0)
##  readr        * 2.1.2      2022-01-30 [1] CRAN (R 4.2.0)
##  readxl         1.4.0      2022-03-28 [1] CRAN (R 4.2.0)
##  recipes        0.2.0      2022-02-18 [1] CRAN (R 4.2.0)
##  remotes        2.4.2      2021-11-30 [1] CRAN (R 4.2.0)
##  reprex         2.0.1      2021-08-05 [1] CRAN (R 4.2.0)
##  rlang          1.0.2      2022-03-04 [1] CRAN (R 4.2.0)
##  rmarkdown      2.14       2022-04-25 [1] CRAN (R 4.2.0)
##  rpart          4.1.16     2022-01-24 [1] CRAN (R 4.2.0)
##  rprojroot      2.0.3      2022-04-02 [1] CRAN (R 4.2.0)
##  rsample        0.1.1      2021-11-08 [1] CRAN (R 4.2.0)
##  rstudioapi     0.13       2020-11-12 [1] CRAN (R 4.2.0)
##  rvest          1.0.2      2021-10-16 [1] CRAN (R 4.2.0)
##  sass           0.4.1      2022-03-23 [1] CRAN (R 4.2.0)
##  scales         1.2.0      2022-04-13 [1] CRAN (R 4.2.0)
##  sessioninfo    1.2.2      2021-12-06 [1] CRAN (R 4.2.0)
##  stringi        1.7.6      2021-11-29 [1] CRAN (R 4.2.0)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 4.2.0)
##  survival       3.3-1      2022-03-03 [1] CRAN (R 4.2.0)
##  testthat       3.1.4      2022-04-26 [1] CRAN (R 4.2.0)
##  tibble       * 3.1.7      2022-05-03 [1] CRAN (R 4.2.0)
##  tidyr        * 1.2.0      2022-02-01 [1] CRAN (R 4.2.0)
##  tidyselect     1.1.2      2022-02-21 [1] CRAN (R 4.2.0)
##  tidyverse    * 1.3.1      2021-04-15 [1] CRAN (R 4.2.0)
##  timeDate       3043.102   2018-02-21 [1] CRAN (R 4.2.0)
##  tune           0.2.0      2022-03-19 [1] CRAN (R 4.2.0)
##  tweenr         1.0.2      2021-03-23 [1] CRAN (R 4.2.0)
##  tzdb           0.3.0      2022-03-28 [1] CRAN (R 4.2.0)
##  usethis        2.1.6      2022-05-25 [1] CRAN (R 4.2.0)
##  utf8           1.2.2      2021-07-24 [1] CRAN (R 4.2.0)
##  vctrs          0.4.1      2022-04-13 [1] CRAN (R 4.2.0)
##  withr          2.5.0      2022-03-03 [1] CRAN (R 4.2.0)
##  workflows      0.2.6      2022-03-18 [1] CRAN (R 4.2.0)
##  xfun           0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2           1.3.3      2021-11-30 [1] CRAN (R 4.2.0)
##  yaml           2.3.5      2022-02-21 [1] CRAN (R 4.2.0)
##  yardstick      1.0.0      2022-06-06 [1] CRAN (R 4.2.0)
## 
##  [1] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```
