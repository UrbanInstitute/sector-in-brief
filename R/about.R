# UI for the about page
aboutUI <- function() {
  about <- bslib::nav_panel(
    title = "About",
    about_title_box,
    htmltools::br(),
    customization,
    htmltools::br(),
    accordion_data_source,
    htmltools::br(),
    variations,
    htmltools::br(),
    faq,
    htmltools::br()
  )
  return(about)
}
