# Shared ggplot2 theme applied to every plot in the dashboard. Defines
# Urban Institute font (Lato) and typography hierarchy, horizontal grid
# lines, and consistent margins. Used additively (`+ plot_theme`) by
# every *_plot.R builder.

plot_theme <- ggplot2::theme_classic() +
  ggplot2::theme(
    text = ggplot2::element_text(family = "Lato"),
    plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0),
    plot.subtitle = ggplot2::element_text(
      size = 16,
      hjust = 0,
      margin = ggplot2::margin(b = 20)
    ),
    axis.text = ggplot2::element_text(size = 12, color = "#000000"),
    axis.title.y = ggplot2::element_text(
      size = 12,
      angle = 90,
      vjust = 0.5,
      hjust = 0.5,
      margin = ggplot2::margin(r = 10)
    ),
    axis.line.y = ggplot2::element_blank(),
    axis.title.x = ggplot2::element_text(
      size = 12,
      margin = ggplot2::margin(t = 10),
      color = "#000000"
    ),
    panel.grid.major.y = ggplot2::element_line(color = "#dcdcdc"),
    panel.grid.minor.y = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor.x = ggplot2::element_blank(),
    plot.caption = ggplot2::element_text(
      hjust = 0,
      size = 10,
      color = "grey50",
      margin = ggplot2::margin(t = 20)
    ),
    plot.margin = ggplot2::margin(
      t = 20,
      r = 20,
      b = 20,
      l = 20
    )
  )
