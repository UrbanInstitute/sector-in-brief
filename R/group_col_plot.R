# Horizontal grouped bar chart (single year, multiple groups).
# Used by plots_build_single for the by_ctype / by_geo / by_subsector /
# by_size views on DAF panels (where time_series = FALSE).

#' Build a horizontal grouped bar plot (single year, ≥2 groups).
#'
#' @param table Tibble with one row per group.
#' @param groupby_var Column that supplies bar identity + fill colour.
#' @param title,caption Pre-computed strings.
#' @param yvar,xvar,ytitle,xtitle Standard ggplot aesthetics / labels.
#' @param num_groups Group count — drives the colourpalette length.
#' @return A girafe interactive plot.
group_col_plot <- function(table,
                           groupby_var,
                           title,
                           caption,
                           yvar,
                           xvar,
                           ytitle,
                           xtitle,
                           num_groups) {
  selected_groups <- unique(table[[groupby_var]])
  subtitle <- plot_subtitle(groupby_var, selected_groups)
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
    y_scale_for(yvar) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = groupby_var,
      y = ytitle
    ) +
    coord_flip() +
    plot_theme
  p <- girafe_wrapper(p)
  return(p)
}