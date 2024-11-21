# UI for the about page
aboutUI <- function() {
  about <- bslib::nav_panel(
    title = "About",
    about_title,
    htmltools::br(),
    customization,
    htmltools::div(
      class = "bg-box__white",
      htmltools::div(
        class = "flex-box__column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = accordion_title("Data Sources"),
            value = "Data Sources",
            data_sources
          )
        )
      )
    ),
    variations,
    htmltools::br(),
    faq
  )
  return(about)
}
