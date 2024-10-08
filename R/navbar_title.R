navbar_title <- function(title, height){
  htmltools::div(
    class = "urbn-navbar-title",
    htmltools::tags$img(src = "ui-logo-rgb-white.svg", height = height),
    title
  ) 
}
  

