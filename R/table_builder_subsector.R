# By-Subsector aggregation. Expands the 3-letter NTEE codes (ART,
# EDU, HEL, ...) to the human-readable subsector labels used in
# legends and tooltips. Any unmapped value falls into "Other".

#' Build the by-Subsector summary table.
#'
#' @param table Pre-aggregated arrow Table from `table_builder()`.
#' @param groupby_var Primary axis ("Year").
#' @param sum_var Metric to aggregate.
#' @param is_pf TRUE → apply 2016-2018 NA replacement for PFs.
#' @return A tibble with one row per (year, subsector).
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
