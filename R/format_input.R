#' @title Format inputs for data pipeline
#' @param input A list of reactive user inputs
#' @param geo_filters A list of reactive geographic filters
#' @param time_series A boolean indicating time series data
#' @param title_prefix A character vector to prefix plot titles
#' @param year_var A character vector defining the year column
#' @param agg_var A character vector defining the column to aggregate
#' @return A list of formatted inputs
format_input <- function(input,
                         geo_filters,
                         time_series,
                         title_prefix,
                         year_var,
                         agg_var) {
  inputs <- list(
    ctype_level1 = input$ctype_level1,
    ctype_level2 = input$ctype_level2,
    geo_level = geo_filters$geo_level(),
    geo_region = geo_filters$region_selector(),
    geo_state_single = geo_filters$state_selector_single(),
    geo_state_mult = geo_filters$state_selector_multi(),
    geo_county = geo_filters$county_selector(),
    geo_cbsa = geo_filters$cbsa_selector(),
    subsector = input$subsector,
    size = input$size,
    year_range = input$date_range,
    time_series = time_series,
    title_prefix = title_prefix,
    year_var = year_var,
    agg_var = agg_var
  )
  return(inputs)
}