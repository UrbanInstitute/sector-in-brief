# Date Range Filter

source("R/build_filters.R")

vars <- tibble::tribble(
  ~ inputId, ~ label, ~ min, ~ max, ~ value, ~ step, ~ ticks, ~ sep, ~ dragRange,
  "date_range", NULL, 1989, 2024, c(1989, 2024), NULL, FALSE, "", TRUE
)

date_filter <- build_filters(sliderInput, vars)