# Single-axis aggregation (no second group column). The "overall" view
# in summarise_data's groupby_ls.

#' Build the overall (single-axis) summary table.
#'
#' @param data Filtered arrow Table.
#' @param groupby_var Primary axis ("Year").
#' @param sum_var Metric to aggregate.
#' @param is_pf TRUE → apply 2016-2018 NA replacement for PFs.
#' @return A tibble with one row per `groupby_var` value.
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