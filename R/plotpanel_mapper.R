plotpanel_mapper <- function(plotpanel_args, id){
  plotpanels <- purrr::pmap(plotpanel_args, plotpanel_builder, id = id)
  names(plotpanels) <- plotpanel_args[["title"]]
  return(plotpanels)
}