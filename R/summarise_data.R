# Run the 5 group-by passes that feed the plot panel. For each user
# query the dashboard renders a 5-up grid of charts:
#
#   - default        (no second grouping)
#   - by_ctype       (by Organization Type)
#   - by_geo         (by whatever the chosen geo_level is)
#   - by_subsector   (by Subsector)
#   - by_asset_size  (by Size band)
#
# Each table is produced via `purrr::possibly()` so a failure on one
# group-by (e.g. a column missing from a panel-specific parquet)
# degrades that single chart to a "no data" placeholder without taking
# the whole panel down.
#
# Two paths: the DAF Proportion panel uses table_builder_proportion
# (numerator/denominator + %); every other panel uses table_builder
# (single sum).

#' Build all five panel tables from a filtered arrow Table.
#'
#' @param data Filtered arrow Table from `filter_data()`.
#' @param groupby_var Primary axis variable (typically "Year").
#' @param sum_var The metric to aggregate. Special value
#'   "Proportion with DAFs" routes through the proportion builder.
#' @param query The query spec from `query_builder()` — used to pick
#'   the geo level for `by_geo` and to detect the private-foundation
#'   org type (which triggers the 2016-2018 NA replacement in the PF
#'   table builders).
#' @return Named list of 5 tibbles, one per group-by.
summarise_data <- function(data, groupby_var, sum_var, query) {
  geo_level <- query$geo_level
  org_type <- query[["filters"]][["Organization Type"]]
  groupby_ls <- list(
    "default"       = NULL,
    "by_ctype"      = "Organization Type",
    "by_geo"        = geo_level,
    "by_subsector"  = "Subsector",
    "by_asset_size" = "Size"
  )

  is_pf <- FALSE
  if (length(org_type) == 1) {
    if (org_type == "501(c)(3) Private Foundations" &
        groupby_var == "Year") {
      is_pf <- TRUE
    }
  }

  if (sum_var == "Proportion with DAFs") {
    table_ls <- purrr::map(
      groupby_ls,
      purrr::possibly(table_builder_proportion, otherwise = blank_table()),
      data = data,
      groupby_var = groupby_var,
      sum_var = "Has DAF",
      sum_var_2 = "Number of Nonprofits",
      proportion_var = sum_var
    )
  } else {
    table_ls <- purrr::map(
      groupby_ls,
      purrr::possibly(table_builder, otherwise = blank_table()),
      data = data,
      groupby_var = groupby_var,
      sum_var = sum_var,
      is_pf = is_pf
    )
  }
  return(table_ls)
}
