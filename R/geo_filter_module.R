# Geographic filter Shiny module — both the UI (geo_filter_ui) and the
# server (geo_filter_server). Splits the geo selection into a level
# radio + level-specific selectizes, with conditionalPanel hiding the
# ones that don't apply. State-then-county and state-then-CBSA
# cascading is handled server-side by substate_filter().
#
# County and metro are selected by their collision-proof codes
# (County FIPS / CBSA Code, ADR 0021): the dropdown VALUE is the code,
# the LABEL is the canonical name. Selecting by code means same-named
# counties in different states stay distinct and the producer's
# de-duplicated names show once each (no "Wayne" vs "Wayne County"
# split). geo_filter_server resolves the selected codes back to names
# (county_label/cbsa_label) for the chips, captions, and notes.
#
# Used inside `data_ui()` as one of the sidebar accordion sections.
# The server returns a list of reactives (state_single(), state_mult(),
# region(), geo_level(), county(), cbsa(), county_label(), cbsa_label())
# consumed by `format_input()` to snapshot into pure inputs.

#' Build deduped named choices (label = name, value = code) for a
#' downstream geo selectize, scoped to one state.
#'
#' @param geo_df Nested geographies lookup (dotted column names).
#' @param state Selected `Census.State`.
#' @param value_var Code column to use as the selectize value
#'   (e.g. "County.FIPS", "CBSA.Code").
#' @param label_var Name column to use as the selectize label.
#' @param type Optional `CBSA.Type` filter (e.g. "Metropolitan
#'   Statistical Area"); "All"/NULL keeps every type.
#' @return A named character vector ready for `choices`.
geo_named_choices <- function(geo_df, state, value_var, label_var, type = NULL) {
  rows <- geo_df[geo_df[["Census.State"]] == state, , drop = FALSE]
  rows <- rows[!is.na(rows[[value_var]]) & nzchar(as.character(rows[[value_var]])), ,
               drop = FALSE]
  if (!is.null(type) && !identical(type, "All") && "CBSA.Type" %in% names(rows)) {
    rows <- rows[!is.na(rows[["CBSA.Type"]]) & rows[["CBSA.Type"]] == type, ,
                 drop = FALSE]
  }
  rows <- unique(rows[, c(value_var, label_var), drop = FALSE])
  stats::setNames(rows[[value_var]], rows[[label_var]])
}

#' Resolve selected geo codes back to their display names.
#'
#' @param codes Selected code values (County FIPS / CBSA Code).
#' @param geo_df Nested geographies lookup.
#' @param code_var,name_var Dotted column names of the code and its name.
#' @return Character vector of names (falls back to the raw code if a
#'   code is somehow absent from the lookup).
geo_code_to_name <- function(codes, geo_df, code_var, name_var) {
  if (length(codes) == 0) return(character(0))
  lut <- unique(geo_df[!is.na(geo_df[[code_var]]), c(code_var, name_var), drop = FALSE])
  out <- lut[[name_var]][match(codes, lut[[code_var]])]
  out[is.na(out)] <- codes[is.na(out)]
  out
}

#' Refresh the choices for a downstream geo selectize from the parent
#' state. Called on state_single change to update county/CBSA lists.
#'
#' @param session Active Shiny session.
#' @param id Target selectize input id (e.g. "county").
#' @param geo_input Parent state value.
#' @param geo_df Nested geographies lookup.
#' @param value_var,label_var Code column (selectize value) + name column
#'   (selectize label).
#' @param type Optional CBSA Type filter (CBSA picker only).
#' @param server Forwarded to `updateSelectizeInput`.
substate_filter <- function(session, id, geo_input, geo_df, value_var, label_var,
                            type = NULL, server = TRUE) {
  shiny::updateSelectizeInput(
    session = session,
    inputId = id,
    choices = geo_named_choices(geo_df, geo_input, value_var, label_var, type),
    server = server
  )
}

# Metro picker split by OMB CBSA Type. Values are the literal CBSA Type
# strings the cbsa crosswalk carries, so they filter geo_df directly.
cbsa_type_choices <- c(
  "All areas"        = "All",
  "Metropolitan"     = "Metropolitan Statistical Area",
  "Micropolitan"     = "Micropolitan Statistical Area"
)

#' Build the Geographic Filters section UI.
#'
#' Returns a plain div with the level radio + the conditional
#' sub-selectizes. Plain div (not a card) because the parent
#' `data_ui` wraps each filter in an accordion panel whose own title
#' acts as the section header — adding a filter_card_header here
#' would duplicate it.
#'
#' @param id Sub-module id (typically the parent's `"geo_filter"`).
#' @param state_choices Accepted for backwards compatibility; the
#'   actual state list comes from `R/geo_choices.R::states`.
#' @return A `htmltools::div`.
geo_filter_ui <- function(id, state_choices) {
  ns <- shiny::NS(id)
  htmltools::div(
    htmltools::p(
      class = "filter-hint",
      "Census-defined geographic levels — see the About page for details."
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
      urbn_radiobuttons(
        ns,
        id = "cbsa_type",
        label = "Area type",
        choices = cbsa_type_choices,
        selected = "All",
        class = "filter__text"
      ),
      condition = "input.geo_level == 'Metro/Micro Area'",
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
#' Wires the state→county and state→CBSA cascades, the CBSA-type split,
#' the geo_reset handler, and exposes the active selections (codes) plus
#' their resolved names as reactives so the parent module's
#' `format_input()` can snapshot them.
#'
#' @param id Sub-module id.
#' @param geo_df Nested geographies lookup.
#' @return Named list of reactives consumed by `format_input()`.
geo_filter_server <- function(id, geo_df) {
  shiny::moduleServer(id, function(input, output, session) {
    observeEvent(input$state_single, {
      substate_filter(
        session, "county", input$state_single, geo_df,
        "County.FIPS", "Census.County"
      )
      substate_filter(
        session, "cbsa", input$state_single, geo_df,
        "CBSA.Code", "Metro.Micro.Area",
        type = input$cbsa_type
      )
    })
    # Re-narrow the metro picker when the user toggles Metro/Micro type.
    shiny::observeEvent(input$cbsa_type, {
      substate_filter(
        session, "cbsa", input$state_single, geo_df,
        "CBSA.Code", "Metro.Micro.Area",
        type = input$cbsa_type
      )
    }, ignoreInit = TRUE)
    shiny::observeEvent(input$geo_reset, {
      shiny::updateSelectizeInput(inputId = "geo_level", selected = "National")
    })
    list(
      state_single = reactive(input$state_single),
      state_mult = reactive(input$state_mult),
      region = reactive(input$region),
      geo_level = reactive(input$geo_level),
      county = reactive(input$county),
      cbsa = reactive(input$cbsa),
      county_label = reactive(
        geo_code_to_name(input$county, geo_df, "County.FIPS", "Census.County")
      ),
      cbsa_label = reactive(
        geo_code_to_name(input$cbsa, geo_df, "CBSA.Code", "Metro.Micro.Area")
      )
    )

  })
}
