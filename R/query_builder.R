#-------------------------------------------------------------------------------
# File: query_builder.R
# Programmer: Thiyaghessan [tpoongundranar@urban.org]
# Date created: 2024-06-01
# Date last modified: 2025-07-11
# Purpose: This file contains all of the functions used to construct the query 
# parameters for the data pipeline. It builds a list of filters based on user
# inputs and geographic selections, which is then used to filter the data.
#
# Usage: query_builder is part of the data_pipeline() called with the data server
# module
#
# Dependencies:
# - R/options_nogeo.R
#-------------------------------------------------------------------------------

#' @title Function to build query parameters for data filtering
#' 
#' @description This function constructs a list of filters based on user inputs
#' and geographic selections. It includes organization type, geographic area,
#' subsector, size, and date range. The function also handles special cases for
#' national views by defaulting to regional disaggregations.
#' 
#' @param inputs A list of user inputs containing filter selections and geographic
#' parameters.
#' @param geo_df A data frame containing geographic information for filtering.
#' 
#' @return A list containing the filters and geographic level for the query.
query_builder <- function(inputs, geo_df) {
  if (inputs$geo_level == "National") {
    inputs$geo_level <- "Census Region"
    inputs$geo_region <- c("Northeast", "Midwest", "South", "West")
  }
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
  query_ls <- list(filters = filter_ls, geo_level = inputs$geo_level)
  return(query_ls)
}

#' @title Function to create ctype query
#' 
#' @description This function modifies the filter list to include the selected
#' 501(c) type. It uses a predefined mapping of ctype to IDs.
#' 
#' @param filter_ls list of filters
#' @param ctype character scalar. 501(c) type.
#' 
#' @return list of filters edited in place
ctype_query <- function(filter_ls, ctype){
  filter_ls[["Organization Type"]] <- ctype_id[ctype] |> unlist()
  return(filter_ls)
}

#' @title Function to edit query for geographic filters
#' 
#' @description This function modifies the filter list based on the geographic
#' selections made by the user. It handles different geographic levels such as
#' Census Region, Census State, Census County, and Census CBSA. For national views,
#' it defaults to regional disaggregations.
#' 
#' @param filter_ls list of filters to edit in place
#' @param query_params A list containing geographic parameters such as geo_level,
#' geo_region, geo_state_mult, geo_state_single, geo_county, and geo_cbsa.
geo_query <- function(filter_ls, query_params) {
  # For national views, default to regional disaggregations
  filter_ls[[query_params$geo_level]] <- switch(
    query_params$geo_level,
    "Census Region" = query_params$geo_region,
    "Census State" = if (length(query_params$geo_state_mult) > 0) {
      query_params$geo_state_mult
    } else {
      query_params$geo_state_single
    },
    "Census County" = query_params$geo_county,
    "Census CBSA" = query_params$geo_cbsa
  )
  return(filter_ls)
}

#' @title Function to check and add filters to the filter list
#' 
#' @description This function checks if a filter input exists and has a valid
#' length. If so, it adds the filter to the filter list. For subsector and size,
#' if all values are selected, the filters aren't triggered.
#' 
#' @param filter character scalar. The name of the filter to check.
#' @param max_len integer scalar. The maximum length for the filter input.
#' @param inputs A list of user inputs containing filter selections.
#' @param filter_ls A list of filters to edit in place.
#' 
#' @return A list of filters with the specified filter added if it meets the criteria.
filter_check <- function(filter, max_len, inputs, filter_ls){
  input <- inputs[[tolower(filter)]]
  if (!is.null(input) && length(input) > 0 && length(input) < max_len) {
    filter_ls[[filter]] <- input
  }
  return(filter_ls)
}