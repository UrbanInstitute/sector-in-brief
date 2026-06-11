# query_builder_download + download helpers: pure functions that turn the
# Custom Panel Datasets form into the modernized API's request body (new
# parquet column names, code-keyed geo filters) and format its response.

fake_geo_df <- function() {
  data.frame(
    Census.State     = c("CA", "CA", "NY", "MD", "MD"),
    Census.County    = c("Los Angeles", "Orange", "Kings", "Baltimore", "Baltimore"),
    County.FIPS      = c("06037", "06059", "36047", "24005", "24510"),
    Metro.Micro.Area = c("Los Angeles-Long Beach-Anaheim, CA",
                         "Los Angeles-Long Beach-Anaheim, CA",
                         "New York-Newark-Jersey City, NY-NJ",
                         "Baltimore-Columbia-Towson, MD",
                         "Baltimore-Columbia-Towson, MD"),
    CBSA.Code        = c("31080", "31080", "35620", "12580", "12580"),
    stringsAsFactors = FALSE
  )
}

base_inputs <- function(...) {
  utils::modifyList(
    list(
      form_select      = "990",
      org_select       = c("501(c)(3) Public Charities"),
      subsector_select = c("ART", "EDU"),
      geo_select       = c("CA"),
      region_select    = character(0),
      county_select    = character(0),
      cbsa_select      = character(0),
      start_year       = 2019,
      end_year         = 2021,
      data_select      = c("org_name_display", "total_revenue"),
      format_select    = "csv",
      email            = "user@example.org"
    ),
    list(...)
  )
}

test_that("payload carries the new schema fields", {
  p <- query_builder_download(base_inputs(), fake_geo_df())

  expect_equal(p$tax_years, 2019:2021)
  expect_type(p$tax_years, "integer")
  expect_equal(p$forms, "990")
  expect_equal(p$columns, c("org_name_display", "total_revenue"))
  expect_equal(as.character(p$format), "csv")
  expect_equal(as.character(p$email), "user@example.org")
  expect_null(p$estimate)
})

test_that("form-type radio maps to API form codes", {
  expect_equal(query_builder_download(base_inputs(form_select = "990"), fake_geo_df())$forms, "990")
  expect_equal(query_builder_download(base_inputs(form_select = "990ez"), fake_geo_df())$forms, "990ez")
  # 990combined already unions 990 + 990-EZ (its own option, not combinable)
  expect_equal(query_builder_download(base_inputs(form_select = "990combined"), fake_geo_df())$forms, "990combined")
  expect_equal(query_builder_download(base_inputs(form_select = "990pf"), fake_geo_df())$forms, "990pf")
  # unknown value falls back to plain 990
  expect_equal(query_builder_download(base_inputs(form_select = "bogus"), fake_geo_df())$forms, "990")
})

test_that("estimate flag sets estimate=true", {
  p <- query_builder_download(base_inputs(), fake_geo_df(), estimate = TRUE)
  expect_true(as.logical(p$estimate))
})

test_that("filters use new column names and omit empty selections", {
  p <- query_builder_download(base_inputs(region_select = "West"), fake_geo_df())
  expect_equal(p$filters$org_type, "501(c)(3) Public Charities")
  expect_equal(p$filters$nteev2_subsector, c("ART", "EDU"))
  expect_equal(p$filters$geo_state_abbr, "CA")
  expect_equal(p$filters$census_region, "West")
  # county/cbsa not selected -> absent
  expect_null(p$filters$geo_county_fips)
  expect_null(p$filters$cbsa_code)
})

test_that("county/metro filter by code, scoped to the selected states", {
  inp <- base_inputs(
    geo_select    = c("CA"),
    county_select = c("Los Angeles", "Orange"),
    cbsa_select   = c("Los Angeles-Long Beach-Anaheim, CA")
  )
  p <- query_builder_download(inp, fake_geo_df())
  expect_equal(sort(p$filters$geo_county_fips), c("06037", "06059"))
  expect_equal(p$filters$cbsa_code, "31080")
})

test_that("shared county names don't leak across states", {
  # "Baltimore" exists in MD only here; selecting NY must not pull it in.
  inp <- base_inputs(geo_select = "NY", county_select = "Baltimore")
  codes <- geo_names_to_codes(inp$county_select, inp$geo_select,
                              fake_geo_df(), "Census.County", "County.FIPS")
  expect_null(codes)
})

test_that("empty columns fall back to curated defaults", {
  p <- query_builder_download(base_inputs(data_select = character(0)), fake_geo_df())
  expect_equal(p$columns, download_column_defaults())
})

test_that("column catalog: defaults are a subset of all api_names, ein excluded", {
  cat <- download_column_catalog()
  expect_true(all(download_column_defaults() %in% cat$api_name))
  expect_false("ein" %in% cat$api_name)
  # grouped choices for pickerInput optgroups
  ch <- download_column_choices()
  expect_true(all(c("Geography", "Financials") %in% names(ch)))
})

test_that("geography defaults: named units default ON, lat/lon opt-in", {
  cat <- download_column_catalog()
  defaults <- download_column_defaults(cat)
  # Human-readable named geographies are pre-selected.
  expect_true(all(c("geo_state_abbr", "geo_county_canonical", "cbsa_title",
                    "census_region") %in% defaults))
  # Point coordinates are offered but NOT pre-selected (~40% NA, specialist).
  expect_true(all(c("geo_lat", "geo_lon") %in% cat$api_name))
  expect_false(any(c("geo_lat", "geo_lon") %in% defaults))
})

test_that("column catalog is form-aware: 990-PF gets its own financials", {
  std <- download_column_catalog("990")
  pf  <- download_column_catalog("990pf")
  # 990 totals that do NOT exist in the 990-PF schema must be absent for PF
  absent_for_pf <- c("total_revenue", "total_expenses", "total_net_assets_eoy")
  expect_true(all(absent_for_pf %in% std$api_name))
  expect_false(any(absent_for_pf %in% pf$api_name))
  # PF-specific Part I fields present + default
  expect_true(all(c("total_revenue_col_a", "net_investment_income",
                    "qualifying_distributions_curr_yr") %in% pf$api_name))
  expect_true("net_investment_income" %in% download_column_defaults(pf))
  # shared base columns identical across forms
  base <- c("tax_year", "org_type", "nteev2_subsector_definition", "geo_state_abbr")
  expect_true(all(base %in% std$api_name) && all(base %in% pf$api_name))
})

test_that("human_bytes formats short-scale sizes", {
  expect_equal(human_bytes(0), "0 B")
  expect_equal(human_bytes(2.91 * 1024^2), "2.9 MB")
  expect_equal(human_bytes(1.4 * 1024^3), "1.4 GB")
  expect_equal(human_bytes(NA), "unknown size")
})

test_that("download_link assembles durable URLs", {
  cfg <- list(download_url = "https://dl.example.aws/")
  expect_equal(
    download_link("/download/abc", config = cfg),
    "https://dl.example.aws/download/abc"
  )
  expect_equal(
    download_link("/download/abc", kind = "dictionary", config = cfg),
    "https://dl.example.aws/download/abc?kind=dictionary"
  )
  expect_null(download_link(NULL, config = cfg))
})
