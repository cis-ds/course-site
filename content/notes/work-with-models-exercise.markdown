---
title: "Working with statistical models"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["stat-learn"]

menu:
  notes:
    parent: Statistical learning
    weight: 4
---




```r
library(tidyverse)
library(broom)

set.seed(123)

theme_set(theme_minimal())
```

## Load `socviz::county_data`


```r
library(socviz)

data("county_data")
glimpse(county_data)
```

```
## Observations: 3,195
## Variables: 32
## $ id               <chr> "0", "01000", "01001", "01003", "01005", "01007…
## $ name             <chr> NA, "1", "Autauga County", "Baldwin County", "B…
## $ state            <fct> NA, AL, AL, AL, AL, AL, AL, AL, AL, AL, AL, AL,…
## $ census_region    <fct> NA, South, South, South, South, South, South, S…
## $ pop_dens         <fct> "[   50,  100)", "[   50,  100)", "[   50,  100…
## $ pop_dens4        <fct> "[ 45,  118)", "[ 45,  118)", "[ 45,  118)", "[…
## $ pop_dens6        <fct> "[ 82,  215)", "[ 82,  215)", "[ 82,  215)", "[…
## $ pct_black        <fct> "[10.0,15.0)", "[25.0,50.0)", "[15.0,25.0)", "[…
## $ pop              <int> 318857056, 4849377, 55395, 200111, 26887, 22506…
## $ female           <dbl> 50.8, 51.5, 51.5, 51.2, 46.5, 46.0, 50.6, 45.2,…
## $ white            <dbl> 77.7, 69.8, 78.1, 87.3, 50.2, 76.3, 96.0, 27.2,…
## $ black            <dbl> 13.2, 26.6, 18.4, 9.5, 47.6, 22.1, 1.8, 69.9, 4…
## $ travel_time      <dbl> 25.5, 24.2, 26.2, 25.9, 24.6, 27.6, 33.9, 26.9,…
## $ land_area        <dbl> 3531905.43, 50645.33, 594.44, 1589.78, 884.88, …
## $ hh_income        <int> 53046, 43253, 53682, 50221, 32911, 36447, 44145…
## $ su_gun4          <fct> NA, NA, "[11,54]", "[11,54]", "[ 5, 8)", "[11,5…
## $ su_gun6          <fct> NA, NA, "[10,12)", "[10,12)", "[ 7, 8)", "[10,1…
## $ fips             <dbl> 0, 1000, 1001, 1003, 1005, 1007, 1009, 1011, 10…
## $ votes_dem_2016   <int> NA, NA, 5908, 18409, 4848, 1874, 2150, 3530, 37…
## $ votes_gop_2016   <int> NA, NA, 18110, 72780, 5431, 6733, 22808, 1139, …
## $ total_votes_2016 <int> NA, NA, 24661, 94090, 10390, 8748, 25384, 4701,…
## $ per_dem_2016     <dbl> NA, NA, 0.23956855, 0.19565310, 0.46660250, 0.2…
## $ per_gop_2016     <dbl> NA, NA, 0.7343579, 0.7735147, 0.5227141, 0.7696…
## $ diff_2016        <int> NA, NA, 12202, 54371, 583, 4859, 20658, 2391, 1…
## $ per_dem_2012     <dbl> NA, NA, 0.2657577, 0.2156657, 0.5125229, 0.2621…
## $ per_gop_2012     <dbl> NA, NA, 0.7263374, 0.7738975, 0.4833755, 0.7306…
## $ diff_2012        <int> NA, NA, 11012, 47443, 334, 3931, 17780, 2808, 7…
## $ winner           <chr> NA, NA, "Trump", "Trump", "Trump", "Trump", "Tr…
## $ partywinner16    <chr> NA, NA, "Republican", "Republican", "Republican…
## $ winner12         <chr> NA, NA, "Romney", "Romney", "Obama", "Romney", …
## $ partywinner12    <chr> NA, NA, "Republican", "Republican", "Democrat",…
## $ flipped          <chr> NA, NA, "No", "No", "Yes", "No", "No", "No", "N…
```

{{% alert note %}}

Use `?county_data` to view the documentation for the dataset.

{{% /alert %}}

## Visualize a basic linear regression model

Generate a graph using `ggplot2` to visualize the relationship between median household income (`hh_income`) and percent of votes cast for the Democratic presidential candidate in 2016 (`per_dem_2016`). Overlay a linear regression best fit line on top of a scatterplot.

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
ggplot(data = county_data,
       mapping = aes(x = hh_income, y = per_dem_2016)) +
  # use alpha to increase transparency of individual points
  geom_point(alpha = .1) +
  # manually specify a linear regression line
  geom_smooth(method = "lm") +
  # format labels and axes tick marks
  scale_x_continuous(labels = scales::dollar) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "2016 U.S. presidential election",
       subtitle = "By county",
       x = "Median household income",
       y = "2016 Democratic presidential vote")
```

<img src="/notes/work-with-models-exercise_files/figure-html/lm-chart-1.png" width="672" />

  </p>
</details>

## Combine plots to show different models

Generate three separate graphs using `ggplot2` to visualize the relationship between median household income (`hh_income`) and percent of votes cast for the Democratic presidential candidate in 2016 (`per_dem_2016`). Each graph should use a different statistical algorithm:

1. A standard linear regression model
1. A linear regression model with a second-order polynomial for income
1. A generalized additive model (`method = "gam"`)

Combine them together into a single plotting object using [`patchwork`](https://github.com/thomasp85/patchwork).

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
library(patchwork)

# create core ggplot() which contains components used for all plots
p <- ggplot(
  data = county_data,
  mapping = aes(x = hh_income, y = per_dem_2016)
) +
  # use alpha to increase transparency of individual points
  geom_point(alpha = .1) +
  # format labels and axes tick marks
  scale_x_continuous(labels = scales::dollar) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = "Median household income",
    y = "2016 Democratic presidential vote"
  )

# plot using linear regression model
p_lm <- p +
  geom_smooth(method = "lm")

# plot using polynomial for income
p_lm_2 <- p +
  geom_smooth(method = "lm", formula = y ~ poly(x, degree = 2))

# plot using gam
p_gam <- p +
  geom_smooth(method = "gam")

# combine together
p_lm +
  p_lm_2 +
  p_gam +
  plot_layout(ncol = 1) +
  plot_annotation(
    title = "2016 U.S. presidential election",
    subtitle = "By county"
  )
```

<img src="/notes/work-with-models-exercise_files/figure-html/combined-chart-1.png" width="672" />

  </p>
</details>

## Show several fits at once with a legend

Generate a single graph using `ggplot2` to visualize the relationship between median household income (`hh_income`) and percent of votes cast for the Democratic presidential candidate in 2016 (`per_dem_2016`). Draw three separate smoothing lines using the following methods:

1. A standard linear regression model
1. A linear regression model with a second-order polynomial for income
1. A generalized additive model (`method = "gam"`)

The graph should be a single `ggplot()` object with properly labeled elements.

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
# reuse core ggplot object, adding three separate geom_smooth() functions
p +
  geom_smooth(
    method = "lm",
    mapping = aes(color = "OLS", fill = "OLS")
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ poly(x, degree = 2),
    mapping = aes(color = "Polynomial", fill = "Polynomial")
  ) +
  geom_smooth(
    method = "gam",
    mapping = aes(color = "GAM", fill = "GAM")
  ) +
  # use an appropriate color palette
  scale_color_brewer(
    # qualitative variable
    type = "qual",
    # use the same palette for the fill aesthetic too
    aesthetics = c("color", "fill")
    ) +
  # add meaningful labels
  labs(
    title = "2016 U.S. presidential election",
    subtitle = "By county",
    color = "Models",
    fill = "Models"
    ) +
  # move the legend to the bottom
  theme(legend.position = "bottom")
```

<img src="/notes/work-with-models-exercise_files/figure-html/mult-fit-legend-1.png" width="672" />

  </p>
</details>

## Generate a coefficient plot

Estimate a linear regression model predicting 2016 Democratic presidential vote share as a function of percentage of female persons (`female`), percentage of white persons (`white`), percentage of black persons (`black`), and median household income (`hh_income`) in thousands of dollars. To make the graph easier to interpret, measure median household income in thousands of dollars (i.e. divide `hh_income` by 1,000) and multiply `per_dem_2016` by 100 (so it scales between 0-100).

Generate a coefficient plot to visualize the OLS estimates and confidence intervals.

1. Generate the plot manually using `broom::tidy()` to extract the coefficient estimates and 95% confidence intervals from the model object.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    # modify hh_income
    county_data <- county_data %>%
      mutate(hh_income_10 = hh_income / 1e03,
             per_dem_2016_100 = per_dem_2016 * 100)
    
    # estimate ols model using lm()
    vote_mod <- lm(per_dem_2016_100 ~ female + white + black + hh_income_10,
                   data = county_data)
    ```
    
    
    ```r
    # extract coefficients using tidy()
    vote_mod_coef <- tidy(vote_mod, conf.int = TRUE)
    vote_mod_coef
    ```
    
    ```
    ## # A tibble: 5 x 7
    ##   term         estimate std.error statistic  p.value conf.low conf.high
    ##   <chr>           <dbl>     <dbl>     <dbl>    <dbl>    <dbl>     <dbl>
    ## 1 (Intercept)    11.4      5.09        2.23 2.55e- 2    1.39     21.3  
    ## 2 female          0.846    0.0934      9.06 2.26e-19    0.663     1.03 
    ## 3 white          -0.459    0.0234    -19.6  8.67e-81   -0.505    -0.413
    ## 4 black           0.159    0.0270      5.88 4.50e- 9    0.106     0.212
    ## 5 hh_income_10    0.346    0.0180     19.2  1.51e-77    0.310     0.381
    ```
    
    ```r
    # clean up the term names to be human readable
    vote_mod_coef %>%
      filter(term != "(Intercept)") %>%
      mutate(term = factor(term, levels = term, labels = c("Percent female", "Percent white", "Percent black", "Median household income"))) %>%
      # generate plot
      ggplot(mapping = aes(x = fct_reorder(term, estimate),
                           y = estimate,
                           ymin = conf.low,
                           ymax = conf.high)) +
      geom_pointrange() +
      coord_flip()
    ```
    
    <img src="/notes/work-with-models-exercise_files/figure-html/ols-mod-viz-broom-1.png" width="672" />
    
      </p>
    </details>

1. Use the `coefplot` package to automatically generate the coefficient plot.

    <details> 
      <summary>Click for the solution</summary>
      <p>
    
    
    ```r
    library(coefplot)
    coefplot(vote_mod, sort = "magnitude", intercept = FALSE)
    ```
    
    <img src="/notes/work-with-models-exercise_files/figure-html/ols-mod-viz-coefplot-1.png" width="672" />
    
      </p>
    </details>

## Visualize marginal effects



### Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.1 (2019-07-05)
##  os       macOS Mojave 10.14.6        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-11-06                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.15    2019-08-21 [1] CRAN (R 3.6.0)
##  bookdown      0.13    2019-08-21 [1] CRAN (R 3.6.0)
##  broom       * 0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.2.0   2019-09-07 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  DT            0.8     2019-08-07 [1] CRAN (R 3.6.0)
##  ellipsis      0.2.0.1 2019-07-02 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.1   2019-08-23 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  htmlwidgets   1.3     2018-09-30 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.1)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lifecycle     0.1.0   2019-08-01 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-140 2019-05-12 [1] CRAN (R 3.6.1)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.5   2019-08-26 [1] CRAN (R 3.6.0)
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown     1.15    2019-08-21 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 1.0.0   2019-09-11 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.9     2019-08-21 [1] CRAN (R 3.6.0)
##  xml2          1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
