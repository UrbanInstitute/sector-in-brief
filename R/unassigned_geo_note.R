# Per-state "unassigned geography" note. Under ADR 0021 the producer
# leaves Census County (and Metro/Micro Area) NA whenever a record's raw
# geocoded label can't be resolved to a canonical county — honest
# "unassigned" rather than a polluted dropdown. Those NA-geo records fall
# out of any FIPS/CBSA-keyed county/metro selection, so the geographic
# breakdown silently under-counts a state's total. This note makes that
# legible: for the state(s) currently in view it sums the metric on the
# NA-geography cells so the user sees how much is excluded (notably
# Connecticut, whose post-2022 planning-region labels resolve to NA).
#
# Distinct from missing_geo_note (R/missing_geo_note.R), which flags
# user-selected geographies that returned no data. This one counts the
# records that have no assignable geography at all.

#' Build the per-state "records with no assigned county/metro" note.
#'
#' Fires only for the state-scoped geo levels (Census State / Census
#' County / Metro/Micro Area) with a state selected — National and Region
#' aggregate every record and would report an uninformative grand total.
#' Respects the active non-geo filters (org type / subsector / size /
#' year) so the count matches what the panel is showing.
#'
#' @param data Lazy arrow Dataset for the panel (from `dataloader()`).
#' @param inputs Snapshot from `format_input()` (geo level + state).
#' @param query Query spec from `query_builder()` (for the non-geo filters).
#' @param agg_var Metric column to sum on the NA-geo cells; when it is not
#'   a real column (e.g. the DAF proportion) the note counts records.
#' @return A single-string note, or NULL when nothing is unassigned.
unassigned_geo_note <- function(data, inputs, query, agg_var) {
  geo_level <- inputs$geo_level
  states <- switch(
    geo_level,
    "Census State"     = if (length(inputs$geo_state_mult) > 0) {
      inputs$geo_state_mult
    } else {
      inputs$geo_state_single
    },
    "Census County"    = inputs$geo_state_single,
    "Metro/Micro Area" = inputs$geo_state_single,
    NULL
  )
  states <- states[!is.na(states) & nzchar(states)]
  if (length(states) == 0) return(NULL)

  na_col <- if (geo_level == "Metro/Micro Area") "Metro/Micro Area" else "Census County"

  # Carry the non-geo filters; swap the geo predicate for the state scope
  # plus the NA-geography test.
  geo_keys <- c("County FIPS", "CBSA Code", "Census County",
                "Metro/Micro Area", "Census State", "Census Region")
  nongeo <- query$filters[setdiff(names(query$filters), geo_keys)]

  d <- data
  for (col in names(nongeo)) {
    d <- dplyr::filter(d, !!rlang::sym(col) %in% !!nongeo[[col]])
  }
  d <- dplyr::filter(d, `Census State` %in% !!states, is.na(!!rlang::sym(na_col)))

  has_metric <- agg_var %in% names(data)
  agg <- if (has_metric) {
    dplyr::summarise(dplyr::group_by(d, `Census State`),
                     value = sum(!!rlang::sym(agg_var), na.rm = TRUE))
  } else {
    dplyr::summarise(dplyr::group_by(d, `Census State`),
                     value = dplyr::n())
  }
  agg <- dplyr::collect(agg)
  agg <- agg[!is.na(agg$value) & agg$value > 0, , drop = FALSE]
  if (nrow(agg) == 0) return(NULL)

  fmt <- if (has_metric && agg_var %in% .dollar_metrics) {
    scales::label_dollar(scale_cut = scales::cut_short_scale())
  } else {
    scales::comma
  }
  parts <- sprintf("%s (%s)", agg[["Census State"]], fmt(agg$value))

  geo_phrase <- if (geo_level == "Metro/Micro Area") {
    "in no metro/micro area (rural or unmapped)"
  } else {
    "with no assigned county"
  }
  paste0("Excluded from the geographic breakdown — records ", geo_phrase,
         ": ", paste(parts, collapse = ", "), ".")
}
