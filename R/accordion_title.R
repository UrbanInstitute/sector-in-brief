#' Wrap an accordion title in an `<h5>` so the typography matches the
#' rest of the dashboard's accordion panels.
#'
#' @param title Title text.
#' @return A `<h5>` tag.
accordion_title <- function(title){
  title <- htmltools::h5(
    title
  )
  return(title)
}