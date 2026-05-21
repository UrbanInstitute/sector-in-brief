# Load a parquet via a cached arrow::open_dataset reference (one read of
# parquet metadata per file, per session) and apply panel-specific filters
# lazily so downstream filter_data + summarise push predicates down into
# the parquet row groups instead of materializing the whole file first.

.dataset_cache <- new.env(parent = emptyenv())

dataloader <- function(path, cols = NULL) {
  in_shiny <- !is.null(shiny::getDefaultReactiveDomain())
  if (in_shiny) shinycssloaders::showPageSpinner()

  key <- normalizePath(path, mustWork = FALSE)
  ds <- .dataset_cache[[key]]
  if (is.null(ds)) {
    ds <- arrow::open_dataset(path)
    .dataset_cache[[key]] <- ds
  }
  data_select <- if (is.null(cols)) ds else dplyr::select(ds, dplyr::all_of(cols))

  if ("Number of DAFs" %in% cols) {
    data_select <- dplyr::filter(data_select, `Number of DAFs` <= 50000)
  } else if ("Total Assets" %in% cols) {
    data_select <- dplyr::filter(data_select, `Total Assets` <= 1e14)
  }
  # daf.parquet covers every BMF-active cell (dollar metrics are NA for
  # no-DAF cells). Dollar-metric DAF views must exclude those so breakdowns
  # don't render $0 entries; DAF Proportion keeps them as the denominator.
  if (grepl("daf\\.parquet$", path)) {
    dollar_col <- intersect(c("Total Contributions", "Total Grants", "Total Value"), cols)
    if (length(dollar_col) == 1 && !("Has DAF" %in% cols)) {
      data_select <- dplyr::filter(data_select, !is.na(!!rlang::sym(dollar_col)))
    }
  }

  if (in_shiny) shinycssloaders::hidePageSpinner()
  data_select
}
