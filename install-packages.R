# install-packages.R
# 8/24/18 BCS
# Get a list of required packages to install on RStudio Cloud
# and setup a default project

library(tidyverse)
library(magrittr)

# get list of .Rmd files
rmd_files <- list.files(
  path = "content/",
  pattern = "*.Rmarkdown",
  full.names = TRUE,
  recursive = TRUE
)

# read in each file and store in a list of character vectors
packages <- tibble(filepath = rmd_files) %>%
  mutate(content = map(filepath, read_lines)) %>%
  # unnest content
  unnest(content) %>%
  # find lines which start with `library(` %>%
  filter(startsWith(content, "library")) %>%
  # get unique content
  select(content) %>%
  distinct() %$%
  # extract library names
  str_extract(content, "\\([^()]+\\)") %>%
  str_remove_all("\\(|\\)")

# print as a concatenated string
packages %>%
  str_flatten(collapse = ", ")

# check which are on CRAN
available_pkgs <- available.packages()[, 1]

pkg_cran <- tibble(packages) %>%
  mutate(on_cran = map_lgl(packages, ~ .x %in% available_pkgs))

with(pkg_cran, packages[on_cran]) %>%
  str_flatten(collapse = '", "') %>%
  str_c('c("', ., '")') %>%
  cat()

# which are not on CRAN
with(pkg_cran, packages[!on_cran]) %>%
  map(library, character.only = TRUE)


# ###### code to run on RStudio cloud project
# pkg_cran <- c("reprex", "tidyverse", "knitr", "gapminder", "forcats", "broom",
#               "wordcloud", "tidytext", "viridis", "rebird", "geonames", "tidycensus",
#               "modelr", "rsample", "magrittr", "ISLR", "titanic", "microbenchmark",
#               "partykit", "caret", "nycflights13", "ggplot2", "tibble", "ggwordcloud",
#               "here", "arrow", "readxl", "haven", "sf", "ggmap", "rnaturalearth",
#               "rtweet", "RColorBrewer", "patchwork", "ymlthis", "RSocrata", "dplyr",
#               "shiny", "httr", "repurrrsive", "purrr", "acs", "downloader", "statebins",
#               "rsparkling", "sparklyr", "h2o", "stringr", "dbplyr", "bigrquery", "FNN",
#               "maps", "gam", "tm", "tictoc", "topicmodels", "rjson", "LDAvis", "rvest",
#               "socviz", "margins", "curl", "jsonlite", "XML", "usethis")
# 
# install.packages(pkg_cran)
# 
# # install packages from GitHub
# remotes::install_github(c(
#   "bradleyboehmke/harrypotter",
#   "uc-cfss/rcfss",
#   "ManifestoProject/manifestoR",
#   "cpsievert/LDAvisData",
#   "hrbrmstr/albersusa"
# ))
