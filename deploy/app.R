########################
# Programmer: Thiyaghessan tpoongundranar@urban.org
# Date created: 2024-09-04
# Date of last revision: 2024-09-09
# Description: This script contains the user interface for the sector in brief
########################

# Load packages
library(bslib)
library(shiny)
library(tidyverse)
library(plotly)
library(ggplot2)
library(urbnthemes)
library(reactable)

asset_size_ls <- list(
  "1" = "Under $100,000",
  "2" = "$100,000 - $499,999",
  "3" = "$500,000 - $999,999",
  "4" = "$1 Million - $4.99 Million",
  "5" = "$5 Million - $9.99 Million",
  "6" = "Above $10 Million"
)

# Load assets
source("executive_summary.R")
source("assets/assets.R")
source("assets/choices.R")
source("utils.R")
source("R/org_filters.R")
source("R/geo_filter_module.R")
source("R/plot_ui.R")
source("R/data.R")
source("R/create_plot_title.R")
source("R/data_server.R")
source("R/data_ui.R")

# Theme
# Shiny Theme
sibtheme <- bslib::bs_theme(
  bg = "#ffffff", 
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

# Datasets
geo_df <- read_csv("data/nested_geographies.csv")
#num_nonprofits <- arrow::read_csv("data/num_nonprofits.csv")

# User Interface
ui <- bslib::page_navbar(
  title = "Nonprofit Sector In Brief",
  id = "tabs",
  fillable = FALSE,
  bg = "#a2d4ec",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css"),
    tags$style(
      HTML(
        "
        .pageheader {
          font-size: 2em;
          color: black;
          text-decoration: underline;
          text-underline-offset: 8px;
          text-align: center;
        }
        h3 {
          font-size: 1.5em;
          color: black;
          text-align: center;
        }
        p {
          font-size: 1em;
          color: black;
          text-align: left;
          margin-left: 0px;
          margin:0;
        }
        .tableheader {
          font-family: 'Lato';
          font-size: 1.3em;
          font-weight: bold;
          color: black;
          text-align: left;
          padding-top: 20px;
        }
        .btn-download {
        color: #ffffff;
        background-color: #1696d2;
        border-color: #1696d2;
        font-size: 18px;
        font-family: 'Lato';
        border-radius: 0;
        margin: auto;
        }
        .btn-download:hover {
        color: #ffffff;
        background-color: #46abdb;
        border-color: #46abdb;
        }
        "
      )
    )
  ),
  exec_summary,
  bslib::nav_panel(
    title = "Number",
    div(
      br(),
      h2("Total number of nonprofits", class = "pageheader"),
      br(),
      h3("The number of organizations that are registered with the Internal Revenue Service (IRS)."),
      br()
    ),
    data_ui("nn_data", org_type_choices, date = TRUE),
    plot_ui("nn_data")
  ),
  bslib::nav_panel(
    title = "Donor Advised Funds",
    div(
      br(),
      h2("Donor Advised Funds", class = "pageheader"),
      br(),
      h3("A donor advised fund (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time."),
      br()
    ),
    bslib::navset_pill(
      bslib::nav_panel(
        "Total Contributions",
        data_ui("daf_contributions", org_type_choices, date = FALSE),
        plot_ui("daf_contributions")
      ),
      bslib::nav_panel(
        "Total Grants",
        data_ui("daf_grants", org_type_choices, date = FALSE),
        plot_ui("daf_grants")
      ),
      bslib::nav_panel(
        "Total Value",
        data_ui("daf_value", org_type_choices, date = FALSE),
        plot_ui("daf_value")
      ),
      bslib::nav_panel(
        "Number of DAFs",
        data_ui("daf_num", org_type_choices, date = FALSE),
        plot_ui("daf_num")
      ),
      bslib::nav_panel(
        "DAF Proprotion",
        data_ui("daf_proportion", org_type_choices, date = FALSE),
        plot_ui("daf_proportion")
      )
      
    )
    
  )
)

server <- function(input, output, session) {
  # Server modules to update county and cbsa options based on State
  # Data Wrangling
  data_server("nn_data", geo_df, num_nonprofit_data, "Year", "Number of Nonprofits", create_single_line_plot, create_group_line_plot)
  data_server("daf_contributions", geo_df, daf_contributions, "Year", "Total Contributions", create_single_col_plot, create_group_col_plot, FALSE)
  data_server("daf_num", geo_df, daf_number, "Year", "Number of DAFs", create_single_col_plot, create_group_col_plot, FALSE)
  data_server("daf_proportion", geo_df, daf_proportion, "Year", "DAF Proportion", create_single_col_plot, create_group_col_plot, FALSE)
  data_server("daf_value", geo_df, daf_value, "Year", "Total Value", create_single_col_plot, create_group_col_plot, FALSE)
  data_server("daf_grants", geo_df, daf_grants, "Year", "Total Grants", create_single_col_plot, create_group_col_plot, FALSE)
  
  
  output$downloadData <- downloadHandler(
    filename = "nonprofit.csv",
    content = function(file) {
      write.csv(tables[["default"]], file)
    }
  )
}

shinyApp(ui = ui, server = server)
