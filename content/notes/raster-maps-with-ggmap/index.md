---
title: "Drawing raster maps with ggmap"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/geoviz_ggmap.html"]
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
library(patchwork)
library(here)

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

[`ggmap`](https://github.com/dkahle/ggmap) is a package for R that retrieves raster map tiles from online mapping services like [Google Maps](https://www.google.com/maps) and plots them using the `ggplot2` framework. The map tiles are **raster** because they are static image files generated previously by the mapping service. You do not need any data files containing information on things like scale, projection, boundaries, etc. because that information is already created by the map tile. This severely limits your ability to redraw or change the appearance of the geographic map, however the tradeoff means you can immediately focus on incorporating additional data into the map.

{{% callout note %}}

Google has [recently changed its API requirements](https://developers.google.com/maps/documentation/geocoding/usage-and-billing), and **ggmap** users are now required to provide an API key *and* enable billing. I would not recommend trying to use Google Maps to obtain map images. The code below would work for you, but Google now charges you each time you obtain a map image. Stick to the other providers such as Stamen Maps.

{{% /callout %}}

## Obtain map images

`ggmap` supports open-source map providers such as [OpenStreetMap](https://www.openstreetmap.org/) and [Stamen Maps](http://maps.stamen.com/#terrain/12/37.7706/-122.3782), as well as the proprietary Google Maps. Obtaining map tiles requires use of the `get_map()` function. There are two formats for specifying the mapping region you wish to obtain:

1. Bounding box
1. Center/zoom

## Specifying map regions

### Bounding box

**Bounding box** requires the user to specify the four corners of the box defining the map region. For instance, to obtain a map of Chicago using Stamen Maps:


```r
# store bounding box coordinates
chi_bb <- c(left = -87.936287,
            bottom = 41.679835,
            right = -87.447052,
            top = 42.000835)

chicago_stamen <- get_stamenmap(bbox = chi_bb,
                                zoom = 11)
chicago_stamen
```

```
## 627x712 terrain map image from Stamen Maps. 
## See ?ggmap to plot it.
```

To view the map, use `ggmap()`:


```r
ggmap(chicago_stamen)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/bb-chicago-stamen-plot-1.png" width="672" />

The `zoom` argument in `get_stamenmap()` controls the level of detail in the map. The larger the number, the greater the detail.


```r
get_stamenmap(bbox = chi_bb,
              zoom = 12) %>%
  ggmap()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/bb-chicago-stamen-zoom-in-1.png" width="672" />

The smaller the number, the lesser the detail.


```r
get_stamenmap(bbox = chi_bb,
              zoom = 10) %>%
  ggmap()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/bb-chicago-stamen-zoom-out-1.png" width="672" />


Trial and error will help you decide on the appropriate level of detail depending on what data you need to visualize on the map.

{{% callout note %}}

Use [bboxfinder.com](http://bboxfinder.com/#0.000000,0.000000,0.000000,0.000000) to determine the exact longitude/latitude coordinates for the bounding box you wish to obtain.

{{% /callout %}}

### Center/zoom

While Stamen Maps and OpenStreetMap require the bounding box format for obtaining map tiles and allow you to increase or decrease the level of detail within a single bounding box, Google Maps requires specifying the **center** coordinate of the map (a single longitude/latitude location) and the level of **zoom** or detail. `zoom` is an integer value from `3` (continent) to `21` (building). This means the level of detail is hardcoded to the size of the mapping region. The default `zoom` level is `10`.


```r
# store center coordinate
chi_center <- c(lon = -87.65, lat = 41.855)

chicago_google <- get_googlemap(center = chi_center)
ggmap(chicago_google)

get_googlemap(center = chi_center,
              zoom = 12) %>%
  ggmap()

get_googlemap(center = chi_center,
              zoom = 8) %>%
  ggmap()
```

{{% callout note %}}

Use [Find Latitude and Longitude](https://www.findlatitudeandlongitude.com/) to get the exact GPS coordinates of the center location.

{{% /callout %}}

## Types of map tiles

Each map tile provider offers a range of different types of maps depending on the background you want for the map. Stamen Maps offers several different types:

<img src="{{< blogdown/postref >}}index_files/figure-html/stamen-maptype-1.png" width="576" />

Google Maps is a bit more limited, but still offers a few major types:



See the documentation for the `get_*map()` function for the exact code necessary to get each type of map.

{{% callout note %}}

`get_map()` is a wrapper that automatically queries Google Maps, OpenStreetMap, or Stamen Maps depending on the function arguments and inputs. While useful, it also combines all the different arguments of `get_googlemap()`, `get_stamenmap()`, and `getopenstreetmap()` and can become a bit jumbled. Use at your own risk.

{{% /callout %}}

## Import crime data

Now that we can obtain map tiles and draw them using `ggmap()`, let's explore how to add data to the map. The city of Chicago has [an excellent data portal](https://data.cityofchicago.org/) publishing a large volume of public records. Here we'll look at [crime data from 2017](https://data.cityofchicago.org/Public-Safety/Crimes-2017/d62x-nvdr).^[[Full documentation of the data from the larger 2001-present crime dataset.](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2).] I previously downloaded a `.csv` file containing all the records, which I import using `read_csv()`:

{{% callout note %}}

If you are copying-and-pasting code from this demonstration, change this line of code to `crimes <- read_csv("https://cfss.uchicago.edu/data/Crimes_-_2017.csv")` to download the file from the course website.

{{% /callout %}}


```r
crimes <- here("static", "data", "Crimes_-_2017.csv") %>%
  read_csv()
glimpse(crimes)
```

```
## Rows: 267,345
## Columns: 22
## $ ID                     <dbl> 11094370, 11118031, 11134189, 11156462, 111648…
## $ `Case Number`          <chr> "JA440032", "JA470589", "JA491697", "JA521389"…
## $ Date                   <chr> "09/21/2017 12:15:00 AM", "10/12/2017 07:14:00…
## $ Block                  <chr> "072XX N CALIFORNIA AVE", "055XX W GRAND AVE",…
## $ IUCR                   <chr> "1122", "1345", "4651", "1110", "0265", "143A"…
## $ `Primary Type`         <chr> "DECEPTIVE PRACTICE", "CRIMINAL DAMAGE", "OTHE…
## $ Description            <chr> "COUNTERFEIT CHECK", "TO CITY OF CHICAGO PROPE…
## $ `Location Description` <chr> "CURRENCY EXCHANGE", "JAIL / LOCK-UP FACILITY"…
## $ Arrest                 <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE…
## $ Domestic               <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS…
## $ Beat                   <chr> "2411", "2515", "0922", "2514", "1221", "0232"…
## $ District               <chr> "024", "025", "009", "025", "012", "002", "005…
## $ Ward                   <dbl> 50, 29, 12, 30, 32, 20, 9, 12, 12, 27, 32, 17,…
## $ `Community Area`       <dbl> 2, 19, 58, 19, 24, 40, 49, 30, 30, 23, 24, 44,…
## $ `FBI Code`             <chr> "10", "14", "26", "11", "02", "15", "03", "06"…
## $ `X Coordinate`         <dbl> 1156443, 1138788, 1159425, 1138653, 1161264, 1…
## $ `Y Coordinate`         <dbl> 1947707, 1913480, 1875711, 1920720, 1905292, 1…
## $ Year                   <dbl> 2017, 2017, 2017, 2017, 2017, 2017, 2017, 2017…
## $ `Updated On`           <chr> "03/01/2018 03:52:35 PM", "03/01/2018 03:52:35…
## $ Latitude               <dbl> 42.0, 41.9, 41.8, 41.9, 41.9, 41.8, 41.7, 41.8…
## $ Longitude              <dbl> -87.7, -87.8, -87.7, -87.8, -87.7, -87.6, -87.…
## $ Location               <chr> "(42.012293397, -87.699714109)", "(41.91871165…
```

Each row of the data frame is a single reported incident of crime. Geographic location is encoded in several ways, though most importantly for us the exact longitude and latitude of the incident is encoded in the `Longitude` and `Latitude` columns respectively.

## Plot high-level map of crime

Let's start with a simple high-level overview of reported crime in Chicago. First we need a map for the entire city.


```r
chicago <- chicago_stamen
ggmap(chicago)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/import-chicago-1.png" width="672" />

## Using `geom_point()`

Since each row is a single reported incident of crime, we could use `geom_point()` to map the location of every crime in the dataset. Because `ggmap()` uses the map tiles (here, defined by `chicago`) as the basic input, we specify `data` and `mapping` inside of `geom_point()`, rather than inside `ggplot()`:


```r
ggmap(chicago) +
  geom_point(data = crimes,
             mapping = aes(x = Longitude,
                           y = Latitude))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-crime-point-1.png" width="672" />

What went wrong? All we get is a sea of black.


```r
nrow(crimes)
```

```
## [1] 267345
```

Oh yeah. There were 267345 reported incidents of crime in the city. Each incident is represented by a dot on the map. How can we make this map more usable? One option is to decrease the size and increase the transparancy of each data point so dense clusters of crime become apparent:


```r
ggmap(chicago) +
  geom_point(data = crimes,
             aes(x = Longitude,
                 y = Latitude),
             size = .25,
             alpha = .01)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-crime-point-alpha-1.png" width="672" />

Better, but still not quite as useful as it could be.

## Using `stat_density_2d()`

Instead of relying on `geom_point()` and plotting the raw data, a better approach is to create a **heatmap**. More precisely, this will be a two-dimensional kernel density estimation (KDE). In this context, KDE will take all the raw data (i.e. reported incidents of crime) and convert it into a smoothed plot showing geographic concentrations of crime. The core function in `ggplot2` to generate this kind of plot is `geom_density_2d()`:


```r
ggmap(chicago) +
  geom_density_2d(data = crimes,
                  aes(x = Longitude,
                      y = Latitude))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/kde-contour-1.png" width="672" />

By default, `geom_density_2d()` draws a [**contour plot**](https://en.wikipedia.org/wiki/Contour_line) with lines of constant value. That is, each line represents approximately the same frequency of crime all along that specific line. Contour plots are frequently used in maps (known as **topographic maps**) to denote elevation.

![The Cadillac Mountains. Source: [US Geological Survey](https://www.usgs.gov/media/images/cadillacmountainss)](/img/contour-map.jpg)

Rather than drawing lines, instead we can fill in the graph so that we use the `fill` aesthetic to draw bands of crime density. To do that, we use the related function `stat_density_2d()`:


```r
ggmap(chicago) +
  stat_density_2d(data = crimes,
                  aes(x = Longitude,
                      y = Latitude,
                      fill = stat(level)),
                  geom = "polygon")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/kde-fill-1.png" width="672" />

Note the two new arguments:

* `geom = "polygon"` - change the [geometric object](/notes/grammar-of-graphics/#geometric-objects) to be drawn from a `density_2d` geom to a `polygon` geom
* `fill = stat(level)` - the value for the `fill` aesthetic is the `level` calculated within `stat_density_2d()`, which we access using the `stat()` notation.

This is an improvement, but we can adjust some additional settings to make the graph visually more useful. Specifically,

* Increase the number of `bins`, or unique bands of color allowed on the graph
* Make the heatmap semi-transparent using `alpha` so we can still view the underlying map
* Change the color palette to better distinguish between high and low crime areas. Here I use `brewer.pal()` from the `RColorBrewer` package to create a custom color palette using reds and yellows.


```r
ggmap(chicago) +
  stat_density_2d(data = crimes,
                  aes(x = Longitude,
                      y = Latitude,
                      fill = stat(level)),
                  alpha = .2,
                  bins = 25,
                  geom = "polygon") +
  scale_fill_gradientn(colors = brewer.pal(7, "YlOrRd"))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-crime-density-1.png" width="672" />

From this map, a couple trends are noticeable:

* The downtown region has the highest crime incidence rate. Not surprising given its population density during the workday.
* There are clusters of crime on the south and west sides. Also not surprising if you know anything about the city of Chicago.

## Looking for variation

Because `ggmap` is built on `ggplot2`, we can use the core features of `ggplot2` to modify the graph. One major feature is faceting. Let's focus our analysis on four types of crimes with similar frequency of reported incidents^[Specifically burglary, motor vehicle theft, narcotics, and robbery.] and facet by type of crime:


```r
ggmap(chicago) +
  stat_density_2d(data = crimes %>%
                    filter(`Primary Type` %in% c("BURGLARY", "MOTOR VEHICLE THEFT",
                                                 "NARCOTICS", "ROBBERY")),
                  aes(x = Longitude,
                      y = Latitude,
                      fill = stat(level)),
                  alpha = .4,
                  bins = 10,
                  geom = "polygon") +
  scale_fill_gradientn(colors = brewer.pal(7, "YlOrRd")) +
  facet_wrap(~ `Primary Type`)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-crime-wday-1.png" width="672" />

There is a large difference in the geographic density of narcotics crimes relative to the other catgories. While burglaries, motor vehicle thefts, and robberies are reasonably prevalent all across the city, the vast majority of narcotics crimes occur in the west and south sides of the city.

## Locations of murders

While `geom_point()` was not appropriate for graphing a large number of observations in a dense geographic location, it does work rather well for less dense areas. Now let's limit our analysis strictly to reported incidents of homicide in 2017.


```r
(homicides <- crimes %>%
  filter(`Primary Type` == "HOMICIDE"))
```

```
## # A tibble: 671 x 22
##        ID `Case Number` Date  Block IUCR  `Primary Type` Description
##     <dbl> <chr>         <chr> <chr> <chr> <chr>          <chr>      
##  1 2.31e4 JA149608      02/1… 001X… 0110  HOMICIDE       FIRST DEGR…
##  2 2.39e4 JA530946      11/3… 088X… 0110  HOMICIDE       FIRST DEGR…
##  3 2.34e4 JA302423      06/1… 047X… 0110  HOMICIDE       FIRST DEGR…
##  4 2.34e4 JA312425      06/1… 006X… 0110  HOMICIDE       FIRST DEGR…
##  5 2.37e4 JA490016      10/2… 048X… 0110  HOMICIDE       FIRST DEGR…
##  6 2.32e4 JA210752      04/0… 013X… 0110  HOMICIDE       FIRST DEGR…
##  7 2.36e4 JA461918      10/0… 018X… 0110  HOMICIDE       FIRST DEGR…
##  8 2.36e4 JA461918      10/0… 018X… 0110  HOMICIDE       FIRST DEGR…
##  9 1.08e7 JA138326      02/0… 013X… 0142  HOMICIDE       RECKLESS H…
## 10 2.35e4 JA364517      07/2… 047X… 0110  HOMICIDE       FIRST DEGR…
## # … with 661 more rows, and 15 more variables: `Location Description` <chr>,
## #   Arrest <lgl>, Domestic <lgl>, Beat <chr>, District <chr>, Ward <dbl>,
## #   `Community Area` <dbl>, `FBI Code` <chr>, `X Coordinate` <dbl>, `Y
## #   Coordinate` <dbl>, Year <dbl>, `Updated On` <chr>, Latitude <dbl>,
## #   Longitude <dbl>, Location <chr>
```

We can draw a map of the city with all homicides indicated on the map using `geom_point()`:


```r
ggmap(chicago) +
  geom_point(data = homicides,
             mapping = aes(x = Longitude,
                           y = Latitude),
             size = 1)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/homicide-city-1.png" width="672" />

Compared to our previous overviews, few if any homicides are reported downtown. We can also narrow down the geographic location to map specific neighborhoods in Chicago. First we obtain map tiles for those specific regions. Here we'll examine North Lawndale and Kenwood.




```r
# North Lawndale is the highest homicides in 2017
# Compare to Kenwood
north_lawndale_bb <- c(
  left = -87.749047,
  bottom = 41.840185,
  right = -87.687893,
  top = 41.879850
)
north_lawndale <- get_stamenmap(bbox = north_lawndale_bb,
                                zoom = 14)

kenwood_bb <- c(
  left = -87.613113,
  bottom = 41.799215,
  right = -87.582536,
  top = 41.819064
)
kenwood <- get_stamenmap(bbox = kenwood_bb,
                                zoom = 15)

ggmap(north_lawndale)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/get-high-low-murder-maps-1.png" width="672" />

```r
ggmap(kenwood)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/get-high-low-murder-maps-2.png" width="672" />

To plot homicides specifically in these neighborhoods, change `ggmap(chicago)` to the appropriate map tile:


```r
ggmap(north_lawndale) +
  geom_point(data = homicides,
             aes(x = Longitude, y = Latitude))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-murder-1.png" width="672" />

```r
ggmap(kenwood) +
  geom_point(data = homicides,
             aes(x = Longitude, y = Latitude))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-murder-2.png" width="672" />

North Lawndale had the most reported homicides in 2017, whereas Kenwood had only a handful. And even though `homicides` contained data for homicides across the entire city, `ggmap()` automatically cropped the graph to keep just the homicides that occurred within the bounding box.

All the other aesthetic customizations of `geom_point()` work with `ggmap`. So we could expand these neighborhood maps to include all violent crime categories^[Specifcally homicides, criminal sexual assault, and robbery. [Aggravated assault and aggravated robbery are also defined as violent crimes by the Chicago Police Departmant](http://gis.chicagopolice.org/clearmap_crime_sums/crime_types.html), but the coding system for this data set does not distinguish between ordinary and aggravated types of assault and robbery.] and distinguish each type by `color`:


```r
(violent <- crimes %>%
  filter(`Primary Type` %in% c("HOMICIDE",
                               "CRIM SEXUAL ASSAULT",
                               "ROBBERY")))
```

```
## # A tibble: 14,146 x 22
##        ID `Case Number` Date  Block IUCR  `Primary Type` Description
##     <dbl> <chr>         <chr> <chr> <chr> <chr>          <chr>      
##  1 1.12e7 JA531910      12/0… 022X… 0265  CRIM SEXUAL A… AGGRAVATED…
##  2 1.10e7 JA322389      06/2… 003X… 031A  ROBBERY        ARMED: HAN…
##  3 1.12e7 JA545986      12/1… 007X… 031A  ROBBERY        ARMED: HAN…
##  4 1.12e7 JA546734      12/1… 007X… 031A  ROBBERY        ARMED: HAN…
##  5 1.12e7 JB147188      10/0… 092X… 0281  CRIM SEXUAL A… NON-AGGRAV…
##  6 1.12e7 JB147599      08/2… 001X… 0281  CRIM SEXUAL A… NON-AGGRAV…
##  7 2.31e4 JA149608      02/1… 001X… 0110  HOMICIDE       FIRST DEGR…
##  8 1.10e7 JA378592      08/0… 038X… 0313  ROBBERY        ARMED: OTH…
##  9 1.12e7 JA538651      12/0… 092X… 031A  ROBBERY        ARMED: HAN…
## 10 1.12e7 JB149656      12/2… 005X… 0330  ROBBERY        AGGRAVATED 
## # … with 14,136 more rows, and 15 more variables: `Location Description` <chr>,
## #   Arrest <lgl>, Domestic <lgl>, Beat <chr>, District <chr>, Ward <dbl>,
## #   `Community Area` <dbl>, `FBI Code` <chr>, `X Coordinate` <dbl>, `Y
## #   Coordinate` <dbl>, Year <dbl>, `Updated On` <chr>, Latitude <dbl>,
## #   Longitude <dbl>, Location <chr>
```


```r
ggmap(north_lawndale) +
  geom_point(data = violent,
             aes(x = Longitude, y = Latitude,
                 color = `Primary Type`)) +
  scale_color_brewer(type = "qual", palette = "Dark2")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-violent-1.png" width="672" />

```r
ggmap(kenwood) +
  geom_point(data = violent,
             aes(x = Longitude, y = Latitude,
                 color = `Primary Type`)) +
  scale_color_brewer(type = "qual", palette = "Dark2")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-violent-2.png" width="672" />

### Additional resources

* [Kahle, D., & Wickham, H. (2013). `ggmap`: Spatial Visualization with ggplot2. *R Journal*, 5(1).](https://journal.r-project.org/archive/2013/RJ-2013-014/RJ-2013-014.pdf)

### Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.3 (2020-10-10)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-01-21                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version date       lib source                              
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports      1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  bitops         1.0-6   2013-08-17 [1] CRAN (R 4.0.0)                      
##  blogdown       1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown       0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom          0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr          3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  cli            2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace     2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI            1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr         2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc           1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools       2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest         0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr        * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
##  ellipsis       0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi          0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
##  forcats      * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  fs             1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  generics       0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  ggmap        * 3.0.0   2019-02-05 [1] CRAN (R 4.0.0)                      
##  ggplot2      * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue           1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven          2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here         * 1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms            0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools      0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr           1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jpeg           0.1-8.1 2019-10-24 [1] CRAN (R 4.0.0)                      
##  jsonlite       1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr          1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
##  lattice        0.20-41 2020-04-02 [1] CRAN (R 4.0.3)                      
##  lifecycle      0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
##  lubridate      1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr       2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  patchwork    * 1.1.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  pillar         1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
##  pkgbuild       1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload        1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
##  plyr           1.8.6   2020-03-03 [1] CRAN (R 4.0.0)                      
##  png            0.1-7   2013-12-03 [1] CRAN (R 4.0.0)                      
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx       3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps             1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6             2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 4.0.0)                      
##  Rcpp           1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr        * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes        2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex         0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
##  RgoogleMaps    1.4.5.3 2020-02-12 [1] CRAN (R 4.0.0)                      
##  rjson          0.2.20  2018-06-08 [1] CRAN (R 4.0.0)                      
##  rlang          0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown      2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot      2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi     0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest          0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  sp             1.4-4   2020-10-07 [1] CRAN (R 4.0.2)                      
##  stringi        1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat       3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble       * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr        * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect     1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse    * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis        2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs          0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr          2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun           0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
