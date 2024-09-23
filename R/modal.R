# Function to create a modal dialog box
modal <- function(tile, message){
  shiny::modalDialog(
    title = title,
    message,
    easyClose = TRUE,
    footer = NULL
  )
}

modal_titles <- 
  list(
    "invalid_inputs" = "Invalid Filter Selection"
  )