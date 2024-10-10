urban_button <- function(ns, id, label) {
  shiny::actionButton(inputId = ns(id),
                      class = "btn-urban",
                      label = label,)
}