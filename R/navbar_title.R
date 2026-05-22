# Navbar branding: the Urban Institute logo plus "| National Center
# for Charitable Statistics" (or "| NCCS" on small screens, via the
# .lg-view / .sm-view CSS classes defined in www/sib_style.css).

#' Build the navbar title element (logo + branding).
#'
#' @param title Accepted for signature compatibility; the title text
#'   itself comes from CSS-visible spans inside the function.
#' @return A `htmltools::tagList`.
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
