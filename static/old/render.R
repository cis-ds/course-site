#!/usr/local/bin/Rscript --vanilla

# renders all .Rmd files in directory if the input file is older than the output file.
# differs in that rmarkdown::render_site renders all files, regardless of modifications

render_site_mod <- function(infolder, outfolder, clean_site = FALSE) {
  if(clean_site == TRUE){
    rmarkdown::clean_site()
    rmarkdown::render_site()
  } else {
    for (infile in list.files(infolder, pattern = "^[^_].*\\.R?md$", full.names = TRUE)) {
      outfile = paste0(outfolder, "/", sub(".Rmd$", ".html", basename(infile)))
      
      # render only if the input file is the last one modified
      if (!file.exists(outfile) |
          file.info(infile)$mtime > file.info(outfile)$mtime) {
        rmarkdown::render(infile)
      }
    }
  }
}


render_site_mod(".", ".", commandArgs(trailingOnly = TRUE)[1])
