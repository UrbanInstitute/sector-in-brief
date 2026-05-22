# One of six caption_*.R helpers. Each appends a per-section line to
# the running plot caption assembled by `plot_caption()`. Only the
# argument matching the active geo level is consumed.

#' Add the geography line(s) to a plot caption.
#'
#' @param caption Running caption string.
#' @param geo_level Active level (e.g. "Census State", "National").
#' @param region,state_single,state_mult,county,cbsa Selections; only
#'   the one(s) matching `geo_level` are read.
#' @return Updated caption string.
caption_geo <- function(caption,
                      geo_level,
                      region,
                      state_single,
                      state_mult,
                      county,
                      cbsa) {
  if (geo_level == "National"){
    caption <- paste("Geography: National, grouped by regions.", "\n")
  }
  else if (geo_level == "Census Region") {
    caption <- paste("Region(s):", paste(region, collapse = ", "), "\n")
  }
  else if (geo_level == "Census State") {
    caption <- paste("State(s):", paste(state_mult, collapse = ", "), "\n")
  }
  else if (geo_level == "Census County") {
    caption <- paste("State:",
                     state_single,
                     "\n",
                     "County(s):",
                     paste(county, collapse = ", "),
                     "\n")
  }
  else if (geo_level == "Metro/Micro Area") {
    caption <- paste(
      "State:",
      state_single,
      "\n",
      "Metro/Micro Area(s):",
      paste(cbsa, collapse = ", "),
      "\n"
    )
  }
  return(caption)
}