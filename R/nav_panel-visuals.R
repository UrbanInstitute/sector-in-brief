###############################################################################
# File: nav_panel-visuals.R
# Author: Thiyaghessan [tpoongundranar@urban.org]
# Date created: 2024-06-01
# Date last edited: 2025-07-02
# Purpose: Create the layout of the navigation panels containing the filters
# and visualizations in each visual page.
# Usage: Sourced by app during startup, visualpanel_mapper() maps arguments from
# visualpanel_args to visualpanel_builder() to create the navigation panels.
# Dependencies:
# - tibble
# - purrr
# - bslib
# - R/text-visuals.R
# - R/data_ui.R
# - R/options_nogeo.R
# - R/plot_ui.R
# Notes:
# Nav panels require the following: Title, header text for panel, description text
# for each variable, unique object id, start and end years to filer datasets.
################################################################################

visualpanel_args <- tibble::tribble(
  ~title, ~panel_header, ~panel_desc, ~panelid, ~start_year, ~end_year,
  "Numbers", "Number of Nonprofits", number_of_nonprofits, "number", 1989, 2024,
  "Assets", "Assets", assets_desc, "assets", 1989, 2021,
  "Revenues", "Revenues", revenue_desc, "revenues", 1989, 2021,
  "Expenses", "Expenses", expenses_desc, "expenses", 1989, 2021,
  "Benefits", "Benefits", benefits_desc, "benefits", 1989, 2021,
  "Government Grants", "Government Grants", gov_grants_desc, "gov_grants", 2021, 2021,
  "Private Foundation Grants", "Grants", grants_desc, "pf_amount", 1989, 2021,
  "Program Related Investments", "Program Related Investments", pri_desc, "pri", 2020, 2023,
  "Number of DAFs", "Number of DAFs", daf_number_desc, "daf_number", 2021, 2021,
  "DAF Contributions", "DAF Contributions", daf_contributions_desc,"daf_contributions", 2021, 2021,
  "DAF Grants", "DAF Grants", daf_grants_desc, "daf_grants", 2021, 2021,
  "DAF Value", "DAF Value", daf_value_desc, "daf_value", 2021, 2021,
  "DAF Proportion", "Percentage of organizations that maintain a DAF", daf_proportion_desc, "daf_proportion", 2021, 2021,
)

#' @title Function to create nav panel templates for all visual pages
#' 
#' @description This function uses purrr::pmap to iterate over each row in
#' visualpanel_args and calls visualpanel_builder to create a navigation panel
#' 
#' @param visualpanel_args A tibble containing the arguments for each visual panel
#' 
#' @return A named list of bslib:nav_panels used for each visualization
visualpanel_mapper <- function(visualpanel_args){
  visualpanels <- purrr::pmap(visualpanel_args, visualpanel_builder)
  names(visualpanels) <- visualpanel_args[["title"]]
  return(visualpanels)
}

#' @title Function to create nav panel template for each visual page
#' 
#' @description This function builds a navigation panel for a single visual page
#' containing cards for each filter and a plot output area.
#' 
#' @param title The title of the visual page
#' @param panel_header The header of the visual page
#' @param panel_desc The description of the visual page
#' @param panelid The id of the visual page
#' @param start_year The start year of the data
#' @param end_year The end year of the data
#' 
#' @return A bslib:nav_panel object containing the layout for the visual page
visualpanel_builder <- function(title,
                                panel_header,
                                panel_desc,
                                panelid,
                                start_year,
                                end_year) {
  choices <- choice_builder(panelid)
  all_cards <- data_ui(panelid, choices, start_year, end_year)
  panel <- bslib::nav_panel(
    title = title,
    card_header_text(panel_header, panel_desc),
    bslib::card(
      class = "card-filter",
      bslib::card_title("Select Your Filters", class = "bg-light-gray"),
      title = "",
      bslib::layout_column_wrap(
        all_cards[["org_card"]], 
        all_cards[["subsector_card"]], 
        all_cards[["size_card"]], 
        all_cards[["geo_card"]], 
        all_cards[["date_card"]]
      ),
      all_cards[["process_button"]]
    ),
    plot_ui(panelid)
  )
  return(panel)
}

#' @title Header and subheader text for each plot card
#' 
#' @description This function creates a list of html tags containing the 
#' header and subheader for each card in the visualization panels.
#' 
#' @param header The main header text for the card. Character string
#' @param subheader The subheader text for the card. Character string
#' 
#' @return A list of html tags containing the header and subheader
card_header_text <- function(header, subheader) {
  headertags <- htmltools::tagList(
    htmltools::h2(header),
    subheader
  )
  return(headertags)
}