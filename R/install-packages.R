# install-packages.R
# 8/24/18 BCS
# Get a list of required packages to install on RStudio Cloud
# and setup a default project

library(tidyverse)
library(magrittr)
library(here)

# get list of .Rmd files
rmd_files <- list.files(path = here("content"), pattern = "*.Rmd|*.Rmarkdown", recursive = TRUE)

# read in each file and store in a list of character vectors
packages <- tibble(filepath = rmd_files) %>%
  mutate(content = map(here("content", filepath), read_lines)) %>%
  # unnest content
  unnest(content) %>%
  # find lines which start with `library(` %>%
  filter(startsWith(content, "library")) %>%
  # get unique content
  select(content) %>%
  distinct %$%
  # extract library names
  str_extract(content, "\\([^()]+\\)") %>%
  str_remove_all("\\(|\\)")

# print as a concatenated string
packages %>%
  str_flatten(collapse = ", ")

# check which are on CRAN
available_on_cran <- function(pkg) {
  pkg %in% available.packages()[,1]
}

pkg_cran <- tibble(packages) %>%
  mutate(on_cran = map_lgl(packages, available_on_cran))

with(pkg_cran, packages[on_cran]) %>%
  str_flatten(collapse = '", "') %>%
  str_c('c("', ., '")') %>%
  cat

# which are not on CRAN
with(pkg_cran, packages[!on_cran]) %>%
  map(library, character.only = TRUE)


###### code to run on RStudio cloud project
# pkg_cran <- c("tidyverse", "broom", "rtweet", "gapminder", "ggplot2",
#               "tibble", "knitr", "forcats", "stringr", "tweenr",
#               "microbenchmark", "feather", "readxl", "haven", "nycflights13",
#               "dplyr", "bigrquery", "rsparkling", "sparklyr", "h2o",
#               "titanic", "sf", "tidycensus", "RColorBrewer", "gridExtra",
#               "viridis", "ggmap", "leaflet", "fiftystater", "reprex",
#               "tidytext", "wordcloud2", "ggrepel", "lattice", "modelr",
#               "readr", "caret", "pROC", "nnet", "ISLR", "profvis", "gam",
#               "tree", "randomForest", "gbm", "ggdendro", "e1071", "FNN",
#               "kknn", "tm", "topicmodels", "car", "lmtest", "GGally",
#               "plotly", "coefplot", "mgcv", "Amelia", "lme4", "purrr",
#               "maps", "shiny", "caret", "rsample", "magrittr", "lubridate",
#               "gutenbergr", "acs", "downloader", "statebins", "wordcloud",
#               "rebird", "geonames", "manifestoR", "curl", "jsonlite", "XML",
#               "httr", "repurrrsive", "listviewer", "rvest", "htmltools",
#               "tidymodels")
# 
# install.packages(pkg_cran)
# 
# # install packages from GitHub
# devtools::install_github(c("dgrtwo/gganimate",
#                            "bradleyboehmke/harrypotter",
#                            "hadley/multidplyr",
#                            "uc-cfss/rcfss"))


