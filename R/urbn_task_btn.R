#' Urban-themed bslib input_task_button.
#'
#' Used as the "UPDATE DATA" button in `data_ui()`. Shows `label_busy`
#' and disables itself while the pipeline is running.
#'
#' @param ns Module namespace function (from `shiny::NS`).
#' @param id Input id (will be namespaced).
#' @param label Idle button text.
#' @param label_busy In-flight button text.
urbn_task_button <- function(ns, id, label, label_busy) {
  bslib::input_task_button(
    id = ns(id),
    class = "btn-urban",
    label = label,
    label_busy = label_busy,
    type = "primary"
  )
}