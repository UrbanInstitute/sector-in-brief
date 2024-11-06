table_builder <- function(data, groupby_var, groupby_var_2, sum_var, is_pf) {
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
          dplyr::filter(`Asset Size` != 0) |>
          dplyr::mutate(
            "Asset Size" = dplyr::case_when(
              `Asset Size` == 1 ~ "Under $100,000",
              `Asset Size` == 2 ~ "$100,000 - $499,999",
              `Asset Size` == 3 ~ "$500,000 - $999,999",
              `Asset Size` == 4 ~ "$1 Million - $4.99 Million",
              `Asset Size` == 5 ~ "$5 Million - $9.99 Million",
              `Asset Size` == 6 ~ "Above $10 Million"
            )
          ) |>
          dplyr::collect()
      } else if (groupby_var_2 == "Subsector"){
        table <- table |>
          dplyr::mutate(
            "Subsector" = dplyr::case_when(
              `Subsector` == "ART" ~ "Arts, Culture, and Humanities",
              `Subsector` == "EDU" ~ "Education (minus Universities)",
              `Subsector` == "HEL" ~ "Health (minus Hospitals)",
              `Subsector` == "HMS" ~ "Human Services",
              `Subsector` == "IFA" ~ "International, Foreign Affairs",
              `Subsector` == "PSB" ~ "Public, Societal Benefit",
              `Subsector` == "REL" ~ "Religion Related",
              `Subsector` == "MMB" ~ "Mutual/Membership Benefit",
              `Subsector` == "UNI" ~ "Universities",
              `Subsector` == "HOS" ~ "Hospitals",
              `Subsector` == "ENV" ~ "Environment and Animals",
              `Subsector` == "UNU" ~ "Other"
            )
          ) |>
          dplyr::collect()
      }
    }
    if (is_pf == TRUE && groupby_var == "Tax Year"){
      table <- table |>
        dplyr::mutate(
          !!sym(sum_var) := dplyr::if_else(
            `Tax Year` %in% c(2016, 2017, 2018, 2019),
            NA,
            !!sym(sum_var)
          )
        ) |>
        dplyr::collect()
    }
    return(table)
  }, error = function(e) {
    table <- tibble::tribble( ~ `No Data Available`, NULL)
    return(table)
  })
}