# Driver tibble for the 11 visualization panels — the UI counterpart
# to data_server_args.R. Each row defines a navset_card_pill tab in
# the Data Visualizations section: header text, descriptive copy,
# panel id (used to namespace the Shiny module + output slots),
# year-range bounds, and the parquet file the panel reads from.
#
# Adding a new panel is one row here + one entry in data_server_args.
#
# start_year / end_year are RESOLVED at app() boot from the manifest's
# year_counts (see R/year_range.R + resolve_visualpanel_year_ranges()
# below). The values declared here act as overrides: NA = derive from
# manifest, integer = pin to this year.
#
# DAFs are pinned to 2021-2023 because the partial-ness in 2024 is in
# column values (sparse Has DAF flag from incomplete e-file ingest),
# not in row counts — the manifest threshold can't detect it.
# Numbers / finances / pf_grants are NA so the trailing partial year
# (currently 2024) auto-drops if the producer publishes one.
visualpanel_args <- tibble::tribble(
  ~title, ~panel_header, ~panel_desc, ~panelid, ~start_year, ~end_year, ~parquet_file,
  "Numbers", "Number of Nonprofits", number_of_nonprofits, "number", NA_integer_, NA_integer_, "number_nonprofits.parquet",
  "Assets", "Assets", assets_desc, "assets", NA_integer_, NA_integer_, "finances.parquet",
  "Revenues", "Revenues", revenue_desc, "revenues", NA_integer_, NA_integer_, "finances.parquet",
  "Expenses", "Expenses", expenses_desc, "expenses", NA_integer_, NA_integer_, "finances.parquet",
  "Benefits", "Benefits", benefits_desc, "benefits", NA_integer_, NA_integer_, "finances.parquet",
  "Private Foundation Grants", "Grants", grants_desc, "pf_amount", NA_integer_, NA_integer_, "pf_grants.parquet",
  "Number of DAFs", "Number of DAFs", daf_number_desc, "daf_number", 2021L, 2023L, "daf.parquet",
  "DAF Contributions", "DAF Contributions", daf_contributions_desc,"daf_contributions", 2021L, 2023L, "daf.parquet",
  "DAF Grants", "DAF Grants", daf_grants_desc, "daf_grants", 2021L, 2023L, "daf.parquet",
  "DAF Value", "DAF Value", daf_value_desc, "daf_value", 2021L, 2023L, "daf.parquet",
  "DAF Proportion", "Percentage of organizations that maintain a DAF", daf_proportion_desc, "daf_proportion", 2021L, 2023L, "daf.parquet",
)

#' Resolve NA year-range overrides against the live manifest.
#'
#' Called from `app()` after `ensure_data_local()`. For each row in
#' visualpanel_args, NA cells get replaced with year bounds derived
#' from `data/_manifest.json`'s `year_counts` (see `panel_year_range()`);
#' explicit integer cells pass through unchanged.
#'
#' @param args A copy of `visualpanel_args` (or a subset for testing).
#' @return The same tibble with start_year/end_year filled in.
resolve_visualpanel_year_ranges <- function(args = visualpanel_args) {
  resolved <- mapply(
    resolve_panel_year_range,
    parquet_file   = args$parquet_file,
    start_override = args$start_year,
    end_override   = args$end_year,
    SIMPLIFY = FALSE
  )
  args$start_year <- vapply(resolved, `[[`, integer(1), 1)
  args$end_year   <- vapply(resolved, `[[`, integer(1), 2)
  args
}
