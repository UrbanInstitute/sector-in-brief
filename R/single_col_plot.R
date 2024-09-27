single_col_plot <- function(table,
                            title,
                            subtitle,
                            yvar,
                            xvar,
                            xtitle,
                            ytitle) {
  p <- ggplot(table, mapping = aes(x = "Total", y = !!sym(yvar))) +
    ggiraph::geom_col_interactive(
      aes(tooltip = tooltip_text(table, yvar, xvar)),
      width = 0.9,
      fill = "#1696d2",
      hover_nearest = TRUE,
    ) +
    plot_scales +
    labs(
      subtitle = subtitle,
      x = xtitle,
      title = title,
      y = ytitle
    ) +
    coord_flip() +
    plot_theme
  p <- ggiraph::girafe(ggobj = p,
                       width_svg = 20,
                       options = ggiraph_options)
  return(p)
}
