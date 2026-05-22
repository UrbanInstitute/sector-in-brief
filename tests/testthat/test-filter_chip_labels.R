# filter_chip_labels: pure helper that decides which chips render
# above the plot. One chip per narrowed filter.

defaults_for <- function() {
  list(
    ctype_default     = c("A", "B", "C"),
    subsector_default = letters[1:12],
    size_default      = 1:6,
    year_default      = c(1989L, 2024L)
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

test_that("narrowed subsector produces a chip", {
  out <- filter_chip_labels(base_inputs(subsector = c("a", "b")), defaults_for())
  expect_length(out, 1)
  expect_match(out, "^Subsector:")
  expect_match(out, "a, b")
})

test_that("narrowed size produces a chip", {
  out <- filter_chip_labels(base_inputs(size = c(1, 2)), defaults_for())
  expect_match(out, "^Size:")
})

test_that("narrowed year range produces a chip", {
  out <- filter_chip_labels(base_inputs(year_range = c(2010L, 2020L)),
                            defaults_for())
  expect_match(out, "^Years: 2010-2020")
})

test_that("any geo level other than National produces a chip", {
  out <- filter_chip_labels(
    base_inputs(geo_level = "Census State", geo_state_mult = c("MA", "NY")),
    defaults_for()
  )
  expect_match(out, "^State: MA, NY")
})

test_that("Metro/Micro Area chip drops the 'Census' prefix", {
  out <- filter_chip_labels(
    base_inputs(geo_level = "Metro/Micro Area",
                geo_cbsa = "Boston-Cambridge-Newton, MA-NH"),
    defaults_for()
  )
  # Doesn't have "Census " in the label.
  expect_false(grepl("Census", out))
  expect_match(out, "^Metro/Micro Area:")
})

test_that("multiple narrowings produce multiple chips in expected order", {
  out <- filter_chip_labels(
    base_inputs(
      geo_level     = "Census Region",
      geo_region    = "Northeast",
      subsector     = c("a"),
      size          = c(1),
      year_range    = c(2010L, 2020L)
    ),
    defaults_for()
  )
  expect_length(out, 4)
  # Order: org, geo, subsector, size, years.
  expect_match(out[1], "^Region")
  expect_match(out[2], "^Subsector")
  expect_match(out[3], "^Size")
  expect_match(out[4], "^Years")
})

test_that("narrowed ctype produces a chip", {
  out <- filter_chip_labels(base_inputs(ctype = c("A")), defaults_for())
  expect_match(out, "^Org Type: A")
})

test_that("ctype default order does not matter", {
  # Same set in different order shouldn't produce a chip.
  out <- filter_chip_labels(base_inputs(ctype = c("C", "B", "A")),
                            defaults_for())
  expect_length(out, 0)
})
