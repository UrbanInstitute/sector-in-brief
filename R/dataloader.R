# Function to load data based on input tab
dataloader <- function(path) {
  shinycssloaders::showPageSpinner()
  data_select <- arrow::read_parquet(path, as_data_frame = FALSE)
  shinycssloaders::hidePageSpinner()
  return(data_select)
}
