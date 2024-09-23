# Module to create highlight filters
highlight_ui <- function(id){
  htmltools::tagList(
    shiny::selectizeInput(
      inputId = shiny::NS(id, "highlight"),
      label = "Highlight (Maximum 8)",
      choices = NULL,
      selected = NULL,
      options = list(maxItems = 8)
    )
  )
}

highlight_server <- function(id, highlight_choices) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::updateSelectizeInput(
      session = session,
      inputId = "highlight",
      choices = highlight_choices,
      selected = ifelse(length(highlight_choices) > 8, highlight_choices[1:8], highlight_choices)
    )
    list(highlights = reactive(input$highlight))
  })
}