``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Must group by variables found in `.data`.
#> * Column `colour` is not found.
```

<sup>Created on 2020-09-21 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>

<details>

<summary>Session info</summary>

``` r
devtools::session_info()
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 4.0.2 (2020-06-22)
#>  os       macOS Catalina 10.15.6      
#>  system   x86_64, darwin17.0          
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  ctype    en_US.UTF-8                 
#>  tz       America/Chicago             
#>  date     2020-09-21                  
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package     * version date       lib source        
#>  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
#>  backports     1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
#>  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
#>  broom         0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
#>  callr         3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
#>  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
#>  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
#>  colorspace    1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
#>  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
#>  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
#>  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
#>  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
#>  devtools      2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
#>  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
#>  dplyr       * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
#>  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
#>  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
#>  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
#>  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
#>  fs            1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
#>  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
#>  ggplot2     * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
#>  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
#>  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
#>  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
#>  highr         0.8     2019-03-20 [1] CRAN (R 4.0.0)
#>  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
#>  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
#>  httr          1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
#>  jsonlite      1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
#>  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.1)
#>  lattice       0.20-41 2020-04-02 [1] CRAN (R 4.0.2)
#>  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
#>  lubridate     1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
#>  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)
#>  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
#>  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
#>  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
#>  nlme          3.1-148 2020-05-24 [1] CRAN (R 4.0.2)
#>  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.1)
#>  pkgbuild      1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
#>  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
#>  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
#>  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
#>  processx      3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
#>  ps            1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
#>  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
#>  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
#>  Rcpp          1.0.5   2020-07-06 [1] CRAN (R 4.0.2)
#>  readr       * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
#>  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
#>  remotes       2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
#>  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
#>  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.1)
#>  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
#>  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
#>  rvest         0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
#>  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
#>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
#>  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
#>  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
#>  testthat      2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
#>  tibble      * 3.0.3   2020-07-10 [1] CRAN (R 4.0.1)
#>  tidyr       * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
#>  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
#>  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
#>  usethis       1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
#>  vctrs         0.3.1   2020-06-05 [1] CRAN (R 4.0.1)
#>  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
#>  xfun          0.15    2020-06-21 [1] CRAN (R 4.0.1)
#>  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
#>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
#> 
#> [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

</details>
