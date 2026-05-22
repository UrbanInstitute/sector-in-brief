# Single-series interactive line chart (time series, no breakdown).
# The "overall" view on Numbers / Finances / PF Grants panels. Like
# group_line_plot, uses solid + dashed-on-NA layers to keep a
# continuous trace across NA years.

#' Build a single-series interactive line chart.
#'
#' @param table Long-format tibble with one row per year.
#' @param title,caption Pre-computed strings.
#' @param yvar,xvar,xtitle,ytitle Standard ggplot aesthetics / labels.
#' @return A girafe interactive plot.
single_line_plot <- function(table,
                             title,
                             caption,
                             yvar,
                             xvar,
                             xtitle,
                             ytitle) {
  subtitle <- plot_subtitle(groupby_var=NULL, selected_groups="")
  p <- ggplot(table, aes(x = !!sym(xvar), y = !!sym(yvar))) +
    ggiraph::geom_line_interactive(size = 1.5,
                                   hover_nearest = FALSE,
                                   color = "#1696d2")
  p <- p +
    ggiraph::geom_line_interactive(
      data = dplyr::filter(table, is.na(!!sym(yvar)) == FALSE),
      size = 1.5,
      hover_nearest = FALSE,
      linetype = "dashed",
      color = "#1696d2"
    )
  p <- p +
    ggiraph::geom_point_interactive(
      aes(tooltip = tooltip_text(table, yvar, xvar)),
      size = 3,
      fill = "white",
      shape = 21,
      stroke = 1.2,
      color = "#1696d2",
      hover_nearest = TRUE
    ) +
    y_scale_for(yvar) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = xtitle,
      y = ytitle
    ) +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    plot_theme
  p <- girafe_wrapper(p)
  return(p)
}