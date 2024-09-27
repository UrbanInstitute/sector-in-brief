group_line_plot <- function(table,
                            groupby_var,
                            title,
                            subtitle,
                            yvar,
                            xvar,
                            ytitle,
                            xtitle,
                            num_groups) {
  p <- ggplot(table, aes(
    x = !!sym(xvar),
    y = !!sym(yvar),
    colour = !!sym(groupby_var),
    data_id = !!sym(groupby_var)
  )) +
    ggiraph::geom_line_interactive(size = 1.5, hover_nearest = FALSE) +
    ggiraph::geom_point_interactive(
      aes(tooltip = paste(
        "<b>",
        groupby_var,
        "</b>: ",
        !!sym(groupby_var),
        "<br><b>",
        yvar,
        "</b>: ",
        !!sym(yvar)
      )),
      size = 3,
      fill = "white",
      shape = 21,
      stroke = 1.2,
      hover_nearest = TRUE
    ) +
    scale_color_manual(values = colorpalette(num_colors=num_groups)) +
    plot_scales +
    labs(
      subtitle = subtitle,
      x = xtitle,
      title = title,
      y = ytitle
    ) +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    plot_theme
  p <- ggiraph::girafe(
    ggobj = p,
    width_svg = 15,
    options = list(opts_sizing(rescale = TRUE), width = 1)
  )
  return(p)
}