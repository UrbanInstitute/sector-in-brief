# Dispatcher: turn the five tables from summarise_data() into five
# ggiraph plots. Errors on any individual table degrade to a blank_plot
# placeholder so one bad group-by doesn't take the whole panel down —
# but unlike a bare purrr::possibly we log the failing group-by + error
# and retry once first. The retry exists because the known failure is a
# first-render warm-up flake (group_line_plot intermittently throws "NAs
# are not allowed in subscripted assignments" on the County By-Geography
# view); a second attempt in the same process almost always succeeds, so
# this turns a silent blank into a rendered plot. The message() makes any
# genuinely persistent failure observable in the prod logs instead of an
# unexplained blank placeholder.

#' Build all five plots for a panel.
#'
#' @param tables_ls Named list of 5 tibbles from `summarise_data()`.
#' @param groupby_vars Length-5 list naming the second group column
#'   for each table (NULL for the overall view).
#' @param title,caption Pre-computed strings shared across the panel.
#' @param yvar,xvar Column names for the y and x aesthetics.
#' @param ytitle,xtitle Axis label strings.
#' @param year_var Time column name — used by `plots_build_single()`
#'   to decide line-vs-bar.
#' @return Named list of 5 ggiraph plot objects.
plots_build_all <- function(tables_ls,
                            groupby_vars,
                            title,
                            caption,
                            yvar,
                            xvar,
                            ytitle,
                            xtitle,
                            year_var) {
  purrr::map2(
    tables_ls,
    groupby_vars,
    plot_or_blank,
    title = title,
    caption = caption,
    yvar = yvar,
    xvar = xvar,
    ytitle = ytitle,
    xtitle = xtitle,
    year_var = year_var
  )
}

#' Build one plot, retrying once and degrading to `blank_plot()` on a
#' persistent failure. Factored out of `plots_build_all` so the
#' retry/fallback/logging is unit-testable in isolation (stub
#' `plots_build_single`); args mirror `plots_build_single`.
#'
#' @inheritParams plots_build_single
#' @return A ggiraph plot, or `blank_plot()` if both attempts fail.
plot_or_blank <- function(table,
                          groupby_var,
                          title,
                          caption,
                          yvar,
                          xvar,
                          ytitle,
                          xtitle,
                          year_var) {
  label <- if (is.null(groupby_var)) "overall" else as.character(groupby_var)
  attempt <- function() {
    plots_build_single(
      table = table, groupby_var = groupby_var,
      title = title, caption = caption,
      yvar = yvar, xvar = xvar,
      ytitle = ytitle, xtitle = xtitle, year_var = year_var
    )
  }
  tryCatch(attempt(), error = function(e1) {
    message(sprintf(
      "[plots_build_all] plots_build_single failed for group-by '%s': %s -- retrying once",
      label, conditionMessage(e1)
    ))
    tryCatch(attempt(), error = function(e2) {
      message(sprintf(
        "[plots_build_all] retry failed for group-by '%s': %s -- using blank placeholder",
        label, conditionMessage(e2)
      ))
      blank_plot()
    })
  })
}
