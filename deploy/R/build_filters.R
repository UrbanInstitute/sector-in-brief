# Function to build filters

build_filters <- function(filter_obj, filter_vars){
  filters <- purrr::pmap(filter_vars, filter_obj)
  names(filters) <- filter_vars[["inputId"]]
  return(filters)
}
