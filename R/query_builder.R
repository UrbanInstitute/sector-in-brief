# This function creates a named list of queries for the data
query_builder <- function(inputs, geo_df) {
  # TODO: Figure out why private foundation code is being transformed incorrectly
  # Load params
  ctype <- inputs$ctype
  geo_level <- inputs$geo_level
  region <- inputs$geo_region
  state_single <- inputs$geo_state_single
  state_mult <- inputs$geo_state_mult
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
  filter_ls <- ctype_query(filter_ls, ctype)
  # Geographies
  if (geo_level == "National") {
    geo_level <- "Census Region"
    region <- c("Northeast", "Midwest", "South", "West")
  }
  filter_ls <- geo_query(filter_ls,
                         geo_level,
                         region,
                         state_single,
                         state_mult,
                         county,
                         cbsa)
  # Subsector
  if (length(subsector) < 12){
    filter_ls[["Subsector"]] <- subsector
  }
  # Size
  if (length(size) < 6) {
    filter_ls[["Size"]] <- size
  }
  # Date Range
  if (time_series == TRUE) {
    years <- seq(year_range[1], year_range[2])
    filter_ls[[year_var]] <- years
  }
  query_ls <- list(filters = filter_ls, geo_level = geo_level)
  return(query_ls)
}