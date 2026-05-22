# PF-specific post-aggregation fix-up: replace the metric with NA for
# tax years 2016-2018 because the producer's coverage of private
# foundations is incomplete for those years. The single-line plot
# layer (geom_line + geom_line dashed on !is.na) preserves a visible
# trace across the gap so users see "data missing" rather than "zero".

#' Replace 2016-2018 metric values with NA for private foundations.
#'
#' @param table Pre-aggregated tibble.
#' @param groupby_var Primary axis (Year column).
#' @param sum_var Metric column to NA-out for the gap years.
#' @return The input tibble with the gap years set to NA.
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