# The plot/table area of one visualization panel: a navset_card with
# the 5 breakdown sub-tabs. Bound to the parent panel's module
# namespace via `id`. Mounted lazily by visualpanel_content().

#' Build the plot/table area UI for one panel.
#'
#' @param id Parent panel's module id.
#' @param selected_geographies Accepted for backwards compatibility
#'   with an older signature; not currently consumed.
#' @return A `bslib::navset_card_underline`.
plot_ui <- function(id, selected_geographies) {
  plotpanels <- plotpanel_mapper(plotpanel_args, id)
  bslib::navset_card_underline(
    title  = "Visualize Your Results",
    height = "100%",
    plotpanels[["Overall"]],
    plotpanels[["By Organization Type"]],
    plotpanels[["By Subsector"]],
    plotpanels[["By Geography"]],
    plotpanels[["By Size"]]
  )
}
