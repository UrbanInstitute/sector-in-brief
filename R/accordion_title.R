#' @title Function to style the title of accordion panels1
#' @param title A character string to be displayed as the title of the accordion panel
#' @param size A character string to specify the size of the title. Default is "md"
#' @return A styled title for the accordion panel
accordion_title <- function(title){
  title <- htmltools::h5(
    title
  )
  return(title)
}