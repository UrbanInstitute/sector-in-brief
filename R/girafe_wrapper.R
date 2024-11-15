#' @title wrapper function for girafe
#' @param ggobj ggplot object
#' @param options list of options for girafe
#' @return girafe plot object
girafe_wrapper <- function(ggobj) {
  girafe_plot <- ggiraph::girafe(
    ggobj = ggobj,
    width_svg = 16,
    height_svg = 9,
    options = list(
      ggiraph::opts_hover(css = "stroke-width: 3px; transition: all 0.3s ease; r: 6; fill-opacity: 1"),
      ggiraph::opts_hover_inv(css = "opacity: 0.1;"),
      ggiraph::opts_selection(css = "r: 6; stroke-width: 3px;"),
      ggiraph::opts_sizing(rescale = TRUE),
      width = 1
    )
  )
  return(girafe_plot)
}