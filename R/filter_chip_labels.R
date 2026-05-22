#' Compute the labels for the active-filter chip row.
#'
#' Returns one chip per filter that the user has narrowed from its
#' default. Rendered above the plot area by `data_server()` so users
#' can see their active filters at a glance without scrolling back
#' to the filter card.
#'
#' Defaults are the *realized* values captured the first time the
#' panel mounts (see `data_server()`'s once-only observer). Doing
#' that, rather than comparing against the static `choices` list,
#' matters for tree inputs: `urbn_tree` expands a parent selection
#' into a flat list of all descendant leaves, so static comparison
#' would mis-flag the unfiltered default as "narrowed" and stick a
#' chip on every panel at first load.
#'
#' Chip text caps at 3 listed items; longer selections collapse to
#' "<filter>: N selected" so the chip row never grows wider than the
#' plot.
#'
#' Pure function — testable without a reactive context.
#'
#' @param inputs Snapshot of the panel's inputs in the shape produced
#'   by `format_input()` (named list with ctype, geo_level, subsector,
#'   size, year_range, plus the conditional geo selections).
#' @param defaults Named list with the panel's realized default
#'   values: `ctype_default`, `subsector_default`, `size_default`,
#'   `year_default` (length-2 integer vector). NULL values are
#'   treated as "defaults not yet captured" → no chip emitted for
#'   that filter. Optional `size_choices` is the panel's named-list
#'   of size choices (label → value, from `choice_builder()`); when
#'   present, size chip text shows the dollar-range labels instead
#'   of the raw integer values.
#' @return Character vector of chip labels, in display order. Empty
#'   when no filter is narrowed.
filter_chip_labels <- function(inputs, defaults) {
  chips <- character()

  # Helper for the multi-select filters (ctype, subsector, size).
  # `selected` drives the diff against the realized default;
  # `display` is what shows up in the chip text (lets size map raw
  # integer values back to dollar-range labels).
  chip_for_set <- function(label, selected, default, display = selected) {
    if (is.null(default)) return(NULL)
    if (is.null(selected) || length(selected) == 0) return(NULL)
    if (setequal(selected, default)) return(NULL)
    if (length(display) <= 3) {
      sprintf("%s: %s", label, paste(display, collapse = ", "))
    } else {
      sprintf("%s: %d selected", label, length(display))
    }
  }

  c1 <- chip_for_set("Org Type", inputs$ctype, defaults$ctype_default)
  if (!is.null(c1)) chips <- c(chips, c1)

  if (!is.null(inputs$geo_level) && inputs$geo_level != "National") {
    selection <- switch(
      inputs$geo_level,
      "Census Region"    = inputs$geo_region,
      "Census State"     = inputs$geo_state_mult,
      "Census County"    = inputs$geo_county,
      "Metro/Micro Area" = inputs$geo_cbsa,
      NULL
    )
    geo_label <- sub("^Census ", "", inputs$geo_level)
    chips <- c(
      chips,
      if (length(selection) == 0) {
        geo_label
      } else if (length(selection) <= 3) {
        sprintf("%s: %s", geo_label, paste(selection, collapse = ", "))
      } else {
        sprintf("%s: %d selected", geo_label, length(selection))
      }
    )
  }

  c2 <- chip_for_set("Subsector", inputs$subsector,
                     defaults$subsector_default)
  if (!is.null(c2)) chips <- c(chips, c2)

  # Size values come through as integers (1-6); map back to the
  # dollar-range labels for the chip text so users don't see
  # "Size: 1, 2". The diff against the realized default still uses
  # the integer values (that's what input$size actually is).
  size_display <- as.character(inputs$size)
  if (!is.null(inputs$size) && !is.null(defaults$size_choices)) {
    inv <- stats::setNames(
      names(defaults$size_choices),
      as.character(unlist(defaults$size_choices))
    )
    matched <- inv[as.character(inputs$size)]
    size_display <- ifelse(is.na(matched), as.character(inputs$size), matched)
  }
  c3 <- chip_for_set("Size", inputs$size, defaults$size_default, size_display)
  if (!is.null(c3)) chips <- c(chips, c3)

  if (!is.null(defaults$year_default) &&
      !is.null(inputs$year_range) &&
      !identical(as.integer(inputs$year_range),
                 as.integer(defaults$year_default))) {
    chips <- c(chips, sprintf("Years: %d-%d",
                              as.integer(inputs$year_range[1]),
                              as.integer(inputs$year_range[2])))
  }

  chips
}
