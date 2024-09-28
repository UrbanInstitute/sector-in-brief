plot_theme <- ggplot2::theme_classic() +
  ggplot2::theme(
    text = element_text(family = "Lato"),
    plot.title = element_text(size = 20, face = "bold", hjust = 0),
    plot.subtitle = element_text(
      size = 16,
      hjust = 0,
      margin = margin(b = 20)
    ),
    axis.text = element_text(size = 12, color = "#000000"),
    axis.title.y = element_text(
      size = 12,
      angle = 90,
      vjust = 0.5,
      hjust = 0.5,
      margin = margin(r = 10)
    ),
    axis.line.y = element_blank(),
    axis.title.x = element_text(
      size = 12,
      margin = margin(t = 10),
      color = "#000000"
    ),
    panel.grid.major.y = element_line(color = "#dcdcdc"),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 10,
      color = "grey50",
      margin = margin(t = 20)
    ),
    plot.margin = margin(
      t = 20,
      r = 20,
      b = 20,
      l = 20
    )
  )
