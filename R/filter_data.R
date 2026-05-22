# Predicate-pushdown filter for arrow datasets.
#
# Receives the filter list assembled by query_builder() — a named list
# where each entry is `column = allowed_values` — and turns it into a
# vectorised %in% predicate that arrow can push down into the parquet
# row groups. `dplyr::compute()` materialises the filtered slice as an
# in-memory arrow Table so the downstream summarise calls don't re-read
# the parquet for each of the 5 group-by passes.

#' Apply a query's filter list to an arrow dataset.
#'
#' @param data An arrow Dataset (lazy reference from `dataloader()`).
#' @param filter_ls Named list. Keys are column names; values are
#'   vectors of allowed values for that column.
#' @return An in-memory arrow Table with rows matching every filter.
filter_data <- function(data, filter_ls) {
  fp <- purrr::map2(
    names(filter_ls),
    filter_ls,
    function(vars, vals) quo((!!(as.name(vars))) %in% !!vals)
  )
  data <- dplyr::filter(data, !!!fp)
  data <- dplyr::compute(data)
  return(data)
}
