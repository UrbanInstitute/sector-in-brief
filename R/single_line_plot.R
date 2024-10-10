single_line_plot <- function(table,
                             title,
                             caption,
                             yvar,
                             xvar,
                             xtitle,
                             ytitle) {
  subtitle <- plot_subtitle(groupby_var=NULL)
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
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = xtitle,
      y = ytitle
    ) +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    plot_theme
  p <- ggiraph::girafe(ggobj = p,
                       width_svg = 16,
                       height_svg = 9,
                       options = ggiraph_options)
  return(p)
}