group_col_plot <- function(table, groupby_var, title, subtitle, yvar, xvar, ytitle, xtitle) {
  p <- ggplot(table, aes(
    x = !!sym(groupby_var),
    y = !!sym(yvar),
    fill = !!sym(groupby_var)
  )) +
    geom_col(width = 0.9) +
    scale_fill_manual(values = colorpalette) +
    plot_scales +
    labs(
      subtitle = subtitle,
      x = groupby_var,
      title = title,
      y = ytitle
    ) +
    coord_flip() +
    plot_theme
  return(p)
}