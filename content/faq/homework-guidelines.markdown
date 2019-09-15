---
date: "2018-09-09T00:00:00-05:00"
draft: false
menu:
  faq:
    parent: Overview
    weight: 1
title: "General homework guidelines"
toc: true
type: docs
aliases: ["/hw00_homework_guidelines"]
---

## GitHub prerequisites

I assume you can [pull from and push to GitHub from RStudio](/setup/git-with-rstudio/).

## Homework workflow

![](/img/homework_workflow.png)

Homework assignments will be stored in separate Git repositories under the `uc-cfss` organization on GitHub. To complete a homework assignment, you need to:

1. [Fork](https://guides.github.com/activities/forking/) the repository
1. [Clone](/setup/git-with-rstudio/#step-2-clone-the-new-github-repository-to-your-computer-via-rstudio) the repository to your computer
1. Modify the files and [commit changes](/setup/git-with-rstudio/#step-3-make-local-changes-save-commit) to complete your solution.
1. [Push](/setup/git-with-rstudio/#step-4-push-your-local-changes-online-to-github)/sync the changes up to GitHub.
1. [Create a pull request](https://help.github.com/articles/creating-a-pull-request) on the original repository to turn in the assignment. **Make sure to include your name in the pull request.**

## Authoring Markdown files

Throughout this course, any basic text document should be written in [Markdown](http://daringfireball.net/projects/markdown/basics) and should always have a filename that ends in `.md`. These files are pleasant to write and read, but are also easily converted into HTML and other output formats. GitHub provides an attractive HTML-like preview for Markdown documents. RStudio's "Preview HTML" button will compile the open document to actual HTML and open a preview.

Whenever you are editing Markdown documents in RStudio, you can display a Markdown cheatsheet by going to Help > Markdown Quick Reference.

## Authoring R Markdown files

If your document is describing a data analysis, author it in [R Markdown](http://rmarkdown.rstudio.com), which is like Markdown, but with the addition of R "code chunks" that are runnable. The filename should end in `.Rmd` or `.rmd`. RStudio's "Knit HTML" button will compile the open document to actual HTML and open a preview.

Whenever you are editing R Markdown documents in RStudio, you can display an R Markdown cheatsheet by going to Help > Cheatsheets > R Markdown Cheat Sheet. A basic introduction to R Markdown can also be found in [R for Data Science](http://r4ds.had.co.nz/r-markdown.html)

## Which files to commit 

* Always commit the main source document, e.g., the R script or R Markdown or Markdown document. Commit early, commit often!
* For R Markdown source, also commit the intermediate Markdown (`.md`) file and any accompaying files, such as figures.
    * Some purists would say intermediate and downstream products do NOT belong in the repo. After all, you can always recreate them from source, right? But here in reality, it turns out to be incredibly handy to have this in the repo.
* Commit the end product file. For homework submissions this is generally the Markdown file (`.md`) because your output format is `github_document` as well as all the graphs generated from the code chunks. For other projects, this might be an HTML (`.html`) or PDF (`.pdf`) file.
    * See above comment re: version control purists vs. pragmatists.
* You may not want to commit the Markdown and/or HTML until the work is fairly advanced, maybe even until submission. Once these enter the repo, you really should recompile them each time you commit changes to the R Markdown source, so that the Git history reflects the way these files should evolve as an ensemble.
* **Never ever** edit the intermediate/output documents "by hand". Only edit the source and then regenerate the downstream products from that.

## Make your work shine!

Here are some minor tweaks that can make a big difference in how awesome your product is.

### Make it easy for people to access your work

Reduce the friction for graders to get the hard-working source code (the `.R` or `.Rmd` file) **and** the front-facing report (`.md` or `.html`).

* Create a `README.md` in the homework's main directory to serve as the landing page for your submission. Whenever anyone visits this repo, this will be automatically rendered nicely! In particular, hyperlinks will work.
* With this `README.md` file, create annotated links to the documents graders will need to access. Such as:
    * Your main R Markdown document
    * The Markdown product that comes from knitting your main R Markdown document
        * Remember GitHub will render this into pseudo-HTML automagically
        * Remember the figures in `_files/` need to be available in the repo in order to appear here

### Linking to HTML files in the repo

Simply visiting an HTML file in a GitHub repo just shows ugly HTML source. You need to do a little extra work to see this rendered as a proper webpage.

  * Navigate to the HTML file on GitHub. Get the URL of the page, which should look something like this: [`https://github.com/uc-cfss/uc-cfss.github.io/blob/master/hw00_homework_guidelines.html`](https://github.com/uc-cfss/uc-cfss.github.io/blob/master/hw00_homework_guidelines.html). Copy that URL!
  * Create a link to that in the usual Markdown way BUT prepend `http://htmlpreview.github.io/?` to the URL. So the URL in your link should look something like this: [`http://htmlpreview.github.io/?https://github.com/uc-cfss/uc-cfss.github.io/blob/master/hw00_homework_guidelines.html`](http://htmlpreview.github.io/?https://github.com/uc-cfss/uc-cfss.github.io/blob/master/hw00_homework_guidelines.html). You can learn more about this preview facility [here](http://htmlpreview.github.io).
  * This sort of link would be fabulous to include in `README.md`.

### Make it easy for others to run your code

* In exactly one, very early R chunk, load any necessary packages, so your dependencies are obvious.
* In exactly one, very early R chunk, import anything coming from an external file. This will make it easy for someone to see which data files are required, edit to reflect their locals paths if necessary, etc. There are situations where you might not keep data in the repo itself.
* In exactly one, very last R chunk, report your session information. This prints version information about R, the operating system, and loaded packages so the reader knows the state of your machine when you rendered the R Markdown document. An R chunk with `devtools::session_info()` will produce something that looks like this:

    
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
    ##  callr         3.3.1   2019-07-18 [1] CRAN (R 3.6.0)
    ##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
    ##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)
    ##  devtools      2.1.0   2019-07-06 [1] CRAN (R 3.6.0)
    ##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
    ##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)
    ##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
    ##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
    ##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)
    ##  pkgbuild      1.0.4   2019-08-05 [1] CRAN (R 3.6.0)
    ##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)
    ##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)
    ##  processx      3.4.1   2019-07-18 [1] CRAN (R 3.6.0)
    ##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)
    ##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
    ##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
    ##  remotes       2.1.0   2019-06-24 [1] CRAN (R 3.6.0)
    ##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
    ##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
    ##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  testthat      2.2.1   2019-07-25 [1] CRAN (R 3.6.0)
    ##  usethis       1.5.1   2019-07-04 [1] CRAN (R 3.6.0)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
    ```

* Pretend you are someone else. Clone a fresh copy of your own repo from GitHub, fire up a new RStudio session and try to knit your R Markdown file. Does it "just work"? It should!
  
### Make pretty tables

Instead of just printing an object with R, you could format the info in an attractive table. Some leads:

* The `kable()` function from `knitr`.
* Also look into the packages `xtable`, `pander`.

{{< tweet 464132152347475968 >}}

### Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
