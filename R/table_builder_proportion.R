table_builder_proportion <- function(data,
                                     groupby_var,
                                     groupby_var_2,
                                     sum_var,
                                     sum_var_2,
                                     proportion_var) {
  tryCatch({
    if (is.null(groupby_var_2)) {
      table <- data |>
        group_by(!!sym(groupby_var)) |>
        summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE),
                  !!sum_var_2 := sum(!!sym(sum_var_2), na.rm = TRUE)) |>
        dplyr::mutate(!!proportion_var := round(!!sym(sum_var) / !!sym(sum_var_2), 2) * 100) |>
        dplyr::collect()
    } else {
      table <- data |>
        group_by(!!sym(groupby_var), !!sym(groupby_var_2)) |>
        summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE),!!sum_var_2 := sum(!!sym(sum_var_2), na.rm = TRUE)) |>
        dplyr::mutate(!!proportion_var := round(!!sym(sum_var) / !!sym(sum_var_2), 2) * 100) |>
        dplyr::collect()
      if (groupby_var_2 == "Size") {
        table <- table |>
          dplyr::mutate(
            "Size" = case_when(
              `Size` <= 1 ~ "Under $100,000",
              `Size` == 2 ~ "$100,000 - $499,999",
              `Size` == 3 ~ "$500,000 - $999,999",
              `Size` == 4 ~ "$1 Million - $4.99 Million",
              `Size` == 5 ~ "$5 Million - $9.99 Million",
              `Size` == 6 ~ "Above $10 Million",
            )
          ) |>
          dplyr::collect()
      }
    }
    return(table)
  }, error = function(e) {
    table <- tibble::tribble(~ `No Data Available`, NULL)
    return(table)
  })
}