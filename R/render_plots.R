render_plots <- function(plots){
  purrr::map(plots, .f = function(plot){ggiraph::renderGirafe({plot})})
}
