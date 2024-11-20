navbar_title <- function(title) {
  tagList(span(
    class = "lg-view",
    h4(
      class = "h4-white",
      a(href = "https://www.urban.org/", img(src = "ui-logo-rgb-white.svg", height = "60px")),
      " | National Center for Charitable Statistics"
    )
  ), span(class = "sm-view", h4(
    class = "h4-white", a(href = "https://www.urban.org/", img(src = "ui-logo-rgb-white.svg", height = "60px")), " | NCCS"
  )))
}


