# Pick the right ggiraph builder for one table based on its shape:
#
#   multi-year + no group   → single_line_plot
#   multi-year + group      → group_line_plot
#   single-year + no group  → single_col_plot
#   single-year + 1 group   → single_col_plot   (degenerate)
#   single-year + >1 group  → group_col_plot
#
# Empty or column-missing tables short-circuit to blank_plot.

#' Build one ggiraph plot from a summary table.
#'
#' @param table Tibble produced by one of the `table_builder_*` calls.
#' @param groupby_var Second group column name, or NULL for overall.
#' @param title,caption Pre-computed strings from `plot_title()` /
#'   `plot_caption()`.
#' @param yvar,xvar,ytitle,xtitle Standard ggplot aesthetics / labels.
#' @param year_var Time column; used here to detect single-year vs
#'   multi-year.
#' @return A girafe interactive plot, or `blank_plot()` on empty input.
plots_build_single <- function(table,
                               groupby_var,
                               title,
                               caption,
                               yvar,
                               xvar,
                               ytitle,
                               xtitle,
                               year_var) {
  if (is.null(table) || nrow(table) == 0 || !(year_var %in% names(table))) {
    return(blank_plot())
  }
  if (length(unique(table[[year_var]])) > 1) {
    if (is.null(groupby_var)) {
      single_line_plot(table = table, title = title, caption = caption,
                       yvar = yvar, xvar = xvar,
                       ytitle = ytitle, xtitle = xtitle)
    } else {
      group_line_plot(table = table, groupby_var = groupby_var,
                      title = title, caption = caption,
                      yvar = yvar, xvar = xvar,
                      ytitle = ytitle, xtitle = xtitle,
                      num_groups = length(unique(table[[groupby_var]])))
    }
  } else {
    if (is.null(groupby_var) ||
        length(unique(table[[groupby_var]])) == 1) {
      single_col_plot(table = table, title = title, caption = caption,
                      yvar = yvar, xvar = xvar,
                      ytitle = ytitle, xtitle = xtitle)
    } else {
      group_col_plot(table = table, groupby_var = groupby_var,
                     title = title, caption = caption,
                     yvar = yvar, xvar = xvar,
                     ytitle = ytitle, xtitle = xtitle,
                     num_groups = length(unique(table[[groupby_var]])))
    }
  }
}
