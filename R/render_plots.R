# Wrap each built girafe plot in renderGirafe so Shiny can serve it to
# the panel's plot_* output slot. Run inside render_outputs().

#' Convert a list of girafe plots into renderGirafe outputs.
#'
#' @param plots Named list of girafe plot objects.
#' @return Named list of `ggiraph::renderGirafe` outputs.
render_plots <- function(plots) {
  purrr::map(plots, .f = function(plot) ggiraph::renderGirafe({ plot }))
}
