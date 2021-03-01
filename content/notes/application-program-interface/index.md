---
title: "Using APIs to get data"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/webdata001_api.html"]
categories: ["webdata"]

menu:
  notes:
    parent: Getting data from the web
    weight: 1
---




```r
library(tidyverse)
library(forcats)
library(broom)
library(wbstats)
library(wordcloud)
library(tidytext)
library(viridis)

set.seed(1234)
theme_set(theme_minimal())
```

There are many ways to obtain data from the Internet. Four major categories are:

* **click-and-download** on the internet as a "flat" file, such as .csv, .xls
* **install-and-play** an API for which someone has written a handy R package
* **API-query** published with an unwrapped API
* **Scraping** implicit in an html website

## Click-and-Download

In the simplest case, the data you need is already on the internet in a tabular format. There are a couple of strategies here:

* Use `read.csv` or `readr::read_csv` to read the data straight into R
* Use the `downloader` package or `curl` from the shell to download the file and store a local copy, then use `read_csv` or something similar to read the data into R
    * Even if the file disappears from the internet, you have a local copy cached

Even in this instance, files may need cleaning and transformation when you bring them into R.

## Data supplied on the web - APIs

Many times, the data that you want is not already organized into one or a few tables that you can read directly into R. More frequently, you find this data is given in the form of an API. **A**pplication **P**rogramming **I**nterfaces (APIs) are descriptions of the kind of requests that can be made of a certain piece of software, and descriptions of the kind of answers that are returned. Many sources of data - databases, websites, services - have made all (or part) of their data available via APIs over the internet. Computer programs ("clients") can make requests of the server, and the server will respond by sending data (or an error message). This client can be many kinds of other programs or websites, including R running from your laptop.

### Some basic terminology

- **Representational State Transfer** (REST) - these allow us to query databases using URLs, just like you would construct a URL to view a web page.
- **Uniform Resource Location** (URL) - a string of characters that uses the Hypertext Transfer Protocol (HTTP) and points to a data resource. On the world wide web this is typically a file written in Hypertext Markup Language (HTML). Here, it will return a file containing a subset of a database.
- HTTP methods/verbs
    - **GET**: fetch an existing resource. The URL contains all the necessary information the server needs to locate and return the resource.
    - **POST**: create a new resource. POST requests usually carry a payload that specifies the data for the new resource.
    - **PUT**: update an existing resource. The payload may contain the updated data for the resource.
    - **DELETE**: delete an existing resource.
    - The most common method you will use for an API is GET.

### How Do GET Requests Work? 

#### A Web Browsing Example {-}

As you might suspect from the example above, surfing the web is basically equivalent to sending a bunch of `GET` requests to different servers and asking for different files written in HTML.

Suppose, for instance, you wanted to look something up on Wikipedia. The first step would be to open your web browser and type in `http://www.wikipedia.org`. Once you hit return, you would see the page below.  

![](/img/wikipedia.png)

Several different processes occurred, however, between hitting "return" and the page finally being rendered. In order:

1. The web browser took the entered character string, used the command-line tool "Curl" to write a properly formatted HTTP GET request, and submitted it to the server that hosts the Wikipedia homepage.
1. After receiving this request, the server sent an HTTP response, from which Curl extracted the HTML code for the page (partially shown below).
1. The raw HTML code was parsed and then executed by the web browser, rendering the page as seen in the window.


```
## No encoding supplied: defaulting to UTF-8.
```

```
## [1] "<!DOCTYPE html>\n<html lang=\"mul\" class=\"no-js\">\n<head>\n<meta charset=\"utf-8\">\n<title>Wikipedia</title>\n<meta name=\"description\" content=\"Wikipedia is a free online encyclopedia, created and edited by volunteers around the world and hosted by the Wikimedia Foundation.\">\n<script>\ndocument.documentElement.className = document.documentElement.className.replace( /(^|\\s)no-js(\\s|$)/, \"$1js-enabled$2\" );\n</script>\n<meta name=\"viewport\" content=\"initial-scale=1,user-scalable=yes\">\n<link rel=\"apple-touch-icon\" href=\"/static/apple-touch/wikipedia.png\">\n<link rel=\"shortcut icon\" href=\"/static/favicon/wikipedia.ico\">\n<link rel=\"license\" href=\"//creativecommons.org/licenses/by-sa/3.0/\">\n<style>\n.sprite{background-image:url(portal/wikipedia.org/assets/img/sprite-46c49284.png);background-image:linear-gradient(transparent,transparent),url(portal/wikipedia.org/assets/img/sprite-46c49284.svg);background-repeat:no-repeat;display:inline-block;vertical-align:middle}.svg-Commons-logo_sister{background-posit"
```

#### Web Browsing as a Template for RESTful Database Querying

The process of web browsing described above is a close analogue for the process of database querying via RESTful APIs, with only a few adjustments:

1. While the Curl tool will still be used to send HTML GET requests to the servers hosting our databases of interest, the character string that we supply to Curl must be constructed so that the resulting request can be interpreted and successfully acted upon by the server.  In particular, it is likely that the character string must encode **search terms and/or filtering parameters**, as well as one or more **authentication codes**.  While the terms are often similar across APIs, most are API-specific.

2. Unlike with web browsing, the content of the server's response that is extracted by Curl is unlikely to be HTML code.  Rather, it will likely be **raw text response that can be parsed into one of a few file formats commonly used for data storage**.  The usual suspects include `.csv`, `.xml`, and `.json` files.

3. Whereas the web browser capably parsed and executed the HTML code, **one or more facilities in R, Python, or other programming languages will be necessary for parsing the server response and converting it into a format for local storage** (e.g., matrices, dataframes, databases, lists, etc.).

## Install and play packages

Many common web services and APIs have been "wrapped", i.e. R functions have been written around them which send your query to the server and format the response.

Why do we want this?

* provenance
* reproducible
* updating
* ease
* scaling

## Obtaining World Bank indicators

The [World Bank](https://www.worldbank.org/) contains a rich and detailed set of socioeconomic indicators spanning several decades and dozens of topics. Their data is available for bulk download as CSV files from their [website](https://data.worldbank.org/); you previously practiced [importing and wrangling this data for all countries](/homework/programming/). However as you noted in that assignment, frequently you only need to obtain a handful of indicators or a subset of countries.

To provide more granular access to this information, the World Bank provides a [RESTful API](https://datahelpdesk.worldbank.org/knowledgebase/topics/125589) for querying and obtaining a portion of their database programmatically. The [`wbstats`](http://nset-ornl.github.io/wbstats/) implements this API in R to allow for relatively easy access to the API and return the results in a tidy data frame.

### Finding available data with `wb_cachelist`

`wb_cachelist` contains a snapshot of available countries, indicators, and other relevant information obtainable through the WB API.


```r
library(wbstats)

str(wb_cachelist, max.level = 1)
```

```
## List of 8
##  $ countries    : tibble [304 × 18] (S3: tbl_df/tbl/data.frame)
##  $ indicators   : tibble [16,649 × 8] (S3: tbl_df/tbl/data.frame)
##  $ sources      : tibble [63 × 9] (S3: tbl_df/tbl/data.frame)
##  $ topics       : tibble [21 × 3] (S3: tbl_df/tbl/data.frame)
##  $ regions      : tibble [48 × 4] (S3: tbl_df/tbl/data.frame)
##  $ income_levels: tibble [7 × 3] (S3: tbl_df/tbl/data.frame)
##  $ lending_types: tibble [4 × 3] (S3: tbl_df/tbl/data.frame)
##  $ languages    : tibble [23 × 3] (S3: tbl_df/tbl/data.frame)
```

```r
glimpse(wb_cachelist$countries)
```

```
## Rows: 304
## Columns: 18
## $ iso3c              <chr> "ABW", "AFG", "AFR", "AGO", "ALB", "AND", "ANR", "…
## $ iso2c              <chr> "AW", "AF", "A9", "AO", "AL", "AD", "L5", "1A", "A…
## $ country            <chr> "Aruba", "Afghanistan", "Africa", "Angola", "Alban…
## $ capital_city       <chr> "Oranjestad", "Kabul", NA, "Luanda", "Tirane", "An…
## $ longitude          <dbl> -70.01670, 69.17610, NA, 13.24200, 19.81720, 1.521…
## $ latitude           <dbl> 12.51670, 34.52280, NA, -8.81155, 41.33170, 42.507…
## $ region_iso3c       <chr> "LCN", "SAS", NA, "SSF", "ECS", "ECS", NA, NA, "ME…
## $ region_iso2c       <chr> "ZJ", "8S", NA, "ZG", "Z7", "Z7", NA, NA, "ZQ", "Z…
## $ region             <chr> "Latin America & Caribbean", "South Asia", "Aggreg…
## $ admin_region_iso3c <chr> NA, "SAS", NA, "SSA", "ECA", NA, NA, NA, NA, "LAC"…
## $ admin_region_iso2c <chr> NA, "8S", NA, "ZF", "7E", NA, NA, NA, NA, "XJ", "7…
## $ admin_region       <chr> NA, "South Asia", NA, "Sub-Saharan Africa (excludi…
## $ income_level_iso3c <chr> "HIC", "LIC", NA, "LMC", "UMC", "HIC", NA, NA, "HI…
## $ income_level_iso2c <chr> "XD", "XM", NA, "XN", "XT", "XD", NA, NA, "XD", "X…
## $ income_level       <chr> "High income", "Low income", "Aggregates", "Lower …
## $ lending_type_iso3c <chr> "LNX", "IDX", NA, "IBD", "IBD", "LNX", NA, NA, "LN…
## $ lending_type_iso2c <chr> "XX", "XI", NA, "XF", "XF", "XX", NA, NA, "XX", "X…
## $ lending_type       <chr> "Not classified", "IDA", "Aggregates", "IBRD", "IB…
```

### Search available data with `wb_search()`

`wb_search()` searches through the `wb_cachelist$indicators` data frame to find indicators that match the search pattern.^[Alternatively, you can use the [web interface](https://data.worldbank.org/indicator) to determine specific indicators and their IDs.]


```r
wb_search("unemployment")
```

```
## # A tibble: 61 x 3
##    indicator_id indicator                      indicator_desc                   
##    <chr>        <chr>                          <chr>                            
##  1 fin37.t.a    Received government transfers… The percentage of respondents wh…
##  2 fin37.t.a.1  Received government transfers… The percentage of respondents wh…
##  3 fin37.t.a.10 Received government transfers… The percentage of respondents wh…
##  4 fin37.t.a.11 Received government transfers… The percentage of respondents wh…
##  5 fin37.t.a.2  Received government transfers… The percentage of respondents wh…
##  6 fin37.t.a.3  Received government transfers… The percentage of respondents wh…
##  7 fin37.t.a.4  Received government transfers… The percentage of respondents wh…
##  8 fin37.t.a.5  Received government transfers… The percentage of respondents wh…
##  9 fin37.t.a.6  Received government transfers… The percentage of respondents wh…
## 10 fin37.t.a.7  Received government transfers… The percentage of respondents wh…
## # … with 51 more rows
```

```r
wb_search("labor force")
```

```
## # A tibble: 245 x 3
##    indicator_id   indicator                 indicator_desc                      
##    <chr>          <chr>                     <chr>                               
##  1 9.0.Employee.… Employees (%)             Share of the labor force (ages 18-6…
##  2 9.0.Employee.… Employees-Bottom 40 Perc… Share of the labor force (ages 18-6…
##  3 9.0.Employee.… Employees-Top 60 Percent… Share of the labor force (ages 18-6…
##  4 9.0.Employer.… Employers (%)             Share of the labor force (ages 18-6…
##  5 9.0.Employer.… Employers-Bottom 40 Perc… Share of the labor force (ages 18-6…
##  6 9.0.Employer.… Employers-Top 60 Percent… Share of the labor force (ages 18-6…
##  7 9.0.Labor.All  Labor Force Participatio… Share of the population (ages 18-65…
##  8 9.0.Labor.B40  Labor Force Participatio… Share of the population (ages 18-65…
##  9 9.0.Labor.T60  Labor Force Participatio… Share of the population (ages 18-65…
## 10 9.0.SelfEmp.A… Self-Employed (%)         Share of the labor force (ages 18-6…
## # … with 235 more rows
```

```r
wb_search("labor force", fields = "indicator")  # limit search to just the indicator name
```

```
## # A tibble: 176 x 3
##    indicator_id  indicator                   indicator_desc                     
##    <chr>         <chr>                       <chr>                              
##  1 9.0.Labor.All Labor Force Participation … Share of the population (ages 18-6…
##  2 9.0.Labor.B40 Labor Force Participation … Share of the population (ages 18-6…
##  3 9.0.Labor.T60 Labor Force Participation … Share of the population (ages 18-6…
##  4 9.1.Labor.All Labor Force Participation … Share of the male population (ages…
##  5 9.1.Labor.B40 Labor Force Participation … Share of the male population (ages…
##  6 9.1.Labor.T60 Labor Force Participation … Share of the male population (ages…
##  7 9.2.Labor.All Labor Force Participation … Share of the female population (ag…
##  8 9.2.Labor.B40 Labor Force Participation … Share of the female population (ag…
##  9 9.2.Labor.T60 Labor Force Participation … Share of the female population (ag…
## 10 account.t.d.… Account, in labor force (%… The percentage of respondents who …
## # … with 166 more rows
```

### Downloading data with `wb_data()`

Once you have the set of indicators you would like to obtain, you can use the `wb_data()` function to generate the API query and download the results. Let's say we want to obtain information on [the percent of females participating in the labor force](https://data.worldbank.org/indicator/SL.TLF.TOTL.FE.ZS?view=chart). The indicator ID is `SL.TLF.TOTL.FE.ZS`. We can download the indicator for all countries from 1990-2020 using:


```r
female_labor <- wb_data(
  indicator = "SL.TLF.TOTL.FE.ZS",
  start_date = 1990,
  end_date = 2020
)
female_labor
```

```
## # A tibble: 6,727 x 9
##    iso2c iso3c country  date SL.TLF.TOTL.FE.… unit  obs_status footnote
##    <chr> <chr> <chr>   <dbl>            <dbl> <chr> <chr>      <chr>   
##  1 AW    ABW   Aruba    1990               NA <NA>  <NA>       <NA>    
##  2 AW    ABW   Aruba    1991               NA <NA>  <NA>       <NA>    
##  3 AW    ABW   Aruba    1992               NA <NA>  <NA>       <NA>    
##  4 AW    ABW   Aruba    1993               NA <NA>  <NA>       <NA>    
##  5 AW    ABW   Aruba    1994               NA <NA>  <NA>       <NA>    
##  6 AW    ABW   Aruba    1995               NA <NA>  <NA>       <NA>    
##  7 AW    ABW   Aruba    1996               NA <NA>  <NA>       <NA>    
##  8 AW    ABW   Aruba    1997               NA <NA>  <NA>       <NA>    
##  9 AW    ABW   Aruba    1998               NA <NA>  <NA>       <NA>    
## 10 AW    ABW   Aruba    1999               NA <NA>  <NA>       <NA>    
## # … with 6,717 more rows, and 1 more variable: last_updated <date>
```

Note the column containing our indicator uses the indicator ID as its name. This is rather unintuitive, so we can adjust it directly in the function.


```r
female_labor <- wb_data(
  indicator = c("fem_lab_part" = "SL.TLF.TOTL.FE.ZS"),
  start_date = 1990,
  end_date = 2020
)
female_labor
```

```
## # A tibble: 6,727 x 9
##    iso2c iso3c country  date fem_lab_part unit  obs_status footnote last_updated
##    <chr> <chr> <chr>   <dbl>        <dbl> <chr> <chr>      <chr>    <date>      
##  1 AW    ABW   Aruba    1990           NA <NA>  <NA>       <NA>     2020-12-14  
##  2 AW    ABW   Aruba    1991           NA <NA>  <NA>       <NA>     2020-12-14  
##  3 AW    ABW   Aruba    1992           NA <NA>  <NA>       <NA>     2020-12-14  
##  4 AW    ABW   Aruba    1993           NA <NA>  <NA>       <NA>     2020-12-14  
##  5 AW    ABW   Aruba    1994           NA <NA>  <NA>       <NA>     2020-12-14  
##  6 AW    ABW   Aruba    1995           NA <NA>  <NA>       <NA>     2020-12-14  
##  7 AW    ABW   Aruba    1996           NA <NA>  <NA>       <NA>     2020-12-14  
##  8 AW    ABW   Aruba    1997           NA <NA>  <NA>       <NA>     2020-12-14  
##  9 AW    ABW   Aruba    1998           NA <NA>  <NA>       <NA>     2020-12-14  
## 10 AW    ABW   Aruba    1999           NA <NA>  <NA>       <NA>     2020-12-14  
## # … with 6,717 more rows
```


```r
ggplot(data = female_labor, mapping = aes(x = date, y = fem_lab_part)) +
  geom_line(mapping = aes(group = country), alpha = .1) +
  geom_smooth() +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Labor force participation",
    x = "Year",
    y = "Percent of total labor force which is female",
    caption = "Source: World Bank"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/female-labor-plot-1.png" width="672" />

By default, `wb_data()` returns queries as data frames in a wide format. So if we request multiple indicators, each indicator will be stored in its own column.


```r
female_vars <- wb_data(
  indicator = c("fem_lab_part" = "SL.TLF.TOTL.FE.ZS",
                "fem_educ_sec" = "SE.SEC.CUAT.UP.FE.ZS"),
  start_date = 1990,
  end_date = 2020
)

ggplot(data = female_vars, mapping = aes(x = fem_educ_sec, y = fem_lab_part)) +
  geom_point(alpha = .2) +
  geom_smooth() +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Female labor force participation",
    x = "Percent of females 25+ who completed secondary school",
    y = "Percent of total labor force which is female",
    caption = "Source: World Bank"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/female-educ-1.png" width="672" />

## Searching geographic info: `geonames`


```r
# install.packages(geonames)
library(geonames)
```

### API authentication

Many APIs require you to register for access. This allows them to track which users are submitting queries and manage demand - if you submit too many queries too quickly, you might be **rate-limited** and your requests de-prioritized or blocked. Always check the API access policy of the web site to determine what these limits are.

There are a few things we need to do to be able to use this package to access the geonames API:

1. Go to [the geonames site](http://www.geonames.org/login/) and register an account. 
2. **Click [here to enable the free web service](http://www.geonames.org/enablefreewebservice)**
3. Tell R your geonames username. You could run the line

``` r 
options(geonamesUsername = "my_user_name")
``` 

in R. However this is insecure. We don't want to risk committing this line and pushing it to our public GitHub page! Instead, you should create a file in the same place as your `.Rproj` file. To do that, run the following command from the R console:

```r
file.edit(here::here(".Rprofile"))
```

{{% callout note %}}

Note: you need to have the [`here`](https://cran.r-project.org/web/packages/here/index.html) package installed for that code to work.

{{% /callout %}}

This will create a special file called `.Rprofile` in the same directory as your `.Rproj` file (assuming you are working in an R project). The file should open automatically in your RStudio script editor. Add

``` r 
options(geonamesUsername = "my_user_name")
``` 

to that file, replacing `my_user_name` with your Geonames username.

#### Important

* Make sure your `.Rprofile` ends with a blank line
* Make sure `.Rprofile` is included in your `.gitignore` file, otherwise it will be synced with Github
* Restart RStudio after modifying `.Rprofile` in order to load any new keys into memory
* Spelling is important when you set the option in your `.Rprofile`
* You can do a similar process for an arbitrary package or key. For example:


```r
# in .Rprofile
options("this_is_my_key" = XXXX)

# later, in the R script:
key <- getOption("this_is_my_key")
```

This is a simple means to keep your keys private, especially if you are sharing the same authentication across several projects. Remember that using `.Rprofile` makes your code un-reproducible. In this case, that is exactly what we want!

### Using Geonames

What can we do? Get access to lots of geographical information via the various ["web services"](http://www.geonames.org/export/ws-overview.html)


```r
countryInfo <- GNcountryInfo()
```


```r
countryInfo %>%
  as_tibble() %>%
  glimpse()
```

```
## Rows: 250
## Columns: 17
## $ continent     <chr> "EU", "AS", "AS", "NA", "NA", "EU", "AS", "AF", "AN", "…
## $ capital       <chr> "Andorra la Vella", "Abu Dhabi", "Kabul", "Saint John’s…
## $ languages     <chr> "ca", "ar-AE,fa,en,hi,ur", "fa-AF,ps,uz-AF,tk", "en-AG"…
## $ geonameId     <chr> "3041565", "290557", "1149361", "3576396", "3573511", "…
## $ south         <chr> "42.428743001", "22.6315119400001", "29.3770645357176",…
## $ isoAlpha3     <chr> "AND", "ARE", "AFG", "ATG", "AIA", "ALB", "ARM", "AGO",…
## $ north         <chr> "42.655765", "26.0693916590001", "38.4907920755748", "1…
## $ fipsCode      <chr> "AN", "AE", "AF", "AC", "AV", "AL", "AM", "AO", "AY", "…
## $ population    <chr> "77006", "9630959", "37172386", "96286", "13254", "2866…
## $ east          <chr> "1.78657600000003", "56.381222289", "74.8894511481168",…
## $ isoNumeric    <chr> "020", "784", "004", "028", "660", "008", "051", "024",…
## $ areaInSqKm    <chr> "468.0", "82880.0", "647500.0", "443.0", "102.0", "2874…
## $ countryCode   <chr> "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "…
## $ west          <chr> "1.41376000100007", "51.5904085340001", "60.47208339722…
## $ countryName   <chr> "Principality of Andorra", "United Arab Emirates", "Isl…
## $ continentName <chr> "Europe", "Asia", "Asia", "North America", "North Ameri…
## $ currencyCode  <chr> "EUR", "AED", "AFN", "XCD", "XCD", "ALL", "AMD", "AOA",…
```

This country info dataset is very helpful for accessing the rest of the data, because it gives us the standardized codes for country and language.  

## The Manifesto Project: `manifestoR`

[The Manifesto Project](https://manifesto-project.wzb.eu/) collects and organizes political party manifestos from around the world. It currently covers over 1000 parties from 1945 until today in over 50 countries on five continents. We can use the [`manifestoR` package](https://github.com/ManifestoProject/manifestoR) to access the API and download those manifestos for analysis in R.

### Load library and set API key

Accessing data from the Manifesto Project API requires an authentication key. You can create an account and key [here](https://manifesto-project.wzb.eu/signup). Here I store my key in `.Rprofile` and retrieve it using `mp_setapikey()`.


```r
library(manifestoR)

# retrieve API key stored in .Rprofile
mp_setapikey(key = getOption("manifesto_key"))
```

### Retrieve the database


```r
(mpds <- mp_maindataset())
```

```
## Connecting to Manifesto Project DB API... 
## Connecting to Manifesto Project DB API... corpus version: 2020-1
```

```
## Warning: `tbl_df()` is deprecated as of dplyr 1.0.0.
## Please use `tibble::as_tibble()` instead.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_warnings()` to see where this warning was generated.
```

```
## # A tibble: 4,582 x 174
##    country countryname oecdmember eumember edate        date party partyname
##      <dbl> <chr>            <dbl>    <dbl> <date>      <dbl> <dbl> <chr>    
##  1      11 Sweden               0        0 1944-09-17 194409 11220 Communis…
##  2      11 Sweden               0        0 1944-09-17 194409 11320 Social D…
##  3      11 Sweden               0        0 1944-09-17 194409 11420 People’s…
##  4      11 Sweden               0        0 1944-09-17 194409 11620 Right Pa…
##  5      11 Sweden               0        0 1944-09-17 194409 11810 Agrarian…
##  6      11 Sweden               0        0 1948-09-19 194809 11220 Communis…
##  7      11 Sweden               0        0 1948-09-19 194809 11320 Social D…
##  8      11 Sweden               0        0 1948-09-19 194809 11420 People’s…
##  9      11 Sweden               0        0 1948-09-19 194809 11620 Right Pa…
## 10      11 Sweden               0        0 1948-09-19 194809 11810 Agrarian…
## # … with 4,572 more rows, and 166 more variables: partyabbrev <chr>,
## #   parfam <dbl>, coderid <dbl>, manual <dbl>, coderyear <dbl>,
## #   testresult <dbl>, testeditsim <dbl>, pervote <dbl>, voteest <dbl>,
## #   presvote <dbl>, absseat <dbl>, totseats <dbl>, progtype <dbl>,
## #   datasetorigin <dbl>, corpusversion <chr>, total <dbl>, peruncod <dbl>,
## #   per101 <dbl>, per102 <dbl>, per103 <dbl>, per104 <dbl>, per105 <dbl>,
## #   per106 <dbl>, per107 <dbl>, per108 <dbl>, per109 <dbl>, per110 <dbl>,
## #   per201 <dbl>, per202 <dbl>, per203 <dbl>, per204 <dbl>, per301 <dbl>,
## #   per302 <dbl>, per303 <dbl>, per304 <dbl>, per305 <dbl>, per401 <dbl>,
## #   per402 <dbl>, per403 <dbl>, per404 <dbl>, per405 <dbl>, per406 <dbl>,
## #   per407 <dbl>, per408 <dbl>, per409 <dbl>, per410 <dbl>, per411 <dbl>,
## #   per412 <dbl>, per413 <dbl>, per414 <dbl>, per415 <dbl>, per416 <dbl>,
## #   per501 <dbl>, per502 <dbl>, per503 <dbl>, per504 <dbl>, per505 <dbl>,
## #   per506 <dbl>, per507 <dbl>, per601 <dbl>, per602 <dbl>, per603 <dbl>,
## #   per604 <dbl>, per605 <dbl>, per606 <dbl>, per607 <dbl>, per608 <dbl>,
## #   per701 <dbl>, per702 <dbl>, per703 <dbl>, per704 <dbl>, per705 <dbl>,
## #   per706 <dbl>, per1011 <dbl>, per1012 <dbl>, per1013 <dbl>, per1014 <dbl>,
## #   per1015 <dbl>, per1016 <dbl>, per1021 <dbl>, per1022 <dbl>, per1023 <dbl>,
## #   per1024 <dbl>, per1025 <dbl>, per1026 <dbl>, per1031 <dbl>, per1032 <dbl>,
## #   per1033 <dbl>, per2021 <dbl>, per2022 <dbl>, per2023 <dbl>, per2031 <dbl>,
## #   per2032 <dbl>, per2033 <dbl>, per2041 <dbl>, per3011 <dbl>, per3051 <dbl>,
## #   per3052 <dbl>, per3053 <dbl>, per3054 <dbl>, …
```

`mp_maindataset()` includes a data frame describing each manifesto included in the database. You can use this database for some exploratory data analysis. For instance, how many manifestos have been published by each political party in Sweden?


```r
mpds %>%
  filter(countryname == "Sweden") %>%
  count(partyname) %>%
  ggplot(aes(fct_reorder(partyname, n), n)) +
  geom_col() +
  labs(title = "Political manifestos published in Sweden",
       x = NULL,
       y = "Total (1948-present)") +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/manifesto-dist-1.png" width="672" />

Or we can use **scaling functions** to identify each party manifesto on an ideological dimension. For example, how have the Democratic and Republican Party manifestos in the United States changed over time?


```r
mpds %>%
  filter(party == 61320 | party == 61620) %>%
  mutate(ideo = mp_scale(.)) %>%
  select(partyname, edate, ideo) %>%
  ggplot(aes(edate, ideo, color = partyname)) +
  geom_line() +
  scale_color_manual(values = c("blue", "red")) +
  labs(title = "Ideological scaling of major US political parties",
       x = "Year",
       y = "Ideological position",
       color = NULL) +
  theme(legend.position = "bottom")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/manifestor-usa-1.png" width="672" />

### Download manifestos

`mp_corpus()` can be used to download the original manifestos as full text documents stored as a [**corpus**](/notes/text-analysis-workflow/#extract-documents-and-move-into-a-corpus). Once you obtain the corpus, you can perform [text analysis](/notes/text-analysis-workflow/). As an example, let's compare the most common words in the Democratic and Republican Party manifestos from the 2016 U.S. presidential election:


```r
# download documents
(docs <- mp_corpus(countryname == "United States" & edate > as.Date("2016-01-01")))
```

```
## Connecting to Manifesto Project DB API... 
## Connecting to Manifesto Project DB API... corpus version: 2020-1 
## Connecting to Manifesto Project DB API... corpus version: 2020-1 
## Connecting to Manifesto Project DB API... corpus version: 2020-1
```

```
## <<ManifestoCorpus>>
## Metadata:  corpus specific: 0, document level (indexed): 0
## Content:  documents: 2
```

```r
# generate wordcloud of most common terms
docs %>%
  tidy() %>%
  mutate(party = factor(party, levels = c(61320, 61620),
                        labels = c("Democratic Party", "Republican Party"))) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%
  count(party, word, sort = TRUE) %>%
  drop_na() %>%
  reshape2::acast(word ~ party, value.var = "n", fill = 0) %>%
  comparison.cloud(max.words = 200)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/manifestor-corpus-1.png" width="672" />

## Census data with `tidycensus`

[`tidycensus`](https://walkerke.github.io/tidycensus/index.html) provides an interface with the US Census Bureau's decennial census and American Community APIs and returns tidy data frames with optional simple feature geometry. These APIs require a free key you can obtain [here](https://api.census.gov/data/key_signup.html). Rather than storing your key in `.Rprofile`, `tidycensus` includes `census_api_key()` which automatically stores your key in `.Renviron`, which is basically a global version of `.Rprofile`. Anything stored in `.Renviron` is automatically loaded anytime you initiate R on your computer, regardless of the project or file location. Once you get your key, load it:


```r
library(tidycensus)
```

```r
census_api_key("YOUR API KEY GOES HERE", install = TRUE)
```

### Obtaining data

`get_decennial()` allows you to obtain data from the 1990, 2000, and 2010 decennial US censuses. Let's look at the number of individuals of Asian ethnicity by state in 2010:


```r
asia10 <- get_decennial(geography = "state", variables = "P008006", year = 2010)
```

```
## Getting data from the 2010 decennial Census
```

```r
asia10
```

```
## # A tibble: 52 x 4
##    GEOID NAME        variable   value
##    <chr> <chr>       <chr>      <dbl>
##  1 01    Alabama     P008006    53595
##  2 02    Alaska      P008006    38135
##  3 04    Arizona     P008006   176695
##  4 05    Arkansas    P008006    36102
##  5 06    California  P008006  4861007
##  6 22    Louisiana   P008006    70132
##  7 21    Kentucky    P008006    48930
##  8 08    Colorado    P008006   139028
##  9 09    Connecticut P008006   135565
## 10 10    Delaware    P008006    28549
## # … with 42 more rows
```

The result of `get_decennial()` is a tidy data frame with one row per geographic unit-variable.

* `GEOID` - identifier for the geographical unit associated with the row
* `NAME` - descriptive name of the geographical unit
* `variable` - the Census variable encoded in the row
* `value` - the value of the variable for that geographic unit

We can quickly visualize this data frame using `ggplot2`:


```r
ggplot(asia10, aes(x = reorder(NAME, value), y = value)) +
  geom_point() +
  scale_y_continuous(labels = scales::comma) +
  labs(x = NULL,
       y = "Number of residents of Asian ethnicity") +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/plot-asia-1.png" width="672" />

Of course this graph is not entirely useful since it is based on the raw frequency of Asian individuals. California is at the top of the list, but it is also the most populous city. Instead, we could normalize this value as a percentage of the entire state population. To do that, we need to retrieve another variable:


```r
asia_pop <- get_decennial(geography = "state",
                          variables = c("P008006", "P008001"),
                          year = 2010) %>%
  spread(variable, value) %>%
  mutate(pct_asia = P008006 / P008001)
```

```
## Getting data from the 2010 decennial Census
```

```r
asia_pop
```

```
## # A tibble: 52 x 5
##    GEOID NAME                  P008001 P008006 pct_asia
##    <chr> <chr>                   <dbl>   <dbl>    <dbl>
##  1 01    Alabama               4779736   53595   0.0112
##  2 02    Alaska                 710231   38135   0.0537
##  3 04    Arizona               6392017  176695   0.0276
##  4 05    Arkansas              2915918   36102   0.0124
##  5 06    California           37253956 4861007   0.130 
##  6 08    Colorado              5029196  139028   0.0276
##  7 09    Connecticut           3574097  135565   0.0379
##  8 10    Delaware               897934   28549   0.0318
##  9 11    District of Columbia   601723   21056   0.0350
## 10 12    Florida              18801310  454821   0.0242
## # … with 42 more rows
```

```r
ggplot(asia_pop, aes(x = reorder(NAME, pct_asia), y = pct_asia)) +
  geom_point() +
  scale_y_continuous(labels = scales::percent) +
  labs(x = NULL,
       y = "Percent of residents of Asian ethnicity") +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/asia-total-pop-1.png" width="672" />

`get_acs()` retrieves data from the American Community Survey. This survey is administered to a sample of 3 million households on an annual basis, so the data points are estimates characterized by a margin of error. `tidycensus` returns both the original estimate and margin of error. Let's get median household income data from the 2014-2019 ACS for each state.


```r
usa_inc <- get_acs(geography = "state", 
                   variables = c(medincome = "B19013_001"), 
                   year = 2019)
```

```
## Getting data from the 2015-2019 5-year ACS
```

```r
usa_inc
```

```
## # A tibble: 52 x 5
##    GEOID NAME                 variable  estimate   moe
##    <chr> <chr>                <chr>        <dbl> <dbl>
##  1 01    Alabama              medincome    50536   304
##  2 02    Alaska               medincome    77640  1015
##  3 04    Arizona              medincome    58945   266
##  4 05    Arkansas             medincome    47597   328
##  5 06    California           medincome    75235   232
##  6 08    Colorado             medincome    72331   370
##  7 09    Connecticut          medincome    78444   553
##  8 10    Delaware             medincome    68287   696
##  9 11    District of Columbia medincome    86420  1008
## 10 12    Florida              medincome    55660   220
## # … with 42 more rows
```

Now we return both an `estimate` column for the ACS estimate and `moe` for the margin of error (defaults to 90% confidence interval).


```r
usa_inc %>%
  ggplot(aes(x = reorder(NAME, estimate), y = estimate)) +
  geom_pointrange(aes(ymin = estimate - moe,
                     ymax = estimate + moe),
                  size = .25) +
  scale_y_continuous(labels = scales::dollar) +
  coord_flip() +
  labs(title = "Household income by state",
    subtitle = "2019 American Community Survey (five-year estimates)",
       x = "",
       y = "ACS estimate (bars represent margin of error)")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/income-usa-plot-1.png" width="672" />

### Search for variables

`get_acs()` or `get_decennial()` requires knowing the variable ID, of which there are thousands. `load_variables()` downloads a list of variable IDs and labels for a given Census or ACS and dataset. You can then use `View()` to interactively browse through and filter for variables in RStudio.

### Drawing maps

`tidycensus` also can return [simple feature geometry](/notes/simple-features/) for geographic units along with variables from the decennial Census or ACS, which can then be [visualized using `geom_sf()`.](/notes/vector-maps/) Let's look at median household income by Census tracts from the 2014-2019 ACS in Loudoun County, Virginia:


```r
loudoun <- get_acs(state = "VA",
                   county = "Loudoun",
                   geography = "tract", 
                   variables = c(medincome = "B19013_001"), 
                   year = 2019,
                   geometry = TRUE)
```


```r
loudoun
```

```
## Simple feature collection with 65 features and 5 fields
## geometry type:  MULTIPOLYGON
## dimension:      XY
## bbox:           xmin: -77.9622 ymin: 38.84621 xmax: -77.32828 ymax: 39.32419
## geographic CRS: NAD83
## First 10 features:
##          GEOID                                           NAME  variable
## 1  51107611005 Census Tract 6110.05, Loudoun County, Virginia medincome
## 2  51107611013 Census Tract 6110.13, Loudoun County, Virginia medincome
## 3  51107611010 Census Tract 6110.10, Loudoun County, Virginia medincome
## 4  51107611802 Census Tract 6118.02, Loudoun County, Virginia medincome
## 5  51107610504 Census Tract 6105.04, Loudoun County, Virginia medincome
## 6  51107611300    Census Tract 6113, Loudoun County, Virginia medincome
## 7  51107610702 Census Tract 6107.02, Loudoun County, Virginia medincome
## 8  51107611602 Census Tract 6116.02, Loudoun County, Virginia medincome
## 9  51107611601 Census Tract 6116.01, Loudoun County, Virginia medincome
## 10 51107611014 Census Tract 6110.14, Loudoun County, Virginia medincome
##    estimate   moe                       geometry
## 1    140464 12264 MULTIPOLYGON (((-77.50754 3...
## 2    162390 14937 MULTIPOLYGON (((-77.50032 3...
## 3     68162 21264 MULTIPOLYGON (((-77.48152 3...
## 4    161125 16451 MULTIPOLYGON (((-77.54472 3...
## 5    112351 11625 MULTIPOLYGON (((-77.56114 3...
## 6    115145 15114 MULTIPOLYGON (((-77.39662 3...
## 7    132958  9530 MULTIPOLYGON (((-77.72496 3...
## 8     83356 19510 MULTIPOLYGON (((-77.42181 3...
## 9    102125 16320 MULTIPOLYGON (((-77.43496 3...
## 10   119877 12721 MULTIPOLYGON (((-77.48567 3...
```

This looks similar to the previous output but because we set `geometry = TRUE` it is now a simple features data frame with a `geometry` column defining the geographic feature. We can visualize it using `geom_sf()` and `viridis::scale_*_viridis()` to adjust the color palette.


```r
ggplot(data = loudoun) +
  geom_sf(mapping = aes(fill = estimate, color = estimate)) +
  coord_sf(crs = 26911) +
  scale_fill_viridis(
    option = "magma",
    labels = scales::dollar,
    aesthetics = c("fill", "color")
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/loudoun-sf-plot-1.png" width="672" />

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).

- Explanation of APIs drawn from Rochelle Terman's [Collecting Data from the Web](https://plsc-31101.github.io/course/collecting-data-from-the-web.html)

## Session Info



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
##  date     2021-03-01                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version date       lib source                              
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                      
##  backports      1.2.1   2020-12-09 [1] CRAN (R 4.0.2)                      
##  base64enc      0.1-3   2015-07-28 [1] CRAN (R 4.0.0)                      
##  blogdown       1.1     2021-01-19 [1] CRAN (R 4.0.3)                      
##  bookdown       0.21    2020-10-13 [1] CRAN (R 4.0.2)                      
##  broom        * 0.7.3   2020-12-16 [1] CRAN (R 4.0.2)                      
##  callr          3.5.1   2020-10-13 [1] CRAN (R 4.0.2)                      
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)                      
##  class          7.3-17  2020-04-26 [1] CRAN (R 4.0.3)                      
##  classInt       0.4-3   2020-04-07 [1] CRAN (R 4.0.0)                      
##  cli            2.3.1   2021-02-23 [1] CRAN (R 4.0.3)                      
##  codetools      0.2-18  2020-11-04 [1] CRAN (R 4.0.2)                      
##  colorspace     2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon         1.4.1   2021-02-08 [1] CRAN (R 4.0.2)                      
##  DBI            1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr         2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  debugme        1.1.0   2017-10-22 [1] CRAN (R 4.0.0)                      
##  desc           1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools       2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest         0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr        * 1.0.4   2021-02-02 [1] CRAN (R 4.0.2)                      
##  DT             0.16    2020-10-13 [1] CRAN (R 4.0.2)                      
##  e1071          1.7-4   2020-10-14 [1] CRAN (R 4.0.2)                      
##  ellipsis       0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                      
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)                      
##  fansi          0.4.2   2021-01-15 [1] CRAN (R 4.0.2)                      
##  farver         2.0.3   2020-01-16 [1] CRAN (R 4.0.0)                      
##  forcats      * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)                      
##  foreign        0.8-81  2020-12-22 [1] CRAN (R 4.0.2)                      
##  fs             1.5.0   2020-07-31 [1] CRAN (R 4.0.2)                      
##  functional     0.6     2014-07-16 [1] CRAN (R 4.0.0)                      
##  generics       0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                      
##  geonames     * 0.999   2019-02-19 [1] CRAN (R 4.0.0)                      
##  ggplot2      * 3.3.3   2020-12-30 [1] CRAN (R 4.0.2)                      
##  glue           1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  gridExtra      2.3     2017-09-09 [1] CRAN (R 4.0.0)                      
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)                      
##  haven          2.3.1   2020-06-01 [1] CRAN (R 4.0.0)                      
##  here           1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  highr          0.8     2019-03-20 [1] CRAN (R 4.0.0)                      
##  hms            0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools      0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)                      
##  htmlwidgets    1.5.3   2020-12-10 [1] CRAN (R 4.0.2)                      
##  httr           1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  janeaustenr    0.1.5   2017-06-10 [1] CRAN (R 4.0.0)                      
##  jsonlite       1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  KernSmooth     2.23-18 2020-10-29 [1] CRAN (R 4.0.2)                      
##  knitr          1.31    2021-01-27 [1] CRAN (R 4.0.2)                      
##  labeling       0.4.2   2020-10-20 [1] CRAN (R 4.0.2)                      
##  lattice        0.20-41 2020-04-02 [1] CRAN (R 4.0.3)                      
##  lifecycle      1.0.0   2021-02-15 [1] CRAN (R 4.0.2)                      
##  lubridate      1.7.9.2 2021-01-18 [1] Github (tidyverse/lubridate@aab2e30)
##  magrittr       2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                      
##  manifestoR   * 1.5.0   2020-11-29 [1] CRAN (R 4.0.2)                      
##  maptools       1.0-2   2020-08-24 [1] CRAN (R 4.0.2)                      
##  Matrix         1.3-0   2020-12-22 [1] CRAN (R 4.0.2)                      
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 4.0.0)                      
##  mnormt         2.0.2   2020-09-01 [1] CRAN (R 4.0.2)                      
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)                      
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)                      
##  nlme           3.1-151 2020-12-10 [1] CRAN (R 4.0.2)                      
##  NLP          * 0.2-1   2020-10-14 [1] CRAN (R 4.0.2)                      
##  pillar         1.5.0   2021-02-22 [1] CRAN (R 4.0.3)                      
##  pkgbuild       1.2.0   2020-12-15 [1] CRAN (R 4.0.2)                      
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                      
##  pkgload        1.1.0   2020-05-29 [1] CRAN (R 4.0.2)                      
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)                      
##  processx       3.4.5   2020-11-30 [1] CRAN (R 4.0.2)                      
##  ps             1.5.0   2020-12-05 [1] CRAN (R 4.0.2)                      
##  psych          2.0.12  2020-12-16 [1] CRAN (R 4.0.2)                      
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                      
##  R6             2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                      
##  rappdirs       0.3.1   2016-03-28 [1] CRAN (R 4.0.0)                      
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 4.0.0)                      
##  Rcpp           1.0.6   2021-01-15 [1] CRAN (R 4.0.2)                      
##  readr        * 1.4.0   2020-10-05 [1] CRAN (R 4.0.2)                      
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)                      
##  remotes        2.2.0   2020-07-21 [1] CRAN (R 4.0.2)                      
##  reprex         1.0.0   2021-01-27 [1] CRAN (R 4.0.2)                      
##  rgdal          1.5-18  2020-10-13 [1] CRAN (R 4.0.2)                      
##  rlang          0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                      
##  rmarkdown      2.6     2020-12-14 [1] CRAN (R 4.0.2)                      
##  rprojroot      2.0.2   2020-11-15 [1] CRAN (R 4.0.2)                      
##  rstudioapi     0.13    2020-11-12 [1] CRAN (R 4.0.2)                      
##  rvest          0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  sf             0.9-6   2020-09-13 [1] CRAN (R 4.0.2)                      
##  slam           0.1-48  2020-12-03 [1] CRAN (R 4.0.2)                      
##  SnowballC      0.7.0   2020-04-01 [1] CRAN (R 4.0.0)                      
##  sp             1.4-4   2020-10-07 [1] CRAN (R 4.0.2)                      
##  stringi        1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat       3.0.2   2021-02-14 [1] CRAN (R 4.0.2)                      
##  tibble       * 3.0.6   2021-01-29 [1] CRAN (R 4.0.2)                      
##  tidycensus   * 0.11    2020-12-14 [1] CRAN (R 4.0.2)                      
##  tidyr        * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect     1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidytext     * 0.2.6   2020-09-20 [1] CRAN (R 4.0.2)                      
##  tidyverse    * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  tigris         1.0     2020-07-13 [1] CRAN (R 4.0.2)                      
##  tm           * 0.7-8   2020-11-18 [1] CRAN (R 4.0.2)                      
##  tmvnsim        1.0-2   2016-12-15 [1] CRAN (R 4.0.0)                      
##  tokenizers     0.2.1   2018-03-29 [1] CRAN (R 4.0.0)                      
##  units          0.6-7   2020-06-13 [1] CRAN (R 4.0.2)                      
##  usethis        2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  utf8           1.1.4   2018-05-24 [1] CRAN (R 4.0.0)                      
##  uuid           0.1-4   2020-02-26 [1] CRAN (R 4.0.0)                      
##  vctrs          0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  viridis      * 0.5.1   2018-03-29 [1] CRAN (R 4.0.0)                      
##  viridisLite  * 0.3.0   2018-02-01 [1] CRAN (R 4.0.0)                      
##  wbstats      * 1.0.4   2020-12-05 [1] CRAN (R 4.0.2)                      
##  withr          2.4.1   2021-01-26 [1] CRAN (R 4.0.2)                      
##  wordcloud    * 2.6     2018-08-24 [1] CRAN (R 4.0.0)                      
##  xfun           0.21    2021-02-10 [1] CRAN (R 4.0.2)                      
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
##  zoo            1.8-8   2020-05-02 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
