plot_scales <- ggplot2::scale_y_continuous(
  limits = c(0, NA),
  expand = expansion(mult = 0.1),
  labels = scales::comma
)
