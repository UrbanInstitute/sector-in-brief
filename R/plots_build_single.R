# Pick the right ggiraph builder for one table based on its shape:
#
#   1 unique year                       → single_col_plot (lollipop)
#                                          OR group_col_plot (horiz bars)
#   2-3 unique years                    → multi_year_col_plot (vertical
#                                          bars by year, optionally
#                                          dodged by group)
#   ≥4 unique years + no group          → single_line_plot
#   ≥4 unique years + group             → group_line_plot
#
# The 2-3-year branch exists because line charts with so few points
# read as discrete values rather than trends. Bars at low temporal
# cardinality (currently DAF panels at 2021-2023) give a cleaner
# year-over-year comparison.
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
#'   multi-year vs many-year cardinality.
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
  n_years <- length(unique(table[[year_var]]))

  if (n_years >= 4) {
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
  } else if (n_years > 1) {
    multi_year_col_plot(
      table = table, groupby_var = groupby_var,
      title = title, caption = caption,
      yvar = yvar, xvar = xvar,
      ytitle = ytitle, xtitle = xtitle,
      num_groups = if (!is.null(groupby_var)) length(unique(table[[groupby_var]])) else 1
    )
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
