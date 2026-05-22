# By-Size aggregation. Rewrites the integer Size band (1-6) to a
# human-readable dollar-range label, with the level ordering preserved
# via a factor (so charts plot small → large rather than alphabetical).
# Despite the historical column name, Size is total expenses, not
# assets (see CLAUDE.md).

#' Build the by-Size summary table.
#'
#' @param table Pre-aggregated arrow Table from `table_builder()`.
#' @param groupby_var Primary axis ("Year").
#' @param sum_var Metric to aggregate.
#' @param is_pf TRUE → apply 2016-2018 NA replacement for PFs.
#' @return A tibble with one row per (year, size band).
table_builder_size <- function(table, groupby_var, sum_var, is_pf) {
  table <- table |>
    dplyr::mutate(
      "Size" = dplyr::case_match(
        `Size`,
        1 ~ "Under $100,000",
        2 ~ "$100,000 - $499,999",
        3 ~ "$500,000 - $999,999",
        4 ~ "$1 Million - $4.99 Million",
        5 ~ "$5 Million - $9.99 Million",
        6 ~ "Above $10 Million",
        .default = "Under $100,000",
        .ptype = factor(
          levels = c(
            "Under $100,000",
            "$100,000 - $499,999",
            "$500,000 - $999,999",
            "$1 Million - $4.99 Million",
            "$5 Million - $9.99 Million",
            "Above $10 Million"
          )
        )
      )
    ) |>
    dplyr::group_by(!!sym(groupby_var), `Size`) |>
    dplyr::summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  if (is_pf == TRUE){
    table <- table_builder_pf(table, groupby_var, sum_var)
  }
  return(table)
}