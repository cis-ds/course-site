---
title: "A dive into R Markdown"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/program_rmarkdown.html"]
categories: ["programming", "project-management"]

menu:
  notes:
    parent: Project management
    weight: 4
---





{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/a-deep-dive-into-r-markdown")
```

{{% /callout %}}

## Reproducibility in scientific research

![](/img/data-science/base.png)

**Reproducibility** is "the idea that data analyses, and more generally, scientific claims, are published with their data and software code so that others may verify the findings and build upon them."^[[Coursera: Reproducible Research](https://www.coursera.org/learn/reproducible-research)] Scholars who implement reproducibility in their projects can quickly and easily reproduce the original results and trace back to determine how they were derived. This easily enables verification and replication, and allows the researcher to precisely replicate his or her analysis. This is extremely important when writing a paper, submitting it to a journal, then coming back months later for a revise and resubmit because you won't remember how all the code/analysis works together when completing your revisions.

Reproducibility is also key for communicating findings with other researchers and decision makers; it allows them to verify your results, assess your assumptions, and understand how your answers were formed rather than solely relying on your claims. In the data science framework employed in [R for Data Science](http://r4ds.had.co.nz), reproducibility is infused throughout the entire workflow.

![Artwork by @allison_horst](/img/allison_horst_art/reproducibility_court.png)

[R Markdown](http://rmarkdown.rstudio.com/) is one approach to ensuring reproducibility by providing a single cohesive authoring framework. It allows you to combine code, output, and analysis into a single document, are easily reproducible, and can be output to many different file formats. R Markdown is just one tool for enabling reproducibility. Another tool is [Git](https://git-scm.com/) for **version control**, which is crucial for collaboration and tracking changes to code and analysis.

![Artwork by @allison_horst](/img/allison_horst_art/rmarkdown_rockstar.png)

### Jupyter Notebooks

In the data science realm, another popular unified authoring framework is the [Jupyter Notebook](http://jupyter.org/). The Jupyter Notebook (originally called *iPython Notebook*) is a web application that incorporates text, code, and output into a single document. Originally created for the Python programming language, Jupyter Notebooks are now multi-language and support over 40 programming languages, including R. You have probably seen or used them before.

There is nothing wrong with Jupyter Notebooks, but I prefer R Markdown because it is integrated into RStudio, arguably the best integrated development environment (IDE) for R. Furthermore, as you will see an R Markdown file is a **plain-text file**. This means the content of the file can be read by any text-editor, and is easily tracked by Git. Jupyter Notebooks are stored as JSON documents, a different and more complex file format. JSON is a useful format as we will see when we get to our modules on obtaining data from the web, but they are also much more difficult to track for revisions using Git. For this reason, in this course we will exclusively use R Markdown for reproducible documents.

## R Markdown basics

An R Markdown file is a plain text file that uses the extension `.Rmd`:


````
---
title: "Gun deaths"
date: "`r lubridate::today()`"
output: html_document
---

```{r setup, include = FALSE}
library(tidyverse)
library(rcfss)

youth <- gun_deaths %>%
  filter(age <= 65)
```

# Gun deaths by age

We have data about `r nrow(gun_deaths)` individuals killed by guns. Only `r nrow(gun_deaths) - nrow(youth)` are older than 65. The distribution of the remainder is shown below:

```{r youth-dist, echo = FALSE}
youth %>% 
  ggplot(aes(age)) + 
  geom_freqpoly(binwidth = 1)
```

# Gun deaths by race

```{r race-dist}
youth %>%
  ggplot(aes(fct_infreq(race) %>% fct_rev())) +
  geom_bar() +
  coord_flip() +
  labs(x = "Victim race")
```
````

R Markdown documents contain 3 major components:

1. A **YAML header** surrounded by `---`s
1. **Chunks** of R code surrounded by ``` (triple-backticks)
1. Text mixed with simple text formatting using the [Markdown syntax](/homework/edit-readme/)

Code chunks are interspersed with text throughout the document. To complete the document, you "Knit" or "render" the document. Most of you probably knit the document by clicking the "Knit" button in the script editor panel. You can also do this programmatically from the console by running the command `rmarkdown::render("example.Rmd")`.

When you **knit** the document you send your `.Rmd` file to [`knitr`](https://yihui.name/knitr/), a package for R that executes all the code chunks and creates a second **markdown** document (`.md`). That markdown document is then passed onto [**pandoc**](http://pandoc.org/), a document rendering software program independent from R. Pandoc allows users to convert back and forth between many different document formats such as HTML, $\LaTeX$, Microsoft Word, etc. By splitting the workflow up, you can convert your R Markdown document into a wide range of output formats.

![](https://r4ds.had.co.nz/images/RMarkdownFlow.png)

## Text formatting with Markdown

[We have previously practiced formatting text using the Markdown syntax.](/homework/edit-readme/) I will not go into it further, but do note that there is a quick reference guide to Markdown built-in to RStudio. To access it, go to **Help** > **Markdown Quick Reference**.

### Exercise

* Render `gun-deaths.Rmd` as an HTML document
* Add text describing the frequency polygon

## Code chunks

**Code chunks** are where you store R code that will be executed. You can name a code chunk using the syntax ```` ```{r name-here} ````. Naming chunks is a good practice to get into for several reasons. First, it makes navigating an R Markdown document using the drop-down code navigator in the bottom-left of the script editor easier since your chunks will have **intuitive** names. Second, it generates meaningful file names for any graphs created within the chunk, rather than unhelpful names such as `unnamed-chunk-1.png`. Finally, once you start **caching** your results (more on that below), using consistent names for chunks avoids having to repeat computationally intensive calculations.

## Customizing chunks

Code chunks can be customized to adjust the output of the chunk. Some important and useful options are:

* `eval = FALSE` - prevents code from being evaluated. I use this in my notes for class when I want to show how to write a specific function but don't need to actually use it.
* `include = FALSE` - runs the code but doesn't show the code or results in the final document. This is useful when you have setup code at the beginning of your document (loading packages, adjusting options, etc.) that may generate a lot of messages that are not really necessary to include in the final report.
* `echo = FALSE` - prevents code from showing in the final output, but does show the results of the code. Use this if you are writing a paper or document for someone who cares more about the substantive results and less about the programming used to obtain them.
* `message = FALSE` or `warning = FALSE` - prevents messages or warnings from appearing in the final document.
* `results = 'hide'` - hides printed output.
* `error = TRUE` - causes the document to continue knitting and rendering even if the code generates a fatal error. I use this a lot when I want to [intentionally demonstrate an error in class](/notes/condition-handling/#fatal-errors). If you're debugging your code, you might want to use this option. However for the final version of your document, you probably do not want to allow errors to pass through unnoticed.

For example, if I wanted a code chunk to not print the code itself or any warnings/messages generated by the chunk (i.e. only print tables and figures), I would write this as:

    ```{r echo = FALSE, message = FALSE, warning = FALSE}
    # code goes here
    ```


## Caching

Remember the R Markdown workflow?

![](https://r4ds.had.co.nz/images/RMarkdownFlow.png)

By default, every time you knit a document R starts completely fresh. None of the previous results are saved. If you have code chunks that run computationally intensive tasks, you might want to store these results to be more efficient and save time. If you use `cache = TRUE`, R will do exactly this. The output of the chunk will be saved to a specially named file on disk. If your [`.gitignore` file is setup correctly](/notes/common-git-problems/#how-to-use-gitignore), this cached file will not be tracked by Git. This is in fact preferable since the cached file could be hundreds of megabytes in size. Now, every time you knit the document the cached results will be used instead of running the code fresh.

### Dependencies

This could be problematic when chunks rely on the output of previous chunks. Take this example from [R for Data Science](http://r4ds.had.co.nz/r-markdown.html#caching)

    ```{r raw_data}
    rawdata <- readr::read_csv("a_very_large_file.csv")
    ```
    
    ```{r processed_data, cache = TRUE}
    processed_data <- rawdata %>% 
      drop_na(import_var) %>% 
      mutate(new_variable = complicated_transformation(x, y, z))
    ```

`processed_data` relies on the `rawdata` file created in the `raw_data` chunk. If you change your code in `raw_data`, `processed_data` will continue to rely on the older cached results. This means even if `rawdata` is altered, the cached results will continue to erroneously be used. To prevent this, use the `dependson` option to declare any chunks the cached chunk relies upon:

    ```{r processed_data, cache = TRUE, dependson = "raw_data"}
    processed_data <- rawdata %>% 
      drop_na(import_var) %>% 
      mutate(new_variable = complicated_transformation(x, y, z))
    ```
    
Now if the code in the `raw_data` chunk is changed, `processed_data` will be run and the cache updated.

## Global options

Rather than setting these options for each individual chunk, you can make them the default options for **all chunks** by using `knitr::opts_chunk$set()`. Just include this in a code chunk (typically in the first code chunk in the document). So for example,

```r
knitr::opts_chunk$set(
  echo = FALSE
)
```

hides the code by default in all code chunks. To override this new default, you can still declare `echo = TRUE` for individual chunks.

## Inline code

Until now, you have only run code in a specially designated chunk. However you can also run R code **in-line** by using the `` `r ` `` syntax. For example, look at the text from the example document earlier:



> We have data about `` `r nrow(gun_deaths)` `` individuals killed by guns. Only `` `r nrow(gun_deaths) - nrow(youth)` `` are older than 65. The distribution of the remainder is shown below:

When you knit the document, the R code is executed:

> We have data about 100798 individuals killed by guns. Only 15687 are older than 65. The distribution of the remainder is shown below:

## Exercise: practice chunk options

* Set `echo = FALSE` as a global option
* Enable caching as a global option and render the document. Look at the file structure for the cache. Now render the document again. Does it run faster?

## YAML header

**Y**et **A**nother **M**arkup **L**anguage, or **YAML** (rhymes with *camel*) is a standardized format for storing hierarchical data in a human-readable syntax. The YAML header controls how `rmarkdown` renders your `.Rmd` file. A YAML header is a section of `key: value` pairs surrounded by `---` marks.




```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output: github_document
---
```

The most important option is `output`, as this determines the final document format. However there are other common options such as providing a `title` and `author` for your document and specifying the `date` of publication.

## Output formats

## HTML document

For your homework assignments, we have used `github_document` to generate a [Markdown document](http://rmarkdown.rstudio.com/markdown_document_format.html). However there are other document formats that are more commonly used.


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output: html_document
---
```

[`output: html_document`](http://rmarkdown.rstudio.com/html_document_format.html) produces an HTML document. The nice feature of this document is that all images are embedded in the HTML file itself, so you can email just the `.html` file to someone and they will be able to open and read it.

### Table of contents

Each output format has various options to customize the appearance of the final document. One option for HTML documents is to add a table of contents through the `toc` option. To add any option for an output format, just add it in a hierarchical format like this:


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  html_document:
    toc: true
    toc_depth: 2
---
```

You can explicitly set the number of levels included in the table of contents with `toc_depth` (the default is 3).

### Appearance and style

There are several options that control the visual appearance of HTML documents.

* `theme` specifies the Bootstrap theme to use for the page (themes are drawn from the [Bootswatch](http://bootswatch.com/) theme library). Valid themes include  `"default"`, `"cerulean"`, `"journal"`, `"flatly"`, `"readable"`, `"spacelab"`, `"united"`, `"cosmo"`, `"lumen"`, `"paper"`, `"sandstone"`, `"simplex"`, and `"yeti"`.
* `highlight` specifies the syntax highlighting style for code chunks. Supported styles include `"default"`, `"tango"`, `"pygments"`, `"kate"`, `"monochrome"`, `"espresso"`, `"zenburn"`, `"haddock"`, and `"textmate"`.


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  html_document:
    theme: readable
    highlight: pygments
---
```

### Code folding

Sometimes when knitting an R Markdown document you want to include your R source code (`echo = TRUE`) but you may want to include it but not make it visible by default. The `code_folding: hide` options allows you to include your R code but hide it. Users can then decide whether or not they want to see specific chunks or all chunks in the document. This strikes a good balance between readability and reproducibility.


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  html_document:
    code_folding: hide
---
```

### Keeping Markdown

When `knitr` processes your `.Rmd` document, it creates a Markdown (`.md`) file that is subsequently deleted. If you want to keep a copy of the Markdown file use the `keep_md` option:


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  html_document:
    keep_md: true
---
```

### Exercise: test HTML options

1. Add a table of contents
1. Use the `"cerulean"` theme
1. Modify the figures so they are 8x6

## PDF document

[`pdf_document`](http://rmarkdown.rstudio.com/pdf_document_format.html) converts the `.Rmd` file to a $\LaTeX$ file which is used to generate a PDF.


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output: pdf_document
---
```

You do need to have a full installation of TeX on your computer to generate PDF output. However the nice thing is that because it uses the $\LaTeX$ rendering engine, you can use raw $\LaTeX$ code in your `.Rmd` file (if you know how to use it).

### Table of contents

Many options for HTML documents also work for PDFs. For instance, you create a table of contents the same way:


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  pdf_document:
    toc: true
    toc_depth: true
---
```

### Syntax highlighting

You cannot customize the `theme` of a `pdf_document` (at least not in the same way as HTML files), but you can still customize the syntax highlighting.


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  pdf_document:
    highlight: pygments
---
```

### $\LaTeX$ options

You can also directly control options in the $\LaTeX$ template itself via the YAML options. Note that these options are passed as top-level YAML metadata, not underneath the `output` section:


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output: pdf_document
geometry: margin=1in
fontsize: 11pt
---
```

### Keep intermediate TeX

R Markdown documents are converted first to a `.tex` file, and then use the $\LaTeX$ engine to convert to PDF. To keep the `.tex` file, use the `keep_tex` option:


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  pdf_document:
    keep_tex: true
---
```

## Presentations

You can use R Markdown not only to generate full documents, but also slide presentations. There are four major presentation formats:

* [ioslides](http://rmarkdown.rstudio.com/ioslides_presentation_format.html) - HTML presentation with ioslides
* [reveal.js](http://rmarkdown.rstudio.com/revealjs_presentation_format.html) - HTML presentation with reveal.js
* [Slidy](http://rmarkdown.rstudio.com/slidy_presentation_format.html) - HTML presentation with W3C Slidy
* [Beamer](http://rmarkdown.rstudio.com/beamer_presentation_format.html) - PDF presentation with $\LaTeX$ Beamer

Each as their own strengths and weaknesses. ioslides and Slidy are probably the easiest to use initially, but are more difficult to customize. reveal.js is more complex, but allows for more customization (this is the format I use for my slides in this class). Beamer is the only presentation format that creates a PDF document and is probably a smoother transition for those already used to Beamer.

## Multiple formats

You can even render your document into multiple output formats by supplying a list of formats:


```
---
author: Benjamin Soltoff
date: '2020-12-15'
title: Gun deaths
output:
  pdf_document: default
  html_document:
    toc: true
    toc_float: true
---
```

If you don't want to change any of the default options for a format, use the `default` option. You **must** assign some value to the second output format, hence the use of `default`.

### Rendering multiple outputs programmatically

When rendering multiple output formats, you cannot just click the "Knit" button. Doing so will only render the first output format listed in the YAML. To render all output formats, you need to programmatically render the document using `rmarkdown::render("my-document.Rmd", output_format = "all")`. Type `?render` in the console to look up the help file for `render()` and see the different arguments the function can accept.

### Exercise: render in multiple formats

* Render `gun-deaths.Rmd` as both an HTML document and a PDF document

{{% callout warning %}}

If you do not have $\LaTeX$ installed on your computer, render `gun-deaths.Rmd` as both an HTML document and a [Word document](http://rmarkdown.rstudio.com/word_document_format.html). And at some point [install $\LaTeX$ on your computer](https://www.latex-project.org/get/) so you can create PDF documents.

{{% /callout %}}

## R scripts

So far we've done a lot of our work in R Markdown documents, knitting together code chunks, output, and Markdown text. However we don't have to use R Markdown documents for all our work. In many instances, using a **script** might be preferable.

## What is a script?

A script is a plain-text file with a `.R` file extension. It contains R code. You can add comments using the `#` symbol. For example, `gun-deaths.R` would look something like this:


```
# gun-deaths.R
# 2017-02-01
# Examine the distribution of age of victims in gun_deaths

# load packages
library(tidyverse)
library(rcfss)

# filter data for under 65
youth <- gun_deaths %>%
  filter(age <= 65)

# number of individuals under 65 killed
nrow(gun_deaths) - nrow(youth)

# graph the distribution of youth
youth %>% 
  ggplot(aes(age)) + 
  geom_freqpoly(binwidth = 1)

# graph the distribution of youth, by race
youth %>%
  ggplot(aes(fct_infreq(race) %>% fct_rev())) +
  geom_bar() +
  coord_flip() +
  labs(x = "Victim race")
```

You edit scripts in the editor panel in R Studio.

![](https://r4ds.had.co.nz/diagrams/rstudio-editor.png)

## When to use a script?

[Scripts are much easier to troubleshoot than R Markdown documents](http://r4ds.had.co.nz/r-markdown.html#troubleshooting) because your code is not split across chunks and you can run everything interactively. When you first begin a project, you may find it useful to use scripts initially to build and debug code, then convert it to an R Markdown document once you begin the substantive analysis and write-up. Or you may use a mix of scripts and R Markdown documents depending on the size and complexity of your project. For instance, you could use a **reproducible pipeline** which uses a sequence of R scripts to download, import, and transform your data, then use an R Markdown document to produce a final report.

{{% callout note %}}

Check out [this example](https://github.com/uc-cfss/pipeline-example) for how one could use a pipeline in this fashion.

{{% /callout %}}

In this class while the final product is generally submitted as an R Markdown document, **it is fine to do your initial work in an R script.** If you find it easier to write and debug code there, then use that approach. Or if you prefer the [R Markdown lab notebook workflow](http://r4ds.had.co.nz/r-markdown-workflow.html), then use that. By this point you have enough competence in R to decide what works for you and what does not. **Find what works best for you and do that.**

## Running scripts interactively

You can run sections of your script by highlighting the appropriate code and typing Cmd/Ctrl + Enter. You can also run code expression-by-expression by placing your cursor at the appropriate expression in the script and typing Cmd/Ctrl + Enter. To run the entire script at once, type Cmd/Ctrl + Shift + S or press "Run" at the top of the script editor panel.

## Running scripts programmatically

To run a script saved on your computer, use the `source()` function in the console. As in `source("gun-deaths.R")`. You can also include this command in a second script. By doing this you can execute a sequence of related scripts all in order, rather than having to run each one manually in the console. See [`runfile.R`](https://github.com/uc-cfss/pipeline-example/blob/master/runfile.R) from the `pipeline-example` repo to see this in action. Remember that R scripts (`.R`) are executed via the `source()` function, whereas R Markdown files (`.Rmd`) are executed via the `rmarkdown::render()` function.

{{% callout note %}}

Want to create a report from an R script? Just call `rmarkdown::render("gun-deaths.R")` to author an R Markdown document based on the R script. It will never be as fully featured as if you originally wrote it in an R Markdown document, but can sometimes be handy. Read [this overview](http://rmarkdown.rstudio.com/articles_report_from_r_script.html) for more details on this procedure.

{{% /callout %}}

## Running scripts via the shell

You can also run scripts directly from the [shell](/setup/shell/) using `Rscript`:

```bash
Rscript gun-deaths.R
```

To render an R Markdown document from the shell, we use the syntax:

```bash
Rscript -e "rmarkdown::render('gun-deaths.Rmd')"
```

This creates a temporary R script which contains the single command `rmarkdown::render('gun-deaths.Rmd')` and executes it via `Rscript`.

![Artwork by @allison_horst](/img/allison_horst_art/rmarkdown_wizards.png)

## Acknowledgments

* Artwork by [@allison_horst](https://github.com/allisonhorst/stats-illustrations)

## Session Info



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
##  here        * 1.0.1   2020-12-13 [1] CRAN (R 4.0.2)                      
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
##  rcfss       * 0.2.1   2020-12-08 [1] local                               
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
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.0)                      
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                      
##  ymlthis     * 0.1.2   2020-02-03 [1] CRAN (R 4.0.0)                      
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```
