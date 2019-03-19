---
title: "Geospatial visualization"
date: 2019-05-15T13:30:00
publishDate: 2019-03-01T13:30:00
draft: false
type: "talk"

alias: ["/cm014.html"]

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
time_start: 2019-05-15T13:30:00
time_end: 2019-05-15T14:50:00
all_day: false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: []

# Abstract and optional shortened version.
abstract: ""
summary: "Define spatial data frames, identify components of geospatial visualizations, and implement maps using ggplot2 and Leaflet."

# Location of event.
location: "Room 247, Saieh Hall for Economics, Chicago, IL"

# Is this a selected talk? (true/false)
selected: false

# Tags (optional).
#   Set `tags: []` for no tags, or use the form `tags: ["A Tag", "Another Tag"]` for one or more tags.
tags: []

# Links (optional).
url_pdf: ""
url_slides: ""
url_video: ""
url_code: ""

# Does the content use math formatting?
math: false
---



## Overview

* Introduce the major components of a geospatial visualization
* Identify how to draw raster maps using `ggmaps` and `get_map()`
* Define shapefiles and import spatial data using the `sf` package
* Draw maps using `ggplot2` and `geom_sf()`
* Change coordinate systems
* Generate appropriate color palettes to visualize additional dimensions of data
* Introduce interactive maps and the `leaflet` package

## Before class

* Read [Introduction to geospatial visualization](geoviz_intro.html)
* Read [Drawing raster maps with `ggmap`](geoviz_ggmap.html)
* Read [Importing shapefiles using `sf`](geoviz_import_data.html)
* Read [Drawing vector maps with `ggplot2` and `sf`](geoviz_plot.html)
* Read [Selecting optimal color palettes](geoviz_color.html)
* Read [Drawing interactive maps with `leaflet`](geoviz_leaflet.html)

## Slides and links

* [Slides](extras/cm014_slides.html)

* [Working with Geospatial Data in R](https://www.datacamp.com/courses/working-with-geospatial-data-in-r) - a DataCamp course which goes into more depth and practice than what we did here
* [Mapping data in *The Truthful Art* by Alberto Cairo](http://proquestcombo.safaribooksonline.com.proxy.uchicago.edu/book/databases-and-reporting-tools/9780133440492/part-iii-functional/ch10_html) - excellent chapter on designing data maps with lots of examples. Though really the entire book is useful if you do a lot of work with data visualizations of any type. **UChicago authentication required.**

## What you need to do

* Work on [homework 7](hw07-geospatial.html)
