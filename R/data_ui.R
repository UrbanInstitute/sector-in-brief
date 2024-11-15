# Module for data processing in Shiny App
data_ui <- function(id, choices, start_year, end_year) {
  ns <- shiny::NS(id)
  htmltools::tagList(
    org_card = bslib::card(
      bslib::card_header("Organization Type", 
                         bslib::tooltip(
                           bsicons::bs_icon("question-circle"),
                           "Section 501(c) of the Internal Revenue Code. Subsector"
                         )),
      urbn_tree(
        ns = ns,
        id = "ctype",
        choice_df = choices$ctype_tree_df,
        selected = choices$ctype,
        width = "500px"
      )
    ),
    geo_card = geo_filter_ui(shiny::NS(id, "geo_filter"), state_choices),
    subsector_card = bslib::card(
      bslib::card_header(
        "Subsector",
        bslib::tooltip(
          bsicons::bs_icon("question-circle"),
          htmltools::HTML("12 general categories of the <a href='https://urbaninstitute.github.io/nccs-legacy/ntee/ntee-history.html'>National Taxonomy of Exempt Entities</a> (NTEE) code system. Asset Size")
        )
      ),
      urbn_checkboxgroup(
        ns = ns,
        id = "subsector",
        choices = choices$subsector,
        selected = choices$subsector
      )
    ), 
    size_card = bslib::card(
      bslib::card_header("Asset Size", 
                         bslib::tooltip(
                           bsicons::bs_icon("question-circle"),
                           "Total assets from the IRS Business Master File grouped in five categories."
                         )),
      urbn_checkboxgroup(
        ns = ns,
        id = "size",
        choices = choices$size,
        selected = choices$size
      )
    ),
    date_card = bslib::card(
      bslib::card_header("Date Range", 
                         bslib::tooltip(
                           bsicons::bs_icon("question-circle"),
                           "Tax years, defined as the 12-month period beginning in a given calendar year, used to calculate annual financial statements"
                         )),
      urbn_slider(ns, "date_range", start_year, end_year)
    ),
    process_button = urbn_task_button(
      ns = ns,
      id = "process_data",
      label = "UPDATE DATA",
      label_busy = "VISUALIZING...")
  )
}