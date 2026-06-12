# State-picker choices scoped to the selected Census region(s), for the
# Custom Panel Datasets download form.
#
# The download API ANDs a census_region filter with the state filter
# (sector-in-brief-api query.py::_expand_region_filter intersects the
# region's states with the selected geo_state_abbr). A contradictory pair —
# e.g. region "Northeast" with state "AZ" (West) — intersects to the empty
# set, which the API renders as `geo_state_abbr IN ()` and 500s on (see
# sector-in-brief-api#13). Constraining the state picker to the selected
# region(s) makes that combination unselectable, so the intersection is
# always the selected states. The region partition in geo_df is verified to
# match the API's CENSUS_REGION exactly.

#' Subset the state choices to those in the selected Census region(s).
#'
#' @param geo_df Nested-geographies lookup (`load_geo_df()`); carries
#'   `Census.State` (abbr) and `Census.Region`.
#' @param regions Selected region labels (`region_select`); empty/NULL means
#'   no region filter.
#' @param state_choices The full named state list (`choices.R::state_choices`,
#'   name = state name, value = abbr).
#' @return `state_choices` filtered to states in `regions`, preserving its
#'   name=label / value=abbr structure. The full list when `regions` is empty.
region_state_choices <- function(geo_df, regions, state_choices) {
  if (length(regions) == 0) {
    return(state_choices)
  }
  abbrs <- unique(geo_df[["Census.State"]][geo_df[["Census.Region"]] %in% regions])
  state_choices[unlist(state_choices, use.names = FALSE) %in% abbrs]
}
