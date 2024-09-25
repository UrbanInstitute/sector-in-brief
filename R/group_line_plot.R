group_line_plot <- function(table,
                                   grouping_var,
                                   title,
                                   subtitle,
                                   yvar,
                                   xvar,
                                   xtitle,
                                   ytitle) {
  p <- ggplot(table, aes(x = !!sym(xvar), y = !!sym(yvar))) +
    geom_line(aes(colour = !!sym(grouping_var)), size = 1.5, linetype = 1) +
    geom_point(
      aes(colour = !!sym(grouping_var)),
      size = 3,
      fill = "white",
      shape = 21,
      stroke = 1.2
    ) +
    scale_color_manual(values = colorpalette) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::unit_format(unit = "m", scale = 1e-6)
    ) +
    labs(
      subtitle = subtitle,
      x = xtitle,
      title = title,
      y = ytitle
    ) +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    plot_theme
  return(p)
}