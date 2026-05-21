# Shared helpers for the test suite.
# `helper-*.R` files are auto-sourced by testthat before any test runs.

# Minimal DAF panel fixture (in-memory; matches the producer schema).
# Columns mirror what data_server_args.R requests for DAF panels.
make_daf_fixture <- function() {
  tibble::tibble(
    `Organization Type`   = rep("501(c)(3) Public Charities", 6),
    Subsector             = rep("EDU", 6),
    Size                  = c(1L, 2L, 3L, 4L, 5L, 6L),
    `Census Region`       = rep("Northeast", 6),
    `Census State`        = rep("MA", 6),
    `Census County`       = c("Suffolk", "Suffolk", "Worcester", "Suffolk", "Suffolk", NA),
    `Metro/Micro Area`    = c("Boston-Cambridge-Newton, MA-NH",
                              "Boston-Cambridge-Newton, MA-NH",
                              "Worcester, MA",
                              "Boston-Cambridge-Newton, MA-NH",
                              "Boston-Cambridge-Newton, MA-NH",
                              NA),
    Year                  = c(2021L, 2022L, 2022L, 2023L, 2024L, 2022L),
    `Number of Nonprofits`= c(100L, 110L, 50L, 120L, 130L, 1000L),
    `Number of DAFs`      = c(3L, 4L, NA, 5L, 6L, NA),
    `Total Contributions` = c(10000, 12000, NA, 15000, 20000, NA),
    `Total Grants`        = c(5000, 6000, NA, 7000, 8000, NA),
    `Total Value`         = c(50000, 60000, NA, 70000, 80000, NA),
    `Has DAF`             = c(1L, 1L, 0L, 1L, 1L, 0L)
  )
}

# Write the fixture to a path the caller supplies (lifetime managed by caller).
# Use as:  path <- withr::local_tempfile(fileext = ".parquet"); fixture_to(path)
fixture_to <- function(path, df = make_daf_fixture()) {
  arrow::write_parquet(df, path)
  invisible(path)
}

# Inject an in-memory data-dictionary fixture into coverage_notes_card's
# module-level cache so the tests don't need data/data_dictionary.parquet.
local_dict_fixture <- function(.local_envir = parent.frame()) {
  prev <- .dict_cache$df
  .dict_cache$df <- tibble::tibble(
    file            = c("daf.parquet", "daf.parquet", "finances.parquet", "number_nonprofits.parquet"),
    column          = c("Year",        "Has DAF",     "Total Expenses",   "Size"),
    datatype        = c("integer",     "integer",     "double",           "integer"),
    description     = c("Tax year",    "DAF flag",    "Total expenses",   "Size band"),
    form_source     = rep("", 4),
    coverage        = c("2021–2024",   "2021–2024",   "1989–2024",        "1989–2026"),
    coverage_notes  = c("DAF reporting began 2008 — coverage starts 2021.",
                        "",
                        "1989-2011 partial 2-line proxy.",
                        "Size=0 means BMF metadata but no CORE filing.")
  )
  withr::defer({ .dict_cache$df <- prev }, envir = .local_envir)
}
