# install-packages.R
# 8/24/18 BCS
# Get a list of required packages to install on RStudio Cloud
# and setup a default project

library(tidyverse)
library(magrittr)

# get list of .Rmd files
rmd_files <- list.files(
  path = "content/",
  pattern = "*.Rmarkdown|*.Rmd",
  full.names = TRUE,
  recursive = TRUE
)

# read in each file and store in a list of character vectors
packages <- tibble(filepath = rmd_files) %>%
  mutate(content = map(filepath, read_lines)) %>%
  # unnest content
  unnest(content)

packages_lib <- packages %>%
  # find lines which start with `library(` %>%
  filter(startsWith(content, "library")) %>%
  # get unique content
  select(content) %>%
  distinct() %$%
  # extract library names
  str_extract(content, "\\([^()]+\\)") %>%
  str_remove_all("\\(|\\)")

packages_colon <- packages %>%
  # find packages directly called using :: syntax
  mutate(libs = str_extract_all(content, "([^\\s]+)\\:\\:")) %>%
  unnest_longer(libs) %>%
  mutate(libs = str_remove_all(libs, "[^a-zA-Z]")) %>%
  filter(libs != "") %>%
  drop_na() %>%
  distinct(libs) %>%
  pull(libs)

# ones to manually install
packages_manual <- c("randomForest", "textdata", "vroom", "leaflet",
                     "widgetframe", "mapproj", "kimisc", "RSQLite",
                     "ranger", "topicmodels", "gsl", "datasauRus",
                     "gganimate", "coefplot", "emo", "babynames",
                     "countrycode", "janitor")

packages <- c(packages_lib, packages_colon, packages_manual) %>%
  unique()

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

# # which are not on CRAN
# with(pkg_cran, packages[!on_cran]) %>%
#   map(library, character.only = TRUE)


# ###### code to run on RStudio cloud project
# pkg_cran <- c("reprex", "tidyverse", "sf", "tidycensus", "viridis", "knitr",
#               "gapminder", "forcats", "broom", "wordcloud", "tidytext", "rebird",
#               "geonames", "modelr", "rsample", "magrittr", "ISLR", "titanic",
#               "microbenchmark", "partykit", "caret", "nycflights13", "ggplot2",
#               "tibble", "harrypotter", "ggwordcloud", "here", "arrow", "readxl",
#               "haven", "ggmap", "rnaturalearth", "rtweet", "leaflet", "stringr",
#               "widgetframe", "RColorBrewer", "patchwork", "ymlthis", "RSocrata",
#               "dplyr", "shiny", "httr", "repurrrsive", "purrr", "acs", "downloader",
#               "statebins", "rsparkling", "sparklyr", "h2o", "dbplyr", "bigrquery",
#               "FNN", "maps", "gam", "tm", "tictoc", "topicmodels", "rjson", "LDAvis",
#               "rvest", "datasauRus", "gganimate", "socviz", "margins", "curl",
#               "jsonlite", "XML", "usethis", "devtools", "blogdown", "scales", "RCurl",
#               "rmarkdown", "readr", "reshape", "randomForest", "vroom", "kimisc",
#               "htmltools", "DT", "listviewer", "DBI", "SnowballC", "ranger", "slam",
#               "textdata", "mapproj", "RSQLite", "gsl", "coefplot", "babynames",
#               "countrycode", "janitor")
# 
# install.packages(pkg_cran)
# 
# # install packages from GitHub
# install.packages("remotes")   # needed to install packages directly from GitHub
# remotes::install_github(c(
#   "bradleyboehmke/harrypotter",
#   "uc-cfss/rcfss",
#   "ManifestoProject/manifestoR",
#   "cpsievert/LDAvisData",
#   "hrbrmstr/albersusa",
#   "hadley/emo"
# ))
