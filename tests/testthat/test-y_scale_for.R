# y_scale_for: pure factory that returns a scale_y_continuous tuned
# to the panel's metric. Test by inspecting the labels callable's
# output on representative magnitudes.

test_that("dollar metrics produce $-prefixed short-scale labels", {
  s <- y_scale_for("Total Assets")
  out <- s$labels(c(0, 1.5e6, 1.2e9))
  expect_equal(out, c("$0", "$2M", "$1B"))   # default accuracy = 1
})

test_that("count metrics produce short-scale labels without $", {
  s <- y_scale_for("Number of Nonprofits")
  out <- s$labels(c(0, 1500, 1.8e6))
  expect_equal(out, c("0", "2K", "2M"))
  expect_false(any(grepl("\\$", out)))
})

test_that("DAF proportion produces percent labels at the right scale", {
  # Values pre-multiplied to 0-100 by table_builder_proportion.
  s <- y_scale_for("Proportion with DAFs")
  out <- s$labels(c(0, 25, 100))
  expect_equal(out, c("0%", "25%", "100%"))
})

test_that("y-axis lower bound is locked at 0", {
  s <- y_scale_for("Total Assets")
  expect_equal(s$limits, c(0, NA))
})
