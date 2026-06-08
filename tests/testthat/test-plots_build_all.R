# plot_or_blank: builds one panel plot and, on failure, retries once
# before degrading to blank_plot(). The retry targets a known first-render
# flake (group_line_plot intermittently throwing "NAs are not allowed in
# subscripted assignments" on the County By-Geography view); the message()
# makes a persistent failure visible in logs instead of a silent blank.
# We mock plots_build_single / blank_plot so the control flow is exercised
# without the heavy ggiraph build.

pob_args <- function(groupby_var = NULL) {
  list(
    table = data.frame(a = 1), groupby_var = groupby_var,
    title = "t", caption = "c",
    yvar = "y", xvar = "x",
    ytitle = "yt", xtitle = "xt", year_var = "Year"
  )
}

test_that("a clean build passes through with no retry and no message", {
  calls <- 0
  local_mocked_bindings(
    plots_build_single = function(...) { calls <<- calls + 1; "PLOT" }
  )
  expect_no_message(res <- do.call(plot_or_blank, pob_args()))
  expect_identical(res, "PLOT")
  expect_equal(calls, 1)
})

test_that("a first-attempt failure is retried once and the retry result is used", {
  calls <- 0
  local_mocked_bindings(
    plots_build_single = function(...) {
      calls <<- calls + 1
      if (calls == 1) stop("NAs are not allowed in subscripted assignments")
      "PLOT_ON_RETRY"
    }
  )
  expect_message(
    res <- do.call(plot_or_blank, pob_args()),
    "retrying once"
  )
  expect_identical(res, "PLOT_ON_RETRY")
  expect_equal(calls, 2)
})

test_that("a persistent failure degrades to blank_plot and logs both attempts", {
  local_mocked_bindings(
    plots_build_single = function(...) stop("boom"),
    blank_plot = function() "BLANK"
  )
  msgs <- capture_messages(
    res <- do.call(plot_or_blank, pob_args(groupby_var = "Census Region"))
  )
  expect_identical(res, "BLANK")
  # two log lines: the retry notice and the give-up notice
  expect_length(msgs, 2)
  # the failing group-by label is surfaced for observability
  expect_true(all(grepl("Census Region", msgs)))
  expect_match(msgs[2], "blank placeholder")
})

test_that("the overall (NULL group-by) view is labelled 'overall' in logs", {
  local_mocked_bindings(
    plots_build_single = function(...) stop("boom"),
    blank_plot = function() "BLANK"
  )
  msgs <- capture_messages(do.call(plot_or_blank, pob_args(groupby_var = NULL)))
  expect_true(all(grepl("'overall'", msgs)))
})

test_that("plots_build_all maps plot_or_blank across all tables", {
  local_mocked_bindings(
    plots_build_single = function(table, groupby_var, ...) groupby_var %||% "overall"
  )
  res <- plots_build_all(
    tables_ls = list(data.frame(a = 1), data.frame(a = 1)),
    groupby_vars = list(NULL, "Census Region"),
    title = "t", caption = "c", yvar = "y", xvar = "x",
    ytitle = "yt", xtitle = "xt", year_var = "Year"
  )
  expect_equal(res, list("overall", "Census Region"))
})
