# Cache the joint result of filter_data() + summarise_data() keyed on the
# query hash, so a repeat UPDATE DATA click with the same filters skips
# the expensive arrow filter + 5x group-by summarise steps entirely
# (~0.7s → ~5ms on cache hit).
#
# Scope: in-process cache, one per R session. On shinyapps.io each session
# gets a fresh process so the cache rebuilds; within a session repeat
# queries hit. A future cross-session cache (S3 or DB) would amortize the
# warm-up across users — out of scope for now.

# Module-level env holds the cachem store. Using an env (not a bare
# variable) because package namespace bindings are locked at load time —
# we can mutate env contents but not reassign the binding itself.
.pipeline_cache <- new.env(parent = emptyenv())

#' Initialize (or reset) the pipeline cache. Idempotent.
#'
#' @param dir directory for the on-disk cache (default: per-session tempdir).
#' @param max_size maximum cache size in bytes (default 50 MB; summary
#'   tables are typically a few KB each, so this is generous).
init_pipeline_cache <- function(dir = file.path(tempdir(), "sib-pipeline-cache"),
                                max_size = 50 * 1024^2) {
  .pipeline_cache$store <- cachem::cache_disk(dir = dir, max_size = max_size)
  invisible(.pipeline_cache$store)
}

#' Run filter + summarise with caching keyed on the query.
#'
#' Returns the same 5-element list `summarise_data()` returns; cached on
#' (query$filters, query$geo_level, year_var, agg_var). The dataloader
#' is already cached at the dataset level (see R/dataloader.R), so
#' identical filter combos hit this cache and skip the arrow work.
cached_filter_and_summarise <- function(data, query, year_var, agg_var) {
  if (is.null(.pipeline_cache$store)) init_pipeline_cache()
  key <- digest::digest(list(
    filters   = query$filters,
    geo_level = query$geo_level,
    year_var  = year_var,
    agg_var   = agg_var
  ))
  cached <- .pipeline_cache$store$get(key)
  if (!inherits(cached, "key_missing")) {
    return(cached)
  }
  filtered_data <- filter_data(data = data, filter_ls = query$filters)
  tables <- summarise_data(
    data = filtered_data,
    groupby_var = year_var,
    sum_var = agg_var,
    query = query
  )
  .pipeline_cache$store$set(key, tables)
  tables
}
