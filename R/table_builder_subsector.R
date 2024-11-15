#' @title Build downloadable tile for results aggregated by subsector
#' @param table A arrow table containing filtered data
#' @param groupby_var A character string of the first variable to group by
#' @param sum_var A character string of the variable to sum
#' @param is_pf A logical value indicating if the table is for private foundations
#' @return A tibble
table_builder_subsector <- function(table, groupby_var, sum_var, is_pf) {
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
        `Subsector` == "UNU" ~ "Other",
        .default = "Other"
      )
    ) |>
    dplyr::group_by(!!sym(groupby_var), `Subsector`) |>
    dplyr::summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  if (is_pf == TRUE){
    table <- table_builder_pf(table, groupby_var, sum_var)
  }
  return(table)
}
