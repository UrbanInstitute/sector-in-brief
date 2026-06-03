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

# Minimal single-dollar-metric fixture for the government-grants /
# program-related-investments panels (most cells NA — most filers report none).
make_single_metric_fixture <- function(metric) {
  df <- tibble::tibble(
    `Organization Type` = rep("501(c)(3) Public Charities", 4),
    Subsector           = rep("EDU", 4),
    Size                = c(1L, 2L, 3L, 4L),
    `Census Region`     = rep("Northeast", 4),
    `Census State`      = rep("MA", 4),
    `Census County`     = rep("Suffolk", 4),
    `Metro/Micro Area`  = rep("Boston-Cambridge-Newton, MA-NH", 4),
    Year                = c(2021L, 2022L, 2023L, 2022L),
    metric_col          = c(10000, NA, 0, NA)  # 2 NA, plus a real 0
  )
  names(df)[names(df) == "metric_col"] <- metric
  df
}

test_that("government_grants.parquet drops NA metric rows (keeps real zeros)", {
  path <- withr::local_tempfile(fileext = "government_grants.parquet")
  fixture_to(path, make_single_metric_fixture("Total Government Grants"))
  cols <- c("Metro/Micro Area", "Year", "Total Government Grants")

  out <- dplyr::collect(dataloader(path, cols))

  # 2 of 4 rows are NA; the explicit 0 is kept.
  expect_equal(nrow(out), 2)
  expect_true(all(!is.na(out$`Total Government Grants`)))
  expect_true(0 %in% out$`Total Government Grants`)
})

test_that("program_related_investments.parquet drops NA metric rows", {
  path <- withr::local_tempfile(fileext = "program_related_investments.parquet")
  fixture_to(path, make_single_metric_fixture("Total Program-Related Investments"))
  cols <- c("Metro/Micro Area", "Year", "Total Program-Related Investments")

  out <- dplyr::collect(dataloader(path, cols))

  expect_equal(nrow(out), 2)
  expect_true(all(!is.na(out$`Total Program-Related Investments`)))
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
