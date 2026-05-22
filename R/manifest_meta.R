# Cached read of the producer manifest's top-level metadata.
# `_manifest.json` carries vintage + built_at + per-file year_counts.
# The vintage indicator in each panel header needs the first two;
# panel_year_range() handles the per-file year_counts separately.

.manifest_cache <- new.env(parent = emptyenv())

#' Read vintage + built_at from `data/_manifest.json`, cached for the
#' session.
#'
#' Returns NULL fields if the manifest is missing or malformed — the
#' panel header then omits the vintage line. (The boot path already
#' fails earlier if the manifest is truly absent, so this is just
#' defensive for tests / fixtures.)
#'
#' @param manifest_path Path to `_manifest.json` (default
#'   `data/_manifest.json`).
#' @return Named list with `vintage` (e.g. "2026.05") and
#'   `built_at_date` (ISO date string parsed from the manifest's
#'   `built_at` timestamp).
manifest_meta <- function(manifest_path = "data/_manifest.json") {
  if (!is.null(.manifest_cache$meta) &&
      identical(.manifest_cache$path, manifest_path)) {
    return(.manifest_cache$meta)
  }
  meta <- list(vintage = NULL, built_at_date = NULL)
  if (file.exists(manifest_path)) {
    tryCatch({
      m <- jsonlite::read_json(manifest_path)
      meta$vintage <- m$vintage
      if (!is.null(m$built_at)) {
        meta$built_at_date <- substr(m$built_at, 1, 10)  # YYYY-MM-DD
      }
    }, error = function(e) NULL)
  }
  .manifest_cache$path <- manifest_path
  .manifest_cache$meta <- meta
  meta
}
