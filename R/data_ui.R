#' @title Shiny module for the data selection UI
#' 
#' @description This module creates a UI for selecting data filters such as 
#' organization type, geographic area, subsector, size, and date range. Each filter
#' is contained in a bslib card object.
#' 
#' @param id The namespace for the module
#' @param choices A list containing the choices for each filter
#' @param start_year The starting year for the date range filter
#' @param end_year The ending year for the date range filter
#' 
#' # @return A list of HTML tags containing the UI elements for data selection
data_ui <- function(id, choices, start_year, end_year) {
  ns <- shiny::NS(id)
  htmltools::tagList(
    org_card = bslib::card(
      bslib::card_header(htmltools::tagList(
        htmltools::h6("Organization Type"),
        htmltools::tags$p(class = "base", html_orgtype),
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
      bslib::card_header(htmltools::tagList(
        htmltools::h6("Subsector"),
        htmltools::tags$p(
          class = "base",
          "12 general categories of the",
          htmltools::a(href = "https://urbaninstitute.github.io/nccs-legacy/ntee/ntee-history.html", "National Taxonomy of Exempt Entities (NTEE)"),
          "code system."
        )
      )),
      urbn_checkboxgroup(
        ns = ns,
        id = "subsector",
        choices = choices$subsector,
        selected = choices$subsector
      )
    ),
    size_card = bslib::card(
      bslib::card_header(htmltools::tagList(
        htmltools::h6("Size"),
        htmltools::tags$p(
          class = "base",
          "Total expenses from the IRS Business Master File grouped in five categories."
        )
      )),
      urbn_checkboxgroup(
        ns = ns,
        id = "size",
        choices = choices$size,
        selected = choices$size
      )
    ),
    date_card = bslib::card(
      bslib::card_header(htmltools::tagList(
        htmltools::h6("Date Range"),
        htmltools::tags$p(
          class = "base",
          "Dates are tax years, which lag calendar years by two years on average (e.g., tax year 2022 is for calendar year 2024)."
        )
      )),
      urbn_slider(ns, "date_range", start_year, end_year)
    ),
    process_button = urbn_task_button(
      ns = ns,
      id = "process_data",
      label = "UPDATE DATA",
      label_busy = "VISUALIZING..."
    )
  )
}