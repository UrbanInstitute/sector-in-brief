# Standard table-builder dispatcher. Picks the right per-dimension
# variant (default / size / subsector / ctype / geo) based on the
# second group column from summarise_data(). All variants apply the PF
# 2016-2018 NA replacement when is_pf = TRUE.
#
# The proportion path (DAF Proportion panel) is handled separately by
# table_builder_proportion.

#' Build one summary table.
#'
#' @param data Filtered arrow Table.
#' @param groupby_var Primary axis (typically "Year").
#' @param groupby_var_2 Second group column, or NULL for the overall
#'   view. Dispatches to one of the table_builder_* variants when set.
#' @param sum_var Metric to aggregate (column name).
#' @param is_pf TRUE if the active org type is private foundations —
#'   triggers the 2016-2018 NA replacement after aggregation.
#' @return A tibble.
table_builder <- function(data,
                          groupby_var,
                          groupby_var_2,
                          sum_var,
                          is_pf) {
  tryCatch({
    if (is.null(groupby_var_2)) {
      table <- table_builder_default(data, groupby_var, sum_var, is_pf)
    } else {
      table <- data |>
        group_by(!!sym(groupby_var), !!sym(groupby_var_2)) |>
        summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
        dplyr::collect()
      if (groupby_var_2 == "Size") {
        table <- table_builder_size(table, groupby_var, sum_var, is_pf)
      } else if (groupby_var_2 == "Subsector") {
        table <- table_builder_subsector(table, groupby_var, sum_var, is_pf)
      } else if (groupby_var_2 == "Organization Type") {
        table <- table_builder_ctype(table, groupby_var, sum_var)
      } else if (groupby_var_2 %in% c("Metro/Micro Area", "Census State", "Census Region", "Census County")) {
        table <- table_builder_geo(table, groupby_var, groupby_var_2, sum_var, is_pf)
      }
    }
    return(table)
  }, error = function(e) {
    print(e)
    table <- tibble::tribble(~ `No Data Available`, NULL)
    return(table)
  })
}