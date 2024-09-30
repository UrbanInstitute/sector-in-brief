single_line_plot <- function(table,
                             title,
                             subtitle,
                             yvar,
                             xvar,
                             xtitle,
                             ytitle) {
  p <- ggplot(table, aes(x = !!sym(xvar), y = !!sym(yvar))) +
    ggiraph::geom_line_interactive(size = 1.5,
                                   hover_nearest = FALSE,
                                   color = "#1696d2")
  if (yvar == "Total Contributions") {
    p <- p +
      ggiraph::geom_line_interactive(
        data = dplyr::filter(table, is.na(!!sym(yvar)) == FALSE),
        size = 1.5,
        hover_nearest = FALSE,
        linetype = "dashed",
        color = "#1696d2"
      )
  }
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
    plot_scales +
    labs(
      subtitle = subtitle,
      x = xtitle,
      title = title,
      y = ytitle
    ) +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    plot_theme
  p <- ggiraph::girafe(ggobj = p,
                       width_svg = 20,
                       options = ggiraph_options)
  return(p)
}