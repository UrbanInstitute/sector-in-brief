# Dashboard-owned catalog of selectable download columns (ADR 0026 §6:
# "default column selection — the dashboard owns this; the API
# force-includes only `ein`").
#
# The modernized API (sector-in-brief-api) whitelists hundreds of NEW
# parquet column names and validates the requested `columns` against the
# live schema, 400-ing on unknowns. There is NO "list columns" endpoint,
# so the dashboard ships its own curated, grouped catalog rather than
# reflecting the full schema. Every `api_name` here must stay within the
# API's allowlist (the new names — there is NO legacy `F9_*` mapping; the
# old `panel_dd.csv` part-based picker is retired).
#
# Column-name provenance: identity / geography / classification names are
# fixed by openapi.yaml + docs/dashboard-integration-handoff.md (the geo
# names are crosswalk-derived per ADR 0021/0023). The FINANCIAL set is
# seeded with the names documented in the contract; expand it only after
# confirming the exact names against a staging response's
# `data_dictionary` (an unknown name 400s the whole request). See the
# TODO marker below.

#' Curated catalog of columns offered in the download form.
#'
#' @return A tibble with one row per selectable column:
#'   * `api_name` — new parquet column name sent to the API.
#'   * `label` — human-facing label shown in the picker.
#'   * `group` — accordion grouping for the picker UI.
#'   * `default` — pre-selected (user-deselectable) when TRUE.
#'   `ein` is intentionally absent: the API force-includes it, so it is
#'   never user-facing.
download_column_catalog <- function() {
  tibble::tribble(
    ~api_name,             ~label,                         ~group,           ~default,
    # --- Identification ---
    "org_name_display",    "Organization name",            "Identification", TRUE,
    # --- Classification ---
    "nteev2",              "NTEE-V2 code",                 "Classification", TRUE,
    "nteev2_subsector",    "Subsector (NTEE major group)", "Classification", TRUE,
    # Plain-English label for the subsector code above. API-derived to the
    # dashboard's canonical table_builder_subsector.R labels (overrides bmf's
    # raw column; EDU/HEL "(minus …)", UNU/unmapped/NULL -> Other; exactly 12
    # distinct values). Added by the API in response to our handoff.
    "nteev2_subsector_definition", "Subsector (plain-English label)", "Classification", TRUE,
    "org_type",            "Organization type (501(c))",   "Classification", TRUE,
    "ntee_common_code",    "NTEE common code",             "Classification", FALSE,
    # --- Geography ---
    "geo_state_abbr",      "State",                        "Geography",      TRUE,
    "geo_county_canonical","County (canonical name)",      "Geography",      TRUE,
    "geo_county_fips",     "County FIPS",                  "Geography",      FALSE,
    "cbsa_title",          "Metro/Micro area",             "Geography",      FALSE,
    "cbsa_code",           "CBSA code",                    "Geography",      FALSE,
    "census_region",       "Census region",                "Geography",      TRUE,
    # --- Financials ---
    # Names are core harmonized_names confirmed against the live staging
    # schema (dev/smoke_raw.R per-column probe, 2026-06-09).
    "total_revenue",       "Total revenue",                "Financials",     TRUE,
    "total_expenses",      "Total functional expenses",    "Financials",     TRUE,
    "total_assets_eoy",    "Total assets (end of year)",   "Financials",     TRUE,
    "total_liabilities_eoy","Total liabilities (end of year)", "Financials",  FALSE,
    "total_net_assets_eoy","Total net assets (end of year)", "Financials",   FALSE
  )
}

#' Picker choices grouped for `shinyWidgets::pickerInput` (label -> name).
#'
#' @param catalog Catalog tibble (defaults to `download_column_catalog()`).
#' @return A named list of named character vectors, one per `group`,
#'   suitable as a grouped `choices` argument.
download_column_choices <- function(catalog = download_column_catalog()) {
  split_groups <- split(catalog, catalog$group)
  lapply(split_groups, function(g) stats::setNames(g$api_name, g$label))
}

#' The default-selected column names.
#'
#' @param catalog Catalog tibble (defaults to `download_column_catalog()`).
#' @return Character vector of `api_name`s pre-selected in the picker.
download_column_defaults <- function(catalog = download_column_catalog()) {
  catalog$api_name[catalog$default]
}
