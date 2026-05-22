# Single-data-point lollipop chart (single year, no breakdown, or a
# breakdown that collapsed to one group). Used for the "Total" view on
# DAF panels where time_series = FALSE and the user hasn't picked a
# breakdown.

#' Build a single-point lollipop chart.
#'
#' @param table Single-row tibble.
#' @param title,caption Pre-computed strings.
#' @param yvar,xvar,xtitle,ytitle Standard ggplot aesthetics / labels.
#' @return A girafe interactive plot.
single_col_plot <- function(table,
                            title,
                            caption,
                            yvar,
                            xvar,
                            xtitle,
                            ytitle) {
  subtitle <- plot_subtitle(groupby_var=NULL, selected_groups="")
  p <- ggplot(table, mapping = aes(x = "Total", y = !!sym(yvar))) +
    ggiraph::geom_segment_interactive(
      aes(x = "Total", 
          xend = "Total",
          y = 0,
          yend = !!sym(yvar)),
      color = "lightgrey",
      lwd = 5
    ) +
    ggiraph::geom_point_interactive(
      aes(tooltip = tooltip_text(table, 
                                 yvar, 
                                 xvar)),
      size = 10,
      fill = "#1696d2",
      shape = 21,
      stroke = 1.2,
      color = "#1696d2",
      hover_nearest = TRUE
    ) +
    plot_scales +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = NULL,
      y = ytitle
    ) +
    plot_theme
  p <- girafe_wrapper(p)
  return(p)
}
