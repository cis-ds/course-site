# uc-cfss.github.io

This is the course site for MACS 30500 - Programming for the Social Sciences.

To render, execute [`render.sh`](render.sh). This will:

* Convert Jupyter Notebooks to Markdown .md files
* Update [`footer.html`](footer.html) with the current date
* Render using RMarkdown all .Rmd files that need to be updated
    * Alternatively, switch the last two lines of code to run `rmarkdown::render_site()` and regenerate all HTML pages