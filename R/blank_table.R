# Empty-state placeholder returned when a table builder errors out
# (wrapped in purrr::possibly inside summarise_data). The "No Data
# Available" column name is what users see in the reactable header.

#' Build a "No Data Available" placeholder table.
#'
#' @return A 0-row tibble with a single column named "No Data Available".
blank_table <- function() {
  table <- tibble::tribble(~ `No Data Available`, NULL)
  return(table)
}
