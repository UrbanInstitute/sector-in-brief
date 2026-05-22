# One of the urbn_* family of Urban-themed Shiny input wrappers
# (checkboxgroup, radiobuttons, slider, tree, task_button). All apply
# a `filter__text` wrapper div so the CSS in www/sib_style.css can
# style the input consistently across filter sections in the sidebar
# accordion.

#' Urban-themed checkboxGroupInput.
#'
#' @param ns Module namespace function (from `shiny::NS`).
#' @param id Input id (will be namespaced).
#' @param choices,selected Standard `checkboxGroupInput` args.
#' @param ... Forwarded to `shiny::checkboxGroupInput`.
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