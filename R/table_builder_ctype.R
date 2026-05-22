# By-Organization-Type aggregation, with two roll-up rules:
#   1. If all four 501(c)(3) ctypes are present, collapse them to a
#      single "All 501(c)(3) Organizations" row.
#   2. If the total ctype count exceeds 8, collapse the long tail
#      (ctype_other) to a single "Other Organizations" row.
# Also applies the PF 2016-2018 NA replacement post-aggregation when
# private foundations are part of the result set.

#' Build the by-Organization-Type summary table.
#'
#' @param table Pre-aggregated arrow Table from `table_builder()`.
#' @param groupby_var Primary axis ("Year").
#' @param sum_var Metric to aggregate.
#' @return A tibble with one row per (year, organization type).
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