single_col_plot <- function(table, title, subtitle, yvar, xvar, xtitle, ytitle) {
  p <- ggplot(table, mapping = aes(x = "Total", y = !!sym(yvar))) +
    geom_col(fill = "#1696d2") +
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
    coord_flip() +
    plot_theme
  return(p)
}
