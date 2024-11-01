#' @title Wrapper function for Urban themed shiny checkboxgroup 
#' @param ns The namespace of the shiny app
#' @param id The id of the checkboxgroup
#' @param choices The choices of the checkboxgroup
#' @param selected The selected choices of the checkboxgroup
#' @return A html div tag containing a shiny checkboxgroup
urbn_checkboxgroup <- function(ns, id, choices, selected, ...){
  htmltools::div(
    class = "filter__text",
    shiny::checkboxGroupInput(
      inputId = ns(id),
      label = NULL,
      choices = choices,
      selected = selected,
      inline = FALSE,
      ...
    )
  )
}