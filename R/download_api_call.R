# Calls the modernized download API's POST /data (ADR 0008 / 0026) from
# the Shiny server. The endpoint is a Lambda Function URL with
# AuthType: AWS_IAM, so the request must be SigV4-signed. We invoke the
# Lambda directly with `paws.compute` (the AWS SDK for R; `lambda()` lives
# in `paws.compute`, a lighter dependency than the full `paws`
# metapackage), which signs from the standard credential chain — no
# manual URL signing.
#
# Credentials: unlike the S3 data sync (anonymous HTTPS, no creds —
# ADR 0011), this path REQUIRES AWS credentials in the Shiny runtime,
# scoped to invoke this one function. Provide them via the standard
# environment (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION) as
# shinyapps.io secrets. `paws` picks them up automatically.
#
# Bytes never flow through here: the API materializes the result to S3 and
# returns presigned + durable URLs (pattern B, ADR 0026 §1). We only move
# the small JSON request/response.

#' Invoke POST /data and return the parsed result.
#'
#' @param payload Request body list from `query_builder_download()`.
#' @param config Endpoint config from `download_api_config()`.
#' @return A list with `ok` (logical). On a synchronous success: `ok = TRUE`
#'   plus the parsed response fields (`job_id`, `row_count`, `result`,
#'   `data_dictionary`, `download_path`, `download_url`, `email`, and — for
#'   estimate calls — `estimate`, `estimated_bytes`). On an async giant
#'   export (ADR 0030, HTTP 202): `ok = TRUE`, `pending = TRUE`, plus
#'   `job_id`, `status`, `download_path`/`download_url`, and
#'   `estimated_bytes` (no `result` yet — the worker emails the link). On
#'   failure: `ok = FALSE` and `error` (a human-readable message).
download_api_call <- function(payload, config = download_api_config()) {
  body <- jsonlite::toJSON(payload, auto_unbox = FALSE, na = "null")

  # TEMP diagnostic (ADR 0030 handoff): log the outgoing request body so a
  # "<col> IN ()" parser error reported from the UI can be traced to either
  # the dashboard payload or the API. The dashboard provably serializes a
  # selected single state as `["AZ"]` (see test-validate_download_request),
  # so this confirms whether staging sends the same. Remove once the API's
  # empty-filter handling is resolved.
  message("[download][diag] request: ", body)

  # NB: the pinned paws.compute (0.10.0) rejects a `timeout` config key
  # ("invalid name: timeout"), so we can't bound the invoke read-timeout to
  # the Lambda's 900s ceiling here (the API session's suggested guard). paws
  # defaults to no timeout, which matches prior behaviour; the estimate→warn
  # step is the practical guard against giant exports. Revisit if a paws
  # upgrade exposes a supported timeout option.
  client <- paws.compute::lambda(config = list(region = config$region))
  invoked <- tryCatch(
    client$invoke(
      FunctionName   = config$function_name,
      InvocationType = "RequestResponse",
      Payload        = body
    ),
    error = function(e) {
      list(.invoke_error = conditionMessage(e))
    }
  )
  if (!is.null(invoked$.invoke_error)) {
    return(list(ok = FALSE, error = invoked$.invoke_error))
  }

  classify_export_response(invoked$FunctionError, rawToChar(invoked$Payload))
}

#' Map a raw API error into a user-facing message.
#'
#' The API can surface low-level engine errors (e.g. a DuckDB "Parser Error"
#' from an empty `IN ()`) that mean nothing to a user and leak query
#' internals. Replace those with a friendly, actionable message; pass through
#' messages that are already human (the API's `detail` validation strings).
#' Pure / testable.
#'
#' @param err The `error` string from `download_api_call()`.
#' @return A user-facing message string.
friendly_api_error <- function(err) {
  if (is.null(err) || !nzchar(err)) {
    return("The export could not be completed. Please try again.")
  }
  if (grepl("parser error|syntax error|\\bSQL\\b|IN \\(\\)", err,
            ignore.case = TRUE)) {
    return(paste(
      "We couldn't process that request. Please check your selections",
      "(organization type, subsector, state, and variables) and try again."
    ))
  }
  err
}

#' Classify the raw Lambda invoke response into the `download_api_call`
#' contract. Pure (no AWS) so the three response shapes are unit-testable.
#'
#' @param function_error The invoke's `FunctionError` (character(0) on
#'   success — a thrown Python handler sets it).
#' @param raw The response `Payload` as a JSON string.
#' @return The same list `download_api_call` returns (see its `@return`).
classify_export_response <- function(function_error, raw) {
  parsed <- tryCatch(
    jsonlite::fromJSON(raw, simplifyVector = FALSE),
    error = function(e) NULL
  )
  if (is.null(parsed)) {
    return(list(ok = FALSE, error = "Could not parse the API response."))
  }

  # A thrown handler surfaces as Lambda FunctionError with the error in
  # the payload ({errorMessage, errorType, stackTrace}); fall back to the
  # raw payload so the cause is never silently swallowed. NB: paws returns
  # FunctionError as character(0) on success (not NULL), so guard on
  # length + nzchar — `!is.null()` alone is true for character(0).
  if (length(function_error) > 0 && nzchar(function_error)) {
    msg <- parsed$errorMessage %||% parsed$error %||% parsed$detail %||% raw
    if (!is.null(parsed$errorType)) {
      msg <- paste0(parsed$errorType, ": ", msg)
    }
    return(list(ok = FALSE, error = msg))
  }

  # Direct invoke may return the Function-URL envelope ({statusCode,
  # body}) or the response object directly; unwrap the former.
  if (!is.null(parsed$statusCode)) {
    status <- parsed$statusCode
    body_obj <- tryCatch(
      jsonlite::fromJSON(parsed$body, simplifyVector = FALSE),
      error = function(e) parsed$body
    )
    if (!is.numeric(status) || status >= 400) {
      # The API returns {error: <code>, detail: <human reason>}. The detail
      # is the actionable part ("tax_years must be a non-empty list"), so
      # prefer it; fall back to the code, then a generic message.
      msg <- if (is.list(body_obj)) {
        body_obj$detail %||% body_obj$error %||% "Validation error."
      } else {
        as.character(body_obj)
      }
      return(list(ok = FALSE, error = msg))
    }
    # Async giant-export (ADR 0030): a request whose estimate exceeds the
    # server's threshold is handed to a Fargate worker and accepted with
    # 202 — `status:"pending"`, a job_id + durable link, but no `result`
    # yet. The worker emails the durable link on completion. Tag it so the
    # caller shows the "we'll email you" message instead of a download card.
    if (is.numeric(status) && status == 202) {
      return(c(list(ok = TRUE, pending = TRUE), body_obj))
    }
    parsed <- body_obj
  }

  # A bare error object (no envelope).
  if (!is.null(parsed$error) || !is.null(parsed$detail)) {
    return(list(ok = FALSE, error = parsed$detail %||% parsed$error))
  }

  # A bare pending object (no envelope) — same async case as the 202 above.
  if (identical(parsed$status, "pending")) {
    return(c(list(ok = TRUE, pending = TRUE), parsed))
  }

  c(list(ok = TRUE), parsed)
}
