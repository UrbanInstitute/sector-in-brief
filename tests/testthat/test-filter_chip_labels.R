# filter_chip_labels: pure helper that decides which chips render
# above the plot. One chip per narrowed filter; ≤3 items list them,
# ≥4 items collapse to "N selected".

defaults_for <- function() {
  list(
    ctype_default     = c("A", "B", "C"),
    subsector_default = letters[1:12],
    size_default      = 1:6,
    year_default      = c(1989L, 2024L),
    size_choices      = list(
      "Under $100,000"             = 1,
      "$100,000 - $499,999"        = 2,
      "$500,000 - $999,999"        = 3,
      "$1 Million - $4.99 Million" = 4,
      "$5 Million - $9.99 Million" = 5,
      "Above $10 Million"          = 6
    )
  )
}

base_inputs <- function(...) {
  defaults <- list(
    ctype            = c("A", "B", "C"),
    geo_level        = "National",
    geo_region       = NULL,
    geo_state_single = NULL,
    geo_state_mult   = NULL,
    geo_county       = NULL,
    geo_cbsa         = NULL,
    subsector        = letters[1:12],
    size             = 1:6,
    year_range       = c(1989L, 2024L)
  )
  utils::modifyList(defaults, list(...))
}

test_that("no chips when nothing is narrowed", {
  expect_length(filter_chip_labels(base_inputs(), defaults_for()), 0)
})

test_that("no chip emitted when its default has not been captured yet", {
  # data_server captures realized defaults asynchronously after first
  # mount; before that, the chip helper sees NULL defaults and must
  # emit nothing so the chip row stays empty.
  defaults <- defaults_for()
  defaults$ctype_default <- NULL
  defaults$subsector_default <- NULL
  defaults$size_default <- NULL
  defaults$year_default <- NULL
  expect_length(
    filter_chip_labels(base_inputs(subsector = c("a", "b")), defaults), 0
  )
})

test_that("narrowed subsector to <=3 lists items", {
  out <- filter_chip_labels(base_inputs(subsector = c("a", "b")), defaults_for())
  expect_match(out, "^Subsector: a, b$")
})

test_that("narrowed subsector to >=4 collapses to count", {
  out <- filter_chip_labels(
    base_inputs(subsector = letters[1:5]), defaults_for()
  )
  expect_match(out, "^Subsector: 5 selected$")
})

test_that("narrowed size chip shows the dollar-range labels, not integers", {
  out <- filter_chip_labels(base_inputs(size = c(1, 2)), defaults_for())
  expect_match(out, "^Size: Under \\$100,000, \\$100,000 - \\$499,999$")
})

test_that("size chip falls back to integer when size_choices not provided", {
  defaults <- defaults_for()
  defaults$size_choices <- NULL
  out <- filter_chip_labels(base_inputs(size = c(1, 2)), defaults)
  expect_match(out, "^Size: 1, 2$")
})

test_that("narrowed size to >=4 still collapses to count", {
  out <- filter_chip_labels(base_inputs(size = c(1, 2, 3, 4)), defaults_for())
  expect_match(out, "^Size: 4 selected$")
})

test_that("narrowed year range produces a chip", {
  out <- filter_chip_labels(base_inputs(year_range = c(2010L, 2020L)),
                            defaults_for())
  expect_match(out, "^Years: 2010-2020$")
})

test_that("any geo level other than National produces a chip", {
  out <- filter_chip_labels(
    base_inputs(geo_level = "Census State", geo_state_mult = c("MA", "NY")),
    defaults_for()
  )
  expect_match(out, "^State: MA, NY$")
})

test_that("Metro/Micro Area chip drops the 'Census' prefix", {
  out <- filter_chip_labels(
    base_inputs(geo_level = "Metro/Micro Area",
                geo_cbsa = "Boston-Cambridge-Newton, MA-NH"),
    defaults_for()
  )
  expect_false(grepl("Census", out))
  expect_match(out, "^Metro/Micro Area:")
})

test_that("multiple narrowings produce multiple chips in expected order", {
  out <- filter_chip_labels(
    base_inputs(
      ctype       = c("A"),
      geo_level   = "Census Region",
      geo_region  = "Northeast",
      subsector   = c("a"),
      size        = c(1),
      year_range  = c(2010L, 2020L)
    ),
    defaults_for()
  )
  expect_length(out, 5)
  expect_match(out[1], "^Org Type")
  expect_match(out[2], "^Region")
  expect_match(out[3], "^Subsector")
  expect_match(out[4], "^Size")
  expect_match(out[5], "^Years")
})

test_that("long ctype labels are truncated with an ellipsis", {
  long_label <- "501(c)(12) - Benevolent Life Insurance Associations, Mutual Ditch or Irrigation Companies, ..."
  defaults <- defaults_for()
  defaults$ctype_default <- c(long_label, "A", "B")  # realized default includes it
  out <- filter_chip_labels(base_inputs(ctype = long_label), defaults)
  expect_match(out, "…$")
  expect_lt(nchar(out), nchar(long_label) + 30)
})

test_that("narrowed ctype to >=4 collapses to count", {
  # Simulate the urbn_tree expanded-leaf case: realized default has
  # many leaves, user narrows to a subset that's still ≥4 items.
  defaults <- defaults_for()
  defaults$ctype_default <- paste0("ctype_", 1:30)
  out <- filter_chip_labels(
    base_inputs(ctype = paste0("ctype_", 1:10)), defaults
  )
  expect_match(out, "^Org Type: 10 selected$")
})

test_that("ctype with realized default order does not matter", {
  out <- filter_chip_labels(base_inputs(ctype = c("C", "B", "A")),
                            defaults_for())
  expect_length(out, 0)
})
