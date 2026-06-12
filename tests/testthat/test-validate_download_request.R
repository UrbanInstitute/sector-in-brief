# validate_download_request: the single pre-submit completeness gate that
# runs regardless of how the user navigated the accordion (the per-step NEXT
# gates are bypassable by jumping to Review). Collects EVERY problem at once.
# Also covers friendly_api_error, which keeps raw engine errors out of the UI.

# A complete, valid request the form would build.
complete_inputs <- function(...) {
  utils::modifyList(list(
    org_select       = "501(c)(3) Public Charities",
    subsector_select = c("EDU", "HMS"),
    geo_select       = "AZ",
    data_select      = paste0("col", 1:3),
    start_year       = "2022",
    end_year         = "2023"
  ), list(...))
}

test_that("a complete request yields no problems", {
  expect_length(validate_download_request(complete_inputs()), 0)
})

test_that("each missing required filter is reported", {
  expect_match(
    validate_download_request(complete_inputs(org_select = character(0))),
    "organization type", all = FALSE
  )
  expect_match(
    validate_download_request(complete_inputs(subsector_select = NULL)),
    "subsector", all = FALSE
  )
  expect_match(
    validate_download_request(complete_inputs(geo_select = character(0))),
    "state", all = FALSE
  )
  expect_match(
    validate_download_request(complete_inputs(data_select = NULL)),
    "variable", all = FALSE
  )
})

test_that("inverted year range is reported (regression: guard must fire)", {
  problems <- validate_download_request(
    complete_inputs(start_year = "2023", end_year = "2022")
  )
  expect_match(problems, "must be on or before", all = FALSE)
})

test_that("equal start/end years are valid", {
  expect_length(
    validate_download_request(complete_inputs(start_year = "2023",
                                              end_year = "2023")),
    0
  )
})

test_that("every problem is collected at once, not just the first", {
  problems <- validate_download_request(list(
    org_select = character(0), subsector_select = NULL,
    geo_select = character(0), data_select = NULL,
    start_year = "2023", end_year = "2022"
  ))
  # 4 missing filters + 1 inverted range
  expect_length(problems, 5)
})

test_that("friendly_api_error masks raw engine errors but passes human text", {
  raw <- "Parser Error: syntax error at or near \")\" ... IN ()"
  expect_match(friendly_api_error(raw), "check your selections")
  expect_false(grepl("Parser Error", friendly_api_error(raw)))
  # An already-human API detail string passes through unchanged.
  human <- "tax_years must be a non-empty list."
  expect_equal(friendly_api_error(human), human)
  # Empty / NULL falls back to a generic message.
  expect_match(friendly_api_error(NULL), "could not be completed")
  expect_match(friendly_api_error(""), "could not be completed")
})
