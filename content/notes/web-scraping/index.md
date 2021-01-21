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

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/getting-data-from-the-web-scraping")
```

{{% /callout %}}

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

{{% callout note %}}

You can think of elements as R functions, and attributes are the arguments to functions. Not all functions require arguments, or they use default arguments.

{{% /callout %}}

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

{{< spoiler text="Click for the solution" >}}

![HTML tag for "Kristen Bell"](/img/frozen_span.png)

"Kristen Bell" is enclosed in the `span` tag. But look through the some of the other source code. `span` is used many times throughout the page. How can we select just the element containing "Kristen Bell", or all the cast member names but nothing else?

{{< /spoiler >}}

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

{{% callout note %}}

[CSS diner](http://flukeout.github.io) is a JavaScript-based interactive game for learning and practicing CSS selectors. Take some time to play and learn more about CSS selector combinations.

{{% /callout %}}

## Find the CSS selector

Which CSS identifiers are associated with Kristen Bell's name in the *Frozen* page? Write a CSS selector that targets them.

![](/img/frozen_css.png)

{{< spoiler text="Click for the solution" >}}

* `span` - the element
* `itemprop` - the class

Therefore the CSS selector would be `span.itemprop`.

{{< /spoiler >}}

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
## {html_document}
## <html xmlns:og="http://ogp.me/ns#" xmlns:fb="http://www.facebook.com/2008/fbml">
## [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=UTF-8 ...
## [2] <body id="styleguide-v2" class="fixed">\n            <img height="1" widt ...
```

{{% callout note %}}

It is always a good practice when web scraping to store the output of `read_html()` in an object immediately, then apply further functions to the stored HTML file. Otherwise you send a request to the server every time you extract information from the HTML. For longer-term projects, you can store `read_html()` objects locally on your computer using `readr::write_rds()` and retrieve them using `readr::read_rds()`. This caches a local copy of the file so you always have a copy preserved, in case the webpage's underlying HTML code is modified (or the website is taken offline).

{{% /callout %}}

## Extract nodes


```r
itals <- html_nodes(frozen, "em")
itals
```

```
## {xml_nodeset (1)}
## [1] <em class="nobr">Written by\n<a href="/search/title?plot_author=DeAlan%20 ...
```

* The first argument to `html_nodes()` is the HTML document or a node previously extracted from the document
* The second argument is a CSS selector to identify which nodes to select

## Extract content from nodes


```r
itals
```

```
## {xml_nodeset (1)}
## [1] <em class="nobr">Written by\n<a href="/search/title?plot_author=DeAlan%20 ...
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
## [1] <a href="/search/title?plot_author=DeAlan%20Wilson%20for%20ComedyE.com&am ...
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
1. Select the nodes that are both `id = "titleCast"` and `a`s
1. Extract the text from the nodes

{{< spoiler text="Click for the solution" >}}


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
## [29] "Kai"                                               
## [30] ""                                                  
## [31] " Maia Wilson\n"                                    
## [32] "Bulda"                                             
## [33] ""                                                  
## [34] " Edie McClurg\n"                                   
## [35] "Gerda"                                             
## [36] ""                                                  
## [37] " Robert Pine\n"                                    
## [38] "Bishop"                                            
## [39] ""                                                  
## [40] " Maurice LaMarche\n"                               
## [41] "King"                                              
## [42] ""                                                  
## [43] " Livvy Stubenrauch\n"                              
## [44] "Young Anna"                                        
## [45] ""                                                  
## [46] " Eva Bella\n"                                      
## [47] "Young Elsa"                                        
## [48] "See full cast"                                     
## [49] " \nView production, box office, & company info\n\n"
```

{{< /spoiler >}}

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

{{% callout note %}}

When using SelectorGadget, always make sure to scroll up and down the web page to make sure you have properly selected only the content you want.

{{% /callout %}}

## Practice using SelectorGadget

1. Install SelectorGadget in your browser
1. Use SelectorGadget to find a CSS selector combination that identifies just the cast member names

{{< spoiler text="Click for the solution" >}}


```r
cast2 <- html_nodes(frozen, "#titleCast td:nth-child(2) a")
html_text(cast2)
```

```
##  [1] " Kristen Bell\n"        " Idina Menzel\n"        " Jonathan Groff\n"     
##  [4] " Josh Gad\n"            " Santino Fontana\n"     " Alan Tudyk\n"         
##  [7] " Ciarán Hinds\n"        " Chris Williams\n"      " Stephen J. Anderson\n"
## [10] " Maia Wilson\n"         " Edie McClurg\n"        " Robert Pine\n"        
## [13] " Maurice LaMarche\n"    " Livvy Stubenrauch\n"   " Eva Bella\n"
```

```r
# remove whitespace
html_text(cast2) %>% str_trim(side = "both")
```

```
##  [1] "Kristen Bell"        "Idina Menzel"        "Jonathan Groff"     
##  [4] "Josh Gad"            "Santino Fontana"     "Alan Tudyk"         
##  [7] "Ciarán Hinds"        "Chris Williams"      "Stephen J. Anderson"
## [10] "Maia Wilson"         "Edie McClurg"        "Robert Pine"        
## [13] "Maurice LaMarche"    "Livvy Stubenrauch"   "Eva Bella"
```

{{< /spoiler >}}

## Practice scraping data

Look up the cost of living for your hometown on [Sperling's Best Places](http://www.bestplaces.net/). Then extract it with `html_nodes()` and `html_text()`.

{{< spoiler text="Click for the solution" >}}

For me, this means I need to obtain information on [Sterling, Virginia](http://www.bestplaces.net/cost_of_living/city/virginia/sterling).


```r
sterling <- read_html("http://www.bestplaces.net/cost_of_living/city/virginia/sterling")

col <- html_nodes(sterling, css = "#mainContent_dgCostOfLiving tr:nth-child(2) td:nth-child(2)")
html_text(col)
```

```
## [1] "134.4"
```

```r
# or use a piped operation
sterling %>%
  html_nodes(css = "#mainContent_dgCostOfLiving tr:nth-child(2) td:nth-child(2)") %>%
  html_text()
```

```
## [1] "134.4"
```

{{< /spoiler >}}

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
## 1          Overall    134.4    103.7      100
## 2          Grocery    110.3     99.6      100
## 3           Health     99.3    102.4      100
## 4          Housing    185.3    111.8      100
## 5 Median Home Cost $428,500 $258,400 $231,200
## 6        Utilities     98.6     99.3      100
## 7   Transportation    118.6     99.4      100
## 8    Miscellaneous    118.2    100.5      100
```

## Extract climate statistics

Visit the climate tab for your home town. Extract the climate statistics of your hometown as a data frame with useful column names.

{{< spoiler text="Click for the solution" >}}

For me, this means I need to obtain information on [Sterling, Virginia](http://www.bestplaces.net/cost_of_living/city/virginia/sterling).


```r
sterling_climate <- read_html("http://www.bestplaces.net/climate/city/virginia/sterling")

climate <- html_nodes(sterling_climate, css = "table")
html_table(climate, header = TRUE, fill = TRUE)[[1]]
```

```
##                                 Sterling, Virginia United States
## 1                      Rainfall           42.0 in.      38.1 in.
## 2                      Snowfall           21.5 in.      27.8 in.
## 3                 Precipitation         116.2 days    106.2 days
## 4                         Sunny           197 days      205 days
## 5                Avg. July High              85.8°         85.8°
## 6                 Avg. Jan. Low              23.5°         21.7°
## 7 Comfort Index (higher=better)                7.3             7
## 8                      UV Index                  4           4.3
## 9                     Elevation            292 ft.      2443 ft.
```

```r
sterling_climate %>%
  html_nodes(css = "table") %>%
  nth(1) %>%
  html_table(header = TRUE)
```

```
##                                 Sterling, Virginia United States
## 1                      Rainfall           42.0 in.      38.1 in.
## 2                      Snowfall           21.5 in.      27.8 in.
## 3                 Precipitation         116.2 days    106.2 days
## 4                         Sunny           197 days      205 days
## 5                Avg. July High              85.8°         85.8°
## 6                 Avg. Jan. Low              23.5°         21.7°
## 7 Comfort Index (higher=better)                7.3             7
## 8                      UV Index                  4           4.3
## 9                     Elevation            292 ft.      2443 ft.
```

{{< /spoiler >}}

## Acknowledgments

* Web scraping lesson drawn from [Extracting data from the web APIs and beyond](https://github.com/ropensci/user2016-tutorial)
* [HTML| Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/HTML)
* [CSS | Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/CSS)

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
##  date     2021-01-21                  
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
##  cli           2.2.0   2020-11-20 [1] CRAN (R 4.0.2)                      
##  colorspace    2.0-0   2020-11-11 [1] CRAN (R 4.0.2)                      
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                      
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.0)                      
##  dbplyr        2.0.0   2020-11-03 [1] CRAN (R 4.0.2)                      
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)                      
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)                      
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                      
##  dplyr       * 1.0.2   2020-08-18 [1] CRAN (R 4.0.2)                      
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
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
##  hms           0.5.3   2020-01-08 [1] CRAN (R 4.0.0)                      
##  htmltools     0.5.1   2021-01-12 [1] CRAN (R 4.0.2)                      
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.2)                      
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                      
##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)                      
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
##  rvest       * 0.3.6   2020-07-25 [1] CRAN (R 4.0.2)                      
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.0)                      
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                      
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                      
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                      
##  testthat      3.0.1   2020-12-17 [1] CRAN (R 4.0.2)                      
##  tibble      * 3.0.4   2020-10-12 [1] CRAN (R 4.0.2)                      
##  tidyr       * 1.1.2   2020-08-27 [1] CRAN (R 4.0.2)                      
##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                      
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)                      
##  usethis       2.0.0   2020-12-10 [1] CRAN (R 4.0.2)                      
##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                      
##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)                      
##  xfun          0.20    2021-01-06 [1] CRAN (R 4.0.2)                      
##  xml2        * 1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
