plot_scales <- ggplot2::scale_y_continuous(
  limits = c(0, NA),
  expand = ggplot2::expansion(mult = 0.1),
  labels = scales::comma
)
