urban_virtualselect <- function(ns, id, label, choices, ...){
  htmltools::div(
    class = "picker-urbn",
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