# Function to load data based on input tab
dataloader <- function(path, cols=NULL) {
  shinycssloaders::showPageSpinner()
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
  shinycssloaders::hidePageSpinner()
  return(data_select)
}
