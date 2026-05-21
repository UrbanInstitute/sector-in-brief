# Derive a panel's year-range slider bounds from the manifest's
# year_counts field instead of hardcoding them.
#
# The producer publishes the row count per year per file. A partial-year
# publish (e.g. 2024 finances arriving ~25% complete) shows up as a
# trailing year whose count is far below the median; auto-trim it.
#
# Caveats: this catches "partial because rows are missing" — it does
# NOT catch "rows are complete but a specific column is partial" (the
# DAF case where 2024 has full BMF rows but the Has DAF flag is sparse
# because e-file ingest is incomplete). Those panels still need an
# explicit override in visualpanel_args.

panel_year_range <- function(parquet_file,
                             manifest_path = "data/_manifest.json",
                             cliff_ratio = 0.5) {
  if (!file.exists(manifest_path)) return(c(NA_integer_, NA_integer_))
  m <- jsonlite::read_json(manifest_path)
  yc <- m$files[[parquet_file]]$year_counts
  if (is.null(yc) || length(yc) == 0) return(c(NA_integer_, NA_integer_))

  yrs <- as.integer(names(yc))
  counts <- vapply(yc, as.integer, integer(1))
  ord <- order(yrs)
  yrs <- yrs[ord]
  counts <- counts[ord]

  # Trim only from the trailing end: drop years where the count drops
  # sharply relative to the previous year (cliff). This catches partial
  # publishes (e.g. finances 2024 at ~25% of 2023) without false-positives
  # on legitimately-low early years (e.g. Numbers 1989-1994 are real but
  # low because NCCS coverage was narrower pre-1995).
  n <- length(counts)
  while (n > 1 && counts[n] < cliff_ratio * counts[n - 1]) {
    n <- n - 1
  }
  c(min(yrs), yrs[n])
}

# Resolve the year range for a panel, honoring per-panel overrides.
# If start_year_override / end_year_override are non-NA, use them;
# otherwise pull from the manifest.
resolve_panel_year_range <- function(parquet_file,
                                     start_override = NA_integer_,
                                     end_override = NA_integer_) {
  range <- panel_year_range(parquet_file)
  c(
    if (!is.na(start_override)) as.integer(start_override) else range[1],
    if (!is.na(end_override))   as.integer(end_override)   else range[2]
  )
}
