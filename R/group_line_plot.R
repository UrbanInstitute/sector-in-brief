group_line_plot <- function(table,
                            groupby_var,
                            title,
                            subtitle,
                            yvar,
                            xvar,
                            ytitle,
                            xtitle,
                            num_groups) {
  p <- ggplot(table,
              aes(
                x = !!sym(xvar),
                y = !!sym(yvar),
                colour = !!sym(groupby_var),
                data_id = !!sym(groupby_var)
              )) +
    ggiraph::geom_line_interactive(size = 1.5, hover_nearest = FALSE)
  if (yvar == "Total Contributions") {
    p <- p +
      ggiraph::geom_line_interactive(
        data = dplyr::filter(table, is.na(!!sym(yvar)) == FALSE),
        size = 1.5,
        hover_nearest = FALSE,
        linetype = "dashed"
      )
  }
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
      subtitle = subtitle,
      x = xtitle,
      title = title,
      y = ytitle
    ) +
    plot_theme
  p <- ggiraph::girafe(ggobj = p,
                       width_svg = 20,
                       options = ggiraph_options)
  return(p)
}