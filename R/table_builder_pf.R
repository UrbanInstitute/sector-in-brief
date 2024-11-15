#' @title Modify reactive table for private foundations
#' @description replacing years 2016-2018 with NA values because those years have
#' missing data
#' @param table A arrow table containing filtered data
#' @param groupby_var A character string of the first variable to group by
#' @param sum_var A character string of the variable to sum
#' @return A tibble
table_builder_pf <- function(table, groupby_var, sum_var) {
  table <- table |>
    dplyr::mutate(
      !!sum_var := dplyr::if_else(
        !!sym(groupby_var) %in% c(2016, 2017, 2018), NA, !!sym(sum_var)
      )
    ) |>
    dplyr::collect()
  return(table)
}