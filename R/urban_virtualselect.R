# Urban-themed wrapper around shinyWidgets::virtualSelectInput. Used
# by the Custom Panel Datasets download page for multi-select inputs
# where the plain selectize gets sluggish with thousands of options
# (county/CBSA pickers there have no maxItems cap).

#' Build an Urban-themed virtual-select multi-input.
#'
#' @param ns Module namespace function from `shiny::NS`.
#' @param id Input id (will be namespaced).
#' @param label Visible label above the input.
#' @param choices Vector or list of choices.
#' @param ... Additional args forwarded to
#'   `shinyWidgets::virtualSelectInput`.
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