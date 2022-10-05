---
date: "2018-09-09T00:00:00-05:00"
weight: 10
title: "General homework guidelines"
toc: true
type: book
aliases: ["/hw00_homework_guidelines"]
---

## GitHub prerequisites

I assume you can [pull from and push to GitHub from RStudio](/setup/git-with-rstudio/).

## Homework workflow

Homework assignments will be stored in separate Git repositories on [Cornell's GitHub Enterprise server](https://github.coecis.cornell.edu/). This is extremely similar to the public [GitHub](https://github.com/) with the added benefit that you already have an account using your NetID and Cornell email.

This class will use one repository per student per assignment. A Git **repository** tracks and saves the history of all changes made to the files in the Git project. To complete a homework assignment, you need to:

1. [Clone](/setup/git-with-rstudio/#step-2-clone-the-new-github-repository-to-your-computer-via-rstudio) the repository to your computer
1. Modify the files and [commit changes](/setup/git-with-rstudio/#step-3-make-local-changes-save-commit) to complete your solution.
1. [Push](/setup/git-with-rstudio/#step-4-push-your-local-changes-online-to-github)/sync the changes up to GitHub.

We will cover more complex Git workflows and how to work with the public GitHub platform later in the course.

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

### Make it easy for others to run your code

* In exactly one, very early R chunk, load any necessary packages, so your dependencies are obvious.
* In exactly one, very early R chunk, import anything coming from an external file. This will make it easy for someone to see which data files are required, edit to reflect their locals paths if necessary, etc. There are situations where you might not keep data in the repo itself.
* In exactly one, very last R chunk, report your session information. This prints version information about R, the operating system, and loaded packages so the reader knows the state of your machine when you rendered the R Markdown document. An R chunk with `sessioninfo::session_info()` will produce something that looks like this:

    
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
    ##  date     2022-10-05
    ##  pandoc   2.18 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date (UTC) lib source
    ##  blogdown      1.10    2022-05-10 [2] CRAN (R 4.2.0)
    ##  bookdown      0.27    2022-06-14 [2] CRAN (R 4.2.0)
    ##  bslib         0.4.0   2022-07-16 [2] CRAN (R 4.2.0)
    ##  cachem        1.0.6   2021-08-19 [2] CRAN (R 4.2.0)
    ##  cli           3.4.0   2022-09-08 [1] CRAN (R 4.2.0)
    ##  digest        0.6.29  2021-12-01 [2] CRAN (R 4.2.0)
    ##  evaluate      0.16    2022-08-09 [1] CRAN (R 4.2.1)
    ##  fastmap       1.1.0   2021-01-25 [2] CRAN (R 4.2.0)
    ##  htmltools     0.5.3   2022-07-18 [2] CRAN (R 4.2.0)
    ##  jquerylib     0.1.4   2021-04-26 [2] CRAN (R 4.2.0)
    ##  jsonlite      1.8.0   2022-02-22 [2] CRAN (R 4.2.0)
    ##  knitr         1.40    2022-08-24 [1] CRAN (R 4.2.0)
    ##  magrittr      2.0.3   2022-03-30 [2] CRAN (R 4.2.0)
    ##  R6            2.5.1   2021-08-19 [2] CRAN (R 4.2.0)
    ##  rlang         1.0.5   2022-08-31 [1] CRAN (R 4.2.0)
    ##  rmarkdown     2.14    2022-04-25 [2] CRAN (R 4.2.0)
    ##  rstudioapi    0.13    2020-11-12 [2] CRAN (R 4.2.0)
    ##  sass          0.4.2   2022-07-16 [2] CRAN (R 4.2.0)
    ##  sessioninfo   1.2.2   2021-12-06 [2] CRAN (R 4.2.0)
    ##  stringi       1.7.8   2022-07-11 [2] CRAN (R 4.2.0)
    ##  stringr       1.4.0   2019-02-10 [2] CRAN (R 4.2.0)
    ##  xfun          0.31    2022-05-10 [1] CRAN (R 4.2.0)
    ##  yaml          2.3.5   2022-02-21 [2] CRAN (R 4.2.0)
    ## 
    ##  [1] /Users/soltoffbc/Library/R/arm64/4.2/library
    ##  [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
    ## 
    ## ──────────────────────────────────────────────────────────────────────────────
    ```

* Pretend you are someone else. Clone a fresh copy of your own repo from GitHub, fire up a new RStudio session and try to knit your R Markdown file. Does it "just work"? It should!
  
### Make pretty tables

Instead of just printing an object with R, you could format the info in an attractive table. Some leads:

* The `kable()` function from `knitr`.
* Also look into the packages `xtable`, `pander`, `gt`.

{{< tweet 464132152347475968 >}}

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
