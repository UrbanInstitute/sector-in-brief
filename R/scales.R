# Shared y-axis scale applied to every plot. Locks the lower bound at
# 0 (the dashboard's metrics are all non-negative) with a 10% headroom
# at the top so labels don't crowd the chart edge, and formats tick
# labels with thousands separators.
plot_scales <- ggplot2::scale_y_continuous(
  limits = c(0, NA),
  expand = ggplot2::expansion(mult = 0.1),
  labels = scales::comma
)
