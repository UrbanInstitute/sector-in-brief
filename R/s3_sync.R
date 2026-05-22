# Pull the sector-in-brief data vintage from S3 at app startup.
# Per ADR 0011 the dashboard reads from S3, not a committed data/ directory.
# Bump VINTAGE here when the producer publishes a new build that has been
# tested against this dashboard. The prod prefix also mirrors the most
# recent vintage to s3://nccsdata/sector-in-brief/latest/ — we pin a
# specific v* tag instead of reading latest/ so the dashboard locks to a
# tested-good shape and a new producer publish can't silently change it.
#
# The bucket allows public GetObject on individual files but NOT
# anonymous ListObjects — so `aws s3 sync` won't work (it needs to
# list). Instead we fetch the manifest first via HTTPS, then download
# each parquet listed in the manifest. No AWS credentials needed
# anywhere — important because institutional AWS accounts often
# rotate keys every 24 hours, which would otherwise break static-env
# setups on shinyapps.io.

S3_BUCKET <- "nccsdata"
S3_PREFIX <- "sector-in-brief"
VINTAGE   <- "v2026.05"

# Public HTTPS endpoint for a file in the vintage's prefix.
vintage_url <- function(file) {
  sprintf("https://%s.s3.amazonaws.com/%s/%s/%s",
          S3_BUCKET, S3_PREFIX, VINTAGE, file)
}

#' Sync the pinned data vintage from S3 into `data_dir`.
#'
#' Short-circuits to "fresh" if `data_dir/_manifest.json` already
#' reports the target VINTAGE (no network call). Otherwise downloads
#' the manifest and every parquet it enumerates. On any download
#' failure with existing local data, returns "stale" + a warning so
#' app() can show a banner. On failure with no local fallback,
#' `stop()`s — the only fatal path.
#'
#' @param data_dir Target directory (default "data").
#' @return List with:
#'   - `status`: one of "fresh", "stale".
#'   - `vintage`: the vintage now available, or NA if unknown.
ensure_data_local <- function(data_dir = "data") {
  manifest <- file.path(data_dir, "_manifest.json")
  read_vintage <- function() {
    if (!file.exists(manifest)) return(NULL)
    tryCatch(jsonlite::read_json(manifest)$vintage, error = function(e) NULL)
  }

  if (file.exists(manifest)) {
    have <- read_vintage()
    if (identical(have, sub("^v", "", VINTAGE))) {
      return(list(status = "fresh", vintage = have))
    }
  }
  if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

  ok <- tryCatch({
    utils::download.file(vintage_url("_manifest.json"), manifest,
                         mode = "wb", quiet = TRUE)
    m <- jsonlite::read_json(manifest)
    for (file in names(m$files)) {
      utils::download.file(vintage_url(file),
                           file.path(data_dir, file),
                           mode = "wb", quiet = TRUE)
    }
    TRUE
  }, error = function(e) {
    message("[s3_sync] download failed from ", vintage_url(""),
            ": ", conditionMessage(e))
    FALSE
  })

  if (ok) {
    return(list(status = "fresh", vintage = read_vintage()))
  }
  # Download failed. Fall back to whatever's on disk if we have something.
  if (file.exists(manifest)) {
    have <- read_vintage()
    warning("data download failed from ", vintage_url(""),
            "; serving stale local data (vintage ", have, ").")
    return(list(status = "stale", vintage = have))
  }
  stop("data download failed from ", vintage_url(""),
       " and no local data to fall back to")
}

#' Export the parquet data dictionary as a CSV under www/.
#'
#' Resolves the static "Download data dictionary" links in
#' visual_text.R. Prepends a UTF-8 BOM so Excel-on-Windows renders
#' en-dashes / em-dashes / inequality signs in coverage_notes
#' correctly. No-op if the parquet doesn't exist (e.g. tests).
#'
#' @param parquet_path Source parquet (typically `data/data_dictionary.parquet`).
#' @param csv_path Destination CSV under `www/`.
publish_data_dictionary <- function(parquet_path = "data/data_dictionary.parquet",
                                    csv_path = "www/data_dictionary.csv") {
  if (!file.exists(parquet_path)) return(invisible())
  dir.create(dirname(csv_path), showWarnings = FALSE, recursive = TRUE)
  tmp <- tempfile(fileext = ".csv")
  utils::write.csv(
    arrow::read_parquet(parquet_path),
    file = tmp,
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  body <- readBin(tmp, "raw", file.info(tmp)$size)
  con <- file(csv_path, "wb")
  on.exit(close(con))
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  writeBin(body, con)
  invisible()
}
