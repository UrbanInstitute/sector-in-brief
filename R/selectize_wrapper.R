#' Thin selectizeInput wrapper that auto-namespaces the id.
#'
#' Used by `geo_filter_module.R` for all the geo selectizes (region,
#' state_mult, state_single, county, cbsa). `maxItems = 5` is
#' enforced at the call sites, not here.
#'
#' @param ns Module namespace function (from `shiny::NS`).
#' @param id Input id (will be namespaced).
#' @param label Visible label above the input.
#' @param choices Vector or list of choices.
#' @param ... Forwarded to `shiny::selectizeInput`.
selectize_wrapper <- function(ns, id, label, choices, ...){
  shiny::selectizeInput(
    inputId = ns(id),
    label = label,
    choices = choices,
    ...
  )
}