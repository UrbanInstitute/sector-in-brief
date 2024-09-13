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

# Load assets
source("executive_summary.R")
source("assets/assets.R")
source("assets/choices.R")
source("data.R")
source("plots.R")
source("utils.R")
source("frontend.R")

asset_size_ls <- list(
  "1" = "Under $100,000",
  "2" = "$100,000 - $499,999",
  "3" = "$500,000 - $999,999",
  "4" = "$1 Million - $4.99 Million",
  "5" = "$5 Million - $9.99 Million",
  "6" = "Above $10 Million"
)

# Load Data
data <- arrow::read_parquet("data/num_nonprofits_full.parquet")

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
  bg = "#1696d2",
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
  daf_frontend
)

server <- function(input, output, session) {
  # Updating filter inputs
  observeEvent(input$state_selector_single, {
    updateSelectizeInput(session, 
                         "county_selector",
                         choices = geo_df$CENSUS_COUNTY_NAME[geo_df$CENSUS_STATE_ABBR == input$state_selector_single],
                         server = TRUE)
    updateSelectizeInput(session, 
                         "cbsa_selector",
                         choices = geo_df$CENSUS_CBSA_NAME[geo_df$CENSUS_STATE_ABBR == input$state_selector_single],
                         server = TRUE)
    
  })
  # Plot Header
  plot_title <- reactive({
    
    if (input$org_level == "Other Nonprofits") {
      title <- paste("Donor Advised Funds In", input$other_orgs)
    } else {
      title <- paste("Donor Advised Funds In", input$org_level)
    }
  })
  
  plot_subtitle <- reactive({
    subtitle <- ""
    if (input$geo_level == "census_region"){
      subtitle <- paste("Region(s):", paste(input$region_selector, collapse = ", "), "\n")
    }
    else if (input$geo_level == "CENSUS_STATE_ABBR"){
      subtitle <- paste("State(s):", paste(input$state_selector_multi, collapse = ", "), "\n")
    }
    else if (input$geo_level == "CENSUS_COUNTY_NAME"){
      subtitle <- paste("State:", input$state_selector_single, "\n",
                        "County(s):", paste(input$county_selector, collapse = ", "), "\n")
    }
    else if (input$geo_level == "CENSUS_CBSA_NAME"){
      subtitle <- paste("State:", input$state_selector_single, "\n",
                        "Metro/Micro Area(s):", paste(input$cbsa_selector, collapse = ", "), "\n")
    }
    
    if (input$subsector_level == "individual"){
      subtitle <- paste(subtitle, "Subsector(s):", paste(input$subsector_select, collapse = ", "), "\n")
    }
    if (input$size_level == "individual"){
      sizes <- unlist(purrr::map(input$size_select, .f = function(x){asset_size_ls[[x]]}))
      subtitle <- paste(subtitle, "Asset Size(s):", paste(sizes, collapse = ", "), "\n")
    }
    print(subtitle)
  })
  # Data Wrangling
  shiny::observeEvent(input$process_daf_data, {
    shiny::withProgress(
      min = 1,
      max = 5,
      {
        setProgress(1, message = "Filtering Data...")
        filtered_data <- filter_data(
          data = daf_int64,
          org_level = input$org_level,
          other_orgs = input$other_orgs,
          geo_level = input$geo_level,
          region = input$region_selector,
          state_single = input$state_selector_single,
          state_mult = input$state_selector_multi,
          county = input$county_selector,
          cbsa = input$cbsa_selector,
          subsector_level = input$subsector_level,
          subsectors = input$subsector_select,
          asset_size_level = input$size_level,
          asset_sizes = input$size_select,
          time_series = FALSE,
          year_start = NULL,
          year_end = NULL
        )
        setProgress(2, message = "Creating Tables...")
        tables <- summarise_data(
          data = filtered_data,
          groupby_var = "Metric",
          sum_var = "Value",
          geo_level = input$geo_level,
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level
        )
        setProgress(3, message = "Creating Graphs...")
        plots <- create_plots(
          table_ls = tables,
          single_plot_func = create_single_facet_bar_plot,
          group_plot_func = create_group_facet_bar_plot,
          geo_level = input$geo_level,
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level,
          title = plot_title(),
          subtitle = plot_subtitle()
        )
        setProgress(4, message = "Displaying Results...")
        output$daf_plot_overall <- renderPlot({
          plots[["default"]]
        })
        output$daf_table_overall <- renderReactable({
          reactable(
            tables[["default"]],
            outlined = TRUE,
            defaultPageSize = 10,
            defaultColDef = colDef(align = "left")
          )
        })
        # Stage 5 Displaying Results - By Subsector
        output$daf_plot_subsector <- renderPlot({
          plots[["by_subsector"]]
        })
        output$daf_table_subsector <- renderReactable({
          if (input$subsector_level == "individual") {
            reactable(
              tables[["by_subsector"]],
              groupBy = "Subsector",
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        # Stage 5 Displaying Results - Geography
        output$daf_plot_geo <- renderPlot({
          plots[["by_geo"]]
        })
        output$daf_table_geo <- renderReactable({
          if (input$geo_level != "all") {
            reactable(
              tables[["by_geo"]],
              groupBy = var_rename_ls[[input$geo_level]],
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          } 
        })
        output$daf_plot_size <- renderPlot({
          plots[["by_asset_size"]]
        })
        # Stage 5 Displaying Results - Asset Size
        output$daf_table_size <- renderReactable({
          if (input$size_level == "individual") {
            reactable(
              tables[["by_asset_size"]],
              groupBy = "Asset Size",
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        setProgress(5, message = "Done!")
      }
      
    )
  })
  
  output$downloadData <- downloadHandler(
    filename = "nonprofit.csv",
    content = function(file) {
      write.csv(tables[["default"]], file)
    }
  )
}

shinyApp(ui = ui, server = server)
