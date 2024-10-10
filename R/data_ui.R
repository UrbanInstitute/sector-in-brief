# Module for data processing in Shiny App
data_ui <- function(id, choices, start_year, end_year) {
  ns <- shiny::NS(id)
  htmltools::tagList(
    org_card = bslib::card(
      bslib::card_header("Organization Type", 
                         shiny::actionLink(shiny::NS(id, "org_reset"), "Reset", style = "float: right;")),
      selectize_wrapper(ns, "ctype_level1", NULL, choices$ctype_level1, "500px"),
      shiny::conditionalPanel(
        selectize_wrapper(ns, "ctype_level2", NULL, choices$ctype_level2, "500px"),
        condition = "input.ctype_level1 == 'Other Nonprofits'",
        ns = ns
      )
    ),
    geo_card = geo_filter_ui(shiny::NS(id, "geo_filter"), state_choices),
    subsector_card = bslib::card(
      bslib::card_header(
        "Subsector",
        shiny::actionLink(shiny::NS(id, "subsector_reset"), "Reset", style = "float: right;")
      ),
      urbn_checkboxgroup(
        ns = ns,
        id = "subsector",
        choices = choices$subsector,
        selected = choices$subsector
      )
    ), 
    size_card = bslib::card(
      bslib::card_header("Asset Size", shiny::actionLink(shiny::NS(id, "size_reset"), "Reset", style = "float: right;")),
      urbn_checkboxgroup(
        ns = ns,
        id = "size",
        choices = choices$size,
        selected = choices$size
      )
    ),
    date_card = bslib::card(
      bslib::card_header("Date Range", shiny::actionLink(shiny::NS(id, "date_reset"), "Reset", style = "float: right;")),
      urbn_slider(ns, "date_range", start_year, end_year)
    ),
    process_button = urbn_task_button(
      ns = ns,
      id = "process_data",
      label = "VISUALIZE DATA",
      label_busy = "VISUALIZING...")
  )
}