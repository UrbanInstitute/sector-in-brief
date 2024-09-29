table_builder <- function(data, groupby_var, groupby_var_2, sum_var) {
  tryCatch({
    if (is.null(groupby_var_2)) {
      table <- data |>
        group_by(!!sym(groupby_var)) |>
        summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
        dplyr::collect()
    } else {
      table <- data |>
        group_by(!!sym(groupby_var), !!sym(groupby_var_2)) |>
        summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
        dplyr::collect()
      if (groupby_var_2 == "Asset Size") {
        table <- table |>
          dplyr::mutate(
            "Asset Size" = case_when(
              `Asset Size` <= 1 ~ "Under $100,000",
              `Asset Size` == 2 ~ "$100,000 - $499,999",
              `Asset Size` == 3 ~ "$500,000 - $999,999",
              `Asset Size` == 4 ~ "$1 Million - $4.99 Million",
              `Asset Size` == 5 ~ "$5 Million - $9.99 Million",
              `Asset Size` == 6 ~ "Above $10 Million",
            )
          ) |>
          dplyr::collect()
      }
    }
    return(table)
  }, error = function(e) {
    table <- tibble::tribble( ~ `No Data Available`, NULL)
    return(table)
  })
}