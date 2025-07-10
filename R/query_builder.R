# This function creates a named list of queries for the data
query_builder <- function(inputs, geo_df) {
  # Create query list
  filter_ls <- list()
  # 1. Organization Type
  filter_ls <- ctype_query(filter_ls, inputs$ctype)
  # 2. Geographies
  filter_ls <- geo_query(filter_ls, inputs)
  # 3. Subsector
  filter_ls <- filter_check("Subsector", 12, inputs, filter_ls)
  # 4. Size
  filter_ls <- filter_check("Size", 6, inputs, filter_ls)
  # 5. Date Range
  if (isTRUE(inputs$time_series)) {
    if (!is.null(inputs$year_range) && length(inputs$year_range) == 2) {
      years <- seq(inputs$year_range[1], inputs$year_range[2])
      filter_ls[[inputs$year_var]] <- years
    } else {
      warning("time_series is TRUE but year_range is not correctly specified.")
    }
  }
  query_ls <- list(filters = filter_ls, geo_level = geo_level)
  return(query_ls)
}

#' @title Function to create ctype query
#' @param filter_ls list of filters
#' @param ctype character scalar. 501(c) type.
#' @return list of filters edited in place
ctype_query <- function(filter_ls, ctype){
  filter_ls[["Organization Type"]] <- ctype_id[ctype] |> unlist()
  return(filter_ls)
}

#' @title Function to edit query for geographic filters
#' @param filter_ls list of filters
#' @param level character scalar. Census geographic unit
#' @param region character vector. Census region
#' @param state_single character scalar. Census state
#' @param state_mult character vector. Multiple census states
#' @param county character vector. Census county
#' @param cbsa character vector. Census CBSA
geo_query <- function(filter_ls, query_params) {
  # For national views, default to regional disaggregations
  if (query_params$geo_level == "National") {
    query_params$geo_level <- "Census Region"
    query_params$geo_region <- c("Northeast", "Midwest", "South", "West")
  }
  filter_ls <- switch(
    query_params$geo_level,
    "Census Region" = query_params$geo_region,
    "Census State" = if (length(query_params$geo_state_mult) > 0) {
      query_params$geo_state_mult
    } else {
      query_params$geo_state_single
    },
    "Census County" = query_params$geo_county,
    "Metro/Micro Area" = query_params$geo_cbsa
  )
  return(filter_ls)
}

filter_check <- function(filter, max_len, inputs, filter_ls){
  input <- inputs[[tolower(filter)]]
  if (!is.null(input) && length(input) > 0 && length(input) < max_len) {
    filter_ls[[filter]] <- input
  }
  return(filter_ls)
}