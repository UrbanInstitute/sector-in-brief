# By-geo aggregation. Currently a thin pass-through that just applies
# the PF 2016-2018 NA replacement when applicable — the underlying
# group-by happened in table_builder() before this is called.

#' Apply post-aggregation tweaks to a by-geo table.
#'
#' @param table Pre-aggregated tibble from `table_builder()`.
#' @param groupby_var Primary axis ("Year").
#' @param groupby_var_2 The geo column (e.g. "Census State"); accepted
#'   for signature symmetry with the other table_builder_* variants.
#' @param sum_var Metric to aggregate.
#' @param is_pf TRUE → apply 2016-2018 NA replacement for PFs.
#' @return The input tibble, optionally NA-replaced for PFs.
table_builder_geo <- function(table, groupby_var, groupby_var_2, sum_var, is_pf){
  if (is_pf == TRUE){
    table <- table_builder_pf(table, groupby_var, sum_var)
  }
  return(table)
}