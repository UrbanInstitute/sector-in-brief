#' @title Wrapper function for Urban themed shinywidgets tree input 
#' @param ns The namespace of the shiny app
#' @param id The id of the tree
#' @param choice_df data.frame. The data frame containing the choices for the tree
#' @param selected character vector. The selected choices of the treeinput.
#' @return A html div tag containing an urban themed tree input
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

