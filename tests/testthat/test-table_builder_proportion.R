# table_builder_proportion computes the DAF Proportion percentage:
# 100 * sum(numerator) / sum(denominator), with optional second groupby
# (e.g. by Size, Subsector, geo level) and a Size-band label rewrite.

test_that("computes single-group proportion as 100 * sum(num)/sum(denom)", {
  df <- tibble::tibble(
    Year                  = c(2022, 2022, 2022),
    `Has DAF`             = c(1, 0, 2),
    `Number of Nonprofits`= c(100, 200, 300)
  )
  out <- table_builder_proportion(
    df,
    groupby_var    = "Year",
    groupby_var_2  = NULL,
    sum_var        = "Has DAF",
    sum_var_2      = "Number of Nonprofits",
    proportion_var = "Proportion with DAFs"
  )
  expect_equal(nrow(out), 1)
  expect_equal(out$`Has DAF`, 3)
  expect_equal(out$`Number of Nonprofits`, 600)
  expect_equal(out$`Proportion with DAFs`, 100 * round(3/600, 2))
})

test_that("two-group proportion with Size rewrites integer bands to labels", {
  df <- tibble::tibble(
    Year                  = rep(2022, 4),
    Size                  = c(1, 2, 3, 6),
    `Has DAF`             = c(1, 2, 0, 5),
    `Number of Nonprofits`= c(10, 20, 30, 40)
  )
  out <- table_builder_proportion(
    df,
    groupby_var    = "Year",
    groupby_var_2  = "Size",
    sum_var        = "Has DAF",
    sum_var_2      = "Number of Nonprofits",
    proportion_var = "Proportion with DAFs"
  )
  expect_setequal(
    out$Size,
    c("Under $100,000", "$100,000 - $499,999", "$500,000 - $999,999", "Above $10 Million")
  )
})

test_that("returns a 'No Data Available' tribble on error", {
  out <- table_builder_proportion(
    NULL,
    groupby_var    = "Year",
    groupby_var_2  = NULL,
    sum_var        = "Has DAF",
    sum_var_2      = "Number of Nonprofits",
    proportion_var = "Proportion with DAFs"
  )
  expect_true("No Data Available" %in% names(out))
})
