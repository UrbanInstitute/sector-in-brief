# Packages the Custom Panel Datasets form into the request body the
# modernized sector-in-brief-api expects (ADR 0008 / 0026). Companion to
# query_builder.R (which builds the in-process arrow filter spec for the
# viz panels); this one targets the external download API and its NEW
# parquet column names.
#
# There is NO legacy column mapping: the old UPPER_SNAKE
# (`CENSUS_STATE_ABBR`, `TAX_YEAR`, `Size`, ...) request shape read stale
# datasets and is retired. Filters map 1:1 onto the new schema; geography
# is filtered by collision-proof CODE (FIPS / CBSA code), not name
# (ADR 0021/0023). The asset-size filter is intentionally absent — the
# API has no range filter for the numeric `total_assets_eoy` (deferred by
# product). Dropping it also removes the legacy `asset_select` wiring bug
# (it read a non-existent input id).

#' Translate selected geography labels to the API's code-keyed filters.
#'
#' County and metro pickers show readable names but the API filters by
#' the stable codes (`geo_county_fips`, `cbsa_code`). The translation is
#' scoped to the selected states so a shared county/metro name does not
#' pull in codes from other states.
#'
#' @param names Selected display names (county canonical names or
#'   Metro/Micro area names).
#' @param states Selected state abbreviations (`geo_select`).
#' @param geo_df Nested-geographies lookup (`load_geo_df()`).
#' @param name_col,code_col Lookup columns in `geo_df` (dotted names).
#' @return Unique character vector of codes, or `NULL` when nothing maps.
geo_names_to_codes <- function(names, states, geo_df, name_col, code_col) {
  if (length(names) == 0) {
    return(NULL)
  }
  in_state <- geo_df[["Census.State"]] %in% states
  matches <- geo_df[in_state & geo_df[[name_col]] %in% names, code_col]
  codes <- unique(matches[!is.na(matches)])
  if (length(codes) == 0) NULL else as.character(codes)
}

#' Build the export request body from the form's inputs.
#'
#' @param inputs Form inputs gathered by `dataRequestServer()`.
#' @param geo_df Nested-geographies lookup, used to translate county/metro
#'   names to FIPS/CBSA codes.
#' @param estimate When TRUE, sets `"estimate": true` so the API returns a
#'   size pre-check (`row_count`, `estimated_bytes`) without materializing,
#'   writing to S3, or emailing (ADR 0026 §6).
#' @return A named list ready to serialize as the API request JSON. Array
#'   fields stay vectors (serialized as JSON arrays even when length 1);
#'   scalar fields are `jsonlite::unbox`-ed.
query_builder_download <- function(inputs, geo_df, estimate = FALSE) {
  # Form-type radio -> API `forms`. 990combined already unions 990 + 990-EZ,
  # so "both" is a single dataset (selecting it alongside 990/990ez would
  # double-count — see openapi.yaml).
  forms <- switch(
    inputs$form_select,
    "990"   = "990",
    "990EZ" = "990combined",
    "990"
  )

  # Columns: the catalog picker returns new api_names directly; fall back
  # to the curated defaults if somehow empty. `ein` is force-included by
  # the API, so we never send it.
  columns <- inputs$data_select
  if (length(columns) == 0) {
    columns <- download_column_defaults()
  }

  # Filters: WHERE col IN (...). Omit empty selections entirely (an empty
  # IN-list would match nothing). Geography filters by code, not name.
  filters <- list()
  if (length(inputs$org_select) > 0) {
    # `org_type` is the API's derived 501(c)-subsection label (PC/PF split),
    # mirroring sector-in-brief-data's derive_organization_type() — its values
    # match the dashboard's `ctype_id` exactly. NOT `nteev2_org_type`, which is
    # a different NTEE-V2 dimension (RG/AA/...).
    filters[["org_type"]] <- inputs$org_select
  }
  if (length(inputs$subsector_select) > 0) {
    filters[["nteev2_subsector"]] <- inputs$subsector_select
  }
  if (length(inputs$geo_select) > 0) {
    filters[["geo_state_abbr"]] <- inputs$geo_select
  }
  if (length(inputs$region_select) > 0) {
    filters[["census_region"]] <- inputs$region_select
  }
  county_fips <- geo_names_to_codes(
    inputs$county_select, inputs$geo_select, geo_df,
    "Census.County", "County.FIPS"
  )
  if (!is.null(county_fips)) {
    filters[["geo_county_fips"]] <- county_fips
  }
  cbsa_codes <- geo_names_to_codes(
    inputs$cbsa_select, inputs$geo_select, geo_df,
    "Metro.Micro.Area", "CBSA.Code"
  )
  if (!is.null(cbsa_codes)) {
    filters[["cbsa_code"]] <- cbsa_codes
  }

  payload <- list(
    tax_years = as.integer(unique(inputs$start_year:inputs$end_year)),
    forms     = forms,
    columns   = columns,
    format    = jsonlite::unbox(inputs$format_select %||% "csv")
  )
  if (length(filters) > 0) {
    payload$filters <- filters
  }
  if (!is.null(inputs$email) && nzchar(inputs$email)) {
    payload$email <- jsonlite::unbox(inputs$email)
  }
  if (isTRUE(estimate)) {
    payload$estimate <- jsonlite::unbox(TRUE)
  }
  payload
}
