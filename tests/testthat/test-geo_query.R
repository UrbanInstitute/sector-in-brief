# geo_query translates the active geo level into filter-list predicates.
# County is filtered on `County FIPS` and Metro/Micro on `CBSA Code`
# (ADR 0021) — the codes are collision-proof, so a county selection is
# NOT scoped to a state (same-named counties in other states carry
# different FIPS and can't be swept in).

test_that("County level filters on County FIPS, not the name, and is not state-scoped", {
  fl <- geo_query(list(), "Census County",
                  region = NULL, state_single = "MI", state_mult = NULL,
                  county = c("26163", "26115"), cbsa = NULL)
  expect_equal(fl[["County FIPS"]], c("26163", "26115"))
  expect_null(fl[["Census County"]])     # not filtered by name
  expect_null(fl[["Census State"]])      # no state-scoping crutch
})

test_that("Metro/Micro Area filters on CBSA Code, not the name", {
  fl <- geo_query(list(), "Metro/Micro Area",
                  region = NULL, state_single = "MO", state_mult = NULL,
                  county = NULL, cbsa = c("28140"))
  expect_equal(fl[["CBSA Code"]], "28140")
  expect_null(fl[["Metro/Micro Area"]])
  expect_null(fl[["Census State"]])      # metros span states; never scoped
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
  fl <- geo_query(list(), "Census Region", c("Northeast", "South"),
                  NULL, NULL, NULL, NULL)
  expect_equal(fl[["Census Region"]], c("Northeast", "South"))
})
