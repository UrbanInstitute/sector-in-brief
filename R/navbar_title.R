navbar_title <- function(title) {
  htmltools::tagList(
    htmltools::span(class = "lg-view", htmltools::div(
      class = "nav",
      htmltools::a(href = "https://www.urban.org/", htmltools::img(src = "ui-logo-rgb-white.svg", height = "60px")),
      htmltools::div(class = "pad", " | National Center for Charitable Statistics")
    )),
    htmltools::span(class = "sm-view", htmltools::div(
      class = "nav",
      htmltools::a(href = "https://www.urban.org/", htmltools::img(src = "ui-logo-rgb-white.svg", height = "60px")),
      htmltools::div(class = "pad", " | NCCS")
    ))
  )
}
