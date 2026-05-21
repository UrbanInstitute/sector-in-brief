# Surface producer-curated coverage notes from data_dictionary.parquet
# as an inline accordion above the visualization plots, filtered to the
# parquet file backing the current panel. The notes call out documented
# data gaps (e.g. PF 2011-2016 partial coverage, DAF coverage starts
# 2021) that materially affect interpretation of the charts.

.dict_cache <- new.env(parent = emptyenv())

load_data_dictionary <- function(path = "data/data_dictionary.parquet") {
  if (is.null(.dict_cache$df)) {
    .dict_cache$df <- arrow::read_parquet(path)
  }
  .dict_cache$df
}

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
