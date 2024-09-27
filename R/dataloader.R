# Function to load data based on input tab
dataloader <- function(path, cols=NULL) {
  shinycssloaders::showPageSpinner()
  data_select <- arrow::read_parquet(path, as_data_frame = FALSE, col_select = cols)
  shinycssloaders::hidePageSpinner()
  return(data_select)
}
