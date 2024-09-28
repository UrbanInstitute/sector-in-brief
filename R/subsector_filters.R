subsector_level_choices <- list(
  "All Subsectors" = "all", 
  "Individual Subsectors" = "individual"
)

subsector_choices <- list(
  "Arts, Culture, and Humanities - ART" = "ART", 
  "Education (minus Universities) - EDU" = "EDU",
  "Health (minus Hospitals) - HEL" = "HEL",
  "Human Services - HMS" = "HMS",
  "International, Foreign Affairs - IFA" = "IFA",
  "Public, Societal Benefit - PSB" = "PSB",
  "Religion Related - REL" = "REL",
  "Mutual/Membership Benefit - MMB" = "MMB",
  "Universities - UNI" = "UNI",
  "Hospitals - HOS" = "HOS"
)

radio_button_vars <- tibble::tribble(
  ~ inputId, ~ label, ~ inline, ~ choices,
  "subsector_level", NULL, TRUE, subsector_level_choices
)

selectize_vars <- tibble::tribble(
  ~ inputId, ~ label, ~ choices, ~ multiple, ~ options,
  "subsector_select", NULL, subsector_choices, TRUE, list(maxItems = 5)
)

subsector_level_filter <- build_filters(shiny::radioButtons, radio_button_vars)
subsector_select_filter <- build_filters(shiny::selectizeInput, selectize_vars)
