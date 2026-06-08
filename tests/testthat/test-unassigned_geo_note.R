# unassigned_geo_note counts records the producer left with NA county /
# metro (honest "unassigned", ADR 0021) for the state(s) in view, so the
# geographic breakdown's silent under-count is made legible.

ds_fixture <- function(env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".parquet", .local_envir = env)
  fixture_to(path)  # make_daf_fixture: MA, one NA-county/NA-metro row (1000)
  arrow::open_dataset(path)
}

test_that("county view reports the NA-county records for the selected state", {
  ds <- ds_fixture()
  note <- unassigned_geo_note(
    ds,
    list(geo_level = "Census County", geo_state_single = "MA", geo_state_mult = NULL),
    list(filters = list()),
    "Number of Nonprofits"
  )
  expect_match(note, "MA")
  expect_match(note, "1,000")
  expect_match(note, "no assigned county")
})

test_that("metro view phrases NA metro as rural/unmapped", {
  ds <- ds_fixture()
  note <- unassigned_geo_note(
    ds,
    list(geo_level = "Metro/Micro Area", geo_state_single = "MA", geo_state_mult = NULL),
    list(filters = list()),
    "Number of Nonprofits"
  )
  expect_match(note, "no metro/micro area")
  expect_match(note, "1,000")
})

test_that("returns NULL at National/Region (too broad to be useful)", {
  ds <- ds_fixture()
  expect_null(unassigned_geo_note(
    ds, list(geo_level = "Census Region"), list(filters = list()),
    "Number of Nonprofits"
  ))
})

test_that("returns NULL when no state is selected", {
  ds <- ds_fixture()
  expect_null(unassigned_geo_note(
    ds,
    list(geo_level = "Census County", geo_state_single = character(0),
         geo_state_mult = NULL),
    list(filters = list()),
    "Number of Nonprofits"
  ))
})

test_that("returns NULL when the selected state has no unassigned records", {
  ds <- ds_fixture()
  # NY has no rows in the fixture → nothing unassigned.
  expect_null(unassigned_geo_note(
    ds,
    list(geo_level = "Census County", geo_state_single = "NY", geo_state_mult = NULL),
    list(filters = list()),
    "Number of Nonprofits"
  ))
})

test_that("dollar metric formats the unassigned sum with a $ short-scale", {
  df <- tibble::tibble(
    `Census State`        = c("MA", "MA"),
    `Census County`       = c("Suffolk County", NA),   # one assigned, one not
    `County FIPS`         = c("25025", NA),
    `Metro/Micro Area`    = c("Boston-Cambridge-Newton, MA-NH", NA),
    `CBSA Code`           = c("14460", NA),
    Year                  = c(2022L, 2022L),
    `Total Contributions` = c(10000, 2e9)              # 2B unassigned
  )
  path <- withr::local_tempfile(fileext = ".parquet")
  arrow::write_parquet(df, path)
  note <- unassigned_geo_note(
    arrow::open_dataset(path),
    list(geo_level = "Census County", geo_state_single = "MA", geo_state_mult = NULL),
    list(filters = list()),
    "Total Contributions"
  )
  expect_match(note, "MA")
  expect_match(note, "\\$2B")
})
