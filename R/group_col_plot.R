group_col_plot <- function(table,
                           groupby_var,
                           title,
                           subtitle,
                           yvar,
                           xvar,
                           ytitle,
                           xtitle,
                           num_groups) {
  p <- ggplot(table, aes(
    x = !!sym(groupby_var),
    y = !!sym(yvar),
    fill = !!sym(groupby_var)
  )) +
    ggiraph::geom_col_interactive(aes(tooltip = tooltip_text(table, 
                                                             yvar, 
                                                             xvar,
                                                             groupby_var)),
                                  width = 0.9,
                                  hover_nearest = TRUE,
    ) +
    scale_fill_manual(values = colorpalette(num_colors = num_groups)) +
    plot_scales +
    labs(
      subtitle = subtitle,
      x = groupby_var,
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