source("R/build_filters.R")

subsector_level_choices <- list(
  "All Subsectors" = "all", 
  "Individual Subsectors" = "individual"
)

subsector_choices <- list(
  "Arts, Culture, and Humanities" = "ART", 
  "Education (minus Universities)" = "EDU",
  "Health (minus Hospitals)" = "HEL",
  "Human Services" = "HMS",
  "International, Foreign Affairs" = "IFA",
  "Public, Societal Benefit" = "PSB",
  "Religion Related" = "REL",
  "Mutual/Membership Benefit" = "MMB",
  "Universities" = "UNI",
  "Hospitals" = "HOS"
)

radio_button_vars <- tibble::tribble(
  ~ inputId, ~ label, ~ inline, ~ choices,
  "nn_subsector_level", NULL, TRUE, subsector_level_choices
)

selectize_vars <- tibble::tribble(
  ~ inputId, ~ label, ~ choices, ~ multiple, ~ options,
  "nn_subsector_select", NULL, subsector_choices, TRUE, list(maxItems = 5)
)

subsector_level_filter <- build_filters(radioButtons, radio_button_vars)
subsector_select_filter <- build_filters(selectizeInput, selectize_vars)
