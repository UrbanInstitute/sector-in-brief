# ensure_data_local: cached fast-path when local manifest matches VINTAGE,
# falls back to HTTPS-driven download otherwise. We never touch the real
# network.

test_that("ensure_data_local is a no-op when local manifest reports the target vintage", {
  tmp <- withr::local_tempdir()
  manifest <- file.path(tmp, "_manifest.json")
  jsonlite::write_json(
    list(vintage = sub("^v", "", VINTAGE)),
    path = manifest,
    auto_unbox = TRUE
  )

  called <- FALSE
  mockery::stub(ensure_data_local, "utils::download.file",
                function(...) { called <<- TRUE; 0L })

  res <- ensure_data_local(data_dir = tmp)
  expect_false(called)
  expect_equal(res$status, "fresh")
  expect_equal(res$vintage, sub("^v", "", VINTAGE))
})

test_that("ensure_data_local downloads from the public HTTPS endpoint when the manifest is missing", {
  tmp <- withr::local_tempdir()
  # No manifest written.

  urls_called <- character()
  fake_dl <- function(url, destfile, ...) {
    urls_called <<- c(urls_called, url)
    # Synthesise a tiny manifest so the loop has something to iterate.
    if (grepl("_manifest\\.json$", url)) {
      jsonlite::write_json(
        list(
          vintage = sub("^v", "", VINTAGE),
          files = list("number_nonprofits.parquet" = list(file = "number_nonprofits.parquet"))
        ),
        path = destfile,
        auto_unbox = TRUE
      )
    } else {
      file.create(destfile)
    }
    0L
  }
  mockery::stub(ensure_data_local, "utils::download.file", fake_dl)

  res <- ensure_data_local(data_dir = tmp)
  # First call is the manifest, then each parquet from the synthesised manifest.
  expect_match(urls_called[1], "^https://nccsdata\\.s3\\.amazonaws\\.com/.*_manifest\\.json$")
  expect_true(any(grepl("number_nonprofits\\.parquet$", urls_called)))
  expect_equal(res$status, "fresh")
})

test_that("ensure_data_local downloads again when manifest vintage doesn't match", {
  tmp <- withr::local_tempdir()
  manifest <- file.path(tmp, "_manifest.json")
  jsonlite::write_json(list(vintage = "1900.01"), path = manifest, auto_unbox = TRUE)

  called <- FALSE
  fake_dl <- function(url, destfile, ...) {
    called <<- TRUE
    if (grepl("_manifest\\.json$", url)) {
      jsonlite::write_json(
        list(vintage = sub("^v", "", VINTAGE), files = list()),
        path = destfile, auto_unbox = TRUE
      )
    } else file.create(destfile)
    0L
  }
  mockery::stub(ensure_data_local, "utils::download.file", fake_dl)

  ensure_data_local(data_dir = tmp)
  expect_true(called)
})

test_that("ensure_data_local stops only when download fails AND no local data exists", {
  tmp <- withr::local_tempdir()
  mockery::stub(ensure_data_local, "utils::download.file",
                function(...) stop("404 not found"))
  expect_error(ensure_data_local(data_dir = tmp),
               "no local data to fall back to")
})

test_that("ensure_data_local falls back to stale local data on download failure", {
  tmp <- withr::local_tempdir()
  manifest <- file.path(tmp, "_manifest.json")
  jsonlite::write_json(list(vintage = "1900.01"), path = manifest, auto_unbox = TRUE)
  mockery::stub(ensure_data_local, "utils::download.file",
                function(...) stop("network down"))

  expect_warning(
    res <- ensure_data_local(data_dir = tmp),
    "serving stale local data"
  )
  expect_equal(res$status, "stale")
  expect_equal(res$vintage, "1900.01")
})

test_that("publish_data_dictionary writes a UTF-8 BOM at the start of the CSV", {
  parquet <- withr::local_tempfile(fileext = ".parquet")
  arrow::write_parquet(
    tibble::tibble(field = "Size", coverage_notes = "1989-2026 expense band"),
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
