# Script to wrangle sensor data

library(tidyverse)

#  Load sensor data, 
sensor_raw <- read_csv(here::here("data/workshop2/estuary_sonde_data.csv"))

# Check sensor data
head(sensor_raw)
str(sensor_raw)
glimpse(sensor_raw)
summary(sensor_raw)


### Clean up sensor data
sensor_data <- 
  sensor_raw |>
  mutate(
    # Parse the messy character string (Day/Month/Year Hour:Minute)
    datetime = dmy_hm(timestamp),
    # Convert the -999.0 hardware error to a true NA
    turbidity = na_if(turbidity, -999),
    # Convert negative salinity values to na
    salinity = ifelse(salinity < 0, NA, salinity),
  )

# Summarise 15-minute sonde data into daily means
sensor_daily <- sensor_data |>
  mutate(
    date = floor_date(datetime, "day"),
    date = as_date(date) # Ensure it matches the Date format of the catch log
  ) |>
  group_by(site, date) |>
  summarise(
    mean_temp = mean(temperature, na.rm = TRUE),
    mean_salinity = mean(salinity, na.rm = TRUE),
    .groups = "drop"
  )

