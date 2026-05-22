# Build the 5 plot/table sub-tabs for one visualization panel, all
# namespaced under the panel's module id.

#' Build all 5 plot/table sub-tabs for one panel.
#'
#' @param plotpanel_args The driver tibble (typically the top-level
#'   constant).
#' @param id The parent panel's module id.
#' @return Named list keyed by sub-tab title; each entry is a
#'   `bslib::nav_panel`.
plotpanel_mapper <- function(plotpanel_args, id) {
  plotpanels <- purrr::pmap(plotpanel_args, plotpanel_builder, id = id)
  names(plotpanels) <- plotpanel_args[["title"]]
  return(plotpanels)
}
