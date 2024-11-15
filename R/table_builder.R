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
      if (groupby_var_2 == "Asset Size") {
        table <- table_builder_size(table, groupby_var, sum_var, is_pf)
      } else if (groupby_var_2 == "Subsector") {
        table <- table_builder_subsector(table, groupby_var, sum_var, is_pf)
      } else if (groupby_var_2 == "Organization Type") {
        table <- table_builder_ctype(table, groupby_var, sum_var)
      } else if (groupby_var_2 %in% c("Census CBSA", "Census State", "Census Region", "Census County")) {
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