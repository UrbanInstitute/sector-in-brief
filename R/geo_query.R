#' Add the geo-level predicate to a query filter list.
#'
#' Called from `query_builder()`. Picks the right vector to filter on
#' based on the active geo_level (state_mult vs state_single, county
#' vs cbsa, etc.).
#'
#' County is filtered on `County FIPS` and Metro/Micro on `CBSA Code`,
#' not on their display names — the codes are collision-proof identity
#' keys (ADR 0021), so a county selection no longer needs to be scoped
#' to one state to avoid sweeping in same-named counties elsewhere
#' (Monroe County exists in 17 states; their FIPS differ).
#'
#' @param filter_ls In-progress filter list.
#' @param level Active geo level (e.g. "Census State", "Metro/Micro Area").
#' @param region,state_single,state_mult Region / state selections.
#' @param county,cbsa County FIPS / CBSA Code values from the picker
#'   (codes, not names); only the one matching `level` is consumed.
#' @return `filter_ls` with the geo predicate added. The key is the code
#'   column for County/Metro so the scan filters on identity, while
#'   `level` (the name column) stays the breakdown axis downstream.
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
    filter_ls[["County FIPS"]] <- county
  } else if (level == "Metro/Micro Area") {
    filter_ls[["CBSA Code"]] <- cbsa
  }
  return(filter_ls)
}
  