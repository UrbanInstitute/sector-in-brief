# This function creates a named list of queries for the data
query_builder <- function(inputs, geo_df) {
  # Load params
  org_level <- inputs$org_level
  other_orgs <- inputs$other_orgs
  geo_level <- inputs$geo_level
  region <- inputs$geo_region
  state_single <- inputs$geo_state_single
  state_mult <- inputs$geo_state_multi
  county <- inputs$geo_county
  cbsa <- inputs$geo_cbsa
  subsector <- inputs$subsector
  size <- inputs$size
  year_range <- inputs$year_range
  year_var <- inputs$year_var
  time_series <- inputs$time_series
  # Create query list
  filter_ls <- list()
  # Organization Type
  if (! is.null(org_level)){
    filter_ls[["Organization Type"]] <- org_level
    if (org_level == "501(c)(4) Social Welfare Organizations") {
      filter_ls[["Organization Type"]] <- "501(c)(4)"
    } else if (org_level == "Other Organizations") {
      filter_ls[["Organization Type"]] <- other_orgs
    }
  }
  # Geographies
  if (geo_level == "all") {
    geo_level <- "Census Region"
    geo_selection <- c("Northeast", "Midwest", "South", "West")
  } else if (geo_level == "Census Region") {
    geo_selection <- paste(region)
  } else if (geo_level == "Census State") {
    if (length(state_mult) > 0) {
      geo_selection <- paste(state_mult)
    } else {
      geo_selection <- state_single
    }
  } else if (geo_level == "Census County") {
    geo_selection <- paste(county)
  } else if (geo_level == "Census CBSA") {
    geo_selection <- paste(cbsa)
  }
  filter_ls[[geo_level]] <- geo_selection
  # Subsector
  filter_ls[["Subsector"]] <- subsector
  # Asset Size
  filter_ls[["Asset Size"]] <- size
  # Date Range
  if (time_series == TRUE) {
    years <- seq(year_range[1], year_range[2])
    filter_ls[[year_var]] <- years
  }
  query_ls <- list(filters = filter_ls, geo_level = geo_level)
  return(query_ls)
}