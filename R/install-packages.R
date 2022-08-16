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

# # install packages from GitHub
install.packages("remotes")   # needed to install packages directly from GitHub
remotes::install_github(c(
  "bradleyboehmke/harrypotter",
  "cis-ds/rcis",
  "ManifestoProject/manifestoR",
  "cpsievert/LDAvisData",
  "hadley/emo",
  "averyrobbins1/appa",
  "cpsievert/LDAvisData"
))

# manually collected packages that need to be installed
install.packages(
  c(
    "tidycensus",
    "textdata",
    "stopwords",
    "rnaturalearth",
    "mapproj",
    "kimisc",
    "glmnet",
    "naivebayes",
    "C50",
    "topicmodels",
    "tsne",
    "sentopics",
    "doParallel",
    "xaringan",
    "xaringanthemer",
    "styler",
    "datapasta"
  )
)