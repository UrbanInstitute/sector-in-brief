# region_state_choices: constrains the download form's State picker to the
# selected Census region(s), so a region + an out-of-region state (which the
# API would intersect to an empty -> `geo_state_abbr IN ()` 500) can't be
# selected. The geo_df region partition is verified elsewhere to match the
# API's CENSUS_REGION.

fake_geo <- function() {
  data.frame(
    Census.State  = c("AZ", "CA", "NY", "NJ", "IL", "TX"),
    Census.Region = c("West", "West", "Northeast", "Northeast", "Midwest", "South"),
    stringsAsFactors = FALSE
  )
}

sc <- list("Arizona" = "AZ", "California" = "CA", "New York" = "NY",
           "New Jersey" = "NJ", "Illinois" = "IL", "Texas" = "TX")

test_that("no region selected returns the full state list unchanged", {
  expect_identical(region_state_choices(fake_geo(), character(0), sc), sc)
  expect_identical(region_state_choices(fake_geo(), NULL, sc), sc)
})

test_that("a region restricts to that region's states, keeping labels", {
  west <- region_state_choices(fake_geo(), "West", sc)
  expect_setequal(unlist(west, use.names = FALSE), c("AZ", "CA"))
  expect_setequal(names(west), c("Arizona", "California"))
})

test_that("multiple regions union their states", {
  res <- region_state_choices(fake_geo(), c("Northeast", "Midwest"), sc)
  expect_setequal(unlist(res, use.names = FALSE), c("NY", "NJ", "IL"))
})

test_that("AZ is unavailable under a non-West region (the item-8 case)", {
  ne <- region_state_choices(fake_geo(), "Northeast", sc)
  expect_false("AZ" %in% unlist(ne, use.names = FALSE))
})
