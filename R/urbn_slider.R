#' @title Wrapper function for Urban Themed R Shiny slider object
#' @param ns The namespace of the shiny app
#' @param id The id of the slider
#' @param start_year The start year of the slider
#' @param end_year The end year of the slider
urbn_slider <- function(ns, id, start_year, end_year) {
  htmltools::div(
    class = "filter__text",
    shiny::sliderInput(
      inputId = ns(id),
      label = NULL,
      min = start_year,
      max = end_year,
      value = c(start_year, end_year),
      step = NULL,
      ticks = FALSE,
      sep = "",
      dragRange = TRUE,
      width = "100%"
    )
  )
}