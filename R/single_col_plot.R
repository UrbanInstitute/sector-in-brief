single_col_plot <- function(table,
                            title,
                            caption,
                            yvar,
                            xvar,
                            xtitle,
                            ytitle) {
  subtitle <- plot_subtitle(groupby_var=NULL)
  p <- ggplot(table, mapping = aes(x = "Total", y = !!sym(yvar))) +
    ggiraph::geom_col_interactive(
      aes(tooltip = tooltip_text(table, yvar, xvar)),
      width = 0.9,
      fill = "#1696d2",
      hover_nearest = TRUE,
    ) +
    plot_scales +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = xtitle,
      y = ytitle
    ) +
    coord_flip() +
    plot_theme
  p <- girafe_wrapper(p)
  return(p)
}
