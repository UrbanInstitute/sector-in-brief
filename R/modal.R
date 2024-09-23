# Function to create a modal dialog box
modal <- function(message){
  shiny::modalDialog(
    title = message,
    easyClose = TRUE
  )
}

modal_titles <- 
  list(
    "invalid_inputs" = "Invalid Filter Selection"
  )