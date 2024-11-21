#' @title Function to format plot captions for selected geographies
#' @param caption A character string containing the plot caption
#' @param geo_level A character string indicating the level of geography
#' @param region A character vector of regions
#' @param state_single A character scalar of single states used with county/cbsa
#' @param state_mult A character vector of multiple states
#' @param county A character vector of counties
#' @param cbsa A character vector of CBSAs
#' @return A character string with the plot caption edited in place
caption_geo <- function(caption,
                      geo_level,
                      region,
                      state_single,
                      state_mult,
                      county,
                      cbsa) {
  if (geo_level == "National"){
    caption <- paste("Geography: National, grouped by regions.", "\n")
  }
  else if (geo_level == "Census Region") {
    caption <- paste("Region(s):", paste(region, collapse = ", "), "\n")
  }
  else if (geo_level == "Census State") {
    caption <- paste("State(s):", paste(state_mult, collapse = ", "), "\n")
  }
  else if (geo_level == "Census County") {
    caption <- paste("State:",
                     state_single,
                     "\n",
                     "County(s):",
                     paste(county, collapse = ", "),
                     "\n")
  }
  else if (geo_level == "Census CBSA") {
    caption <- paste(
      "State:",
      state_single,
      "\n",
      "Metro/Micro Area(s):",
      paste(cbsa, collapse = ", "),
      "\n"
    )
  }
  return(caption)
}