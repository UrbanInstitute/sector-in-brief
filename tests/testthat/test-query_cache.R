# cached_filter_and_summarise: first call runs filter+summarise, subsequent
# calls with the same query return the cached tables without re-running.

# Each test gets a fresh per-tempdir cache so they don't interfere.
local_fresh_cache <- function(.local_envir = parent.frame()) {
  prev <- .pipeline_cache$store
  init_pipeline_cache(dir = withr::local_tempdir(.local_envir = .local_envir))
  withr::defer({ .pipeline_cache$store <- prev }, envir = .local_envir)
}

# Minimal query / data setup
sample_query <- function() {
  list(
    filters = list(
      `Census Region` = "Northeast",
      Year = 2020:2022,
      Size = c(1L, 2L, 3L)
    ),
    geo_level = "Census Region"
  )
}

test_that("cache miss runs the pipeline; cache hit returns stored tables", {
  local_fresh_cache()
  path <- withr::local_tempfile(fileext = "daf.parquet")
  fixture_to(path)
  data <- dataloader(path, c("Size", "Census Region", "Year", "Has DAF"))
  query <- list(filters = list(Year = 2021:2023), geo_level = "Census Region")

  call_count <- 0
  mockery::stub(cached_filter_and_summarise, "summarise_data",
                function(...) { call_count <<- call_count + 1; list(default = "stub") })

  t1 <- cached_filter_and_summarise(data, query, year_var = "Year", agg_var = "Has DAF")
  t2 <- cached_filter_and_summarise(data, query, year_var = "Year", agg_var = "Has DAF")

  # First call ran summarise_data; second was a cache hit.
  expect_equal(call_count, 1)
  expect_identical(t1, t2)
})

test_that("different query hashes miss separately", {
  local_fresh_cache()
  path <- withr::local_tempfile(fileext = "daf.parquet")
  fixture_to(path)
  data <- dataloader(path, c("Size", "Census Region", "Year", "Has DAF"))

  call_count <- 0
  mockery::stub(cached_filter_and_summarise, "summarise_data",
                function(...) { call_count <<- call_count + 1; list(default = "stub") })

  cached_filter_and_summarise(
    data,
    list(filters = list(Year = 2021:2023), geo_level = "Census Region"),
    year_var = "Year", agg_var = "Has DAF"
  )
  cached_filter_and_summarise(
    data,
    list(filters = list(Year = 2022:2023), geo_level = "Census Region"),  # different range
    year_var = "Year", agg_var = "Has DAF"
  )
  cached_filter_and_summarise(
    data,
    list(filters = list(Year = 2021:2023), geo_level = "Census Region"),
    year_var = "Year", agg_var = "Number of Nonprofits"  # different agg
  )

  expect_equal(call_count, 3)
})

test_that("init_pipeline_cache is idempotent", {
  init_pipeline_cache()
  c1 <- .pipeline_cache$store
  init_pipeline_cache()
  c2 <- .pipeline_cache$store
  # Both should be valid cache_disk objects (we re-init, not just attach)
  expect_true(inherits(c1, "cachem"))
  expect_true(inherits(c2, "cachem"))
})
