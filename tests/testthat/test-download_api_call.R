# classify_export_response: the pure response-classifier behind
# download_api_call. Covers the three /data response shapes (200 sync,
# 202 async-pending per ADR 0030, 400 validation) plus Lambda FunctionError
# and unparseable payloads — the live invoke itself needs AWS, so the
# contract logic is tested here instead.

# Build the Function-URL envelope the Lambda returns: {statusCode, body}
# where body is a JSON *string* (double-encoded), as the real API sends it.
mk_envelope <- function(status, body_list) {
  body_str <- as.character(jsonlite::toJSON(body_list, auto_unbox = TRUE))
  as.character(jsonlite::toJSON(list(statusCode = status, body = body_str),
                                auto_unbox = TRUE))
}

test_that("200 sync ready -> ok, not pending, carries result", {
  raw <- mk_envelope(200, list(
    job_id = "abc", row_count = 5,
    result = list(format = "csv", bytes = 100, url = "https://s3/abc"),
    download_url = "https://dl/abc"
  ))
  r <- classify_export_response(character(0), raw)
  expect_true(isTRUE(r$ok))
  expect_null(r$pending)
  expect_equal(r$row_count, 5)
  expect_equal(r$result$format, "csv")
})

test_that("202 async pending -> ok + pending, no result, carries job_id/bytes", {
  raw <- mk_envelope(202, list(
    job_id = "abc", status = "pending",
    download_path = "/download/abc", download_url = "https://dl/abc",
    estimated_bytes = 9e9
  ))
  r <- classify_export_response(character(0), raw)
  expect_true(isTRUE(r$ok))
  expect_true(isTRUE(r$pending))
  expect_null(r$result)
  expect_equal(r$job_id, "abc")
  expect_equal(r$estimated_bytes, 9e9)
})

test_that("400 validation -> not ok, surfaces detail over code", {
  raw <- mk_envelope(400, list(error = "validation_error",
                               detail = "tax_years must be a non-empty list of years"))
  r <- classify_export_response(character(0), raw)
  expect_false(isTRUE(r$ok))
  expect_equal(r$error, "tax_years must be a non-empty list of years")
})

test_that("Lambda FunctionError -> not ok, includes errorType", {
  raw <- '{"errorMessage":"boom","errorType":"RuntimeError","stackTrace":[]}'
  r <- classify_export_response("Unhandled", raw)
  expect_false(isTRUE(r$ok))
  expect_match(r$error, "RuntimeError")
  expect_match(r$error, "boom")
})

test_that("unparseable payload -> not ok with a clear message", {
  r <- classify_export_response(character(0), "not json{")
  expect_false(isTRUE(r$ok))
  expect_match(r$error, "parse", ignore.case = TRUE)
})

test_that("bare pending object (no envelope) is treated as async", {
  raw <- '{"status":"pending","job_id":"xyz","estimated_bytes":123}'
  r <- classify_export_response(character(0), raw)
  expect_true(isTRUE(r$ok))
  expect_true(isTRUE(r$pending))
  expect_equal(r$job_id, "xyz")
})
