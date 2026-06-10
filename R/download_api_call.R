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
#' @return A list with `ok` (logical). On success: `ok = TRUE` plus the
#'   parsed response fields (`job_id`, `row_count`, `result`,
#'   `data_dictionary`, `download_path`, `download_url`, `email`, and —
#'   for estimate calls — `estimate`, `estimated_bytes`). On failure:
#'   `ok = FALSE` and `error` (a human-readable message).
download_api_call <- function(payload, config = download_api_config()) {
  body <- jsonlite::toJSON(payload, auto_unbox = FALSE, na = "null")

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

  raw <- rawToChar(invoked$Payload)
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
  if (length(invoked$FunctionError) > 0 && nzchar(invoked$FunctionError)) {
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
      msg <- if (is.list(body_obj)) {
        body_obj$error %||% body_obj$detail %||% "Validation error."
      } else {
        as.character(body_obj)
      }
      return(list(ok = FALSE, error = msg))
    }
    parsed <- body_obj
  }

  # A bare error object (no envelope).
  if (!is.null(parsed$error)) {
    return(list(ok = FALSE, error = parsed$error))
  }

  c(list(ok = TRUE), parsed)
}
