library(tidyverse)
library(knitr)

# get list of .Rmd files
rmd_files <- list.files(
  path = ".",
  pattern = "*.Rmarkdown|*.Rmd",
  full.names = TRUE,
  recursive = TRUE
)

map(.x = rmd_files, .f = convert_chunk_header, output = identity)
