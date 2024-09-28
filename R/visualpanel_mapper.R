visualpanel_mapper <- function(visualpanel_args){
  visualpanels <- purrr::pmap(visualpanel_args, visualpanel_builder)
  names(visualpanels) <- visualpanel_args[["title"]]
  return(visualpanels)
}