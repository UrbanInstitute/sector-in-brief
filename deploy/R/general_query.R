# Function to filter data
general_query <- function(data, var, val) {
  data <- filter(data, !!sym(var) %in% val)
  return(data)
}