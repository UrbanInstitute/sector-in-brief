source("R/build_filters.R")

# Organization Type Filters

vars <- tibble::tribble(
  ~ inputId,   ~ label, ~ choices,
  "daf_org_level", NULL, c("501(c)(3) Public Charities","501(c)(4) Social Welfare Organizations", "Other Nonprofits","All Nonprofits"),
  "org_level", NULL, c("501(c)(3) Public Charities", "501(c)(3) Private Foundations", "501(c)(4) Social Welfare Organizations", "Other Nonprofits","All Nonprofits"),
)
names <- c("daf_org_filter", "nn_org_filter")

org_filters <- build_filters(selectizeInput, names, vars)
