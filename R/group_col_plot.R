group_col_plot <- function(table,
                           groupby_var,
                           title,
                           caption,
                           yvar,
                           xvar,
                           ytitle,
                           xtitle,
                           num_groups) {
  subtitle <- plot_subtitle(groupby_var)
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
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = groupby_var,
      y = ytitle
    ) +
    coord_flip() +
    plot_theme
  p <- ggiraph::girafe(ggobj = p,
                       width_svg = 20,
                       options = ggiraph_options)
  return(p)
}