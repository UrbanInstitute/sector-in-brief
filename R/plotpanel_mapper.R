plotpanel_mapper <- function(plotpanel_args, id){
  plotpanels <- purrr::pmapper(plotpanel_args, plotpanel_builder, id = id)
  names(plotpanels) <- plotpanel_args[["title"]]
  return(plotpanels)
}