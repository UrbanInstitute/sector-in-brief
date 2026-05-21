test_that("coverage_notes_card returns NULL when parquet_file is empty / NA", {
  local_dict_fixture()
  expect_null(coverage_notes_card(NA_character_))
  expect_null(coverage_notes_card(""))
})

test_that("coverage_notes_card returns NULL when no rows have coverage_notes", {
  local_dict_fixture()
  # In the fixture, daf.parquet has one row with notes + one empty;
  # nonexistent.parquet has zero rows at all.
  expect_null(coverage_notes_card("nonexistent.parquet"))
})

test_that("coverage_notes_card renders an accordion with the matching note text", {
  local_dict_fixture()
  res <- coverage_notes_card("daf.parquet")
  expect_s3_class(res, "shiny.tag")
  rendered <- as.character(res)
  expect_match(rendered, "Known Data Coverage Gaps", fixed = TRUE)
  expect_match(rendered, "DAF reporting began 2008", fixed = TRUE)
})

test_that("coverage_notes_card filters dictionary by file argument", {
  local_dict_fixture()
  rendered <- as.character(coverage_notes_card("finances.parquet"))
  expect_match(rendered, "partial 2-line proxy", fixed = TRUE)
  # Notes from other files should not leak in
  expect_no_match(rendered, "DAF reporting began", fixed = TRUE)
})
