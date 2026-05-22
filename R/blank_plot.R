# Empty-state placeholder returned when a panel has no rows after
# filtering, or when an individual plot builder errors out (wrapped in
# purrr::possibly). Same theme as real plots so the canvas size stays
# consistent in the navset_card_pill grid.

#' Build a "No Data Available" placeholder plot.
#'
#' @return A girafe interactive plot with no geoms and a prompt to
#'   adjust filters.
blank_plot <- function() {
  p <- ggplot() +
    labs(
      subtitle = "",
      x = "",
      title = "No Data Available, Select Other Filters and Try Again",
      y = ""
    ) +
    plot_theme
  p <- girafe_wrapper(p)
  return(p)
}
