plot_ui <- function(id, selected_geographies) {
  plotpanels <- plotpanel_mapper(plotpanel_args, id)
  bslib::navset_card_tab(
    title =   "",
    height = "100%",
    bslib::card_title("Visualize Your Results", class = "viz-header"),
    plotpanels[["Overall"]],
    plotpanels[["By Organization Type"]],
    plotpanels[["By Subsector"]],
    plotpanels[["By Geography"]],
    plotpanels[["By Asset Size"]]
  )
}