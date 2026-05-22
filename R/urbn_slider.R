#' Urban-themed year-range sliderInput.
#'
#' Fixed to a year-range double-slider; bounds passed in by
#' `data_ui()` from the manifest-derived per-panel year range.
#'
#' @param ns Module namespace function (from `shiny::NS`).
#' @param id Input id (will be namespaced).
#' @param start_year,end_year Slider min/max.
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