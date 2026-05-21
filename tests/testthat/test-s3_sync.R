# ensure_data_local: cached fast-path when local manifest matches VINTAGE,
# falls back to aws s3 sync otherwise. We never touch the real network.

test_that("ensure_data_local is a no-op when local manifest reports the target vintage", {
  tmp <- withr::local_tempdir()
  manifest <- file.path(tmp, "_manifest.json")
  jsonlite::write_json(
    list(vintage = sub("^v", "", VINTAGE)),
    path = manifest,
    auto_unbox = TRUE
  )

  called <- FALSE
  mockery::stub(ensure_data_local, "system2", function(...) { called <<- TRUE; 0L })

  ensure_data_local(data_dir = tmp)
  expect_false(called)
})

test_that("ensure_data_local invokes aws s3 sync when the manifest is missing", {
  tmp <- withr::local_tempdir()
  # No manifest written.

  call_args <- NULL
  mockery::stub(ensure_data_local, "system2", function(command, args, ...) {
    call_args <<- list(command = command, args = args)
    0L
  })

  ensure_data_local(data_dir = tmp)
  expect_equal(call_args$command, "aws")
  expect_equal(head(call_args$args, 2), c("s3", "sync"))
  expect_match(call_args$args[3], "^s3://nccsdata/")
  expect_equal(call_args$args[4], tmp)
})

test_that("ensure_data_local invokes sync when manifest vintage doesn't match", {
  tmp <- withr::local_tempdir()
  manifest <- file.path(tmp, "_manifest.json")
  jsonlite::write_json(list(vintage = "1900.01"), path = manifest, auto_unbox = TRUE)

  called <- FALSE
  mockery::stub(ensure_data_local, "system2", function(...) { called <<- TRUE; 0L })

  ensure_data_local(data_dir = tmp)
  expect_true(called)
})

test_that("ensure_data_local stops with an informative error when aws sync fails", {
  tmp <- withr::local_tempdir()
  mockery::stub(ensure_data_local, "system2", function(...) 1L)
  expect_error(ensure_data_local(data_dir = tmp), "aws s3 sync failed")
})

test_that("ensure_data_local appends --profile <PROFILE> when SIB_AWS_PROFILE is set", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(SIB_AWS_PROFILE = "ci-profile")

  call_args <- NULL
  mockery::stub(ensure_data_local, "system2", function(command, args, ...) {
    call_args <<- args
    0L
  })

  ensure_data_local(data_dir = tmp)
  expect_true("--profile" %in% call_args)
  expect_equal(call_args[which(call_args == "--profile") + 1], "ci-profile")
})

test_that("publish_data_dictionary writes a UTF-8 BOM at the start of the CSV", {
  parquet <- withr::local_tempfile(fileext = ".parquet")
  arrow::write_parquet(
    tibble::tibble(field = "Size", coverage_notes = "1989–2026 expense band"),
    parquet
  )
  csv <- withr::local_tempfile(fileext = ".csv")

  publish_data_dictionary(parquet_path = parquet, csv_path = csv)

  bom <- readBin(csv, "raw", n = 3)
  expect_equal(as.integer(bom), c(0xEF, 0xBB, 0xBF))
})

test_that("publish_data_dictionary is a no-op when the parquet doesn't exist", {
  csv <- withr::local_tempfile(fileext = ".csv")
  publish_data_dictionary(parquet_path = "definitely-not-here.parquet",
                          csv_path = csv)
  expect_false(file.exists(csv))
})
