query_builder_download <- function(inputs){
  filters <- list()
  vars <- list(
    "var" = c(
      "EIN2",
      "ORG_TYPE",
      "Size",
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
  filters[["Size"]] <- inputs$asset_select
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