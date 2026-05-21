plot_ui <- function(id, selected_geographies) {
  plotpanels <- plotpanel_mapper(plotpanel_args, id)
  bslib::navset_card_underline(
    title =   "Visualize Your Results",
    height = "100%",
    plotpanels[["Overall"]],
    plotpanels[["By Organization Type"]],
    plotpanels[["By Subsector"]],
    plotpanels[["By Geography"]],
    plotpanels[["By Size"]]
  )
}