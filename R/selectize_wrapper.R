#' @title Wrapper for selectizeInput
#' @param ns The namespace of the shiny app
#' @param id The id of the selectizeInput
#' @param label The label of the selectizeInput
#' @param choices The choices of the selectizeInput
#' @param width The width of the selectizeInput
#' @return A selectizeInput
selectize_wrapper <- function(ns, id, label, choices, width){
  shiny::selectizeInput(
    inputId = ns(id),
    label = label,
    choices = choices,
    width = width
  )
}