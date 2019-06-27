---
title: "Getting data from the web: scraping"
date: 2019-07-18T10:00:00
publishDate: 2019-05-15T13:30:00
draft: false
type: "talk"

aliases: ["/cm016.html"]

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
time_end: 2019-07-18T12:00:00
all_day: false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: []

# Abstract and optional shortened version.
abstract: ""
summary: "Practice scraping content from web pages using rvest."

# Location of event.
location: "Room 315, Haskell Hall, Chicago, IL"

# Is this a selected talk? (true/false)
selected: false

# Tags (optional).
#   Set `tags: []` for no tags, or use the form `tags: ["A Tag", "Another Tag"]` for one or more tags.
tags: []

# Links (optional).
url_pdf: ""
url_slides: "/slides/getting-data-from-the-web-scraping/"
url_video: ""
url_code: ""

# Does the content use math formatting?
math: false
---



## Overview

* Define HTML and CSS selectors
* Introduce the `rvest` package
* Demonstrate how to extract information from HTML pages
* Demonstrate how to extract tables and convert to data frames
* Practice scraping data

## Before class

## Class materials

* [Web scraping](/notes/web-scraping/)
* `rvest`
    * Load the library (`library(rvest)`)
    * `demo("tripadvisor")` - scraping a Trip Advisor page
    * `demo("united")` - how to scrape a web page which requires a login
    * [Scraping IMDB](https://blog.rstudio.org/2014/11/24/rvest-easy-web-scraping-with-r/)

## What you need to do

* Start [homework 7](/homework/webdata/)
* [Obtain an API key from the Census Bureau](https://api.census.gov/data/key_signup.html) - you will need access to their API next week for geospatial visualizations
