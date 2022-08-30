## census-acs.R
## 
## Get data from Census Bureau ACS for exercises

library(tidyverse)
library(tidycensus)

# get foreign born population
get_acs(
  geography = "state",
  variables = c("total" = "B05012_001",  "native" = "B05012_002", "foreign" = "B05012_003"),
  year = 2019,
  output = "wide"
) %>%
  select(-ends_with("M")) %>%
  rename(total = totalE,
         native = nativeE,
         foreign = foreignE) %>%
  mutate(pct_foreign = foreign / total) %>%
  write_csv(file = here("data", "foreign-born.csv"))

# get median household income in 2019 for Cook County, IL by census tract
get_acs(
  state = "IL",
  county = "Cook",
  geography = "tract",
  variables = c(medincome = "B19013_001"),
  year = 2019,
  geometry = TRUE
) %>%
  st_write(dsn = here("data", "cook-county-inc.geojson"))

# get median household income in 2019 for all counties in the United States
get_acs(
  state = setdiff(x = state.abb, y = c("AK", "HI")),
  geography = "county",
  variables = c(medincome = "B19013_001"),
  year = 2019,
  geometry = TRUE
) %>%
  st_write(dsn = here("data", "usa-inc.geojson"))
