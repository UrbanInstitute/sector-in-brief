# Action button styled with the Urban Institute "btn-urban" class
# (yellow background, black text — see www/sib_style.css). Used for
# the multi-step "NEXT" / "SUBMIT REQUEST" buttons in the Custom
# Panel Datasets download flow (R/data_download_dashboard.R). The
# panel-filter Reset button uses its own .btn-reset styling.

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