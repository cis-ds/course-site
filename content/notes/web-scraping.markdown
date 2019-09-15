---
title: "Scraping web pages"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/webdata005_scraping.html"]
categories: ["webdata"]

menu:
  notes:
    parent: Getting data from the web
    weight: 5
---




```r
library(tidyverse)
library(rvest)

theme_set(theme_minimal())
```

What if data is present on a website, but isn't provided in an API at all? It is possible to grab that information too. How easy that is to do depends a lot on the quality of the website that we are using.

## HTML

HTML is a structured way of displaying information. It is very similar in structure to XML (in fact many modern html sites are actually XHTML5, [which is also valid XML](http://www.w3.org/TR/html5/the-xhtml-syntax.html))

![[tags](https://xkcd.com/1144/)](https://imgs.xkcd.com/comics/tags.png)

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

> You can think of elements as R functions, and attributes are the arguments to functions. Not all functions require arguments, or they use default arguments.

```html
<a href="http://github.com">GitHub</a>
```

* `<a></a>` - tag name
* `href` - attribute (name)
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

## Find the source code

Navigate to [the IMDB page for *Frozen*](http://www.imdb.com/title/tt2294629/) and open the source code. Locate the piece of HTML that inserts "Kristen Bell" into the cast section. Which HTML tag surrounds her name?

![IMDB page for *Frozen*](/img/frozen_bell.png)

<details> 
  <summary>Click for the solution</summary>
  <p>

![HTML tag for "Kristen Bell"](/img/frozen_span.png)

"Kristen Bell" is enclosed in the `span` tag. But look through the some of the other source code. `span` is used many times throughout the page. How can we select just the element containing "Kristen Bell", or all the cast member names but nothing else?
    
  </p>
</details>

## CSS selectors

**Cascading Style Sheets** (CSS) are a flexible framework for customizing the appearance of elements in a web page. They work in conjunction with HTML to format the appearance of content on the web.

##### HTML

![HTML only](/img/shiny-css-none.png)

##### HTML + CSS

![HTML + CSS](/img/shiny-css.png)

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

> [CSS diner](http://flukeout.github.io) is a JavaScript-based interactive game for learning and practicing CSS selectors. Take some time to play and learn more about CSS selector combinations.

## Find the CSS selector

Which CSS identifiers are associated with Kristen Bell's name in the *Frozen* page? Write a CSS selector that targets them.

![](/img/frozen_css.png)

<details> 
  <summary>Click for the solution</summary>
  <p>

* `span` - the element
* `itemprop` - the class

Therefore the CSS selector would be `span.itemprop`.
    
  </p>
</details>

## `rvest`

`rvest` is a package that contains functions to easily extract information from a webpage. The basic workflow is:

1. Download the HTML and turn it into an XML file with `read_html()`
1. Extract specific nodes with `html_nodes()`
1. Extract content from nodes with various functions

## Download the HTML


```r
library(rvest)
frozen <- read_html("http://www.imdb.com/title/tt2294629/")
frozen
```

```
## {xml_document}
## <html xmlns:og="http://ogp.me/ns#" xmlns:fb="http://www.facebook.com/2008/fbml">
## [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset= ...
## [2] <body id="styleguide-v2" class="fixed">\n\n            <img height=" ...
```

> It is always a good practice when web scraping to store the output of `read_html()` in an object immediately, then apply further functions to the stored HTML file. Otherwise you send a request to the server every time you extract information from the HTML. For longer-term projects, you can store `read_html()` objects locally on your computer using `readr::write_rds()` and retrieve them using `readr::read_rds()`. This caches a local copy of the file so you always have a copy preserved, in case the webpage's underlying HTML code is modified (or the website is taken offline).

## Extract nodes


```r
itals <- html_nodes(frozen, "em")
itals
```

```
## {xml_nodeset (1)}
## [1] <em class="nobr">Written by\n<a href="/search/title?plot_author=DeAl ...
```

* The first argument to `html_nodes()` is the HTML document or a node previously extracted from the document
* The second argument is a CSS selector to identify which nodes to select

## Extract content from nodes


```r
itals
```

```
## {xml_nodeset (1)}
## [1] <em class="nobr">Written by\n<a href="/search/title?plot_author=DeAl ...
```

```r
html_text(itals)
```

```
## [1] "Written by\nDeAlan Wilson for ComedyE.com"
```

```r
html_name(itals)
```

```
## [1] "em"
```

```r
html_children(itals)
```

```
## {xml_nodeset (1)}
## [1] <a href="/search/title?plot_author=DeAlan%20Wilson%20for%20ComedyE.c ...
```

```r
html_attr(itals, "class")
```

```
## [1] "nobr"
```

```r
html_attrs(itals)
```

```
## [[1]]
##  class 
## "nobr"
```

## Extract content

Now it's your turn to practice.

1. Read in the *Frozen* HTML
1. Select the nodes that are both `a`s and `id = "titleCast"`
1. Extract the text from the nodes

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
library(rvest)
frozen <- read_html("http://www.imdb.com/title/tt2294629/")
cast <- html_nodes(frozen, "#titleCast a")
html_text(cast)
```

```
##  [1] "Edit"                                                         
##  [2] ""                                                             
##  [3] " Kristen Bell\n"                                              
##  [4] "Anna"                                                         
##  [5] ""                                                             
##  [6] " Idina Menzel\n"                                              
##  [7] "Elsa"                                                         
##  [8] ""                                                             
##  [9] " Jonathan Groff\n"                                            
## [10] "Kristoff"                                                     
## [11] ""                                                             
## [12] " Josh Gad\n"                                                  
## [13] "Olaf"                                                         
## [14] ""                                                             
## [15] " Santino Fontana\n"                                           
## [16] "Hans"                                                         
## [17] ""                                                             
## [18] " Alan Tudyk\n"                                                
## [19] "Duke"                                                         
## [20] ""                                                             
## [21] " Ciarán Hinds\n"                                              
## [22] "Pabbie"                                                       
## [23] "Grandpa"                                                      
## [24] ""                                                             
## [25] " Chris Williams\n"                                            
## [26] "Oaken"                                                        
## [27] ""                                                             
## [28] " Stephen J. Anderson\n"                                       
## [29] ""                                                             
## [30] " Maia Wilson\n"                                               
## [31] "Bulda"                                                        
## [32] ""                                                             
## [33] " Edie McClurg\n"                                              
## [34] ""                                                             
## [35] " Robert Pine\n"                                               
## [36] ""                                                             
## [37] " Maurice LaMarche\n"                                          
## [38] "King"                                                         
## [39] ""                                                             
## [40] " Livvy Stubenrauch\n"                                         
## [41] "Young Anna"                                                   
## [42] ""                                                             
## [43] " Eva Bella\n"                                                 
## [44] "Young Elsa"                                                   
## [45] "See full cast"                                                
## [46] " \nView production, box office, & company info on IMDbPro\n\n"
```
    
  </p>
</details>

Do you collect the cast names and only the cast names? We've scraped too much. The problem is that our CSS selector is not specific enough for our needs. We need an easy way to identify CSS selector combinations to extract only the content we want, and nothing more.

## SelectorGadget

**SelectorGadget** is a GUI tool used to identify CSS selector combinations from a webpage.

## Install SelectorGadget

1. Run `vignette("selectorgadget")`
1. Drag **SelectorGadget** link into your browser's bookmark bar

## Using SelectorGadget

1. Navigate to a webpage
1. Open the SelectorGadget bookmark
1. Click on the item to scrape
1. Click on yellow items you do not want to scrape
1. Click on additional items that you do want to scrape
1. Rinse and repeat until only the items you want to scrape are highlighted in yellow
1. Copy the selector to use with `html_nodes()`

> When using SelectorGadget, always make sure to scroll up and down the web page to make sure you have properly selected only the content you want.

## Practice using SelectorGadget

1. Install SelectorGadget in your browser
1. Use SelectorGadget to find a CSS selector combination that identifies just the cast member names

<details> 
  <summary>Click for the solution</summary>
  <p>


```r
cast2 <- html_nodes(frozen, "#titleCast td:nth-child(2) a")
html_text(cast2)
```

```
##  [1] " Kristen Bell\n"        " Idina Menzel\n"       
##  [3] " Jonathan Groff\n"      " Josh Gad\n"           
##  [5] " Santino Fontana\n"     " Alan Tudyk\n"         
##  [7] " Ciarán Hinds\n"        " Chris Williams\n"     
##  [9] " Stephen J. Anderson\n" " Maia Wilson\n"        
## [11] " Edie McClurg\n"        " Robert Pine\n"        
## [13] " Maurice LaMarche\n"    " Livvy Stubenrauch\n"  
## [15] " Eva Bella\n"
```
    
  </p>
</details>

## Practice scraping data

Look up the cost of living for your hometown on [Sperling's Best Places](http://www.bestplaces.net/). Then extract it with `html_nodes()` and `html_text()`.

<details> 
  <summary>Click for the solution</summary>
  <p>

For me, this means I need to obtain information on [Sterling, Virginia](http://www.bestplaces.net/cost_of_living/city/virginia/sterling).


```r
sterling <- read_html("http://www.bestplaces.net/cost_of_living/city/virginia/sterling")

col <- html_nodes(sterling, css = "#mainContent_dgCostOfLiving tr:nth-child(2) td:nth-child(2)")
html_text(col)
```

```
## [1] "147.3"
```

```r
# or use a piped operation
sterling %>%
  html_nodes(css = "#mainContent_dgCostOfLiving tr:nth-child(2) td:nth-child(2)") %>%
  html_text()
```

```
## [1] "147.3"
```
    
  </p>
</details>

## Tables

Use `html_table()` to scrape whole tables of data as a data frame.


```r
tables <- html_nodes(sterling, css = "table")

tables %>%
  # get the first table
  nth(1) %>%
  # convert to data frame
  html_table(header = TRUE)
```

```
##     COST OF LIVING Sterling Virginia      USA
## 1          Overall    147.3    113.8      100
## 2          Grocery    105.3     98.8      100
## 3           Health       94    101.5      100
## 4          Housing    216.9    135.1      100
## 5 Median Home Cost $405,700 $252,700 $216,200
## 6        Utilities     98.6     99.3      100
## 7   Transportation    141.4    115.5      100
## 8    Miscellaneous    118.2    100.5      100
```

## Extract climate statistics

Visit the climate tab for your home town. Extract the climate statistics of your hometown as a data frame with useful column names.

<details> 
  <summary>Click for the solution</summary>
  <p>

For me, this means I need to obtain information on [Sterling, Virginia](http://www.bestplaces.net/cost_of_living/city/virginia/sterling).


```r
sterling_climate <- read_html("http://www.bestplaces.net/climate/city/virginia/sterling")

climate <- html_nodes(sterling_climate, css = "table")
html_table(climate, header = TRUE, fill = TRUE)[[1]]
```

```
##                         CLIMATE Sterling, Virginia United States
## 1                Rainfall (in.)               43.1          39.2
## 2                Snowfall (in.)               21.3          25.8
## 3            Precipitation Days              106.0         102.0
## 4                    Sunny Days              197.0         205.0
## 5                Avg. July High               86.3          86.1
## 6                 Avg. Jan. Low               23.1          22.6
## 7 Comfort Index (higher=better)               47.0          54.0
## 8                      UV Index                4.0           4.3
## 9                 Elevation ft.              292.0        2443.0
```

```r
sterling_climate %>%
  html_nodes(css = "table") %>%
  nth(1) %>%
  html_table(header = TRUE)
```

```
##                         CLIMATE Sterling, Virginia United States
## 1                Rainfall (in.)               43.1          39.2
## 2                Snowfall (in.)               21.3          25.8
## 3            Precipitation Days              106.0         102.0
## 4                    Sunny Days              197.0         205.0
## 5                Avg. July High               86.3          86.1
## 6                 Avg. Jan. Low               23.1          22.6
## 7 Comfort Index (higher=better)               47.0          54.0
## 8                      UV Index                4.0           4.3
## 9                 Elevation ft.              292.0        2443.0
```
    
  </p>
</details>

## Acknowledgments

* Web scraping lesson drawn from [Extracting data from the web APIs and beyond](https://github.com/ropensci/user2016-tutorial)
* [HTML| Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/HTML)
* [CSS | Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/CSS)

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
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
##  blogdown      0.14    2019-07-13 [1] CRAN (R 3.6.0)
##  bookdown      0.12    2019-07-11 [1] CRAN (R 3.6.0)
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)
##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
##  dplyr       * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)
##  ggplot2     * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
##  haven         2.1.1   2019-07-04 [1] CRAN (R 3.6.0)
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)
##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
##  httr          1.4.1   2019-08-05 [1] CRAN (R 3.6.0)
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)
##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
##  modelr        0.1.5   2019-08-08 [1] CRAN (R 3.6.0)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
##  nlme          3.1-141 2019-08-01 [1] CRAN (R 3.6.0)
##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
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
##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)
##  rvest       * 0.3.4   2019-05-15 [1] CRAN (R 3.6.0)
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)
##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
##  xml2        * 1.2.2   2019-08-09 [1] CRAN (R 3.6.0)
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```
