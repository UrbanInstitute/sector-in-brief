# dataloader applies panel-specific filters depending on which columns
# are requested. These tests check the filter routing without touching
# the real synced parquets.

test_that("daf.parquet dollar-metric path drops NA dollar rows", {
  path <- withr::local_tempfile(fileext = "daf.parquet")
  fixture_to(path)
  cols <- c("Metro/Micro Area", "Year", "Total Contributions")

  out <- dplyr::collect(dataloader(path, cols))

  # Fixture has 6 rows; 2 have NA Total Contributions (the no-DAF cells).
  expect_equal(nrow(out), 4)
  expect_true(all(!is.na(out$`Total Contributions`)))
})

test_that("daf.parquet DAF Proportion path keeps NA dollar rows", {
  path <- withr::local_tempfile(fileext = "daf.parquet")
  fixture_to(path)
  cols <- c("Has DAF", "Number of Nonprofits", "Year")

  out <- dplyr::collect(dataloader(path, cols))

  # All 6 rows kept — Has DAF in cols means we want all BMF cells as denominator.
  expect_equal(nrow(out), 6)
  expect_true(any(out$`Has DAF` == 0))
})

test_that("daf.parquet Number of DAFs view applies the <= 50000 outlier filter", {
  path <- withr::local_tempfile(fileext = "daf.parquet")
  fx <- make_daf_fixture()
  fx$`Number of DAFs`[1] <- 60000L  # outlier
  fixture_to(path, fx)

  cols <- c("Year", "Number of DAFs")
  out <- dplyr::collect(dataloader(path, cols))

  expect_false(any(out$`Number of DAFs` > 50000, na.rm = TRUE))
  expect_true(all(!is.na(out$`Number of DAFs`)))
})

test_that("non-daf parquet is not subject to the daf dollar filter", {
  # Same schema but a different filename should not trigger the daf branch
  path <- withr::local_tempfile(fileext = ".parquet")  # not named *daf.parquet
  fixture_to(path)

  cols <- c("Year", "Total Contributions")
  out <- dplyr::collect(dataloader(path, cols))

  # No filter; all 6 rows pass through (NAs preserved).
  expect_equal(nrow(out), 6)
})
