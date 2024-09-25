group_col_plot <- function(table, grouping_var, title, subtitle, yvar, xvar, ytitle) {
  p <- ggplot(table, aes(
    x = !!sym(grouping_var),
    y = !!sym(yvar),
    fill = !!sym(grouping_var)
  )) +
    geom_col(width = 0.9) +
    scale_fill_manual(values = colorpalette) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::comma()
    ) +
    labs(
      subtitle = subtitle,
      x = grouping_var,
      title = title,
      y = ytitle
    ) +
    coord_flip() +
    plot_theme
  return(p)
}