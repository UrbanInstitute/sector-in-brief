#' @title Function to build overall table
#' @param data A arrow table containing filtered data
#' @param groupby_var A character string of the first variable to group by
#' @param sum_var A character string of the variable to sum
#' @param is_pf A logical value indicating if the table is for private foundations
#' @return A tibble
table_builder_default <- function(data, groupby_var, sum_var, is_pf) {
  table <- data |>
    group_by(!!sym(groupby_var)) |>
    summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  if (is_pf == TRUE){
    table <- table_builder_pf(table, groupby_var, sum_var)
  }
  return(table)
}