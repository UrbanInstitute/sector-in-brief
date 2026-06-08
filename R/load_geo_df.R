# Load the nested-geographies lookup used by the geo filter dropdowns.
#
# This is the data-derived allowlist (ADR 0021): one row per selectable
# (state, county) — NA-county rows are already dropped by the producer —
# carrying the canonical county name, its County FIPS, and the
# Metro/Micro Area + CBSA Code it rolls up to. The dashboard derives the
# cascading dropdown choices from it (state → county → metro), filtering
# by the collision-proof code while showing the readable name.

#' Read nested_geographies.csv with FIPS/CBSA kept as strings, and join
#' the CBSA Type so the metro picker can split Metropolitan vs
#' Micropolitan.
#'
#' `read.csv` would coerce `County FIPS` / `CBSA Code` to integer and
#' strip their significant leading zeros (state `01` Alabama; the 5-char
#' GEOID), so they are forced to character. `CBSA Type` is joined from
#' the published cbsa crosswalk (one row per county GEOID) by CBSA Code.
#'
#' @param csv Path to the nested_geographies lookup.
#' @param cbsa_xwalk Path to the cbsa crosswalk parquet (optional — when
#'   absent the `CBSA.Type` column is simply omitted and the Metro/Micro
#'   filter degrades to "all areas").
#' @return A data.frame with dotted column names
#'   (`Census.State`, `Census.County`, `County.FIPS`, `Metro.Micro.Area`,
#'   `CBSA.Code`, `Census.Region`, and `CBSA.Type` when available).
load_geo_df <- function(csv = "data/nested_geographies.csv",
                        cbsa_xwalk = "data/cbsa_crosswalk.parquet") {
  geo_df <- utils::read.csv(
    csv,
    colClasses = c("County.FIPS" = "character", "CBSA.Code" = "character")
  )
  if (file.exists(cbsa_xwalk)) {
    types <- arrow::read_parquet(
      cbsa_xwalk,
      col_select = c("CBSA Code", "CBSA Type")
    )
    types <- unique(types[!is.na(types[["CBSA Code"]]), ])
    geo_df[["CBSA.Type"]] <- types[["CBSA Type"]][
      match(geo_df[["CBSA.Code"]], types[["CBSA Code"]])
    ]
  }
  geo_df
}
