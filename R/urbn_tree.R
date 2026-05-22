#' Urban-themed shinyWidgets treeInput (hierarchical checkbox).
#'
#' Used for the Organization Type filter so a user can pick a parent
#' node (e.g. "501(c)(3) Organizations") and cascade-select its
#' children. Choices come from `choice_builder()`'s `ctype_tree_df`.
#'
#' @param ns Module namespace function (from `shiny::NS`).
#' @param id Input id (will be namespaced).
#' @param choice_df Two-level tibble (level1, level2) for `create_tree`.
#' @param selected Initial selection vector.
#' @param ... Forwarded to `shinyWidgets::treeInput`.
urbn_tree <- function(ns, id, choice_df, selected, ...){
  htmltools::div(
    class = "filter__text",
    shinyWidgets::treeInput(
      inputId = ns(id),
      label = NULL,
      choices = shinyWidgets::create_tree(choice_df),
      selected = selected,
      returnValue = "text",
      closeDepth = 0,
      ...
    )
  )
}

