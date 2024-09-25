single_line_plot <- function(table,
                             title,
                             subtitle,
                             yvar,
                             xvar,
                             xtitle,
                             ytitle) {
  p <- ggplot(table, aes(x = !!sym(xvar), y = !!sym(yvar))) +
    geom_line(size = 1.5,
              linetype = 1,
              color = "#1696d2") +
    geom_point(
      size = 3,
      color = "#1696d2",
      fill = "white",
      shape = 21,
      stroke = 1.2
    ) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::comma()
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