source("load.R")

library(plotly)
library(magrittr)

station_times %>%
  group_by(station) %>%
  summarize(across(
    diff_min,
    .fns = list(
      min = min,
      max = max,
      mean = mean,
      median = median,
      count = ~ n()
    )
  ))

station_times %>%
  filter(train == 42) %>%
  select(station, scheduled, estimated, diff, diff_min) %>%
  ggplot(aes(x = estimated, y = diff_min)) +
  geom_line()

(station_times %>% # wrapped in () so we can pipe to `ggplotly`
    mutate(
      seconds_since_journey_departure = estimated - min(estimated),
      mins_since_journey_departure = as.integer(seconds_since_journey_departure) / 60
    ) %>%
    ggplot(aes(x = mins_since_journey_departure, y = diff_min, colour = train_id, fill = train_id)) +
    geom_line() +
    geom_point()) %>%
  ggplotly()


