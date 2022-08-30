## get-311.R
## 
## Use the Chicago Data Portal API to get 311 reports for dead animals and potholes

library(tidyverse)
library(RSocrata)
library(here)

# use API to get 311 complaints for dead animals and potholes
short_codes <- c("SGQ", "PHF")
short_codes_urls <- str_c(
  "https://data.cityofchicago.org/resource/v6vf-nfxy.json?sr_short_code=",
  short_codes
)

# generate all queries
chi_311_full <- map_df(short_codes_urls, read.socrata) %>%
  as_tibble()

# clean up/shrink the dataset for exercises
chi_311_full %>%
  select(starts_with("sr"), -sr_type, created_date, community_area, ward, latitude, longitude) %>%
  mutate(across(.cols = c(community_area, ward, latitude, longitude), .fns = as.numeric)) %>%
  write_csv(here("data", "chicago-311.csv"))
