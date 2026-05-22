#' Urban-themed radioButtons.
#'
#' @param ns Module namespace function (from `shiny::NS`).
#' @param id Input id (will be namespaced).
#' @param label,choices,selected Standard `radioButtons` args.
#' @param class CSS class applied to the wrapping div.
urbn_radiobuttons <- function(ns, id, label, choices, selected, class){
  htmltools::div(
    class = class,
    shiny::radioButtons(
      inputId = ns(id),
      label = label,
      choices = choices,
      selected = selected,
      inline = FALSE
    )
  )
}