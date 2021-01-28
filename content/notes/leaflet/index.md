---
title: "Drawing interactive maps with Leaflet"
date: 2019-03-01

type: docs
draft: true
aliases: ["/geoviz_leaflet.html"]
categories: ["dataviz", "geospatial"]

menu:
  notes:
    parent: Geospatial visualization
    weight: 6
---

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>

<script src="{{< blogdown/postref >}}index_files/pymjs/pym.v1.js"></script>

<script src="{{< blogdown/postref >}}index_files/widgetframe-binding/widgetframe.js"></script>

``` r
library(tidyverse)
library(leaflet)
library(stringr)
library(sf)
library(here)
library(widgetframe)

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())
```

[Leaflet](https://leafletjs.com/) is an open-source JavaScript library for creating interactive maps. Unlike static visualization packages such as `ggplot2` or `ggmap`, Leaflet maps are fully interactive and can include features such as:

  - Interactive panning/zooming
  - Pop-up tooltips and labels
  - Highlighting/selecting regions

It is used by many news organizations and tech websites to visualize geographic data. The `leaflet` package for R enables the creation of interactive maps within R without learning how to write JavaScript code. The [`leaflet` documentation](https://rstudio.github.io/leaflet/) is a handy walkthrough for the basics of creating Leaflet maps in R. Let’s explore here how to create Leaflet maps using the same data we used to create [raster maps with `ggmap`](/notes/raster-maps-with-ggmap/), [crime data from the city of Chicago in 2017](https://data.cityofchicago.org/Public-Safety/Crimes-2017/d62x-nvdr).\[1\]

``` r
crimes <- here("static", "data", "Crimes_-_2017.csv") %>%
  read_csv()
glimpse(crimes)
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

## Basic usage

Leaflet maps are built using layers, similar to `ggplot2`.

1.  Create a map widget by calling `leaflet()`
2.  Add **layers** to the map using one or more of the layer functions (e.g. `addTiles()`, `addMarkers()`, `addPolygons()`)
3.  Repeat step 2 as many times as necessary to incorporate the necessary information
4.  Display the map widget

A basic example is:

``` r
m <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng = -87.597241, lat = 41.789829,
             popup = "Saieh Hall of Economics")
m %>%
  frameWidget()
```

<div id="htmlwidget-1" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"url":"index_files/figure-html//widgets/widget_leaflet-basic.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

{{% callout warning %}}

Note: you do not need to use `frameWidget()` to view the output of each map in RStudio. I only use it here because it is necessary based on the publishing package used to construct the website.

{{% /callout %}}

## Basemaps

Like `ggmap`, `leaflet` supports basemaps using map tiles. By default, OpenStreetMap tiles are used.

``` r
m <- leaflet() %>%
  setView(lng = -87.618994, lat = 41.875619, zoom = 12)
m %>%
  addTiles() %>%
  frameWidget()
```

<div id="htmlwidget-2" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"url":"index_files/figure-html//widgets/widget_basemap.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

## Add markers

**Markers** are used to identify points on the map. Each point needs to be defined in terms of latitude/longitude coordinates. These can come from a variety of sources, most commonly either a [map data file](/notes/simple-features/) such as a shapefile or GeoJSON (imported using `sf`) or a data frame with latitude and longitude columns.

Let’s use the Chicago crimes data to draw a map of the city identifying the location of each reported homicide:

``` r
(homicides <- crimes %>%
  filter(`Primary Type` == "HOMICIDE"))
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

``` r
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers() %>%
  frameWidget()
```

<div id="htmlwidget-3" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

{{% callout note %}}

`addMarkers()` and related functions will automatically check data frames for columns called `lng`/`long`/`longitude` and `lat`/`latitude` (case-insensitively). If your coordinate columns have any other names, you need to explicitly identify them using the `lng` and `lat` arguments. Such as \`addMarkers(lng = \~Longitude, lat = \~Latitude).

{{% /callout %}}

Without any customization, we get a basic map with each murder location indicated by a dropped pin. Each markers appearance can be customized, though the technical difficulty quickly ramps up. The [awesome markers](https://github.com/lvoogdt/Leaflet.awesome-markers) plugin offers the most straight-forward customizability options. Instead of using `addMarkers()`, use `addAwesomeMarkers()` to control the appearance of the markers using icons from the [Font Awesome](http://fontawesome.io/icons/), [Bootstrap Glyphicons](https://getbootstrap.com/components/), and [Ion icons](http://ionicons.com/) icon libraries. First you define the appearance of the icon using `awesomeIcons()`, then pass that as an argument to `addAwesomeMarkers()`:

``` r
icons <- awesomeIcons(
  icon = 'bolt',
  iconColor = 'orange',
  markerColor = "black",
  library = 'fa'
)

leaflet(data = homicides) %>%
  addTiles() %>%
  addAwesomeMarkers(icon = icons) %>%
  frameWidget()
```

<div id="htmlwidget-4" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map-icons.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

One concern is that some neighborhoods have so many murders that the points overlap. One solution enabled by Leaflet’s interactivity is to **cluster** markers at varying levels of detail using the `clusterOptions` argument to `addMarkers()`:

``` r
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions()) %>%
  frameWidget()
```

<div id="htmlwidget-5" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-5">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map-cluster.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

Alternatively, we could use circles using `addCircleMarkers()`:

``` r
leaflet(data = homicides) %>%
  addTiles() %>%
  addCircleMarkers() %>%
  frameWidget()
```

<div id="htmlwidget-6" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-6">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map-circles.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

## Add labels and popups

Each point can have text added to it using either a **label** (appears either on hover or statically) or a popup (appears only on click). For instance we can label each murder with the date/timestamp when it was originally reported.

``` r
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(label = ~Date) %>%
  frameWidget()
```

<div id="htmlwidget-7" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-7">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map-label.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

If we only want the information to appear when we click on the point, we should instead use `popup = ~Date`:

``` r
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(popup = ~Date) %>%
  frameWidget()
```

<div id="htmlwidget-8" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-8">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map-popups.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

We can combine multiple pieces of information to create a custom popup message. Unfortunately this does require [basic knowledge of writing HTML documents](https://websitesetup.org/html5-cheat-sheet/).

``` r
homicides %>%
  mutate(popup = str_c(Date,
                       Block,
                       str_c("Location type:", `Location Description`,
                             sep = " "),
                       sep = "<br/>")) %>%
  leaflet() %>%
  addTiles() %>%
  addMarkers(popup = ~popup) %>%
  frameWidget()
```

<div id="htmlwidget-9" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-9">{"x":{"url":"index_files/figure-html//widgets/widget_homicide-map-popups-long.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

## Add lines and shapes

Leaflet can also draw spatial lines and shapes from R and add them to maps. Given our previous exposure to `sf` and importing shapefiles using `st_read()`, let draw a map of Chicago with each community area outlined.

``` r
areas <- here("static", "data",
              "Boundaries - Community Areas (current)",
              "geo_export_328cdcbf-33ba-4997-8ce8-90953c6fec19.shp") %>%
  st_read() %>%
  # convert community names to title case
  mutate(community = str_to_title(community))
```

    ## Reading layer `geo_export_328cdcbf-33ba-4997-8ce8-90953c6fec19' from data source `/Users/soltoffbc/Projects/Computing for Social Sciences/course-site/static/data/Boundaries - Community Areas (current)/geo_export_328cdcbf-33ba-4997-8ce8-90953c6fec19.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 77 features and 9 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: -87.9 ymin: 41.6 xmax: -87.5 ymax: 42
    ## geographic CRS: WGS84(DD)

To do this in `ggplot()`, we only need two lines of code:

``` r
ggplot(data = areas) +
  geom_sf()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/community-areas-ggplot-1.png" width="672" />

To draw this in `leaflet`, we use `addPolygons()`:

``` r
leaflet(data = areas) %>%
  addPolygons(color = "#444444",
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE)) %>%
  frameWidget()
```

<div id="htmlwidget-10" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-10">{"x":{"url":"index_files/figure-html//widgets/widget_community-areas-leaflet.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

The first several arguments adjust the appearance of each polygon region (e.g. color, opacity, border thickness). `highlightOptions` emphasizes the currently moused-over polygon. We can further add detail to this map by labeling each community area just as we did with points:

``` r
leaflet(data = areas) %>%
  addPolygons(label = ~community,
              color = "#444444",
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE)) %>%
  frameWidget()
```

<div id="htmlwidget-11" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-11">{"x":{"url":"index_files/figure-html//widgets/widget_community-areas-label.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

And since `leaflet` map widgets are built in layers, we can overlay the community areas on top of a standard map of the city.

``` r
leaflet(data = areas) %>%
  addTiles() %>%
  addPolygons(label = ~community,
              color = "#444444",
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE)) %>%
  frameWidget()
```

<div id="htmlwidget-12" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-12">{"x":{"url":"index_files/figure-html//widgets/widget_community-areas-overlay.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

## Choropleth of homicides by neighborhood

Now that we have a basic map of the city of Chicago with each community area identified, we can turn this map into a choropleth by filling in the color of each community area based on the number of reported homicides in 2017. First we calculate the total number of reported homicides by community area and merge this with the simple features data frame:

``` r
(areas_homicides <- areas %>%
   select(community, area_numbe) %>%
   mutate(area_numbe = as.numeric(as.character(area_numbe))) %>%
   left_join(homicides %>%
               count(`Community Area`),
             by = c("area_numbe" = "Community Area")) %>%
   mutate(n = ifelse(is.na(n), 0, n)))
```

    ## Simple feature collection with 77 features and 3 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: -87.9 ymin: 41.6 xmax: -87.5 ymax: 42
    ## geographic CRS: WGS84(DD)
    ## First 10 features:
    ##          community area_numbe  n                       geometry
    ## 1          Douglas         35  3 MULTIPOLYGON (((-87.6 41.8,...
    ## 2          Oakland         36  0 MULTIPOLYGON (((-87.6 41.8,...
    ## 3      Fuller Park         37  2 MULTIPOLYGON (((-87.6 41.8,...
    ## 4  Grand Boulevard         38 10 MULTIPOLYGON (((-87.6 41.8,...
    ## 5          Kenwood         39  4 MULTIPOLYGON (((-87.6 41.8,...
    ## 6   Lincoln Square          4  1 MULTIPOLYGON (((-87.7 42, -...
    ## 7  Washington Park         40 12 MULTIPOLYGON (((-87.6 41.8,...
    ## 8        Hyde Park         41  1 MULTIPOLYGON (((-87.6 41.8,...
    ## 9         Woodlawn         42 14 MULTIPOLYGON (((-87.6 41.8,...
    ## 10     Rogers Park          1  4 MULTIPOLYGON (((-87.7 42, -...

## Add color

Next we need to define the [color palette](geoviz_color.html) for this map. `leaflet` has [its own series of functions to generate palettes](https://rstudio.github.io/leaflet/colors.html) using either `RColorBrewer` or `viridis`.

First, we define the bins. This is a numeric vector that defines the boundaries between intervals (`(0,10]`, `(10,20]`, and so on).

Then, we call `colorBin()` to generate a palette function that maps the `RColorBrewer` `"YlOrRd"` palette to our bins.

Finally, we modify `addPolygons()` to use the palette function and the density values to generate a vector of colors for `fillColor()`, and also add some other static style properties.

``` r
bins <- c(0, 10, 20, 30, 40, 50, Inf)
pal <- colorBin("YlOrRd", domain = areas_homicides$n, bins = bins)

areas_homicides %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons(label = ~community,
              fillColor = ~pal(n),
              color = "#444444",
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE)) %>%
  frameWidget()
```

<div id="htmlwidget-13" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-13">{"x":{"url":"index_files/figure-html//widgets/widget_choropleth-color.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

## Custom information

Let’s now modify the label to explicitly identify the number of reported homicides in the community area. We generate the HTML by hand and pass it to `map(htmltools::HTML)` so that Leaflet knows to treat each label as HTML instead of plain text. We also adjust the appearance of each label using the `labelOptions` argument and corresponding function.

``` r
areas_homicides %>%
  mutate(popup = str_c("<strong>", community, "</strong>",
                       "<br/>",
                       "Reported homicides in 2017: ", n) %>%
           map(htmltools::HTML)) %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons(label = ~popup,
              fillColor = ~pal(n),
              color = "#444444",
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE),
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  frameWidget()
```

<div id="htmlwidget-14" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-14">{"x":{"url":"index_files/figure-html//widgets/widget_choropleth-label-detail.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

## Add legend

Finally, we add a legend using `addLegend()`.

``` r
areas_homicides %>%
  mutate(popup = str_c("<strong>", community, "</strong>",
                       "<br/>",
                       "Reported homicides in 2017: ", n) %>%
           map(htmltools::HTML)) %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons(label = ~popup,
              fillColor = ~pal(n),
              color = "#444444",
              weight = 1,
              smoothFactor = 0.5,
              opacity = 1.0,
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = TRUE),
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  addLegend(pal = pal,
            values = ~n,
            opacity = 0.7,
            title = NULL,
            position = "bottomright") %>%
  frameWidget()
```

<div id="htmlwidget-15" style="width:100%;height:480px;" class="widgetframe html-widget"></div>
<script type="application/json" data-for="htmlwidget-15">{"x":{"url":"index_files/figure-html//widgets/widget_choropleth-label-legend.html","options":{"xdomain":"*","allowfullscreen":false,"lazyload":false}},"evals":[],"jsHooks":[]}</script>

The main requirement here is `pal = pal`, which tells `addLegend()` the custom palette function used to create the color palette.

## Session Info

``` r
devtools::session_info()
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
    ##  date     2021-01-28                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source                              
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
    ##  backports     1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
    ##  blogdown      1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
    ##  bookdown      0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
    ##  broom         0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
    ##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
    ##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
    ##  class         7.3-17  2020-04-26 [1] CRAN (R 4.0.3)                      
    ##  classInt      0.4-3   2020-04-07 [1] CRAN (R 4.0.0)                      
    ##  cli           2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
    ##  colorspace    2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
    ##  crosstalk     1.1.0.1 2020-03-13 [1] CRAN (R 4.0.0)                      
    ##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
    ##  dbplyr        2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
    ##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
    ##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
    ##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
    ##  dplyr       * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
    ##  e1071         1.7-4   2020-10-14 [1] CRAN (R 4.0.2)                      
    ##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
    ##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                      
    ##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
    ##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
    ##  generics      0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
    ##  ggplot2     * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
    ##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
    ##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
    ##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
    ##  here        * 1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
    ##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
    ##  htmltools     0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
    ##  htmlwidgets * 1.5.3   2020-12-10 [1] CRAN (R 4.0.2)                      
    ##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
    ##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
    ##  KernSmooth    2.23-18 2020-10-29 [1] CRAN (R 4.0.2)                      
    ##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
    ##  leaflet     * 2.0.3   2019-11-16 [1] CRAN (R 4.0.0)                      
    ##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                      
    ##  lubridate     1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
    ##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
    ##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
    ##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
    ##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
    ##  pillar        1.4.7   2020-11-20 [1] CRAN (R 4.0.2)                      
    ##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
    ##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
    ##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)                      
    ##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
    ##  processx      3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
    ##  ps            1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
    ##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
    ##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
    ##  Rcpp          1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
    ##  readr       * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
    ##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
    ##  remotes       2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
    ##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.0)                      
    ##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
    ##  rmarkdown     2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
    ##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
    ##  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
    ##  rvest         0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
    ##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
    ##  sf          * 0.9-6   2020-09-13 [1] CRAN (R 4.0.2)                      
    ##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
    ##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
    ##  testthat      3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
    ##  tibble      * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
    ##  tidyr       * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
    ##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
    ##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
    ##  units         0.6-7   2020-06-13 [1] CRAN (R 4.0.2)                      
    ##  usethis       2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
    ##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
    ##  widgetframe * 0.3.1   2017-12-20 [1] CRAN (R 4.0.0)                      
    ##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
    ##  xfun          0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
    ##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
    ##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
    ## 
    ## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library

1.  [Full documentation of the data from the larger 2001-present crime dataset.](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2).
