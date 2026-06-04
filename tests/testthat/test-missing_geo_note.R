# missing_geo_note names user-selected geographies that returned no data.

# missing_geo_note diffs query$geo_selected (display names for the active
# level) against the by_geo breakdown axis. County/metro are filtered by
# code, so the selection is carried as names in geo_selected, not under a
# name-keyed filter entry.
q <- function(level, selected) {
  list(geo_level = level, geo_selected = selected,
       filters = setNames(list(selected), level))
}
geo_tbl <- function(level, values) {
  tables <- list()
  tables[["by_geo"]] <- setNames(tibble::tibble(values, x = seq_along(values)),
                                 c(level, "Total Program-Related Investments"))
  tables
}

test_that("flags a selected county absent from the result", {
  note <- missing_geo_note(
    q("Census County", c("Butte County", "Los Angeles County")),
    geo_tbl("Census County", c("Los Angeles County")),
    "Total Program-Related Investments"
  )
  expect_match(note, "Butte County")
  expect_match(note, "No reported Program-Related Investments")
  expect_false(grepl("Los Angeles", note))  # present geos not listed
})

test_that("returns NULL when all selected geographies are present", {
  note <- missing_geo_note(
    q("Census State", c("MA", "NY")),
    geo_tbl("Census State", c("MA", "NY")),
    "Total Government Grants"
  )
  expect_null(note)
})

test_that("skips National / Region levels (not explicit small-N selections)", {
  note <- missing_geo_note(
    q("Census Region", c("West")),
    geo_tbl("Census Region", c("Northeast")),
    "Total Program-Related Investments"
  )
  expect_null(note)
})

test_that("returns NULL when the result is a blank table (no geo column)", {
  tables <- list(by_geo = blank_table())
  note <- missing_geo_note(
    q("Census County", c("Butte County")),
    tables,
    "Total Program-Related Investments"
  )
  expect_null(note)
})

test_that("lists multiple missing areas", {
  note <- missing_geo_note(
    q("Metro/Micro Area", c("Lufkin, TX", "Omaha, NE-IA", "Boston, MA")),
    geo_tbl("Metro/Micro Area", c("Boston, MA")),
    "Total Program-Related Investments"
  )
  expect_match(note, "Lufkin, TX")
  expect_match(note, "Omaha, NE-IA")
})
