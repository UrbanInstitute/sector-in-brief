# Multi-series interactive line chart (time series, multiple groups).
# Default for the by_ctype / by_geo / by_subsector / by_size views on
# Numbers, Finances, and PF Grants panels. The double-line trick
# (solid + dashed-on-NA) keeps a continuous trace through years where
# the metric is NA (e.g. 2016-2018 for private foundations).

#' Build a multi-series interactive line chart.
#'
#' @param table Long-format tibble: one row per (year, group).
#' @param groupby_var Column that supplies series identity + colour.
#' @param title,caption Pre-computed strings.
#' @param yvar,xvar,ytitle,xtitle Standard ggplot aesthetics / labels.
#' @param num_groups Series count — drives the colourpalette length.
#' @return A girafe interactive plot.
group_line_plot <- function(table,
                            groupby_var,
                            title,
                            caption,
                            yvar,
                            xvar,
                            ytitle,
                            xtitle,
                            num_groups) {
  selected_groups <- unique(table[[groupby_var]])
  subtitle <- plot_subtitle(groupby_var, selected_groups)
  p <- ggplot(table,
              aes(
                x = !!sym(xvar),
                y = !!sym(yvar),
                colour = !!sym(groupby_var),
                data_id = !!sym(groupby_var)
              )) +
    ggiraph::geom_line_interactive(size = 1.5, hover_nearest = FALSE)
  p <- p +
    ggiraph::geom_line_interactive(
      data = dplyr::filter(table, is.na(!!sym(yvar)) == FALSE),
      size = 1.5,
      hover_nearest = FALSE,
      linetype = "dashed"
    )
  p <- p +
    ggiraph::geom_point_interactive(
      aes(tooltip = tooltip_text(table, yvar, xvar, groupby_var)),
      size = 3,
      fill = "white",
      shape = 21,
      stroke = 1.2,
      hover_nearest = FALSE
    ) +
    scale_color_manual(
      values = colorpalette(num_colors = num_groups)
    ) +
    plot_scales +
    ggplot2::scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = xtitle,
      y = ytitle,
      color = ifelse(groupby_var == "Metro/Micro Area", "Metro Area", groupby_var)
    ) +
    plot_theme
  p <- girafe_wrapper(p)
  return(p)
}