# gun-deaths.R
# 2017-02-01
# Examine the distribution of age of victims in gun_deaths


# load packages
library(tidyverse)
library(rcfss)

# filter data for under 65
youth <- gun_deaths %>%
  filter(age <= 65)

# number of individuals under 65 killed
nrow(gun_deaths) - nrow(youth)

# graph the distribution of youth
youth %>% 
  ggplot(aes(age)) + 
  geom_freqpoly(binwidth = 1)
