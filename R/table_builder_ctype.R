#' @title Build reactive table for results aggregated by organization type
#' @param table A arrow table containing filtered data
#' @param groupby_var A character string of the first variable to group by
#' @param sum_var A character string of the variable to sum
#' @return A tibble
table_builder_ctype <- function(table, groupby_var, sum_var) {
  table_ctypes <- unique(table[["Organization Type"]])
  if (all(ctype_501c3 %in% table_ctypes)) {
    table <- table |>
      dplyr::mutate(
        "Organization Type" = dplyr::case_when(
          `Organization Type` %in% ctype_501c3 ~ "All 501(c)(3) Organizations",
          .default = as.character(`Organization Type`)
        )
      ) |>
      dplyr::collect()
  }
  if (length(table_ctypes) > 8) {
    table <- table |>
      dplyr::mutate(
        "Organization Type" = dplyr::case_when(
          `Organization Type` %in% ctype_other ~ "Other Organizations",
          .default = as.character(`Organization Type`)
        )
      ) |>
      dplyr::collect()
  }
  table <- table |>
    dplyr::group_by(!!sym(groupby_var), `Organization Type`) |>
    dplyr::summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  table_ctypes <- unique(table[["Organization Type"]])
  if ("501(c)(3) Private Foundations" %in% table_ctypes){
    table <- table |>
      dplyr::mutate(
        !!sum_var := dplyr::if_else(
          `Organization Type` == "501(c)(3) Private Foundations" & !!sym(groupby_var) %in% c(2016, 2017, 2018), 
          NA, 
          !!sym(sum_var)
        )
      ) |>
      dplyr::collect()
  }
  return(table)
}