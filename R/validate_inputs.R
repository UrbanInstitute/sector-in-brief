#' Validate user filter selections before running the data pipeline.
#'
#' Returns a structured result so callers can surface messages inline
#' next to the offending filter card rather than via a single modal.
#'
#' @param inputs The list produced by `format_input()`.
#' @return list with:
#'   - `valid`: TRUE if no problems
#'   - `errors`: named list keyed by filter group (`geo`, `subsector`, `size`),
#'     each value a single user-facing message. Only populated keys appear.
validate_inputs <- function(inputs) {
  errors <- list()

  if (inputs$geo_level == "Census Region") {
    if (length(inputs$geo_region) == 0) {
      errors$geo <- "Please select at least one region."
    }
  } else if (inputs$geo_level == "Census State") {
    if (length(inputs$geo_state_mult) == 0) {
      errors$geo <- "Please select at least one state."
    }
  } else if (inputs$geo_level == "Census County") {
    if (length(inputs$geo_county) == 0) {
      errors$geo <- "Please select at least one county."
    }
  } else if (inputs$geo_level == "Metro/Micro Area") {
    if (length(inputs$geo_cbsa) == 0) {
      errors$geo <- "Please select at least one Metro/Micro Area."
    }
  }

  if (length(inputs$subsector) == 0) {
    errors$subsector <- "Please select at least one subsector."
  }
  if (length(inputs$size) == 0) {
    errors$size <- "Please select at least one size category."
  }

  list(valid = length(errors) == 0, errors = errors)
}
