#' Add the partial-coverage disclosure to a plot caption.
#'
#' The actual cutoff is set per-panel at boot by `year_range.R`, which
#' trims trailing years whose row counts cliff below the previous
#' year (i.e. partial IRS publishes). The disclaimer here just calls
#' that out for the reader; it deliberately does not name a specific
#' year so it stays correct as the manifest moves forward.
#'
#' @param caption Running caption string.
#' @param year_var Time column name ("Year"); other values are no-op.
#' @return Updated caption string.
caption_year <- function(caption, year_var) {
  if (year_var == "Year") {
    caption <- paste(
      caption,
      "•\tTrailing tax years with partial IRS coverage are excluded from this chart's range.",
      "\n"
    )
  }
  return(caption)
}
