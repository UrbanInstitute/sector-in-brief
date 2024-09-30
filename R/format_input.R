format_input <- function(input, geo_filters, time_series, title_prefix, year_var){
  inputs <- list(
    org_level = input$org_level,
    other_orgs = input$other_orgs,
    geo_level = geo_filters$geo_level(),
    geo_region = geo_filters$region_selector(),
    geo_state_single = geo_filters$state_selector_single(),
    geo_state_multi = geo_filters$state_selector_multi(),
    geo_county = geo_filters$county_selector(),
    geo_cbsa = geo_filters$cbsa_selector(),
    subsector = input$subsector_select,
    size = input$size_filter,
    year_range = input$date_range,
    time_series = time_series,
    title_prefix = title_prefix,
    year_var = year_var
  )
  return(inputs)
}