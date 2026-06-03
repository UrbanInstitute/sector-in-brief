# geo_query translates the active geo level into filter-list predicates.
# The County branch must ALSO scope to the selected state, because county
# names are not unique across states (regression: same-named counties in
# other states inflated totals — see R/geo_query.R).

test_that("County level scopes to the selected state and county", {
  fl <- geo_query(list(), "Census County",
                  region = NULL, state_single = "MI", state_mult = NULL,
                  county = c("Wayne County", "Monroe County"), cbsa = NULL)
  expect_equal(fl[["Census State"]], "MI")
  expect_equal(fl[["Census County"]], c("Wayne County", "Monroe County"))
})

test_that("County level degrades to name-only when no state is selected", {
  fl <- geo_query(list(), "Census County",
                  region = NULL, state_single = character(0), state_mult = NULL,
                  county = c("Wayne County"), cbsa = NULL)
  expect_null(fl[["Census State"]])
  expect_equal(fl[["Census County"]], "Wayne County")
})

test_that("Metro/Micro Area is NOT state-scoped (metros span states)", {
  fl <- geo_query(list(), "Metro/Micro Area",
                  region = NULL, state_single = "MO", state_mult = NULL,
                  county = NULL, cbsa = c("Kansas City, MO-KS"))
  expect_null(fl[["Census State"]])
  expect_equal(fl[["Metro/Micro Area"]], "Kansas City, MO-KS")
})

test_that("State level uses multi-select when present, else single", {
  fl_mult <- geo_query(list(), "Census State", NULL, "MI",
                       c("MI", "OH"), NULL, NULL)
  expect_equal(fl_mult[["Census State"]], c("MI", "OH"))

  fl_single <- geo_query(list(), "Census State", NULL, "MI",
                         character(0), NULL, NULL)
  expect_equal(fl_single[["Census State"]], "MI")
})

test_that("Region level filters on region", {
  fl <- geo_query(list(), "Census Region", c("Midwest"), NULL, NULL, NULL, NULL)
  expect_equal(fl[["Census Region"]], "Midwest")
})
