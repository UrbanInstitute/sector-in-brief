# Pick the right ggiraph builder for one table based on its shape:
#
#   ≤3 unique years + no group    → multi_year_col_plot (vertical bars
#                                    by year — including the 1-year
#                                    case, which renders as a single
#                                    bar so it's visually consistent
#                                    with the 2-3-year case)
#   ≤3 unique years + group       → multi_year_col_plot (year-dodged
#                                    clustered bars) for ≥2 years,
#                                    group_col_plot (horizontal bars)
#                                    for the 1-year case where
#                                    horizontal layout reads better
#                                    with many groups (e.g. 12
#                                    subsectors)
#   ≥4 unique years + no group    → single_line_plot
#   ≥4 unique years + group       → group_line_plot
#
# The ≤3-year branch uses bars because line charts with so few
# points read as discrete values rather than trends — bars give a
# cleaner year-over-year comparison.
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
    # 1 unique year. Overall (no group) routes through the same
    # multi_year_col_plot path as 2-3 years so the visual is just
    # "1 bar" rather than the legacy lollipop. Grouped uses
    # horizontal bars where the group labels read better on the
    # y axis than dodged at a single x position.
    if (is.null(groupby_var) ||
        length(unique(table[[groupby_var]])) == 1) {
      multi_year_col_plot(table = table, groupby_var = NULL,
                          title = title, caption = caption,
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
