---
title: "Geospatial visualization: raster maps"
date: 2019-11-26T12:30:00
publishDate: 2019-05-20T13:30:00
draft: false
type: "talk"

aliases: ["/cm014.html", "/syllabus/geospatial-visualization/"]

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
time_end: 2019-11-26T13:50:00
all_day: false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: []

# Abstract and optional shortened version.
abstract: ""
summary: "Identify components of geospatial visualizations and implement raster maps using ggplot2."

# Location of event.
location: "Room 104, Stuart Hall, Chicago, IL"

# Is this a selected talk? (true/false)
selected: false

# Tags (optional).
#   Set `tags: []` for no tags, or use the form `tags: ["A Tag", "Another Tag"]` for one or more tags.
tags: []

# Links (optional).
url_pdf: ""
url_slides: "/slides/geospatial-visualization-raster-maps/"
url_video: ""
url_code: ""

# Does the content use math formatting?
math: false
---



## Overview

* Introduce the major components of a geospatial visualization
* Identify how to draw raster maps using `ggmaps` and `get_map()`
* Practice generating raster maps

## Before class

* Read [Introduction to geospatial visualization](/notes/intro-geospatial-viz/)
* Read [Drawing raster maps with `ggmap`](/notes/raster-maps-with-ggmap/)

## Class materials

* [Practice drawing raster maps](/notes/raster-maps-practice/)

* [Mapping data in *The Truthful Art* by Alberto Cairo](https://uchicago.ares.atlas-sys.com/ares/ares.dll?SessionID=A103809140M&Action=10&Type=10&Value=696335) - excellent chapter on designing data maps with lots of examples. Though really the entire book is useful if you do a lot of work with data visualizations of any type. **UChicago authentication required.**

## Additional resources

* [Learn Spatial Analysis](https://spatialanalysis.github.io/) - tutorials and workshops conducted by the Center for Spatial Data Science at the University of Chicago. Lots of materials developed using R.

## What you need to do

* [Obtain an API key](https://api.census.gov/data/key_signup.html) and [store it securely](/notes/application-program-interface/#census-data-with-tidycensus) on your computer. We will be using `tidycensus` next class, so you will save time if you set this up in advance.
