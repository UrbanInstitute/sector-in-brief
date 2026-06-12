# County picker choices for the Custom Panel Datasets download form.
#
# County NAMES collide heavily across states — "Washington County" exists in
# 30 states, and 422 county names are shared by more than one state. A
# name-keyed picker both hides which county you're selecting and (since the
# API filters by FIPS) can pull every same-named county in the selected
# states. So the picker is keyed on the collision-proof County FIPS (its
# value) and labelled "<County>, <ST>" (what the user reads). The form then
# sends FIPS straight through to the API's `geo_county_fips` filter — no
# name->code translation, no collision.

#' Build the county picker's choices: FIPS values, "County, ST" labels.
#'
#' @param geo_df Nested-geographies lookup (`load_geo_df()`); dotted column
#'   names, `County.FIPS` already character (leading zeros preserved).
#' @param states Optional state abbreviations (`geo_select`) to scope the
#'   list to; `NULL` returns every county.
#' @return A named character vector — names are `"<County>, <ST>"` labels,
#'   values are County FIPS — sorted by label. Empty when nothing matches.
county_fips_choices <- function(geo_df, states = NULL) {
  rows <- geo_df
  if (!is.null(states)) {
    rows <- rows[rows[["Census.State"]] %in% states, , drop = FALSE]
  }
  fips <- as.character(rows[["County.FIPS"]])
  keep <- !is.na(fips) & nzchar(fips) & !duplicated(fips)
  rows <- rows[keep, , drop = FALSE]
  if (nrow(rows) == 0) {
    return(character(0))
  }
  labels <- paste0(rows[["Census.County"]], ", ", rows[["Census.State"]])
  ord <- order(labels)
  stats::setNames(as.character(rows[["County.FIPS"]][ord]), labels[ord])
}
