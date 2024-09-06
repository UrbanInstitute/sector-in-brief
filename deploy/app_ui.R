########################
# Programmer: Thiyaghessan tpoongundranar@urban.org
# Date created: 2024-09-04
# Date of last revision: 2024-09-05
# Description: This script contains the user interface for the sector in brief
########################

# Load packages
library(bslib)
library(shiny)
library(tidyverse)
library(plotly)
library(ggplot2)
library(DT)

# Load assets
source("executive_summary.R")
source("assets/assets.R")
source("ui_plots.R")

# Theme
# Shiny Theme
sibtheme <- bslib::bs_theme(
  bg = "#FFF", 
  fg = "#000",
  primary = "#1696d2",
  secondary = "#fdbf11",
  success = "#55b748",
  warning = "#ec008b",
  danger = "#db2b27",
  info = "#d2d2d2",
  base_font = font_google("Lato"),
  version = 5
)

# Sidebar
org_accordion <- bslib::accordion_panel(
  "Organization Type",
  selectizeInput(
    "org_selector",
    "Select Organization Type",
    choices = c("501(c)(3) Public Charities", 
                "501(c)(3) Private Foundations", 
                "501(c)(4) Organizations", 
                "Other Nonprofits")
  ),
  shiny::conditionalPanel(
    selectizeInput(
      "501c_selector",
      label = "Other 501(c) Type",
      choices = c("501(c)(4)", "501(c)(5)")
    ),
    condition = "input.org_selector == 'Other Nonprofits'"
  )
)

sidebar <- bslib::sidebar(
  title = "Select Data for Nonprofits by:",
  id = "sidebar",
  open = FALSE,
  bslib::accordion(
    org_accordion,
    bslib::accordion_panel(
      "Geography",
      radioButtons(
        "geo_selector",
        "Select Geographic Level",
        choices = c("Region", "State", "County", "Metro/Micro Area")
      ),
      shiny::conditionalPanel(
        selectizeInput(
          "region_selector",
          label = "Select Region",
          choices = c("Northeast", "South"),
          multiple = TRUE
        ),
        condition = "input.geo_selector == 'Region'"
      ),
      shiny::conditionalPanel(
        selectizeInput(
          "state_selector_multi",
          label = "Select State",
          choices = c("California", "New York"),
          multiple = TRUE
        ),
        condition = "input.geo_selector == 'State'"
      ),
      shiny::conditionalPanel(
        selectizeInput(
          "state_selector_single",
          label = "Select State",
          choices = c("California", "New York"),
          multiple = FALSE
        ),
        condition = "input.geo_selector == 'County' | input.geo_selector == 'Metro/Micro Area'"
      ),
      shiny::conditionalPanel(
        selectizeInput(
          "county_selector",
          label = "Select County",
          choices = c("County A", "County B"),
          multiple = TRUE
        ),
        condition = "input.geo_selector == 'County'"
      ),
      
      shiny::conditionalPanel(
        selectizeInput(
          "cbsa_selector",
          label = "Select Metro/Micro Area",
          choices = c("Metro A", "Metro B"),
          multiple = TRUE
        ),
        condition = "input.geo_selector == 'Metro/Micro Area'"
      )
    ),
    bslib::accordion_panel(
      "Subsector",
      industry_group_filter
    ),
    bslib::accordion_panel(
      "Size",
      size_filter
    ),
    bslib::input_task_button(
      id = "update_plot",
      style = "margin-top: 32px; margin-left: 32px",
      label = "Retrieve Data",
      label_busy = "Updating Plots",
      type = "primary"
    )
  ),
  shiny::img(src="ui-logo-rgb.png")
)

# User Interface
ui <- bslib::page_navbar(
  title = "Nonprofit Sector In Brief",
  id = "tabs",
  theme = sibtheme,
  fillable = FALSE,
  exec_summary,
  bslib::nav_panel(
    "Number",
    fillable = FALSE,
    bslib::navset_card_tab(
      title = "Number of Organizations",
      sidebar = sidebar,
      height = "100%",
      nav_panel(
        "Overall",
        bslib::card_title("Yearly Trends in Aggregate"),
        bslib::card(num_nonprofits_plot, height = "60%"),
        bslib::card(num_nonprofits_table, height = "40%")
      ),
      nav_panel("By Subsector", 
                bslib::card_title("Yearly Trends by Subsector"),
                bslib::card(num_nonprofits_subsector_plot, height = "60%"),
                bslib::card(num_nonprofits_subsector_table, height = "40%")
      ),
      nav_panel("By Geography", "By Geography"),
      nav_panel("By Size", "By Size")
    ),
    bslib::navset_card_tab(
      title = "Number of Organizations",
      height = "100%",
      bslib::layout_columns(
        bslib::card(
          selectizeInput(
            "org_selector",
            "Select Organization Type",
            choices = c("501(c)(3) Public Charities", 
                        "501(c)(3) Private Foundations", 
                        "501(c)(4) Organizations", 
                        "Other Nonprofits")
          ),
          shiny::conditionalPanel(
            selectizeInput(
              "501c_selector",
              label = "Other 501(c) Type",
              choices = c("501(c)(4)", "501(c)(5)")
            ),
            condition = "input.org_selector == 'Other Nonprofits'"
          )
        ),
        bslib::card(
          radioButtons(
            "geo_selector",
            "Select Geographic Level",
            choices = c("Region", "State", "County", "Metro/Micro Area")
          ),
          shiny::conditionalPanel(
            selectizeInput(
              "region_selector",
              label = "Select Region",
              choices = c("Northeast", "South"),
              multiple = TRUE
            ),
            condition = "input.geo_selector == 'Region'"
          ),
          shiny::conditionalPanel(
            selectizeInput(
              "state_selector_multi",
              label = "Select State",
              choices = c("California", "New York"),
              multiple = TRUE
            ),
            condition = "input.geo_selector == 'State'"
          ),
          shiny::conditionalPanel(
            selectizeInput(
              "state_selector_single",
              label = "Select State",
              choices = c("California", "New York"),
              multiple = FALSE
            ),
            condition = "input.geo_selector == 'County' | input.geo_selector == 'Metro/Micro Area'"
          ),
          shiny::conditionalPanel(
            selectizeInput(
              "county_selector",
              label = "Select County",
              choices = c("County A", "County B"),
              multiple = TRUE
            ),
            condition = "input.geo_selector == 'County'"
          ),
          shiny::conditionalPanel(
            selectizeInput(
              "cbsa_selector",
              label = "Select Metro/Micro Area",
              choices = c("Metro A", "Metro B"),
              multiple = TRUE
            ),
            condition = "input.geo_selector == 'Metro/Micro Area'"
          )
        ),
        bslib::card(
          industry_group_filter
        ),
        bslib::card(
          size_filter
        )
      ),
      nav_panel(
        "Overall",
        bslib::card_title("Yearly Trends in Aggregate"),
        bslib::card(num_nonprofits_plot, height = "60%"),
        bslib::card(num_nonprofits_table, height = "40%")
      ),
      nav_panel("By Subsector",
                bslib::card_title("Yearly Trends by Subsector"),
                bslib::card(num_nonprofits_subsector_plot, height = "60%"),
                bslib::card(num_nonprofits_subsector_table, height = "40%")),
      nav_panel("By Geography", "By Geography"),
      nav_panel("By Size", "By Size")
    )
  ),
  bslib::nav_menu(
    "Expenses",
    bslib::nav_panel("Overall",
                     fillable = TRUE,
                     bslib::navset_card_tab(
                       title = "Aggregate Expenses",
                       bslib::card_title("Yearly Trends in Aggregate"),
                       bslib::card(num_nonprofits_plot, height = "60%"),
                       bslib::card(num_nonprofits_table, height = "40%")
                     )
    ),
    bslib::nav_panel("Functional Expenses",
                     height = "100%",
                     bslib::navset_card_tab(
                       height = "100%",
                       title = "Functional Expenses",
                       bslib::card_title("Yearly Trends in Aggregate"),
                       bslib::card(num_nonprofits_plot, height = "100%"),
                       bslib::card(num_nonprofits_table, height = "0%")
                     )
    )
  )
)

server <- function(input, output, session) {
  output$table <- renderTable(iris)
}

shinyApp(ui = ui, server = server)