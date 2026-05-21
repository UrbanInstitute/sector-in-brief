# panel_year_range: derive (start, end) from manifest year_counts.
# Trims only trailing partial years (cliff detection); leaves legit
# low early years alone.

write_manifest <- function(year_counts) {
  tmp <- withr::local_tempfile(fileext = ".json", .local_envir = parent.frame())
  jsonlite::write_json(
    list(files = list(test.parquet = list(year_counts = year_counts))),
    tmp, auto_unbox = TRUE
  )
  tmp
}

test_that("returns NA NA when manifest is missing", {
  expect_equal(panel_year_range("foo.parquet", manifest_path = "/no/such/file.json"),
               c(NA_integer_, NA_integer_))
})

test_that("returns NA NA when file is not in manifest", {
  mf <- write_manifest(list(`2020` = 100, `2021` = 100))
  expect_equal(panel_year_range("not_in_manifest.parquet", manifest_path = mf),
               c(NA_integer_, NA_integer_))
})

test_that("returns full range when all years are similarly populated", {
  mf <- write_manifest(list(`2020` = 100, `2021` = 110, `2022` = 105))
  expect_equal(panel_year_range("test.parquet", manifest_path = mf), c(2020L, 2022L))
})

test_that("trims a trailing year that falls off a cliff (< 50% of prev)", {
  mf <- write_manifest(list(`2020` = 100, `2021` = 100, `2022` = 30))
  expect_equal(panel_year_range("test.parquet", manifest_path = mf), c(2020L, 2021L))
})

test_that("trims multiple trailing partial years", {
  mf <- write_manifest(list(`2020` = 100, `2021` = 100, `2022` = 30, `2023` = 10))
  expect_equal(panel_year_range("test.parquet", manifest_path = mf), c(2020L, 2021L))
})

test_that("does NOT trim legitimately low early years (no false positive)", {
  # Realistic Numbers shape: 1989-1994 had ~51k rows, then ~125k+ from 1995
  # onward. Should keep all years, not trim from the start.
  mf <- write_manifest(list(
    `1989` = 51000, `1990` = 51000, `1991` = 51000,
    `1995` = 122000, `2020` = 200000, `2024` = 210000
  ))
  expect_equal(panel_year_range("test.parquet", manifest_path = mf), c(1989L, 2024L))
})

test_that("resolve_panel_year_range honors integer overrides", {
  mf <- write_manifest(list(`2020` = 100, `2021` = 100, `2022` = 100))
  # No override: use manifest
  expect_equal(
    resolve_panel_year_range("test.parquet", NA_integer_, NA_integer_),
    c(NA_integer_, NA_integer_)  # manifest_path defaults to data/, not our tmp
  )
  # Override both: ignore manifest
  expect_equal(
    resolve_panel_year_range("test.parquet", 2010L, 2015L),
    c(2010L, 2015L)
  )
})
