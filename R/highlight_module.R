# Module to create highlight filters
highlight_ui <- function(id){
  htmltools::tagList(
    shiny::checkboxGroupInput(
      inputId = shiny::NS(id, "highlight"),
      label = "Highlight",
      choices = NULL,
      selected = NULL
    )
  )
}

highlight_server <- function(id, highlight_choices) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::updateCheckboxGroupInput(
      session = session,
      inputId = "highlight",
      choices = highlight_choices,
      selected = highlight_choices
    )
  })
}