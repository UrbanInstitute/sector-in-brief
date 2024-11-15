# Function to filter data
filter_data <- function(data, filter_ls){     
  fp <- purrr::map2(names(filter_ls), filter_ls, function(vars, vals) quo((!!(as.name(vars))) %in% !!vals))
  data <- dplyr::filter(data, !!!fp)
  data <- dplyr::compute(data)
  return(data)
}