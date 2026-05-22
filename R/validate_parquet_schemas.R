#' Validate parquet files against the expected schema contract.
#'
#' Called once at app startup after `ensure_data_local()`. Compares each
#' declared file's actual arrow schema against `expected_parquet_schemas`
#' and aborts with a single, structured error message listing every
#' problem found across all files.
#'
#' Three classes of problem are surfaced as hard failures:
#'   - file missing on disk after the S3 sync
#'   - declared column missing from the file
#'   - declared column present but with a different arrow type
#'
#' Extra (undeclared) columns are tolerated and only logged via message(),
#' since the producer is free to add fields without breaking the dashboard.
#'
#' @param data_dir directory containing the parquet files (default "data").
#' @param schemas the schema contract; default reads from
#'   `expected_parquet_schemas` in R/expected_schema.R.
#' @return invisibly TRUE on success.
validate_parquet_schemas <- function(data_dir = "data",
                                     schemas = expected_parquet_schemas) {
  problems <- character()

  for (file in names(schemas)) {
    path <- file.path(data_dir, file)
    if (!file.exists(path)) {
      problems <- c(problems, sprintf("- %s: file not found at %s", file, path))
      next
    }

    fields <- arrow::open_dataset(path)$schema$fields
    actual <- stats::setNames(
      vapply(fields, function(f) f$type$ToString(), character(1)),
      vapply(fields, function(f) f$name, character(1))
    )
    expected <- schemas[[file]]

    missing_cols <- setdiff(names(expected), names(actual))
    if (length(missing_cols) > 0) {
      problems <- c(
        problems,
        sprintf("- %s: missing columns: %s",
                file, paste(missing_cols, collapse = ", "))
      )
    }

    type_mismatches <- character()
    for (col in intersect(names(expected), names(actual))) {
      if (!identical(actual[[col]], expected[[col]])) {
        type_mismatches <- c(
          type_mismatches,
          sprintf("'%s' got %s expected %s",
                  col, actual[[col]], expected[[col]])
        )
      }
    }
    if (length(type_mismatches) > 0) {
      problems <- c(
        problems,
        sprintf("- %s: type mismatches: %s",
                file, paste(type_mismatches, collapse = "; "))
      )
    }

    extra_cols <- setdiff(names(actual), names(expected))
    if (length(extra_cols) > 0) {
      message(sprintf("[schema] %s has undeclared columns (tolerated): %s",
                      file, paste(extra_cols, collapse = ", ")))
    }
  }

  if (length(problems) > 0) {
    stop(
      "Parquet schema validation failed. The producer (sector-in-brief-data)\n",
      "appears to have changed the data shape. Update R/expected_schema.R in\n",
      "lockstep, or pin a known-good vintage in R/s3_sync.R.\n\n",
      paste(problems, collapse = "\n"),
      call. = FALSE
    )
  }
  invisible(TRUE)
}
