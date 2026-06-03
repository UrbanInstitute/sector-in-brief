# When a user explicitly selects geographies (states / counties / metro
# areas) and some of them have no reported data, the NA-drop in
# dataloader() removes those cells entirely, so the geography silently
# vanishes from the breakdown. This builds an inline note naming the
# absent selections so the omission is legible ("no reported data" rather
# than a measured $0 or an apparent bug). Affects the NA-drop dollar
# panels (DAFs, Government Grants, Program-Related Investments) most,
# but the logic is panel-agnostic.

#' Note text for user-selected geographies absent from the result.
#'
#' Only fires for the explicit small-N geo levels (State / County /
#' Metro-Micro). National and Region are skipped: National is rewritten
#' to all four regions in query_builder(), so a "missing region" there
#' is not an explicit user choice.
#'
#' @param query Query spec from `query_builder()` (`filters`, `geo_level`).
#' @param tables Named list from `summarise_data()`; uses `by_geo`.
#' @param agg_var Metric column name, used to phrase the note.
#' @return A single-string note, or NULL when nothing is missing.
missing_geo_note <- function(query, tables, agg_var) {
  geo_level <- query$geo_level
  if (!geo_level %in% c("Census State", "Census County", "Metro/Micro Area")) {
    return(NULL)
  }
  selected <- as.character(query$filters[[geo_level]])
  if (length(selected) == 0) return(NULL)

  geo_tbl <- tables[["by_geo"]]
  # blank_table() (empty result) lacks the geo column — nothing to diff;
  # the overall empty-state placeholder already covers that case.
  if (is.null(geo_tbl) || !geo_level %in% names(geo_tbl)) return(NULL)

  present <- unique(as.character(geo_tbl[[geo_level]]))
  present <- present[!is.na(present)]
  missing <- setdiff(selected, present)
  if (length(missing) == 0) return(NULL)

  metric <- sub("^Total ", "", agg_var)
  paste0("No reported ", metric,
         " for the following selected areas: ",
         paste(missing, collapse = ", "), ".")
}
