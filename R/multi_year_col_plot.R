# Vertical bar chart for panels with 2-3 unique years (currently the
# DAF panels at default settings). Lines aren't a great fit at this
# point cardinality — 3 dots connected by a line conveys discrete
# values, not a trend — so we render bars instead.
#
# Handles both the "Overall" (no group) and breakdown (group) cases:
# overall is a single bar per year; breakdowns are clustered bars
# (year on x, dodged by group). >3 years route through the
# single_line_plot / group_line_plot path instead.

#' Build a multi-year bar chart (2-3 unique years).
#'
#' @param table Long-format tibble: one row per (year, group) or
#'   per year for the overall case.
#' @param groupby_var Second-group column name, or NULL for overall.
#' @param title,caption Pre-computed strings from `plot_title()` /
#'   `plot_caption()`.
#' @param yvar,xvar Column names for the y aesthetic and the year
#'   axis. xvar is treated as a discrete factor so each year gets
#'   its own bar slot rather than continuous-x positioning.
#' @param ytitle,xtitle Axis label strings.
#' @param num_groups Group count — drives the colourpalette length
#'   for the dodged-bar case. Ignored when groupby_var is NULL.
#' @return A girafe interactive plot.
multi_year_col_plot <- function(table,
                                groupby_var = NULL,
                                title,
                                caption,
                                yvar,
                                xvar,
                                ytitle,
                                xtitle,
                                num_groups = 1) {
  selected_groups <- if (!is.null(groupby_var)) unique(table[[groupby_var]]) else ""
  subtitle <- plot_subtitle(groupby_var, selected_groups)

  if (is.null(groupby_var)) {
    p <- ggplot(table,
                aes(x = factor(!!sym(xvar)), y = !!sym(yvar))) +
      ggiraph::geom_col_interactive(
        aes(tooltip = tooltip_text(table, yvar, xvar)),
        fill = "#1696d2",
        width = 0.7,
        hover_nearest = TRUE
      )
  } else {
    p <- ggplot(table,
                aes(
                  x    = factor(!!sym(xvar)),
                  y    = !!sym(yvar),
                  fill = !!sym(groupby_var)
                )) +
      ggiraph::geom_col_interactive(
        aes(tooltip = tooltip_text(table, yvar, xvar, groupby_var)),
        position = ggplot2::position_dodge2(preserve = "single"),
        width = 0.8,
        hover_nearest = TRUE
      ) +
      scale_fill_manual(values = colorpalette(num_colors = num_groups))
  }

  p <- p +
    plot_scales +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = xtitle,
      y = ytitle,
      fill = if (!is.null(groupby_var) && groupby_var == "Metro/Micro Area") {
        "Metro Area"
      } else {
        groupby_var
      }
    ) +
    plot_theme
  girafe_wrapper(p)
}
