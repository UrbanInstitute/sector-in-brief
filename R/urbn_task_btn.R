#' @title Wrapper function for Urban themed bslib input task button
#' @param ns The namespace of the shiny app
#' @param id The id of the button
#' @param label The label of the button
#' @param label_busy The label of the button when busy
#' @return A bslib input task button
urbn_task_button <- function(ns, id, label, label_busy) {
  bslib::input_task_button(
    id = ns(id),
    class = "btn-urban",
    label = label,
    label_busy = label_busy,
    type = "primary"
  )
}