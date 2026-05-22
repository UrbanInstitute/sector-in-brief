# Action button styled with the Urban Institute "btn-urban" class
# (yellow background, black text — see www/sib_style.css). Used for
# filter-reset buttons inside the filter cards.

#' Build an Urban-themed action button.
#'
#' @param ns Module namespace function from `shiny::NS`.
#' @param id Input id (will be namespaced).
#' @param label Visible button text.
urban_button <- function(ns, id, label) {
  shiny::actionButton(inputId = ns(id),
                      class = "btn-urban",
                      label = label,)
}