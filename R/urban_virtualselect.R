urban_virtualselect <- function(ns, id, label, choices){
  htmltools::div(
    class = "form-choice-header",
    shinyWidgets::virtualSelectInput(
      inputId = ns(id),
      label = "Select State(s)",
      choices = choices,
      showValueAsTags = TRUE,
      search = TRUE,
      multiple = TRUE
    )
  )
}