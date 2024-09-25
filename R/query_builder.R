# This function creates a named list of queries for the data
query_builder <- function(inputs) {
  # Load params
  org_level <- inputs$org_level
  other_orgs <- inputs$other_orgs
  geo_level <- inputs$geo_level
  region <- inputs$region
  state_single <- inputs$state_single
  state_mult <- inputs$state_mult
  county <- inputs$county
  cbsa <- inputs$cbsa
  subsector_select <- inputs$subsector_select
  size_select <- inputs$size_select
  year_range <- inputs$year_range
  # Create query list
  filter_ls <- list("Organization Type" = org_level)
  # Organization Type
  if (org_level == "501(c)(4) Social Welfare Organizations") {
    filter_ls[["Organization Type"]] <- "501(c)(4) Social Welfare Organizations"
  } else if (org_level == "Other Organizations") {
    filter_ls[["Organization Type"]] <- other_orgs
  }
  # Geographies
  if (geo_level == "all") {
    geo_level <- "Census State"
    geo_selection <- unique(geo_df[["Census State"]])
  } else if (geo_level == "Census Region") {
    geo_selection <- paste(region, collapse = ", ")
  } else if (geo_level == "Census State") {
    if (length(state_mult) > 0) {
      geo_selection <- paste(state_mult, collapse = ", ")
    } else {
      geo_selection <- state_single
    }
  } else if (geo_level == "Census County") {
    geo_selection <- paste(county, collapse = ", ")
  } else if (geo_level == "Census CBSA") {
    geo_selection <- paste(cbsa, collapse = ", ")
  }
  filter_ls[[geo_level]] <- geo_selection
  # Subsector
  filter_ls[["Subsector"]] <- subsector_select
  # Asset Size
  filter_ls[["Asset Size"]] <- size_select
  # Date Range
  if (length(year_range) > 0) {
    years <- seq(year_range[1], year_range[2])
    filter_ls[["Year"]] <- years
  }
  
  return(filter_ls)
}