make_inputs <- function(...) {
  defaults <- list(
    geo_level = "National",
    geo_region = NULL,
    geo_state_single = NULL,
    geo_state_mult = NULL,
    geo_county = NULL,
    geo_cbsa = NULL,
    subsector = c("Arts"),
    size = c("1", "2")
  )
  utils::modifyList(defaults, list(...))
}

test_that("national selection with subsector and size is valid", {
  res <- validate_inputs(make_inputs())
  expect_true(res$valid)
  expect_length(res$errors, 0)
})

test_that("missing subsector flags subsector error", {
  res <- validate_inputs(make_inputs(subsector = character()))
  expect_false(res$valid)
  expect_true("subsector" %in% names(res$errors))
})

test_that("missing size flags size error", {
  res <- validate_inputs(make_inputs(size = character()))
  expect_false(res$valid)
  expect_equal(names(res$errors), "size")
})

test_that("multiple missing filters accumulate (does not overwrite)", {
  res <- validate_inputs(make_inputs(
    geo_level = "Census Region",
    geo_region = NULL,
    subsector = character(),
    size = character()
  ))
  expect_false(res$valid)
  expect_setequal(names(res$errors), c("geo", "subsector", "size"))
})

test_that("Census Region without selection flags geo", {
  res <- validate_inputs(make_inputs(geo_level = "Census Region"))
  expect_false(res$valid)
  expect_match(res$errors$geo, "region", ignore.case = TRUE)
})

test_that("Census State without selection flags geo", {
  res <- validate_inputs(make_inputs(geo_level = "Census State"))
  expect_false(res$valid)
  expect_match(res$errors$geo, "state", ignore.case = TRUE)
})

test_that("Census County without county selection flags geo", {
  # The state_single selectize always has a default (multiple=FALSE
  # auto-picks the first state), so the only failure mode in practice
  # is an empty county selection.
  res <- validate_inputs(make_inputs(
    geo_level = "Census County",
    geo_state_single = "California"
  ))
  expect_false(res$valid)
  expect_match(res$errors$geo, "count(y|ies)", ignore.case = TRUE)
})

test_that("Metro/Micro Area with state and CBSA is valid", {
  res <- validate_inputs(make_inputs(
    geo_level = "Metro/Micro Area",
    geo_state_single = "California",
    geo_cbsa = "Los Angeles-Long Beach-Anaheim, CA"
  ))
  expect_true(res$valid)
})

test_that("Metro/Micro Area without CBSA flags geo", {
  res <- validate_inputs(make_inputs(
    geo_level = "Metro/Micro Area",
    geo_state_single = "California"
  ))
  expect_false(res$valid)
  expect_match(res$errors$geo, "Metro/Micro Area", ignore.case = TRUE)
})
