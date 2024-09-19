# Module for geographic filters - need to update choices argument

substate_filter <- function(session, id, geo_input, geo_df, geo_var, server = TRUE) {
  shiny::updateSelectizeInput(
    session = session,
    inputId = id,
    choices = geo_df[[geo_var]][geo_df[["Census State"]] == geo_input],
    server = TRUE
  )
}

geo_filter_ui <- function(id, state_choices) {
  htmltools::tagList(
    radioButtons(
      shiny::NS(id, "geo_level"),
      inline = FALSE,
      "Select Geographic Level",
      choices = list("Entire USA" = "all", 
                     "Region" = "Census Region", 
                     "State" = "Census State", 
                     "County" = "Census County", 
                     "Metro/Micro Area" = "Census CBSA"),
      selected = "all"
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "region_selector"),
        label = "Select Region(s)",
        choices = c("Northeast", "South", "Midwest", "West"),
        multiple = TRUE
      ),
      condition = "input.geo_level == 'Census Region'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "state_selector_multi"),
        label = "Select State(s)",
        choices = state_choices,
        multiple = TRUE
      ),
      condition = "input.geo_level == 'Census State'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "state_selector_single"),
        label = "Select State",
        choices = state_choices,
        multiple = FALSE
      ),
      condition = "input.geo_level == 'Census County' | input.geo_level == 'Census CBSA'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "county_selector"),
        label = "Select Counties",
        choices = NULL,
        multiple = TRUE,
        options = list(maxItems = 5)
      ),
      condition = "input.geo_level == 'Census County'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "cbsa_selector"),
        label = "Select Metro/Micro Area(s)",
        choices = NULL,
        multiple = TRUE,
        options = list(maxItems = 5)
      ),
      condition = "input.geo_level == 'Census CBSA'",
      ns = shiny::NS(id)
    )
  )
}

geo_filter_server <- function(id, geo_df) {
  shiny::moduleServer(id, function(input, output, session) {
    observeEvent(input$state_selector_single, {
      substate_filter(session,
                     "county_selector",
                     input$state_selector_single,
                     geo_df,
                     "Census County")
      substate_filter(session,
                     "cbsa_selector",
                     input$state_selector_single,
                     geo_df,
                     "Census CBSA")
    })
    list(
      state_selector_single = reactive(input$state_selector_single),
      state_selector_multi = reactive(input$state_selector_multi),
      region_selector = reactive(input$region_selector),
      geo_level = reactive(input$geo_level),
      county_selector = reactive(input$county_selector),
      cbsa_selector = reactive(input$cbsa_selector)
    )
    
  })
}