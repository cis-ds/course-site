## get-311.R
## 
## Use the NYC Data Portal API to get 311 reports and crime data

library(tidyverse)
library(RSocrata)
library(here)

# use API to get 311 complaints for
# - Food Poisoning
# - Sidewalk Condition
nyc_311 <- read.socrata(
  url = "https://data.cityofnewyork.us/resource/erm2-nwe9.json?$where=complaint_type in('Food Poisoning', 'Sidewalk Condition')"
) %>%
  as_tibble()

# clean up/shrink the dataset for exercises
nyc_311 %>%
  select(unique_key, created_date, complaint_type, borough, latitude, longitude) %>%
  mutate(across(.cols = c(latitude, longitude), .fns = as.numeric)) %>%
  write_csv(here("static", "data", "nyc-311.csv"))

# use API to get year to date NYPD complaint data
nyc_crimes <- read.socrata(
  url = "https://data.cityofnewyork.us/resource/5uac-w243.json"
) %>%
  as_tibble()

# clean up/shrink the dataset for demos
nyc_crimes %>%
  select(cmplnt_num, boro_nm, cmplnt_fr_dt, law_cat_cd, ofns_desc, latitude, longitude) %>%
  mutate(across(.cols = c(latitude, longitude), .fns = as.numeric)) %>%
  write_csv(here("static", "data", "nyc-crimes.csv"))
