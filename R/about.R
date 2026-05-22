# The About tab. Static content built from R/text_about.R blocks:
# title, customization, data sources, variations, and FAQ accordions.
# Wrapped in a function (not a constant) because accordion content
# resolves at render time via urbn_accordion_panel().

#' Build the About-tab nav panel.
#'
#' @return A `bslib::nav_panel`.
aboutUI <- function() {
  about <- bslib::nav_panel(
    title = "About",
    about_title_box,
    htmltools::br(),
    customization,
    htmltools::br(),
    data_sources,
    htmltools::br(),
    variations,
    htmltools::br(),
    faq,
    htmltools::br()
  )
  return(about)
}
