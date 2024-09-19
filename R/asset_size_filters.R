size_level_choices <- list(
  "All Asset Sizes" = "all", 
  "Individual Asset Sizes" = "individual"
)

size_choices <- list(
  "Under $100,000" = 1,
  "$100,000 - $499,999" = 2,
  "$500,000 - $999,999" = 3,
  "$1 Million - $4.99 Million" = 4,
  "$5 Million - $9.99 Million" = 5,
  "Above $10 Million" = 6
)

radio_button_vars <- tibble::tribble(
  ~ inputId, ~ label, ~ inline, ~ choices,
  "size_level", NULL, TRUE, size_level_choices
)

selectize_vars <- tibble::tribble(
  ~ inputId, ~ label, ~ choices, ~ multiple, ~ options,
  "size_select", NULL, size_choices, TRUE, list(maxItems = 5)
)

size_level_filter <- build_filters(shiny::radioButtons, radio_button_vars)
size_select_filter <- build_filters(shiny::selectizeInput, selectize_vars)