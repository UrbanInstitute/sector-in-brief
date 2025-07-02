#-------------------------------------------------------------------------------
# File: geo_filter_module.R
# Author: Thiyaghessan Poongundranar [tpoongundranar@urban.org]
# Date Created: 2024-06-01
# Date Last Edited: 2025-07-02
#
# Purpose: Server and UI logic, and options for dynamic geographic filtering in
# the dashboard.
#
# Usage: The module is used to update the region, state, county and metro/micro
# area filters based on the selected geographic level. County and Metro/Micro 
# Area filters are dynamically updated based on the selected state.
#
# Dependencies: 
#  - shiny
#  - bslib
#  - R/urbn_radiobuttons.R
#-------------------------------------------------------------------------------

state_choices <- list(
  "Alabama" = "AL",
  "Alaska" = "AK", 
  "Arizona" = "AZ",
  "Arkansas" = "AR",
  "California" = "CA",
  "Colorado" = "CO",
  "Connecticut" = "CT",
  "Delaware" = "DE",
  "District of Columbia" = "DC",
  "Florida" = "FL",
  "Georgia" = "GA",
  "Hawaii" = "HI",
  "Idaho" = "ID",
  "Illinois" = "IL",
  "Indiana" = "IN",
  "Iowa" = "IA",
  "Kansas" = "KS",
  "Kentucky" = "KY",
  "Louisiana" = "LA",
  "Maine" = "ME",
  "Maryland" = "MD",
  "Massachusetts" = "MA",
  "Michigan" = "MI",
  "Minnesota" = "MN",
  "Mississippi" = "MS",
  "Missouri" = "MO",
  "Montana" = "MT",
  "Nebraska" = "NE",
  "Nevada" = "NV",
  "New Hampshire" = "NH",
  "New Jersey" = "NJ",
  "New Mexico" = "NM",
  "New York" = "NY",
  "North Carolina" = "NC",
  "North Dakota" = "ND",
  "Ohio" = "OH",
  "Oklahoma" = "OK",
  "Oregon" = "OR",
  "Pennsylvania" = "PA",
  "Rhode Island" = "RI",
  "South Carolina" = "SC",
  "South Dakota" = "SD",
  "Tennessee" = "TN",
  "Texas" = "TX",
  "Utah" = "UT",
  "Vermont" = "VT",
  "Virginia" = "VA",
  "Washington" = "WA",
  "West Virginia" = "WV",
  "Wisconsin" = "WI",
  "Wyoming" = "WY"
)

usethis::use_data(state_choices, 
                  internal = TRUE, 
                  overwrite = TRUE)

#' @title Update geographic filter based on selected state
#' 
#' @description This function updates the substate filters 
#' (county and metro/micro area) dynamically based on the state selected by the
#' user
#' 
#' @param session The Shiny session object
#' @param id The input ID of the substate filter
#' @param geo_input The selected state input
#' @param geo_df The data frame containing nested geographic information
#' @param geo_var The column name in the data frame that contains the substate
#' variable (e.g., "Census.County" or "Metro.Micro.Area")
#' 
#' #' @return NULL
substate_filter <- function(session, id, geo_input, geo_df, geo_var) {
  shiny::updateSelectizeInput(
    session = session,
    inputId = id,
    choices = geo_df[[geo_var]][geo_df[["Census.State"]] == geo_input],
    server = TRUE
  )
}

#' @title UI for geographic filter module
#' 
#' @description This function creates the UI for the geographic filter module,
#' including radio buttons for geographic level selection and conditional
#' panels for selecting regions, states, counties, and metro/micro areas.
#' 
#' @param id The namespace for the module
#' @param state_choices A list of state choices for the selectize inputs
#' 
#' @return A bslib card containing the UI elements for geographic filtering
geo_filter_ui <- function(id, state_choices) {
  ns <- shiny::NS(id)
  bslib::card(
    bslib::card_header(
      htmltools::tagList(
        htmltools::h6("Geographic Filters"),
        htmltools::p(
          class = "base",
          "Information about census-defined geographic level is available on the About page."
        )
      )
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
        multiple = TRUE
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

#' @title Server logic for geographic filter module
#' 
#' @description This function contains the server logic for the geographic filter
#' module. It observes changes in the selected state and updates the county and
#' metro/micro area filters accordingly. It also provides reactive values for
#' the selected geographic inputs.
#' 
#' @param id The namespace for the module
#' @param geo_df A data frame containing nested geographic information
#' 
#' @return A list of reactive values for the selected geographic inputs
geo_filter_server <- function(id, geo_df) {
  shiny::moduleServer(id, function(input, output, session) {
    observeEvent(input$state_single, {
      substate_filter(session,
                      "county",
                      input$state_single,
                      geo_df,
                      "Census.County")
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