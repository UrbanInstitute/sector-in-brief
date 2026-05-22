# Packages the Custom Panel Datasets form into the JSON payload the
# NCCS data-extract API expects. Companion to query_builder.R (which
# builds the in-process arrow filter spec); this one targets an
# external service and a different schema (UPPER_SNAKE column names).

#' Build the data-extract API request from the form's inputs.
#'
#' @param inputs Form inputs gathered by `dataRequestServer()`.
#' @return A JSON string ready to POST to the data-extract endpoint.
query_builder_download <- function(inputs) {
  filters <- list()
  vars <- list(
    "var" = c(
      "EIN2",
      "ORG_TYPE",
      "ASSET_SIZE",
      "SUBSECTOR",
      "CENSUS_STATE_ABBR",
      "CENSUS_COUNTY_NAME",
      "CENSUS_CBSA_NAME",
      "CENSUS_REGION",
      "TAX_YEAR"
    )
  )
  panel_dd <- readr::read_csv("data/panel_dd.csv") |>
    dplyr::mutate(
      part = substr(variable_name, 4, 5)
    )
  # Option 2
  filters[["ORG_TYPE"]] <- inputs$org_select
  filters[["ASSET_SIZE"]] <- inputs$asset_select
  filters[["SUBSECTOR"]] <- inputs$subsector_select
  # Option 3
  filters[["CENSUS_STATE_ABBR"]] <- inputs$geo_select
  filters[["CENSUS_COUNTY_NAME"]] <- inputs$county_select
  filters[["CENSUS_CBSA_NAME"]] <- inputs$cbsa_select
  filters[["CENSUS_REGION"]] <- inputs$region_select
  # Option 4
  filters[["TAX_YEAR"]] <- as.character(unique(inputs$start_year:inputs$end_year))
  # Option 5
  panel_vars <- panel_dd |>
    dplyr::filter(part %in% inputs$data_select) |>
    dplyr::pull(variable_name)
  vars[["var"]] <- c(vars$var, panel_vars)
  
  
  
  request <- list(
    "requestContext" = list(
      "stage" = "stg",
      "userEmail" = jsonlite::unbox(inputs$email)
    ),
    "queryParameters" = list(
      "varParameters" = vars,
      "filterParameters" = filters,
      "stage" = jsonlite::unbox("stg")
    )
  )
  
  request <- jsonlite::toJSON(request)
  
  return(request)
}