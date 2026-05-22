# Geographic filter Shiny module — both the UI (geo_filter_ui) and the
# server (geo_filter_server). Splits the geo selection into a level
# radio + level-specific selectizes, with conditionalPanel hiding the
# ones that don't apply. State-then-county and state-then-CBSA
# cascading is handled server-side by substate_filter().
#
# Used inside `data_ui()` as one of the filter cards. The server
# returns a list of reactives (state_single(), state_mult(), region(),
# geo_level(), county(), cbsa()) consumed by `format_input()` to
# snapshot into pure inputs.

#' Refresh the choices for a downstream geo selectize from the parent
#' state. Called on state_single change to update county/CBSA lists.
#'
#' @param session Active Shiny session.
#' @param id Target selectize input id (e.g. "county").
#' @param geo_input Parent state value.
#' @param geo_df Nested geographies lookup.
#' @param geo_var Column in `geo_df` to pull values from.
#' @param server Forwarded to `updateSelectizeInput`.
substate_filter <- function(session, id, geo_input, geo_df, geo_var, server = TRUE) {
  shiny::updateSelectizeInput(
    session = session,
    inputId = id,
    choices = geo_df[[geo_var]][geo_df[["Census.State"]] == geo_input],
    server = TRUE
  )
}

#' Build the Geographic Filters card UI.
#'
#' @param id Sub-module id (typically the parent's `"geo_filter"`).
#' @param state_choices Accepted for backwards compatibility; the
#'   actual state list comes from `R/geo_choices.R::states`.
#' @return A `bslib::card`.
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

#' Server half of the geo filter module.
#'
#' Wires the state→county and state→CBSA cascades, the geo_reset
#' handler, and exposes the active selections as reactives so the
#' parent module's `format_input()` can snapshot them.
#'
#' @param id Sub-module id.
#' @param geo_df Nested geographies lookup.
#' @return Named list of reactives consumed by `format_input()`.
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