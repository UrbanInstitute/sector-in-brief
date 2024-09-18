create_blank_plot <- function(title) {
  p <- ggplot() +
    labs(title = title) +
    theme_classic() +
    theme(
      text = element_text(family = "Lato"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
    )
  return(p)
}