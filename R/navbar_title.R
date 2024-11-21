navbar_title <- function(title) {
  tagList(span(class = "lg-view", div(
    class = "nav",
    a(href = "https://www.urban.org/", img(src = "ui-logo-rgb-white.svg", height = "60px")),
    htmltools::div(class = "pad", " | National Center for Charitable Statistics")
  )), span(class = "sm-view", div(
    class = "nav",
    a(href = "https://www.urban.org/", img(src = "ui-logo-rgb-white.svg", height = "60px")),
    htmltools::div(class = "pad", " | NCCS")
  )))
}


