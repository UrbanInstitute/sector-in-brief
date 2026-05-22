# Module for geographic filters - need to update choices argument

substate_filter <- function(session, id, geo_input, geo_df, geo_var, server = TRUE) {
  shiny::updateSelectizeInput(
    session = session,
    inputId = id,
    choices = geo_df[[geo_var]][geo_df[["Census.State"]] == geo_input],
    server = TRUE
  )
}

geo_filter_ui <- function(id, state_choices) {
  ns <- shiny::NS(id)
  bslib::card(
    filter_card_header(
      "Geographic Filters",
      "Information about census-defined geographic level is available on the About page."
    ),
    urbn_radiobuttons(
      ns,
      id = "geo_level",
      label = "Select Geographic Level",
      choices = geo_level,
      selected = "National",
      class = "filter__text"
    ),
    shiny::conditionalPanel(
      selectize_wrapper(
        ns = ns,
        id = "region",
        label = "Select Region(s)",
        choices = c("Northeast", "South", "Midwest", "West"),
        multiple = TRUE
      ),
      condition = "input.geo_level == 'Census Region'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectize_wrapper(
        ns = ns,
        id = "state_mult",
        label = "Select State(s)",
        choices = states,
        multiple = TRUE,
        options = list(maxItems = 5)
      ),
      condition = "input.geo_level == 'Census State'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectize_wrapper(
        ns = ns,
        id = "state_single",
        label = "Select State",
        choices = states,
        multiple = FALSE
      ),
      condition = "input.geo_level == 'Census County' | input.geo_level == 'Metro/Micro Area'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectize_wrapper(
        ns = ns,
        id = "county",
        label = "Select Counties",
        choices = NULL,
        multiple = TRUE,
        options = list(maxItems = 5)
      ),
      condition = "input.geo_level == 'Census County'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectize_wrapper(
        ns = ns,
        id = "cbsa",
        label = "Select Metro/Micro Area(s)",
        choices = NULL,
        multiple = TRUE,
        options = list(maxItems = 5)
      ),
      condition = "input.geo_level == 'Metro/Micro Area'",
      ns = shiny::NS(id)
    )
  )
}

geo_filter_server <- function(id, geo_df) {
  shiny::moduleServer(id, function(input, output, session) {
    observeEvent(input$state_single, {
      substate_filter(
        session,
        "county",
        input$state_single,
        geo_df,
        "Census.County"
      )
      substate_filter(session,
                      "cbsa",
                      input$state_single,
                      geo_df,
                      "Metro.Micro.Area")
    })
    shiny::observeEvent(input$geo_reset, {
      shiny::updateSelectizeInput(inputId = "geo_level", selected = "National")
    })
    list(
      state_single = reactive(input$state_single),
      state_mult = reactive(input$state_mult),
      region = reactive(input$region),
      geo_level = reactive(input$geo_level),
      county = reactive(input$county),
      cbsa = reactive(input$cbsa)
    )
    
  })
}