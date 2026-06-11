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
# form-specific: 990/990-EZ/990-combined share the 990 totals, but 990-PF
# has an ENTIRELY DIFFERENT Part I schema (no total_revenue/total_expenses/
# total_net_assets_eoy — the API 400s on those for a 990-PF query). All
# names confirmed against the live core dictionaries (an unknown name 400s
# the whole request).

#' Curated catalog of columns offered in the download form.
#'
#' @param form Selected form code (`"990"`, `"990ez"`, `"990combined"`, or
#'   `"990pf"`). Only the Financials block differs by form — 990-PF reports
#'   its own Part I line items, so requesting the 990 totals against a
#'   990-PF query is rejected by the API. Ignored when `source = "bmf"`.
#' @param source Query mode (ADR 0029): `"core"` (default, filing-level —
#'   the form-aware catalog below) or `"bmf"` (org-level registry — no
#'   financials, no tax year; see `download_bmf_catalog()`).
#' @return A tibble with one row per selectable column:
#'   * `api_name` — new parquet column name sent to the API.
#'   * `label` — human-facing label shown in the picker.
#'   * `group` — accordion grouping for the picker UI.
#'   * `default` — pre-selected (user-deselectable) when TRUE.
#'   `ein` is intentionally absent: the API force-includes it, so it is
#'   never user-facing.
download_column_catalog <- function(form = "990", source = "core") {
  if (identical(source, "bmf")) {
    return(download_bmf_catalog())
  }
  base <- tibble::tribble(
    ~api_name,             ~label,                         ~group,           ~default,
    # --- Identification ---
    # `tax_years` in the request only selects which year-partitions to read;
    # this column echoes the year into each output row (essential for
    # multi-year exports). Harmonized name confirmed in the core dictionary;
    # not to be confused with `extract_year` (the SOI processing year).
    "tax_year",            "Tax year",                     "Identification", TRUE,
    "org_name_display",    "Organization name",            "Identification", TRUE,
    # --- Classification --- (BMF/derived; form-independent)
    "nteev2",              "NTEE-V2 code",                 "Classification", TRUE,
    "nteev2_subsector",    "Subsector (NTEE major group)", "Classification", TRUE,
    # Plain-English label for the subsector code above. API-derived to the
    # dashboard's canonical table_builder_subsector.R labels (overrides bmf's
    # raw column; EDU/HEL "(minus …)", UNU/unmapped/NULL -> Other; exactly 12
    # distinct values). Added by the API in response to our handoff.
    "nteev2_subsector_definition", "Subsector (plain-English label)", "Classification", TRUE,
    "org_type",            "Organization type (501(c))",   "Classification", TRUE,
    "ntee_common_code",    "NTEE common code",             "Classification", FALSE,
    # --- Geography --- (crosswalk-derived; form-independent)
    # State / canonical county / CBSA name / region default ON: the
    # human-readable named geographies most exports want. FIPS + CBSA code
    # are opt-in join keys. geo_lat/geo_lon are the geocoder's WGS-84
    # point coordinates — opt-in only: ~40% are NA (geocoder unmatched)
    # and point coords are specialist GIS data, not wanted in a typical
    # finance/classification pull.
    "geo_state_abbr",      "State",                        "Geography",      TRUE,
    "geo_county_canonical","County (canonical name)",      "Geography",      TRUE,
    "geo_county_fips",     "County FIPS",                  "Geography",      FALSE,
    "cbsa_title",          "Metro/Micro area",             "Geography",      TRUE,
    "cbsa_code",           "CBSA code",                    "Geography",      FALSE,
    "census_region",       "Census region",                "Geography",      TRUE,
    "geo_lat",             "Latitude (WGS 84)",            "Geography",      FALSE,
    "geo_lon",             "Longitude (WGS 84)",           "Geography",      FALSE
  )
  rbind(base, download_financials_catalog(form))
}

#' Form-specific Financials block for the download catalog.
#'
#' 990/990-EZ/990-combined share the harmonized 990 totals. 990-PF has a
#' separate Part I schema, so it gets its own set (the `*_col_a` columns are
#' the "revenue and expenses per books" column; total_revenue/total_expenses/
#' total_net_assets_eoy simply do not exist for 990-PF). All names verified
#' against the live core dictionaries.
#'
#' @param form Selected form code.
#' @return A catalog tibble (same columns as `download_column_catalog`).
download_financials_catalog <- function(form = "990") {
  if (identical(form, "990pf")) {
    tibble::tribble(
      ~api_name,                         ~label,                                    ~group,       ~default,
      "total_revenue_col_a",             "Total revenue (per books)",               "Financials", TRUE,
      "total_expenses_col_a",            "Total expenses (per books)",              "Financials", TRUE,
      "net_investment_income",           "Net investment income",                   "Financials", TRUE,
      "qualifying_distributions_curr_yr","Qualifying distributions (current year)", "Financials", TRUE,
      "total_assets_eoy",                "Total assets (end of year, book value)",  "Financials", TRUE,
      "fair_mkt_value_total_assets_eoy", "Total assets (fair market value)",        "Financials", FALSE,
      "total_liabilities_eoy",           "Total liabilities (end of year)",         "Financials", FALSE,
      "contributions_received",          "Contributions received",                  "Financials", FALSE,
      "contributions_paid",              "Contributions and grants paid",           "Financials", FALSE,
      "distributable_amount",            "Distributable amount",                    "Financials", FALSE
    )
  } else {
    tibble::tribble(
      ~api_name,              ~label,                            ~group,       ~default,
      "total_revenue",        "Total revenue",                   "Financials", TRUE,
      "total_expenses",       "Total functional expenses",       "Financials", TRUE,
      "total_assets_eoy",     "Total assets (end of year)",      "Financials", TRUE,
      "total_liabilities_eoy","Total liabilities (end of year)", "Financials", FALSE,
      "total_net_assets_eoy", "Total net assets (end of year)",  "Financials", FALSE
    )
  }
}

#' Org-level (BMF) column catalog (ADR 0029, `source = "bmf"`).
#'
#' The BMF registry is one row per EIN for every registered nonprofit
#' (including non-filers), so it has NO financials and NO tax-year column —
#' the Financials block and `tax_year` are absent. The crosswalk-derived
#' geography + classification columns are the same as core mode. Defaults
#' are the dashboard's pick (the API forces only `ein`): organization name,
#' state, org type, and subsector. `first_year_in_bmf`/`last_year_in_bmf`
#' (the registry lifespan) are default-on because the API force-appends them
#' whenever the `active_years` filter is applied (filter provenance) — so
#' the picker reflects what actually comes back.
#'
#' @return A catalog tibble (same columns as `download_column_catalog`).
download_bmf_catalog <- function() {
  tibble::tribble(
    ~api_name,             ~label,                         ~group,             ~default,
    # --- Identification --- (no tax_year: the registry has no filing year)
    "org_name_display",    "Organization name",            "Identification",   TRUE,
    # --- Registry coverage --- (org lifespan; force-appended by the API
    # when active_years is applied, so surfaced default-on)
    "first_year_in_bmf",   "First year in registry",       "Registry coverage", TRUE,
    "last_year_in_bmf",    "Last year in registry",        "Registry coverage", TRUE,
    # --- Classification ---
    "nteev2",              "NTEE-V2 code",                 "Classification",   FALSE,
    "nteev2_subsector",    "Subsector (NTEE major group)", "Classification",   TRUE,
    "nteev2_subsector_definition", "Subsector (plain-English label)", "Classification", TRUE,
    "org_type",            "Organization type (501(c))",   "Classification",   TRUE,
    "ntee_common_code",    "NTEE common code",             "Classification",   FALSE,
    # --- Geography ---
    "geo_state_abbr",      "State",                        "Geography",        TRUE,
    "geo_county_canonical","County (canonical name)",      "Geography",        FALSE,
    "geo_county_fips",     "County FIPS",                  "Geography",        FALSE,
    "cbsa_title",          "Metro/Micro area",             "Geography",        FALSE,
    "cbsa_code",           "CBSA code",                    "Geography",        FALSE,
    "census_region",       "Census region",                "Geography",        FALSE,
    "geo_lat",             "Latitude (WGS 84)",            "Geography",        FALSE,
    "geo_lon",             "Longitude (WGS 84)",           "Geography",        FALSE
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
