---
title: "Scraping web pages"
date: 2019-03-01

type: book
toc: true
draft: false
aliases: ["/webdata005_scraping.html", "/notes/web-scraping/"]
categories: ["webdata"]

weight: 65
---




```r
library(tidyverse)
library(rvest)
library(lubridate)

theme_set(theme_minimal())
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("cis-ds/getting-data-from-the-web-scraping")
```

{{% /callout %}}

What if data is present on a website, but isn't provided in an API at all? It is possible to grab that information too. How easy that is to do depends a lot on the quality of the website that we are using.

## HTML

HTML is a structured way of displaying information. It is very similar in structure to XML (in fact many modern html sites are actually XHTML5, [which is also valid XML](http://www.w3.org/TR/html5/the-xhtml-syntax.html))

{{< figure src="https://imgs.xkcd.com/comics/tags.png" caption="[tags](https://xkcd.com/1144/)" >}}

## Process

**HyperText Markup Language** (HTML) is the basic building block of the World Wide Web. It defines the structure and format of content on web pages. The HTML code is stored on a server and retrieved by your computer when you visit a web page.

1. The web browser sends a request to the server that hosts the website.
1. The server sends the browser an HTML document.
1. The browser uses instructions in the HTML to render the website.

## Components of HTML code

HTML code looks something like this:

```html
<html>
  <head>
    <title>Title</title>
    <link rel="icon" type="icon" href="http://a" />
    <link rel="icon" type="icon" href="http://b" />
    <script src="https://c.js"></script>
  </head>
  <body>
    <div>
      <p>Click <b>here</b> now.</p>
      <span>Frozen</span>
    </div>
    <table style="width:100%">
      <tr>
        <td>Kristen</td>
        <td>Bell</td>
      </tr>
      <tr>
        <td>Idina</td>
        <td>Menzel</td>
      </tr>
    </table>
  <img src="http://ia.media-imdb.com/images.png"/>
  </body>
</html>
```

HTML code consists of **markup** code used to annotate text, images, and other content for display in a web browswer. As you can see, the code above consists of HTML **elements** which are created by a tag `<>`. Elements can also have **attributes** that configure the elements or adjust their behavior.

{{% callout note %}}

You can think of elements as R functions, and attributes are the arguments to functions. Not all functions require arguments, or they use default arguments.

{{% /callout %}}

```html
<a href="http://github.com">GitHub</a>
```

* `<a></a>` - tag name
* `href` - attribute (argument)
* `"http://github.com"` - attribute (value)
* `GitHub` - content

HTML code utilizes a nested structure. The above tags can be represented as:

* `html`
    * `head`
        * `title`
        * `link`
        * `link`
        * `script`
    * `body`
        * `div`
            * `p`
                * `b`
            * `span`
        * `table`
            * `tr`
                * `td`
                * `td`
            * `tr`
                * `td`
                * `td`
        * `img`

Let's say we want to find the content "here". Which tag in our sample HTML code contains that content?

* `html`
    * `head`
        * `title`
        * `link`
        * `link`
        * `script`
    * `body`
        * `div`
            * `p`
                * <span style="color:red">**`b`**</span>
            * `span`
        * `table`
            * `tr`
                * `td`
                * `td`
            * `tr`
                * `td`
                * `td`
        * `img`

## CSS selectors

**Cascading Style Sheets** (CSS) are a flexible framework for customizing the appearance of elements in a web page. They work in conjunction with HTML to format the appearance of content on the web.

##### HTML

{{< figure src="shiny-css-none.png" caption="HTML only" >}}

##### HTML + CSS

{{< figure src="shiny-css.png" caption="HTML + CSS" >}}

## CSS code

```css
span {
  color: #ffffff;
}

.num {
  color: #a8660d;
}

table.data {
  width: auto;
}

#firstname {
  background-color: yellow;
}
```

CSS uses **selectors**  and **styles**. Selectors define to which elements of the HTML code the styles apply. A CSS script describes an element by its **tag**, **class**, and/or **ID**. Class and ID are defined in the HTML code as attributes of the element.

```html
<span class="bigname" id="shiny">Shiny</span>
```

* `<span></span>` - tag name
* `bigname` - class (optional)
* `shiny` - id (optional)

So a CSS selector of

```css
span
```

would select all elements with the `span` tag. Likewise, a CSS selector of

```css
.bigname
```

selects all elements with the `bigname` class (note the use of a `.` to select based on class). A CSS selector of

```css
span.bigname
```

selects all elements with the `span` tag **and** the `bigname` class. Finally,

```css
#shiny
```

selects all elements with the `shiny` id.

Prefix | Matches
-------|--------
none   | tag
.      | class
#      | id

{{% callout note %}}

[CSS diner](http://flukeout.github.io) is a JavaScript-based interactive game for learning and practicing CSS selectors. Take some time to play and learn more about CSS selector combinations.

{{% /callout %}}

## Find the CSS selector

```html
<body>
    <table id="content">
        <tr class='name'>
            <td class='firstname'>
                Kurtis
            </td>
            <td class='lastname'>
                McCoy
            </td>
        </tr>
        <tr class='name'>
            <td class='firstname'>
                Leah
            </td>
            <td class='lastname'>
                Guerrero
            </td>
        </tr>
    </table>
</body>
```

Find the CSS selectors for the following elements in the HTML above:

1. The entire table.
1. Just the element containing first names.

(Hint: There will be multiple solutions for each.)

{{< spoiler text="Click for the solution" >}}

1. Options include

    ```css
    table
    #content
    table#content
    ```
1. Options include

    ```css
    .firstname
    td.firstname
    .name .firstname
    tr .firstname
    ```
    
{{< /spoiler >}}

## Scraping presidential statements

To demonstrate webscraping in R, we are going to collect records on presidential statements from [The American Presidency Project](https://www.presidency.ucsb.edu/).

Let's say we are interested in how presidents speak about "space exploration." On the website, we punch in this search term, and we get the [following 346 results](https://www.presidency.ucsb.edu/advanced-search?field-keywords=%22space+exploration%22&field-keywords2=&field-keywords3=&from%5Bdate%5D=&to%5Bdate%5D=&person2=&items_per_page=100).[^count]

Our goal is to scrape these records and store pertinent information in a data frame. We will be doing this in two steps:

1. Write a function to scrape each individual record page.
2. Use this function to loop through all results, and collect all pages.

Load the following packages to get started:

```r
library(tidyverse)
library(rvest)
library(lubridate)
```

### Using `rvest` to read HTML

The package [`rvest`](https://rvest.tidyverse.org/) allows us to:

1. Collect the HTML source code of a webpage.
2. Read the HTML of the page.
3. Select and keep certain elements of the page that are of interest.

Let's start with step one. We use the `read_html` function to call the results URL and grab the HTML response. Store this result as an object.


```r
dwight <- read_html(x = "https://www.presidency.ucsb.edu/documents/special-message-the-congress-relative-space-science-and-exploration")

# Let's take a look at the object we just created
dwight
```

```
## {html_document}
## <html lang="en" dir="ltr" prefix="content: http://purl.org/rss/1.0/modules/content/ dc: http://purl.org/dc/terms/ foaf: http://xmlns.com/foaf/0.1/ og: http://ogp.me/ns# rdfs: http://www.w3.org/2000/01/rdf-schema# sioc: http://rdfs.org/sioc/ns# sioct: http://rdfs.org/sioc/types# skos: http://www.w3.org/2004/02/skos/core# xsd: http://www.w3.org/2001/XMLSchema#">
## [1] <head profile="http://www.w3.org/1999/xhtml/vocab">\n<meta charset="utf-8 ...
## [2] <body class="html not-front not-logged-in one-sidebar sidebar-first page- ...
```

This is pretty messy. We need to use `rvest` to make this information more usable.

### Find page elements

`rvest` has a number of functions to find information on a page. Like other webscraping tools, `rvest` lets you find elements by their:

1. HTML tags.
1. HTML attributes.
1. CSS selectors.

Let's search first for HTML tags.

The function `html_elements` searches a parsed HTML object to find all the elements with a particular HTML tag, and returns all of those elements.

What does the example below do?


```r
html_elements(x = dwight, css = "a")
```

```
## {xml_nodeset (72)}
##  [1] <a href="#main-content" class="element-invisible element-focusable">Skip ...
##  [2] <a href="https://www.presidency.ucsb.edu/">The American Presidency Proje ...
##  [3] <a class="btn btn-default" href="https://www.presidency.ucsb.edu/about"> ...
##  [4] <a class="btn btn-default" href="/advanced-search"><span class="glyphico ...
##  [5] <a href="https://www.ucsb.edu/" target="_blank"><img alt="ucsb wordmark  ...
##  [6] <a href="/documents" class="active-trail dropdown-toggle" data-toggle="d ...
##  [7] <a href="/documents/presidential-documents-archive-guidebook">Guidebook</a>
##  [8] <a href="/documents/category-attributes">Category Attributes</a>
##  [9] <a href="/statistics">Statistics</a>
## [10] <a href="/media" title="">Media Archive</a>
## [11] <a href="/presidents" title="">Presidents</a>
## [12] <a href="/analyses" title="">Analyses</a>
## [13] <a href="https://giving.ucsb.edu/Funds/Give?id=185" title="">GIVE</a>
## [14] <a href="/documents/presidential-documents-archive-guidebook" title="">A ...
## [15] <a href="/documents" title="" class="active-trail">Categories</a>
## [16] <a href="/documents/category-attributes" title="">Attributes</a>
## [17] <a href="/documents/app-categories/presidential" title="Presidential (73 ...
## [18] <a href="/documents/app-categories/spoken-addresses-and-remarks/presiden ...
## [19] <a href="/documents/app-categories/spoken-addresses-and-remarks/presiden ...
## [20] <a href="/documents/app-categories/written-presidential-orders/president ...
## ...
```

That is a lot of results! Many elements on a page will have the same HTML tag. For instance, if you search for everything with the `a` tag, you are likely to get a lot of stuff, much of which you do not want. 

In our case, we only want the links corresponding to the speaker Dwight D. Eisenhower.

{{< figure src="scraping-links.png" caption="Special Message to the Congress Relative to Space Science and Exploration." >}}

### SelectorGadget

**SelectorGadget** is a GUI tool used to identify CSS selector combinations from a webpage.

#### Install SelectorGadget

1. Read [here](https://rvest.tidyverse.org/articles/articles/selectorgadget.html)
1. Drag **SelectorGadget** link into your browser's bookmark bar

#### Using SelectorGadget

1. Navigate to a webpage
1. Open the SelectorGadget bookmark
1. Click on the item to scrape
1. Click on yellow items you do not want to scrape
1. Click on additional items that you do want to scrape
1. Rinse and repeat until only the items you want to scrape are highlighted in yellow
1. Copy the selector to use with `html_elements()`

{{% callout note %}}

When using SelectorGadget, always make sure to scroll up and down the web page to make sure you have properly selected only the content you want.

{{% /callout %}}

#### Find the CSS selector

Use Selector Gadget to find the CSS selector for the document's *speaker*.

Then, modify an argument in `html_elements` to look for this more specific CSS selector.

{{< spoiler text="Click for the solution" >}}


```r
html_elements(x = dwight, css = ".diet-title a")
```

```
## {xml_nodeset (1)}
## [1] <a href="/people/president/dwight-d-eisenhower">Dwight D. Eisenhower</a>
```

{{< /spoiler >}}

### Get attributes and text of elements

Once we identify elements, we want to access information in those elements. Oftentimes this means two things:

1. Text
1. Attributes

Getting the text inside an element is pretty straightforward. We can use the `html_text2()` command inside of `rvest` to get the text of an element:


```r
# identify element with speaker name
speaker <- html_elements(dwight, ".diet-title a") %>% 
  html_text2() # Select text of element

speaker
```

```
## [1] "Dwight D. Eisenhower"
```

You can access a tag's attributes using `html_attr`. For example, we often want to get a URL from an `a` (link) element. This is the URL the link "points" to. It is contained in the attribute `href`:


```r
speaker_link <- html_elements(dwight, ".diet-title a") %>% 
  html_attr("href")

speaker_link
```

```
## [1] "/people/president/dwight-d-eisenhower"
```

### Let's do this!

Believe it or not, that is all you need to scrape a website. Let's apply those skills to scrape a sample document from the UCSB website -- the [first item in our search results](https://www.presidency.ucsb.edu/documents/special-message-the-congress-relative-space-science-and-exploration). 

We will collect the document's date, speaker, title, and full text.

**Think**: Why are we doing through all this effort to scrape just one page?

1. Date

    
    ```r
    date <- html_elements(x = dwight, css = ".date-display-single") %>%
      html_text2() %>% # Grab element text
      mdy() # Format using lubridate
    date
    ```
    
    ```
    ## [1] "1958-04-02"
    ```

1. Speaker

    
    ```r
    speaker <- html_elements(x = dwight, css = ".diet-title a") %>%
      html_text2()
    speaker
    ```
    
    ```
    ## [1] "Dwight D. Eisenhower"
    ```
    
1. Title

    
    ```r
    title <- html_elements(x = dwight, css = "h1") %>%
      html_text2()
    title
    ```
    
    ```
    ## [1] "Special Message to the Congress Relative to Space Science and Exploration."
    ```

1. Text

    
    ```r
    text <- html_elements(x = dwight, css = "div.field-docs-content") %>%
      html_text2()
    
    # This is a long document, so let's just display the first 1,000 characters
    text %>% str_sub(1, 1000) 
    ```
    
    ```
    ## [1] "To the Congress of the United States:\n\nRecent developments in long-range rockets for military purposes have for the first time provided man with new machinery so powerful that it can put satellites into orbit, and eventually provide the means for space exploration. The United States of America and the Union of Soviet Socialist Republics have already successfully placed in orbit a number of earth satellites. In fact, it is now within the means of any technologically advanced nation to embark upon practicable programs for exploring outer space. The early enactment of appropriate legislation will help assure that the United States takes full advantage of the knowledge of its scientists, the skill of its engineers and technicians, and the resourcefulness of its industry in meeting the challenges of the space age.\n\nDuring the past several months my Special Assistant for Science and Technology and the President's Science Advisory Committee, of which he is the Chairman, have been conducting a"
    ```
    
#### Make a function

Make a function called `scrape_docs` that accepts a URL of an individual document, scrapes the page, and returns a data frame containing the document's date, speaker, title, and full text.

This involves:

- Requesting the HTML of the webpage using the full URL and `rvest`
- Using `rvest` to locate all elements on the page we want to save
- Storing each of those items into a data frame
- Returning that data frame

```r
scrape_doc <- function(url){

  # YOUR CODE HERE
  
}

# Uncomment to test
# scrape_doc("https://www.presidency.ucsb.edu/documents/letter-t-keith-glennan-administrator-national-aeronautics-and-space-administration")
```

{{< spoiler text="Click for the solution" >}}


```r
scrape_doc <- function(url){
  # get HTML page
  url_contents <- read_html(x = url)
  
  # extract elements we want
  date <- html_elements(x = url_contents, css = ".date-display-single") %>%
    html_text2() %>% # Grab element text
    mdy() # Format using lubridate
  
  speaker <- html_elements(x = url_contents, css = ".diet-title a") %>%
    html_text2()
  
  title <- html_elements(x = url_contents, css = "h1") %>%
    html_text2()
  
  text <- html_elements(x = url_contents, css = "div.field-docs-content") %>%
    html_text2()
  
  # store in a data frame
  url_data <- tibble(
    date = date,
    speaker = speaker,
    title = title,
    text = text
  )
  
  # return the data frame
  return(url_data)
}

scrape_doc("https://www.presidency.ucsb.edu/documents/letter-t-keith-glennan-administrator-national-aeronautics-and-space-administration")
```

```
## # A tibble: 1 × 4
##   date       speaker              title                                    text 
##   <date>     <chr>                <chr>                                    <chr>
## 1 1959-03-03 Dwight D. Eisenhower Letter to T. Keith Glennan, Administrat… "Dea…
```

{{< /spoiler >}}

## Scrape cost of living data

Look up the cost of living for your hometown on [Sperling's Best Places](http://www.bestplaces.net/). Then extract it with `html_elements()` and `html_text()`.

{{< spoiler text="Click for the solution" >}}

For me, this means I need to obtain information on [Sterling, Virginia](http://www.bestplaces.net/cost_of_living/city/virginia/sterling).


```r
sterling <- read_html("http://www.bestplaces.net/cost_of_living/city/virginia/sterling")

col <- html_elements(sterling, css = "#mainContent_dgCostOfLiving tr:nth-child(2) td:nth-child(2)")
html_text2(col)
```

```
## [1] "134.4"
```

```r
# or use a piped operation
sterling %>%
  html_elements(css = "#mainContent_dgCostOfLiving tr:nth-child(2) td:nth-child(2)") %>%
  html_text2()
```

```
## [1] "134.4"
```

{{< /spoiler >}}

## Tables

Use `html_table()` to scrape whole tables of data as a data frame.


```r
tables <- html_elements(sterling, css = "table")

tables %>%
  # get the first table
  nth(1) %>%
  # convert to data frame
  html_table(header = TRUE)
```

```
## # A tibble: 8 × 4
##   `COST OF LIVING` Sterling Virginia USA     
##   <chr>            <chr>    <chr>    <chr>   
## 1 Overall          134.4    103.7    100     
## 2 Grocery          110.3    99.6     100     
## 3 Health           99.3     102.4    100     
## 4 Housing          185.3    111.8    100     
## 5 Median Home Cost $519,800 $329,200 $291,700
## 6 Utilities        98.6     99.3     100     
## 7 Transportation   118.6    99.4     100     
## 8 Miscellaneous    118.2    100.5    100
```

## Extract climate statistics

Visit the climate tab for your home town. Extract the climate statistics of your hometown as a data frame with useful column names.

{{< spoiler text="Click for the solution" >}}

For me, this means I need to obtain information on [Sterling, Virginia](http://www.bestplaces.net/cost_of_living/city/virginia/sterling).


```r
sterling_climate <- read_html("http://www.bestplaces.net/climate/city/virginia/sterling")

climate <- html_elements(sterling_climate, css = "table")
html_table(climate, header = TRUE, fill = TRUE)[[1]]
```

```
## # A tibble: 9 × 3
##   ``                            `Sterling, Virginia` `United States`
##   <chr>                         <chr>                <chr>          
## 1 Rainfall                      42.0 in.             38.1 in.       
## 2 Snowfall                      21.5 in.             27.8 in.       
## 3 Precipitation                 116.2 days           106.2 days     
## 4 Sunny                         197 days             205 days       
## 5 Avg. July High                85.8°                85.8°          
## 6 Avg. Jan. Low                 23.5°                21.7°          
## 7 Comfort Index (higher=better) 7.3                  7              
## 8 UV Index                      4                    4.3            
## 9 Elevation                     292 ft.              2443 ft.
```

```r
sterling_climate %>%
  html_elements(css = "table") %>%
  nth(1) %>%
  html_table(header = TRUE)
```

```
## # A tibble: 9 × 3
##   ``                            `Sterling, Virginia` `United States`
##   <chr>                         <chr>                <chr>          
## 1 Rainfall                      42.0 in.             38.1 in.       
## 2 Snowfall                      21.5 in.             27.8 in.       
## 3 Precipitation                 116.2 days           106.2 days     
## 4 Sunny                         197 days             205 days       
## 5 Avg. July High                85.8°                85.8°          
## 6 Avg. Jan. Low                 23.5°                21.7°          
## 7 Comfort Index (higher=better) 7.3                  7              
## 8 UV Index                      4                    4.3            
## 9 Elevation                     292 ft.              2443 ft.
```

{{< /spoiler >}}

## Acknowledgments

* Scraping presidential statements drawn from [PLSC 31101: Computational Tools for Social Science](https://plsc-31101.github.io/course/collecting-data-from-the-web.html#webscraping)
* [HTML| Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/HTML)
* [CSS | Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/CSS)

## Session Info



```r
sessioninfo::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.2.1 (2022-06-23)
##  os       macOS Monterey 12.3
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/New_York
##  date     2022-08-22
##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  assertthat      0.2.1      2019-03-21 [2] CRAN (R 4.2.0)
##  backports       1.4.1      2021-12-13 [2] CRAN (R 4.2.0)
##  blogdown        1.10       2022-05-10 [2] CRAN (R 4.2.0)
##  bookdown        0.27       2022-06-14 [2] CRAN (R 4.2.0)
##  broom           1.0.0      2022-07-01 [2] CRAN (R 4.2.0)
##  bslib           0.4.0      2022-07-16 [2] CRAN (R 4.2.0)
##  cachem          1.0.6      2021-08-19 [2] CRAN (R 4.2.0)
##  cellranger      1.1.0      2016-07-27 [2] CRAN (R 4.2.0)
##  cli             3.3.0      2022-04-25 [2] CRAN (R 4.2.0)
##  colorspace      2.0-3      2022-02-21 [2] CRAN (R 4.2.0)
##  crayon          1.5.1      2022-03-26 [2] CRAN (R 4.2.0)
##  DBI             1.1.3      2022-06-18 [2] CRAN (R 4.2.0)
##  dbplyr          2.2.1      2022-06-27 [2] CRAN (R 4.2.0)
##  digest          0.6.29     2021-12-01 [2] CRAN (R 4.2.0)
##  dplyr         * 1.0.9      2022-04-28 [2] CRAN (R 4.2.0)
##  ellipsis        0.3.2      2021-04-29 [2] CRAN (R 4.2.0)
##  evaluate        0.16       2022-08-09 [1] CRAN (R 4.2.1)
##  fansi           1.0.3      2022-03-24 [2] CRAN (R 4.2.0)
##  fastmap         1.1.0      2021-01-25 [2] CRAN (R 4.2.0)
##  forcats       * 0.5.1      2021-01-27 [2] CRAN (R 4.2.0)
##  fs              1.5.2      2021-12-08 [2] CRAN (R 4.2.0)
##  gargle          1.2.0      2021-07-02 [2] CRAN (R 4.2.0)
##  generics        0.1.3      2022-07-05 [2] CRAN (R 4.2.0)
##  ggplot2       * 3.3.6      2022-05-03 [2] CRAN (R 4.2.0)
##  glue            1.6.2      2022-02-24 [2] CRAN (R 4.2.0)
##  googledrive     2.0.0      2021-07-08 [2] CRAN (R 4.2.0)
##  googlesheets4   1.0.0      2021-07-21 [2] CRAN (R 4.2.0)
##  gtable          0.3.0      2019-03-25 [2] CRAN (R 4.2.0)
##  haven           2.5.0      2022-04-15 [2] CRAN (R 4.2.0)
##  here            1.0.1      2020-12-13 [2] CRAN (R 4.2.0)
##  hms             1.1.1      2021-09-26 [2] CRAN (R 4.2.0)
##  htmltools       0.5.3      2022-07-18 [2] CRAN (R 4.2.0)
##  httr            1.4.3      2022-05-04 [2] CRAN (R 4.2.0)
##  jquerylib       0.1.4      2021-04-26 [2] CRAN (R 4.2.0)
##  jsonlite        1.8.0      2022-02-22 [2] CRAN (R 4.2.0)
##  knitr           1.39       2022-04-26 [2] CRAN (R 4.2.0)
##  lifecycle       1.0.1      2021-09-24 [2] CRAN (R 4.2.0)
##  lubridate     * 1.8.0      2021-10-07 [2] CRAN (R 4.2.0)
##  magrittr        2.0.3      2022-03-30 [2] CRAN (R 4.2.0)
##  modelr          0.1.8      2020-05-19 [2] CRAN (R 4.2.0)
##  munsell         0.5.0      2018-06-12 [2] CRAN (R 4.2.0)
##  pillar          1.8.0      2022-07-18 [2] CRAN (R 4.2.0)
##  pkgconfig       2.0.3      2019-09-22 [2] CRAN (R 4.2.0)
##  purrr         * 0.3.4      2020-04-17 [2] CRAN (R 4.2.0)
##  R6              2.5.1      2021-08-19 [2] CRAN (R 4.2.0)
##  readr         * 2.1.2      2022-01-30 [2] CRAN (R 4.2.0)
##  readxl          1.4.0      2022-03-28 [2] CRAN (R 4.2.0)
##  reprex          2.0.1.9000 2022-08-10 [1] Github (tidyverse/reprex@6d3ad07)
##  rlang           1.0.4      2022-07-12 [2] CRAN (R 4.2.0)
##  rmarkdown       2.14       2022-04-25 [2] CRAN (R 4.2.0)
##  rprojroot       2.0.3      2022-04-02 [2] CRAN (R 4.2.0)
##  rstudioapi      0.13       2020-11-12 [2] CRAN (R 4.2.0)
##  rvest         * 1.0.2      2021-10-16 [2] CRAN (R 4.2.0)
##  sass            0.4.2      2022-07-16 [2] CRAN (R 4.2.0)
##  scales          1.2.0      2022-04-13 [2] CRAN (R 4.2.0)
##  sessioninfo     1.2.2      2021-12-06 [2] CRAN (R 4.2.0)
##  stringi         1.7.8      2022-07-11 [2] CRAN (R 4.2.0)
##  stringr       * 1.4.0      2019-02-10 [2] CRAN (R 4.2.0)
##  tibble        * 3.1.8      2022-07-22 [2] CRAN (R 4.2.0)
##  tidyr         * 1.2.0      2022-02-01 [2] CRAN (R 4.2.0)
##  tidyselect      1.1.2      2022-02-21 [2] CRAN (R 4.2.0)
##  tidyverse     * 1.3.2      2022-07-18 [2] CRAN (R 4.2.0)
##  tzdb            0.3.0      2022-03-28 [2] CRAN (R 4.2.0)
##  utf8            1.2.2      2021-07-24 [2] CRAN (R 4.2.0)
##  vctrs           0.4.1      2022-04-13 [2] CRAN (R 4.2.0)
##  withr           2.5.0      2022-03-03 [2] CRAN (R 4.2.0)
##  xfun            0.31       2022-05-10 [1] CRAN (R 4.2.0)
##  xml2            1.3.3      2021-11-30 [2] CRAN (R 4.2.0)
##  yaml            2.3.5      2022-02-21 [2] CRAN (R 4.2.0)
## 
##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```

[^count]: 372 results as of July 13, 2021.
