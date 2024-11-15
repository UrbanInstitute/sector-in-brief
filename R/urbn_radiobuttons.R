#' @title Urban theming for shiny radiobuttons
#' @param ns The namespace of the shiny app
#' @param id The id of the radiobuttons
#' @param label The label of the radiobuttons
#' @param choices The choices of the radiobuttons
#' @param selected The selected choice of the radiobuttons
#' @param class The div class of the radiobutton
#' @return A shiny radiobuttons
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