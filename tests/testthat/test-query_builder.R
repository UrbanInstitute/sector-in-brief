# query_builder builds the filter list passed to filter_data. These tests
# exercise the filtering rules — size only filters when not all selected,
# subsector only when not all selected, year unconditional (PR #17 fix).

base_inputs <- function(...) {
  defaults <- list(
    ctype = "501(c)(3) Public Charities",
    geo_level = "National",
    geo_region = NULL,
    geo_state_single = NULL,
    geo_state_mult = NULL,
    geo_county = NULL,
    geo_cbsa = NULL,
    subsector = letters[1:12],     # all 12 selected
    size = 1:6,                    # all 6 selected
    year_range = c(2020L, 2022L),
    year_var = "Year",
    time_series = TRUE
  )
  utils::modifyList(defaults, list(...))
}

test_that("year filter is always set (time_series TRUE or FALSE)", {
  q1 <- query_builder(base_inputs(time_series = TRUE), geo_df = NULL)
  q2 <- query_builder(base_inputs(time_series = FALSE), geo_df = NULL)
  expect_equal(q1$filters$Year, 2020:2022)
  expect_equal(q2$filters$Year, 2020:2022)
})

test_that("size filter is omitted when all 6 sizes selected", {
  q <- query_builder(base_inputs(size = 1:6), geo_df = NULL)
  expect_null(q$filters$Size)
})

test_that("size filter is applied when fewer than 6 sizes selected", {
  q <- query_builder(base_inputs(size = c(1, 3, 5)), geo_df = NULL)
  expect_equal(q$filters$Size, c(1, 3, 5))
})

test_that("subsector filter is omitted when all 12 selected", {
  q <- query_builder(base_inputs(subsector = letters[1:12]), geo_df = NULL)
  expect_null(q$filters$Subsector)
})

test_that("subsector filter is applied when fewer than 12 selected", {
  q <- query_builder(base_inputs(subsector = c("EDU", "HEL")), geo_df = NULL)
  expect_equal(q$filters$Subsector, c("EDU", "HEL"))
})

test_that("National geo_level expands to all four Census Regions", {
  q <- query_builder(base_inputs(geo_level = "National"), geo_df = NULL)
  expect_equal(q$geo_level, "Census Region")
  expect_setequal(q$filters$`Census Region`,
                  c("Northeast", "Midwest", "South", "West"))
})
