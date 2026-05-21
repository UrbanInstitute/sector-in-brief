# Function to load data based on input tab.
# Spinner calls are guarded so dataloader is testable outside a Shiny session.
dataloader <- function(path, cols=NULL) {
  in_shiny <- !is.null(shiny::getDefaultReactiveDomain())
  if (in_shiny) shinycssloaders::showPageSpinner()
  data_select <- arrow::read_parquet(path, as_data_frame = FALSE, col_select = cols)
  if ("Number of DAFs" %in% cols){
    data_select <- data_select |>
      dplyr::filter(
        `Number of DAFs` <= 50000
      ) |>
      dplyr::compute()
  } else if ("Total Assets" %in% cols){
    data_select <- data_select |>
      dplyr::filter(
        `Total Assets` <= 1e14
      ) |>
      dplyr::compute()
  }
  # daf.parquet now covers every BMF-active cell (dollar metrics are NA for
  # no-DAF cells). Dollar-metric DAF views must exclude those so breakdowns
  # don't render $0 entries; DAF Proportion keeps them as the denominator.
  if (grepl("daf\\.parquet$", path)) {
    dollar_col <- intersect(c("Total Contributions", "Total Grants", "Total Value"), cols)
    if (length(dollar_col) == 1 && !("Has DAF" %in% cols)) {
      data_select <- data_select |>
        dplyr::filter(!is.na(!!rlang::sym(dollar_col))) |>
        dplyr::compute()
    }
  }
  if (in_shiny) shinycssloaders::hidePageSpinner()
  return(data_select)
}
