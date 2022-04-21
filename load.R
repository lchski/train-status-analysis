library(tidyverse)
library(lubridate)
library(jsonlite)
library(janitor)

status_dir <- "../data/via-train-status-data/statuses/csv/"
status_files <- fs::dir_ls(status_dir, glob = "*.csv")

working_timezone <- "Canada/Eastern" # assume VIA works in Eastern time, so we transpose when we cast `as_datetime`

statuses_raw <- map_df(status_files, read_csv, .id = "source_file") %>%
  clean_names %>%
  mutate(
    source_file = str_remove_all(source_file, status_dir),
    scrape_date = as_datetime(str_remove_all(source_file, fixed(".csv")), tz = working_timezone)
  ) %>%
  select(source_file, scrape_date, everything())

statuses <- statuses_raw %>%
  mutate(
    train_date = str_remove(train, "^[0-9]*"),
    train_date = str_remove_all(train_date, "^ \\(|\\)$"),
    train_date = if_else(
      train_date == "",
      date(scrape_date),
      as_date(paste0(year(scrape_date), train_date))
    ),
    train = as.integer(str_extract(train, "^[0-9]*")),
    train_id = paste0(train, "_", train_date)
  ) %>%
  select(source_file, scrape_date, train_id, train, train_date, everything())

train_summaries <- statuses %>%
  select(-source_file, -times) %>%
  filter( # filter out trains still on the move
    arrived & departed |
    ! arrived & ! departed
  ) %>%
  distinct()

arrived_trains <- train_summaries %>%
  filter(arrived, departed)

status_times <- statuses %>%
  select(scrape_date, train_id, times) %>%
  mutate(times = map(times, fromJSON)) %>%
  unnest(c(times)) %>%
  unnest_wider(c(departure, arrival), names_sep = "_") %>%
  clean_names %>%
  mutate(across(matches("estimated|scheduled"), ~ as_datetime(.x, tz = working_timezone)))


# THOUGHTS!
# 
# We want to get the “last” set of arrival data for each train. We could use arrived_trains,
# group_by(train_id), slice_tail() to get `scrape_date`. Then we could left_join status_times
# on train_id, for the `times` once the train has arrived.

station_times <- arrived_trains %>%
  select(train_id, train, scrape_date) %>%
  group_by(train_id) %>%
  slice_max(scrape_date) %>%
  left_join(status_times)

# Very alternatively, make a scraper for the status data per train: https://reservia.viarail.ca/tsi/GetTrainStatus.aspx?l=en&TsiCCode=VIA&TsiTrainNumber=84&DepartureDate=2022-04-19&ArrivalDate=2022-04-19&TrainInstanceDate=2022-04-19

