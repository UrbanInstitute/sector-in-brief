# download_form_min_year: the form-specific CORE floor for the download form.
# 990combined/990pf are reconciled back to 1989 in processed_merged/; standalone
# 990/990ez exist only from 2012 in processed/core/ (canonical API contract —
# sector-in-brief #77 / sector-in-brief-api #19).

test_that("merged-tier forms reach 1989, standalone forms floor at 2012", {
  expect_equal(download_form_min_year("990combined"), DOWNLOAD_MERGED_MIN_TAX_YEAR)
  expect_equal(download_form_min_year("990pf"),        DOWNLOAD_MERGED_MIN_TAX_YEAR)
  expect_equal(download_form_min_year("990combined"), 1989L)

  expect_equal(download_form_min_year("990"),   DOWNLOAD_CORE_MIN_TAX_YEAR)
  expect_equal(download_form_min_year("990ez"), DOWNLOAD_CORE_MIN_TAX_YEAR)
  expect_equal(download_form_min_year("990"),   2012L)
})

test_that("an unknown form falls back to the conservative 2012 floor", {
  expect_equal(download_form_min_year("bogus"), DOWNLOAD_CORE_MIN_TAX_YEAR)
})
