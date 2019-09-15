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

## Data supplied on the web

Many times, the data that you want is not already organized into one or a few tables that you can read directly into R. More frequently, you find this data is given in the form of an API. **A**pplication **P**rogramming **I**nterfaces (APIs) are descriptions of the kind of requests that can be made of a certain piece of software, and descriptions of the kind of answers that are returned. Many sources of data - databases, websites, services - have made all (or part) of their data available via APIs over the internet. Computer programs ("clients") can make requests of the server, and the server will respond by sending data (or an error message). This client can be many kinds of other programs or websites, including R running from your laptop.

## Install and play packages

Many common web services and APIs have been "wrapped", i.e. R functions have been written around them which send your query to the server and format the response.

Why do we want this?

* provenance
* reproducible
* updating
* ease
* scaling

## Sightings of birds: `rebird`

[`rebird`](https://github.com/ropensci/rebird) is an R interface for the [ebird](http://ebird.org/content/ebird/) database. e-Bird lets birders upload sightings of birds, and allows everyone access to those data.


```r
install.packages("rebird")
```


```r
library(rebird)
```

## Search birds by geography

The ebird website categorizes some popular locations as "Hotspots". These are areas where there are both lots of birds and lots of birders. Once such location is at Lincoln Park Zoo in Chicago. You can see data for this site at [http://ebird.org/ebird/hotspot/L1573785](http://ebird.org/ebird/hotspot/L1573785)

At that link, you can see a page like this:

![Lincoln Park Zoo](/img/lincoln_park_zoo.png)

The data already look to be organized in a data frame! `rebird` allows us to read these data directly into R.

> The ID code for Lincoln Park Zoo is **L1573785**


```r
ebirdhotspot(locID = "L1573785", key = getOption("EBIRD_KEY")) %>%
  as_tibble()
```

```
## Warning: Deprecated: 'ebirdhotspot' will be removed in the next version of
## rebird as it might not be suported in the new eBird API. Use 'ebirdregion'
## instead.
```

```
## # A tibble: 54 x 12
##    speciesCode comName sciName locId locName obsDt howMany   lat   lng
##    <chr>       <chr>   <chr>   <chr> <chr>   <chr>   <int> <dbl> <dbl>
##  1 cangoo      Canada… Branta… L157… Lincol… 2019…      17  41.9 -87.6
##  2 wooduc      Wood D… Aix sp… L157… Lincol… 2019…       2  41.9 -87.6
##  3 mallar3     Mallard Anas p… L157… Lincol… 2019…       6  41.9 -87.6
##  4 gresca      Greate… Aythya… L157… Lincol… 2019…       1  41.9 -87.6
##  5 buffle      Buffle… Buceph… L157… Lincol… 2019…       1  41.9 -87.6
##  6 comgol      Common… Buceph… L157… Lincol… 2019…       4  41.9 -87.6
##  7 hoomer      Hooded… Lophod… L157… Lincol… 2019…       1  41.9 -87.6
##  8 moudov      Mourni… Zenaid… L157… Lincol… 2019…       2  41.9 -87.6
##  9 ribgul      Ring-b… Larus … L157… Lincol… 2019…       9  41.9 -87.6
## 10 yebsap      Yellow… Sphyra… L157… Lincol… 2019…       1  41.9 -87.6
## # … with 44 more rows, and 3 more variables: obsValid <lgl>,
## #   obsReviewed <lgl>, locationPrivate <lgl>
```

We can use the function `ebirdgeo` to get a list for an area. (Note that South and West are negative):


```r
chibirds <- ebirdgeo(lat = 41.8781, lng = -87.6298, key = getOption("EBIRD_KEY"))
chibirds %>%
  as_tibble() %>%
  glimpse()
```

```
## Observations: 147
## Variables: 12
## $ speciesCode     <chr> "daejun", "cangoo", "wooduc", "buwtea", "mallar3…
## $ comName         <chr> "Dark-eyed Junco", "Canada Goose", "Wood Duck", …
## $ sciName         <chr> "Junco hyemalis", "Branta canadensis", "Aix spon…
## $ locId           <chr> "L6822227", "L143490", "L143490", "L143490", "L1…
## $ locName         <chr> "Backyard, Chicago, Illinois, US", "Thatcher Woo…
## $ obsDt           <chr> "2019-03-28 09:54", "2019-03-28 09:17", "2019-03…
## $ howMany         <int> 1, 2, 3, 2, 2, 1, 2, 1, 3, 2, 2, 1, 1, 1, 2, 79,…
## $ lat             <dbl> 41.89829, 41.89357, 41.89357, 41.89357, 41.89357…
## $ lng             <dbl> -87.68245, -87.82979, -87.82979, -87.82979, -87.…
## $ obsValid        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, …
## $ obsReviewed     <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,…
## $ locationPrivate <lgl> TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, …
```

**Note**: Check the defaults on this function. e.g. radius of circle, time of year.

We can also search by "region", which refers to short codes which serve as common shorthands for different political units. For example, France is represented by the letters **FR**:


```r
frenchbirds <- ebirdregion("FR", key = getOption("EBIRD_KEY"))

frenchbirds %>%
  as_tibble() %>%
  glimpse()
```

```
## Observations: 246
## Variables: 12
## $ speciesCode     <chr> "blackc1", "winwre4", "rocpig", "rinphe", "marti…
## $ comName         <chr> "Eurasian Blackcap", "Eurasian Wren", "Rock Pige…
## $ sciName         <chr> "Sylvia atricapilla", "Troglodytes troglodytes",…
## $ locId           <chr> "L8920860", "L8920860", "L8920860", "L8920860", …
## $ locName         <chr> "Miannay FR-Picardy (50,0980,1,7184)", "Miannay …
## $ obsDt           <chr> "2019-03-28 14:45", "2019-03-28 14:45", "2019-03…
## $ howMany         <int> 1, 1, 4, 1, 2, 1, 15, 3, 1, 1, 2, 1, 2, 1, 5, 2,…
## $ lat             <dbl> 50.09798, 50.09798, 50.09798, 50.09798, 50.09798…
## $ lng             <dbl> 1.718410, 1.718410, 1.718410, 1.718410, 1.718410…
## $ obsValid        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, …
## $ obsReviewed     <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,…
## $ locationPrivate <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, …
```

`rebird` **knows where you are**:


```r
ebirdgeo(key = getOption("EBIRD_KEY")) %>%
  as_tibble()
```

```
## Warning: As a complete lat/long pair was not provided, your location was
## determined using your computer's public-facing IP address. This will likely
## not reflect your physical location if you are using a remote server or
## proxy.
```

```
## # A tibble: 133 x 12
##    speciesCode comName sciName locId locName obsDt howMany   lat   lng
##    <chr>       <chr>   <chr>   <chr> <chr>   <chr>   <int> <dbl> <dbl>
##  1 cangoo      Canada… Branta… L694… Lake i… 2019…       8  41.7 -88.0
##  2 wooduc      Wood D… Aix sp… L694… Lake i… 2019…       7  41.7 -88.0
##  3 mallar3     Mallard Anas p… L694… Lake i… 2019…       6  41.7 -88.0
##  4 moudov      Mourni… Zenaid… L694… Lake i… 2019…       2  41.7 -88.0
##  5 whbnut      White-… Sitta … L694… Lake i… 2019…       1  41.7 -88.0
##  6 amerob      Americ… Turdus… L694… Lake i… 2019…       6  41.7 -88.0
##  7 houfin      House … Haemor… L694… Lake i… 2019…       4  41.7 -88.0
##  8 amegfi      Americ… Spinus… L694… Lake i… 2019…       1  41.7 -88.0
##  9 rewbla      Red-wi… Agelai… L694… Lake i… 2019…      15  41.7 -88.0
## 10 rusbla      Rusty … Euphag… L694… Lake i… 2019…       2  41.7 -88.0
## # … with 123 more rows, and 3 more variables: obsValid <lgl>,
## #   obsReviewed <lgl>, locationPrivate <lgl>
```

## Searching geographic info: `geonames`


```r
# install.packages(geonames)
library(geonames)
```

## API authentication

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

> Note: you need to have the [`here`](https://cran.r-project.org/web/packages/here/index.html) package installed for that code to work.

This will create a special file called `.Rprofile` in the same directory as your `.Rproj` file (assuming you are working in an R project). The file should open automatically in your RStudio script editor. Add

``` r 
options(geonamesUsername = "my_user_name")
``` 

to that file, replacing `my_user_name` with your Geonames username.

### Important

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

## Using Geonames

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
## Observations: 250
## Variables: 17
## $ continent     <chr> "EU", "AS", "AS", "NA", "NA", "EU", "AS", "AF", "A…
## $ capital       <chr> "Andorra la Vella", "Abu Dhabi", "Kabul", "Saint J…
## $ languages     <chr> "ca", "ar-AE,fa,en,hi,ur", "fa-AF,ps,uz-AF,tk", "e…
## $ geonameId     <chr> "3041565", "290557", "1149361", "3576396", "357351…
## $ south         <chr> "42.428743001", "22.631513764", "29.3770645357176"…
## $ isoAlpha3     <chr> "AND", "ARE", "AFG", "ATG", "AIA", "ALB", "ARM", "…
## $ north         <chr> "42.655765", "26.0693916660001", "38.4907920755748…
## $ fipsCode      <chr> "AN", "AE", "AF", "AC", "AV", "AL", "AM", "AO", "A…
## $ population    <chr> "84000", "4975593", "29121286", "86754", "13254", …
## $ east          <chr> "1.78657600000003", "56.381564568", "74.8894511481…
## $ isoNumeric    <chr> "020", "784", "004", "028", "660", "008", "051", "…
## $ areaInSqKm    <chr> "468.0", "82880.0", "647500.0", "443.0", "102.0", …
## $ countryCode   <chr> "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "A…
## $ west          <chr> "1.41376000100007", "51.572410727", "60.4720833972…
## $ countryName   <chr> "Principality of Andorra", "United Arab Emirates",…
## $ continentName <chr> "Europe", "Asia", "Asia", "North America", "North …
## $ currencyCode  <chr> "EUR", "AED", "AFN", "XCD", "XCD", "ALL", "AMD", "…
```

This country info dataset is very helpful for accessing the rest of the data, because it gives us the standardized codes for country and language.  

## The Manifesto Project: `manifestoR`

[The Manifesto Project](https://manifesto-project.wzb.eu/) collects and organizes political party manifestos from around the world. It currently covers over 1000 parties from 1945 until today in over 50 countries on five continents. We can use the [`manifestoR` package](https://github.com/ManifestoProject/manifestoR) to access the API and download those manifestos for analysis in R.

## Load library and set API key

Accessing data from the Manifesto Project API requires an authentication key. You can create an account and key [here](https://manifesto-project.wzb.eu/signup). Here I store my key in `.Rprofile` and retrieve it using `mp_setapikey()`.


```r
library(manifestoR)

# retrieve API key stored in .Rprofile
mp_setapikey(key = getOption("manifesto_key"))
```

## Retrieve the database


```r
(mpds <- mp_maindataset())
```

```
## Connecting to Manifesto Project DB API... 
## Connecting to Manifesto Project DB API... corpus version: 2018-2
```

```
## # A tibble: 4,388 x 174
##    country countryname oecdmember eumember edate        date party
##      <dbl> <chr>            <dbl>    <dbl> <date>      <dbl> <dbl>
##  1      11 Sweden               0        0 1944-09-17 194409 11220
##  2      11 Sweden               0        0 1944-09-17 194409 11320
##  3      11 Sweden               0        0 1944-09-17 194409 11420
##  4      11 Sweden               0        0 1944-09-17 194409 11620
##  5      11 Sweden               0        0 1944-09-17 194409 11810
##  6      11 Sweden               0        0 1948-09-19 194809 11220
##  7      11 Sweden               0        0 1948-09-19 194809 11320
##  8      11 Sweden               0        0 1948-09-19 194809 11420
##  9      11 Sweden               0        0 1948-09-19 194809 11620
## 10      11 Sweden               0        0 1948-09-19 194809 11810
## # … with 4,378 more rows, and 167 more variables: partyname <chr>,
## #   partyabbrev <chr>, parfam <dbl>, coderid <dbl>, manual <dbl>,
## #   coderyear <dbl>, testresult <dbl>, testeditsim <dbl>, pervote <dbl>,
## #   voteest <dbl>, presvote <dbl>, absseat <dbl>, totseats <dbl>,
## #   progtype <dbl>, datasetorigin <dbl>, corpusversion <chr>, total <dbl>,
## #   peruncod <dbl>, per101 <dbl>, per102 <dbl>, per103 <dbl>,
## #   per104 <dbl>, per105 <dbl>, per106 <dbl>, per107 <dbl>, per108 <dbl>,
## #   per109 <dbl>, per110 <dbl>, per201 <dbl>, per202 <dbl>, per203 <dbl>,
## #   per204 <dbl>, per301 <dbl>, per302 <dbl>, per303 <dbl>, per304 <dbl>,
## #   per305 <dbl>, per401 <dbl>, per402 <dbl>, per403 <dbl>, per404 <dbl>,
## #   per405 <dbl>, per406 <dbl>, per407 <dbl>, per408 <dbl>, per409 <dbl>,
## #   per410 <dbl>, per411 <dbl>, per412 <dbl>, per413 <dbl>, per414 <dbl>,
## #   per415 <dbl>, per416 <dbl>, per501 <dbl>, per502 <dbl>, per503 <dbl>,
## #   per504 <dbl>, per505 <dbl>, per506 <dbl>, per507 <dbl>, per601 <dbl>,
## #   per602 <dbl>, per603 <dbl>, per604 <dbl>, per605 <dbl>, per606 <dbl>,
## #   per607 <dbl>, per608 <dbl>, per701 <dbl>, per702 <dbl>, per703 <dbl>,
## #   per704 <dbl>, per705 <dbl>, per706 <dbl>, per1011 <dbl>,
## #   per1012 <dbl>, per1013 <dbl>, per1014 <dbl>, per1015 <dbl>,
## #   per1016 <dbl>, per1021 <dbl>, per1022 <dbl>, per1023 <dbl>,
## #   per1024 <dbl>, per1025 <dbl>, per1026 <dbl>, per1031 <dbl>,
## #   per1032 <dbl>, per1033 <dbl>, per2021 <dbl>, per2022 <dbl>,
## #   per2023 <dbl>, per2031 <dbl>, per2032 <dbl>, per2033 <dbl>,
## #   per2041 <dbl>, per3011 <dbl>, per3051 <dbl>, per3052 <dbl>,
## #   per3053 <dbl>, …
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

<img src="/notes/application-program-interface_files/figure-html/manifesto-dist-1.png" width="672" />

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

<img src="/notes/application-program-interface_files/figure-html/manifestor-usa-1.png" width="672" />

## Download manifestos

`mp_corpus()` can be used to download the original manifestos as full text documents stored as a [**corpus**](/notes/text-analysis-workflow/#extract-documents-and-move-into-a-corpus). Once you obtain the corpus, you can perform [text analysis](/notes/text-analysis-workflow/). As an example, let's compare the most common words in the Democratic and Republican Party manifestos from the 2012 U.S. presidential election:


```r
# download documents
(docs <- mp_corpus(countryname == "United States" & edate > as.Date("2012-01-01")))
```

```
## Connecting to Manifesto Project DB API... 
## Connecting to Manifesto Project DB API... corpus version: 2018-2 
## Connecting to Manifesto Project DB API... 
## Connecting to Manifesto Project DB API... corpus version: 2018-2 
## Connecting to Manifesto Project DB API... corpus version: 2018-2 
## Connecting to Manifesto Project DB API... corpus version: 2018-2
```

```
## <<ManifestoCorpus>>
## Metadata:  corpus specific: 0, document level (indexed): 0
## Content:  documents: 4
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

<img src="/notes/application-program-interface_files/figure-html/manifestor-corpus-1.png" width="672" />

## Census data with `tidycensus`

[`tidycensus`](https://walkerke.github.io/tidycensus/index.html) provides an interface with the US Census Bureau's decennial census and American Community APIs and returns tidy data frames with optional simple feature geometry. These APIs require a free key you can obtain [here](https://api.census.gov/data/key_signup.html). Rather than storing your key in `.Rprofile`, `tidycensus` includes `census_api_key()` which automatically stores your key in `.Renviron`, which is basically a global version of `.Rprofile`. Anything stored in `.Renviron` is automatically loaded anytime you initiate R on your computer, regardless of the project or file location. Once you get your key, load it:


```r
library(tidycensus)
```

```r
census_api_key("YOUR API KEY GOES HERE", install = TRUE)
```

## Obtaining data

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
  coord_flip()
```

<img src="/notes/application-program-interface_files/figure-html/plot-asia-1.png" width="672" />

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
  coord_flip()
```

<img src="/notes/application-program-interface_files/figure-html/asia-total-pop-1.png" width="672" />

`get_acs()` retrieves data from the American Community Survey. This survey is administered to a sample of 3 million households on an annual basis, so the data points are estimates characterized by a margin of error. `tidycensus` returns both the original estimate and margin of error. Let's get median household income data from the 2012-2016 ACS for counties in Illinois.


```r
usa_inc <- get_acs(geography = "state", 
                   variables = c(medincome = "B19013_001"), 
                   year = 2016)
```

```
## Getting data from the 2012-2016 5-year ACS
```

```r
usa_inc
```

```
## # A tibble: 52 x 5
##    GEOID NAME                 variable  estimate   moe
##    <chr> <chr>                <chr>        <dbl> <dbl>
##  1 01    Alabama              medincome    44758   314
##  2 02    Alaska               medincome    74444   809
##  3 04    Arizona              medincome    51340   231
##  4 05    Arkansas             medincome    42336   234
##  5 06    California           medincome    63783   188
##  6 08    Colorado             medincome    62520   287
##  7 09    Connecticut          medincome    71755   473
##  8 10    Delaware             medincome    61017   723
##  9 11    District of Columbia medincome    72935  1164
## 10 12    Florida              medincome    48900   200
## # … with 42 more rows
```

Now we return both an `estimate` column for the ACS estimate and `moe` for the margin of error (defaults to 90% confidence interval).


```r
usa_inc %>%
  ggplot(aes(x = reorder(NAME, estimate), y = estimate)) +
  geom_pointrange(aes(ymin = estimate - moe,
                     ymax = estimate + moe),
                  size = .25) +
  coord_flip() +
  labs(title = "Household income by state",
       subtitle = "2012-2016 American Community Survey",
       x = "",
       y = "ACS estimate (bars represent margin of error)")
```

<img src="/notes/application-program-interface_files/figure-html/income-usa-plot-1.png" width="672" />

## Search for variables

`get_acs()` or `get_decennial()` requires knowing the variable ID, of which there are thousands. `load_variables()` downloads a list of variable IDs and labels for a given Census or ACS and dataset. You can then use `View()` to interactively browse through and filter for variables in RStudio.

## Drawing maps

`tidycensus` also can return [simple feature geometry](/notes/simple-features/) for geographic units along with variables from the decennial Census or ACS, which can then be [visualized using `geom_sf()`.](/notes/vector-maps/) Let's look at median household income by Census tracts from the 2012-2016 ACS in Loudoun County, Virginia:


```r
loudoun <- get_acs(state = "VA",
                   county = "Loudoun",
                   geography = "tract", 
                   variables = c(medincome = "B19013_001"), 
                   year = 2016,
                   geometry = TRUE)
```


```r
loudoun
```

```
## Simple feature collection with 65 features and 5 fields
## geometry type:  MULTIPOLYGON
## dimension:      XY
## bbox:           xmin: -77.96196 ymin: 38.84645 xmax: -77.32828 ymax: 39.32419
## epsg (SRID):    4269
## proj4string:    +proj=longlat +datum=NAD83 +no_defs
## First 10 features:
##          GEOID                                           NAME  variable
## 1  51107610101 Census Tract 6101.01, Loudoun County, Virginia medincome
## 2  51107610102 Census Tract 6101.02, Loudoun County, Virginia medincome
## 3  51107610201 Census Tract 6102.01, Loudoun County, Virginia medincome
## 4  51107610202 Census Tract 6102.02, Loudoun County, Virginia medincome
## 5  51107610300    Census Tract 6103, Loudoun County, Virginia medincome
## 6  51107610400    Census Tract 6104, Loudoun County, Virginia medincome
## 7  51107610503 Census Tract 6105.03, Loudoun County, Virginia medincome
## 8  51107610504 Census Tract 6105.04, Loudoun County, Virginia medincome
## 9  51107610505 Census Tract 6105.05, Loudoun County, Virginia medincome
## 10 51107610506 Census Tract 6105.06, Loudoun County, Virginia medincome
##    estimate   moe                       geometry
## 1    132833 19347 MULTIPOLYGON (((-77.76219 3...
## 2    124659 16679 MULTIPOLYGON (((-77.66133 3...
## 3    141250  6709 MULTIPOLYGON (((-77.79794 3...
## 4    140481 10796 MULTIPOLYGON (((-77.84565 3...
## 5    148583  9368 MULTIPOLYGON (((-77.65754 3...
## 6    128657  9107 MULTIPOLYGON (((-77.60321 3...
## 7    150982  6323 MULTIPOLYGON (((-77.54714 3...
## 8    108042  4652 MULTIPOLYGON (((-77.56114 3...
## 9     45226  7533 MULTIPOLYGON (((-77.56454 3...
## 10   118750 17032 MULTIPOLYGON (((-77.5484 39...
```

This looks similar to the previous output but because we set `geometry = TRUE` it is now a simple features data frame with a `geometry` column defining the geographic feature. We can visualize it using `geom_sf()` and `viridis::scale_*_viridis()` to adjust the color palette.


```r
ggplot(data = loudoun) +
  geom_sf(aes(fill = estimate, color = estimate)) + 
  coord_sf(crs = 26911) + 
  scale_fill_viridis(option = "magma") + 
  scale_color_viridis(option = "magma")
```

<img src="/notes/application-program-interface_files/figure-html/loudoun-sf-plot-1.png" width="672" />

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).

## Session Info



```r
devtools::session_info()
```

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
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports      1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  base64enc      0.1-3   2015-07-28 [1] CRAN (R 3.6.0)
##  blogdown       0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown       0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom        * 0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr          3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli            1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace     1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc           1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools       2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest         0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr        * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  DT             0.8     2019-08-07 [1] CRAN (R 3.6.0)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats      * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  foreign        0.8-72  2019-08-02 [1] CRAN (R 3.6.0)
##  fs             1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  functional     0.6     2014-07-16 [1] CRAN (R 3.6.0)
##  generics       0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2      * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue           1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gridExtra      2.3     2017-09-09 [1] CRAN (R 3.6.0)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven          2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here           0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms            0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools      0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  htmlwidgets    1.3     2018-09-30 [1] CRAN (R 3.6.0)
##  httr           1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  janeaustenr    0.1.5   2017-06-10 [1] CRAN (R 3.6.0)
##  jsonlite       1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr          1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice        0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval       0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate      1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr       1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  manifestoR   * 1.3.0   2018-05-28 [1] CRAN (R 3.6.0)
##  Matrix         1.2-17  2019-03-22 [1] CRAN (R 3.6.0)
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  mnormt         1.5-5   2016-10-15 [1] CRAN (R 3.6.0)
##  modelr         0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme           3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  NLP          * 0.2-0   2018-10-18 [1] CRAN (R 3.6.0)
##  pillar         1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild       1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
##  pkgconfig      2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
##  pkgload        1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
##  prettyunits    1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
##  processx       3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
##  ps             1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
##  psych          1.8.12  2019-01-12 [1] CRAN (R 3.6.0)
##  purrr        * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
##  R6             2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
##  RColorBrewer * 1.1-2   2014-12-07 [1] CRAN (R 3.6.0)
##  Rcpp           1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
##  readr        * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 3.6.0)
##  remotes        2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
##  rlang          0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
##  rmarkdown      1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot      1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi     0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest          0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales         1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  slam           0.1-45  2019-02-26 [1] CRAN (R 3.6.0)
##  SnowballC      0.6.0   2019-01-15 [1] CRAN (R 3.6.0)
##  stringi        1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat       2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble       * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr        * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect     0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidytext     * 0.2.2   2019-07-29 [1] CRAN (R 3.6.0)
##  tidyverse    * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  tm           * 0.7-6   2018-12-21 [1] CRAN (R 3.6.0)
##  tokenizers     0.2.1   2018-03-29 [1] CRAN (R 3.6.0)
##  usethis        1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs          0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  viridis      * 0.5.1   2018-03-29 [1] CRAN (R 3.6.0)
##  viridisLite  * 0.3.0   2018-02-01 [1] CRAN (R 3.6.0)
##  withr          2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  wordcloud    * 2.6     2018-08-24 [1] CRAN (R 3.6.0)
##  xfun           0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2           1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml           2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot        0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
##  zoo            1.8-6   2019-05-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
