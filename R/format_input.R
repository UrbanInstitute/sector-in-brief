# Resolve a panel's Shiny inputs + reactive geo filters into a plain
# named list, so downstream functions (query_builder, validate_inputs)
# can be unit-tested without a reactive context. This is the boundary
# between the reactive world and pure functions.

#' Snapshot Shiny inputs into a plain named list for the pipeline.
#'
#' @param input The Shiny `input` reactive (current values are read here).
#' @param geo_filters The reactive return value of
#'   `geo_filter_server()` — a list of reactives, called here to
#'   resolve them to values.
#' @param time_series TRUE for line plots, FALSE for bar plots.
#' @param title_prefix Prefix used by `plot_title()` downstream.
#' @param year_var,agg_var Column names from `data_server_args`.
format_input <- function(input,
                         geo_filters,
                         time_series,
                         title_prefix,
                         year_var,
                         agg_var) {
  inputs <- list(
    ctype = input$ctype,
    geo_level = geo_filters$geo_level(),
    geo_region = geo_filters$region(),
    geo_state_single = geo_filters$state_single(),
    geo_state_mult = geo_filters$state_mult(),
    geo_county = geo_filters$county(),
    geo_cbsa = geo_filters$cbsa(),
    # County/metro are selected by code; carry the resolved display
    # names alongside so chips, captions, and notes read names not codes.
    geo_county_label = geo_filters$county_label(),
    geo_cbsa_label = geo_filters$cbsa_label(),
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