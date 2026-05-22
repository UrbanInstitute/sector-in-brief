# Empty-state placeholder returned when a panel has no rows after
# filtering, or when an individual plot builder errors out (wrapped in
# purrr::possibly). Same theme as real plots so the canvas size stays
# consistent in the navset_card_pill grid.
#
# The message guides users toward the filters most likely responsible
# for an empty result (date range tends to be the narrowest, geography
# the next most common cause).

#' Build a "No Data Available" placeholder plot.
#'
#' @return A girafe interactive plot with no geoms and a prompt to
#'   adjust filters.
blank_plot <- function() {
  p <- ggplot() +
    labs(
      title = "No data for this combination of filters.",
      subtitle = "Try widening the date range, choosing a broader geography, or selecting more subsectors.",
      x = "",
      y = ""
    ) +
    plot_theme +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(size = 18, color = "#5c5859"),
      plot.subtitle = ggplot2::element_text(size = 13, color = "#5c5859")
    )
  p <- girafe_wrapper(p)
  return(p)
}
