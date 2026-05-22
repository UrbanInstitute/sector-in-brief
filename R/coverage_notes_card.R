# Surface producer-curated coverage notes from data_dictionary.parquet
# as an inline accordion above the visualization plots, filtered to the
# parquet file backing the current panel. The notes call out documented
# data gaps (e.g. PF 2011-2016 partial coverage, DAF coverage starts
# 2021) that materially affect interpretation of the charts.

.dict_cache <- new.env(parent = emptyenv())

#' Read (and memoise) the parquet data dictionary.
#'
#' Cached for the session via a module-level env. Tests can replace
#' `.dict_cache$df` directly via `local_dict_fixture()` (see
#' helper-fixtures.R) to avoid touching disk.
#'
#' @param path Path to `data_dictionary.parquet`.
#' @return Tibble with columns file, column, datatype, description,
#'   form_source, coverage, coverage_notes.
load_data_dictionary <- function(path = "data/data_dictionary.parquet") {
  if (is.null(.dict_cache$df)) {
    .dict_cache$df <- arrow::read_parquet(path)
  }
  .dict_cache$df
}

#' Build the per-panel coverage-notes accordion.
#'
#' Filters the data dictionary to rows for the panel's parquet file
#' that have non-empty `coverage_notes`, formats them as a bulleted
#' list inside a collapsed accordion. NULL when no notes apply.
#'
#' @param parquet_file Filename for the active panel (matches
#'   data_dictionary's `file` column).
#' @return A `bslib::accordion` or NULL.
coverage_notes_card <- function(parquet_file) {
  if (is.na(parquet_file) || !nzchar(parquet_file)) return(NULL)
  dd <- load_data_dictionary()
  notes <- dd[dd$file == parquet_file & nzchar(dd$coverage_notes), ]
  if (nrow(notes) == 0) return(NULL)
  items <- lapply(seq_len(nrow(notes)), function(i) {
    htmltools::tags$li(
      htmltools::tags$b(notes$column[i]),
      " (", notes$coverage[i], "): ",
      notes$coverage_notes[i]
    )
  })
  bslib::accordion(
    open = FALSE,
    urbn_accordion_panel(
      title = "Known Data Coverage Gaps",
      htmltools::p(
        class = "base",
        "The fields below have documented data gaps that may affect ",
        "interpretation. Full notes are in the downloadable ",
        htmltools::a(href = "data_dictionary.csv", "data dictionary"),
        "."
      ),
      htmltools::tags$ul(items)
    )
  )
}
