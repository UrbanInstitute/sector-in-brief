#' Compute the labels for the active-filter chip row.
#'
#' Returns one chip per filter that the user has narrowed from its
#' default. Rendered above the plot area by `data_server()` so users
#' can see their active filters at a glance without scrolling back
#' to the filter card.
#'
#' Pure function — testable without a reactive context.
#'
#' @param inputs Snapshot of the panel's inputs in the shape produced
#'   by `format_input()` (named list with ctype, geo_level, subsector,
#'   size, year_range, plus the conditional geo selections).
#' @param defaults Named list with the panel's default values:
#'   `ctype_default`, `subsector_default`, `size_default`,
#'   `year_default` (length-2 integer vector).
#' @return Character vector of chip labels, in display order. Empty
#'   when no filter is narrowed (the chip row will then render nothing).
filter_chip_labels <- function(inputs, defaults) {
  chips <- character()

  # Organization type — chip when the user narrowed from the default set.
  if (!is.null(inputs$ctype) &&
      !setequal(inputs$ctype, defaults$ctype_default)) {
    chips <- c(chips, sprintf("Org Type: %s", paste(inputs$ctype, collapse = ", ")))
  }

  # Geography — chip whenever the level isn't National (the open default).
  if (!is.null(inputs$geo_level) && inputs$geo_level != "National") {
    selection <- switch(
      inputs$geo_level,
      "Census Region"    = inputs$geo_region,
      "Census State"     = inputs$geo_state_mult,
      "Census County"    = inputs$geo_county,
      "Metro/Micro Area" = inputs$geo_cbsa,
      NULL
    )
    label <- if (length(selection) > 0) {
      sprintf("%s: %s",
              sub("^Census ", "", inputs$geo_level),
              paste(selection, collapse = ", "))
    } else {
      sub("^Census ", "", inputs$geo_level)
    }
    chips <- c(chips, label)
  }

  if (!is.null(inputs$subsector) &&
      length(inputs$subsector) < length(defaults$subsector_default)) {
    chips <- c(chips, sprintf("Subsector: %s",
                              paste(inputs$subsector, collapse = ", ")))
  }

  if (!is.null(inputs$size) &&
      length(inputs$size) < length(defaults$size_default)) {
    chips <- c(chips, sprintf("Size: %s", paste(inputs$size, collapse = ", ")))
  }

  if (!is.null(inputs$year_range) &&
      !identical(as.integer(inputs$year_range),
                 as.integer(defaults$year_default))) {
    chips <- c(chips, sprintf("Years: %d-%d",
                              as.integer(inputs$year_range[1]),
                              as.integer(inputs$year_range[2])))
  }

  chips
}
