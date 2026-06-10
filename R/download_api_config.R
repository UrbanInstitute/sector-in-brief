# Endpoint configuration for the Custom Panel Datasets download API
# (ADR 0008 / 0026). The dashboard talks to the modernized
# `sector-in-brief-api` (DuckDB-on-parquet): a private POST /data run by
# the Shiny server (IAM-authed Lambda invoke) and a public
# GET /download/{job_id} durable link shown to / emailed to the user.
#
# Everything here is resolved from environment variables so the
# staging -> prod pointer switch is a deploy-time config change, never a
# code edit (ADR 0011 residual #1 — the legacy path hardcoded a `/stg/`
# URL). Defaults point at the staging stack so a clone-and-run dev
# session works without extra setup.

#' Resolve the download-API endpoint configuration.
#'
#' @return A named list:
#'   * `function_name` — Lambda function name for the IAM-authed
#'     `POST /data` (direct `paws` invoke; the SDK signs SigV4).
#'   * `data_url` — Function URL alternative for `POST /data` (only used
#'     if a future caller signs the URL directly; the `paws` path ignores
#'     it).
#'   * `download_url` — public base URL for the durable
#'     `GET /download/{job_id}` link (no signing).
#'   * `region` — AWS region the Lambda lives in.
download_api_config <- function() {
  list(
    function_name = Sys.getenv(
      "SIB_API_FUNCTION_NAME",
      "sector-in-brief-api-query-stg"
    ),
    data_url = Sys.getenv(
      "SIB_API_DATA_URL",
      "https://mz66675k3bkjp5n7zcuvoi5nry0cwysj.lambda-url.us-east-1.on.aws"
    ),
    download_url = Sys.getenv(
      "SIB_API_DOWNLOAD_URL",
      "https://w5tws2ws3racy4des7afbtpdya0gpzln.lambda-url.us-east-1.on.aws"
    ),
    region = Sys.getenv("SIB_API_REGION", "us-east-1")
  )
}

#' Build an absolute durable download link from a `download_path`.
#'
#' The API returns `download_url` (absolute) directly, but it is built
#' against the API's own configured base; we re-assemble from the
#' dashboard's configured `download_url` so the link the user sees always
#' matches the environment the dashboard is pointed at.
#'
#' @param download_path Relative path from the API response, e.g.
#'   `/download/{job_id}`.
#' @param kind Optional `"dictionary"` to append `?kind=dictionary`.
#' @param config Endpoint config from `download_api_config()`.
#' @return Absolute URL string, or `NULL` when `download_path` is missing.
download_link <- function(download_path, kind = NULL,
                          config = download_api_config()) {
  if (is.null(download_path) || !nzchar(download_path)) {
    return(NULL)
  }
  base <- sub("/+$", "", config$download_url)
  url <- paste0(base, download_path)
  if (!is.null(kind) && nzchar(kind)) {
    url <- paste0(url, "?kind=", kind)
  }
  url
}

#' Format a byte count as a short human-readable size (for the size
#' estimate shown before a large export).
#'
#' @param bytes Numeric byte count.
#' @return A string like "2.9 MB" / "1.4 GB".
human_bytes <- function(bytes) {
  if (is.null(bytes) || is.na(bytes) || bytes < 0) {
    return("unknown size")
  }
  units <- c("B", "KB", "MB", "GB", "TB")
  if (bytes < 1) {
    return("0 B")
  }
  power <- min(floor(log(bytes, 1024)), length(units) - 1)
  value <- bytes / (1024^power)
  paste0(formatC(value, format = "f", digits = if (power >= 2) 1 else 0),
         " ", units[power + 1])
}
