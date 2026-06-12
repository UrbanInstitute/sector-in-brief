# Pre-submit completeness check for the Custom Panel Datasets form. The
# per-step "NEXT" gates only fire when the user clicks through each panel in
# order; the accordion lets them jump straight to Review and SUBMIT, bypassing
# those gates. An incomplete request then reaches the API as `col IN ()` and
# surfaces a raw SQL parser error. This is the single gate the submit observer
# runs regardless of navigation path — it collects EVERY problem so the user
# can fix them in one pass (ADR 0026).

#' Validate a download request's required selections.
#'
#' Pure (reads only the passed input values) so it is unit-testable. Checks
#' the four required filters and the year-range ordering; geography county/
#' metro are optional and not checked here.
#'
#' @param inputs The form inputs (or a plain list in tests) carrying
#'   `org_select`, `subsector_select`, `geo_select`, `data_select`,
#'   `start_year`, `end_year`.
#' @return A character vector of human-readable problems, one per issue.
#'   Empty (`character(0)`) when the request is complete and valid.
validate_download_request <- function(inputs) {
  problems <- character(0)
  if (length(inputs$org_select) == 0) {
    problems <- c(problems, "Select at least one organization type.")
  }
  if (length(inputs$subsector_select) == 0) {
    problems <- c(problems, "Select at least one subsector.")
  }
  if (length(inputs$geo_select) == 0) {
    problems <- c(problems, "Select at least one state.")
  }
  if (length(inputs$data_select) == 0) {
    problems <- c(problems, "Select at least one variable.")
  }
  # Year order: the two pickers don't constrain each other, and an inverted
  # range would otherwise build a descending tax_years list. Compare as
  # integers; skip silently if either is unset (a missing year is not the
  # error we report here).
  start_year <- suppressWarnings(as.integer(inputs$start_year))
  end_year <- suppressWarnings(as.integer(inputs$end_year))
  if (!is.na(start_year) && !is.na(end_year) && start_year > end_year) {
    problems <- c(
      problems,
      "\"From\" year must be on or before \"Through\" year."
    )
  }
  problems
}
