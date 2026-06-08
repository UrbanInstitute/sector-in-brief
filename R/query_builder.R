# Translate the formatted Shiny inputs into a query specification that
# filter_data() can push down into arrow. Output shape:
#
#   list(filters   = named-list of column → allowed-values,
#        geo_level = string)
#
# geo_level is forwarded separately because summarise_data() needs to
# know which column to use as the geographic breakdown axis, in
# addition to filtering on it.
#
# Subsector and Size are only added to the filter list when the user
# narrowed from the default (all 12 / all 6); otherwise they are
# omitted so the arrow scan can skip the comparison entirely. Year is
# always filtered — the date slider exists on every panel.

#' Build the filter + geo-level query for the pipeline.
#'
#' @param inputs Named list from `format_input()` (Shiny inputs +
#'   panel context resolved to plain values).
#' @param geo_df Geographic lookup table (unused at present; passed
#'   through to keep the signature stable across geo_query rewrites).
#' @return `list(filters, geo_level, geo_selected)`. National view
#'   rewrites `geo_level` to "Census Region" with all four regions
#'   selected so the by-geo breakdown shows region totals instead of
#'   being empty. `geo_selected` carries the user's selection as display
#'   *names* for the active level (county/metro codes resolved to names)
#'   so `missing_geo_note()` can diff against the named breakdown axis.
query_builder <- function(inputs, geo_df) {
  ctype <- inputs$ctype
  geo_level <- inputs$geo_level
  region <- inputs$geo_region
  state_single <- inputs$geo_state_single
  state_mult <- inputs$geo_state_mult
  county <- inputs$geo_county
  cbsa <- inputs$geo_cbsa
  subsector <- inputs$subsector
  size <- inputs$size
  year_range <- inputs$year_range
  year_var <- inputs$year_var
  time_series <- inputs$time_series

  # The active level's selection expressed as display names — county and
  # metro are filtered by code but surfaced to the user by name.
  geo_selected <- switch(
    geo_level,
    "Census State"     = if (length(state_mult) > 0) state_mult else state_single,
    "Census County"    = inputs$geo_county_label,
    "Metro/Micro Area" = inputs$geo_cbsa_label,
    NULL
  )

  filter_ls <- list()
  filter_ls <- ctype_query(filter_ls, ctype)

  if (geo_level == "National") {
    geo_level <- "Census Region"
    region <- c("Northeast", "Midwest", "South", "West")
  }
  filter_ls <- geo_query(filter_ls,
                         geo_level,
                         region,
                         state_single,
                         state_mult,
                         county,
                         cbsa)

  if (length(subsector) < 12) {
    filter_ls[["Subsector"]] <- subsector
  }
  # checkboxGroupInput returns strings; Size is int32 in the parquet
  # and arrow's lazy planner rejects string-vs-int32 comparisons.
  if (length(size) < 6) {
    filter_ls[["Size"]] <- as.integer(size)
  }
  # Applied unconditionally so the slider works on single-year panels
  # (DAFs) too. time_series only controls chart type downstream (line
  # vs bar). Integer coercion for the same arrow type-match reason.
  years <- seq(as.integer(year_range[1]), as.integer(year_range[2]))
  filter_ls[[year_var]] <- years

  list(filters = filter_ls, geo_level = geo_level, geo_selected = geo_selected)
}
