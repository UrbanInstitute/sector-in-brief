#' Add the geo-level predicate to a query filter list.
#'
#' Called from `query_builder()`. Picks the right vector to filter on
#' based on the active geo_level (state_mult vs state_single, county
#' vs cbsa, etc.).
#'
#' @param filter_ls In-progress filter list.
#' @param level Active geo level (e.g. "Census State", "Metro/Micro Area").
#' @param region,state_single,state_mult,county,cbsa Selections from
#'   the geo filter UI; only the one matching `level` is consumed.
#' @return `filter_ls` with one (or, for County, two) new entries added.
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
    # County names are NOT unique across states (e.g. Monroe County
    # exists in 17 states). The county picker is cascaded from a single
    # selected state, so scope the filter to that state too — otherwise
    # same-named counties elsewhere are swept in, inflating totals.
    # CBSA below needs no such scoping: metro names embed their state(s)
    # and legitimately span state lines.
    if (length(state_single) > 0 && any(nzchar(state_single))) {
      filter_ls[["Census State"]] <- state_single
    }
    filter_ls[[level]] <- county
  } else if (level == "Metro/Micro Area") {
    filter_ls[[level]] <- cbsa
  }
  return(filter_ls)
}
  