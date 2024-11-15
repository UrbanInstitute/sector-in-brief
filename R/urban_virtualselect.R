urban_virtualselect <- function(ns, id, label, choices, ...){
  htmltools::div(
    class = "form-choice-header",
    shinyWidgets::virtualSelectInput(
      inputId = ns(id),
      label = label,
      choices = choices,
      showValueAsTags = TRUE,
      search = TRUE,
      multiple = TRUE,
      ...
    )
  )
}