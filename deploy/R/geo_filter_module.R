# Module for geographic filters - need to update choices argument

substate_filter <- function(session, id, geo_input, geo_df, geo_var, server = TRUE) {
  shiny::updateSelectizeInput(
    session = session,
    inputId = id,
    choices = geo_df[[geo_var]][geo_df[["CENSUS_STATE_ABBR"]] == geo_input],
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
                     "Region" = "census_region", 
                     "State" = "CENSUS_STATE_ABBR", 
                     "County" = "CENSUS_COUNTY_NAME", 
                     "Metro/Micro Area" = "CENSUS_CBSA_NAME"),
      selected = "all"
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "region_selector"),
        label = "Select Region(s)",
        choices = c("Northeast", "South", "Midwest", "West"),
        multiple = TRUE
      ),
      condition = "input.geo_level == 'census_region'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "state_selector_multi"),
        label = "Select State(s)",
        choices = state_choices,
        multiple = TRUE
      ),
      condition = "input.geo_level == 'CENSUS_STATE_ABBR'",
      ns = shiny::NS(id)
    ),
    shiny::conditionalPanel(
      selectizeInput(
        shiny::NS(id, "state_selector_single"),
        label = "Select State",
        choices = state_choices,
        multiple = FALSE
      ),
      condition = "input.geo_level == 'CENSUS_COUNTY_NAME' | input.geo_level == 'CENSUS_CBSA_NAME'",
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
      condition = "input.geo_level == 'CENSUS_COUNTY_NAME'",
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
      condition = "input.geo_level == 'CENSUS_CBSA_NAME'",
      ns = shiny::NS(id)
    )
  )
}

geo_filter_server <- function(id, geo_df) {
  shiny::moduleServer(id, function(input, output, session) {
    observeEvent(input$state_selector_single, {
      update_nestgeo(session,
                     "county_selector",
                     input$state_selector_single,
                     geo_df,
                     "CENSUS_COUNTY_NAME")
      update_nestgeo(session,
                     "cbsa_selector",
                     input$state_selector_single,
                     geo_df,
                     "CENSUS_CBSA_NAME")
    })
  })
}