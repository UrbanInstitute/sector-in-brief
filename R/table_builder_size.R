#' @title Build downloadable tile for results aggregated by asset size category
#' @param table A arrow table containing filtered data
#' @param groupby_var A character string of the first variable to group by
#' @param sum_var A character string of the variable to sum
#' @param is_pf A logical value indicating if the table is for private foundations
#' @return A tibble
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