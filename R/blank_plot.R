# Plot to return in case of error
blank_plot <- function() {
  p <- ggplot() +
    labs(
      subtitle = "",
      x = "",
      title = "No Data Available, Select Other Filters and Try Again",
      y = ""
    ) +
    plot_theme
  p <- ggiraph::girafe(ggobj = p,
                       width_svg = 20,
                       options = ggiraph_options)
  return(p)
}