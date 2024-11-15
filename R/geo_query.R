#' @title Function to edit query for geographic filters
#' @param filter_ls list of filters
#' @param level character scalar. Census geographic unit
#' @param region character vector. Census region
#' @param state_single character scalar. Census state
#' @param state_mult character vector. Multiple census states
#' @param county character vector. Census county
#' @param cbsa character vector. Census CBSA
geo_query <- function(filter_ls,
                      level,
                      region,
                      state_single,
                      state_mult,
                      county,
                      cbsa) {
  if (level == "Census Region") {
    filter_ls[[level]] <- region
  } else if (level == "Census State") {
    if (length(state_mult) > 0) {
      filter_ls[[level]] <- state_mult
    } else {
      filter_ls[[level]] <- state_single
    }
  } else if (level == "Census County") {
    filter_ls[[level]] <- county
  } else if (level == "Census CBSA") {
    filter_ls[[level]] <- cbsa
  }
  return(filter_ls)
}
  