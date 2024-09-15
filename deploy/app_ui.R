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
source("data.R")
source("plots.R")
source("utils.R")
source("R/geo_filter_module.R")
source("frontend.R")
source("backend.R")
source("daf_data.R")

# Load Data
data <- arrow::read_parquet("data/num_nonprofits_full.parquet") |>
  dplyr::rename("Number of Nonprofits" = num_nonprofit)

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
  num_nonprofit_frontend,
  daf_frontend
)

server <- function(input, output, session) {
  # Server modules to update county and cbsa options based on State
  geo_filter_server("nn_geo_filter", geo_df)
  geo_filter_server("daf_geo_filter", geo_df)
  
  # Plot Header
  plot_title_num_nonprofit <- reactive({
    
    if (input$org_level == "Other Nonprofits") {
      title <- paste("Number of", input$other_orgs)
    } else {
      title <- paste("Number of", input$org_level)
    }
    if (input$date_range[1] != input$date_range[2] ) {
      title <- paste(title, ",", input$date_range[1], "-", input$date_range[2])
    } else {
      title <- paste(title, ",", input$date_range[1])
    }
  })
  

  
  
  # Data Wrangling
  shiny::observeEvent(input$process_num_nonprofit_data, {
    plot_subtitle_num_nonprofit <-
      plot_subtitle(
        geo_level = input$geo_level,
        region_selector = input$region_selector,
        state_selector_single = input$state_selector_single,
        state_selector_multi = input$state_selector_multi,
        county_selector = input$county_selector,
        cbsa_selector = input$cbsa_selector,
        subsector_level = input$subsector_level,
        subsector_select = input$subsector_select,
        size_level = input$size_level,
        size_select = input$size_select
      )
    shiny::withProgress(
      min = 1,
      max = 5,
      {
        setProgress(1, message = "Filtering Data...")
        filtered_data <- filter_data(
          data = data,
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
          time_series = TRUE,
          year_start = input$date_range[1],
          year_end = input$date_range[2]
        )
        setProgress(2, message = "Creating Tables...")
        tables <- summarise_data(
          data = filtered_data,
          groupby_var = "Year",
          sum_var = "Number of Nonprofits",
          geo_level = input$geo_level,
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level
        )
        setProgress(3, message = "Creating Graphs...")
        plots <- create_plots(
          table_ls = tables,
          single_plot_func = create_single_line_plot,
          group_plot_func = create_group_line_plot,
          geo_level = input$geo_level,
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level,
          title = plot_title_num_nonprofit(),
          subtitle = plot_subtitle_num_nonprofit
        )
        setProgress(4, message = "Displaying Results...")
        output$num_nonprofit_plot_overall <- renderPlot({
          plots[["default"]]
        })
        output$num_nonprofit_table_overall <- renderReactable({
          reactable(
            tables[["default"]],
            outlined = TRUE,
            defaultPageSize = 10,
            defaultColDef = colDef(align = "left")
          )
        })
        # Stage 5 Displaying Results - By Subsector
        output$num_nonprofit_plot_subsector <- renderPlot({
          plots[["by_subsector"]]
        })
        output$num_nonprofit_table_subsector <- renderReactable({
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
        output$num_nonprofit_plot_geo <- renderPlot({
          plots[["by_geo"]]
        })
        output$num_nonprofit_table_geo <- renderReactable({
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
        output$num_nonprofit_plot_size <- renderPlot({
          plots[["by_asset_size"]]
        })
        # Stage 5 Displaying Results - Asset Size
        output$num_nonprofit_table_size <- renderReactable({
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
  
  shiny::observeEvent(input$process_daf_data, {
    plot_title_daf <- plot_title_daf(input$daf_other_orgs, input$daf_org_level)
    plot_subtitle_daf <-
      plot_subtitle(
        geo_level = input$daf_geo_level,
        region_selector = input$daf_region_selector,
        state_selector_single = input$daf_state_selector_single,
        state_selector_multi = input$daf_state_selector_multi,
        county_selector = input$daf_county_selector,
        cbsa_selector = input$daf_cbsa_selector,
        subsector_level = input$daf_subsector_level,
        subsector_select = input$daf_subsector_select,
        size_level = input$daf_size_level,
        size_select = input$daf_size_select
      )
    shiny::withProgress(
      min = 1,
      max = 5,
      {
        setProgress(1, message = "Filtering Data...")
        filtered_data <- filter_data(
          data = daf_int64,
          org_level = input$daf_org_level,
          other_orgs = input$daf_other_orgs,
          geo_level = input$daf_geo_level,
          region = input$daf_region_selector,
          state_single = input$daf_state_selector_single,
          state_mult = input$daf_state_selector_multi,
          county = input$daf_county_selector,
          cbsa = input$daf_cbsa_selector,
          subsector_level = input$daf_subsector_level,
          subsectors = input$daf_subsector_select,
          asset_size_level = input$daf_size_level,
          asset_sizes = input$daf_size_select,
          time_series = FALSE,
          year_start = NULL,
          year_end = NULL
        )
        filtered_data_daf_num <- filter_data(
          data = daf_int,
          org_level = input$daf_org_level,
          other_orgs = input$daf_other_orgs,
          geo_level = input$daf_geo_level,
          region = input$daf_region_selector,
          state_single = input$daf_state_selector_single,
          state_mult = input$daf_state_selector_multi,
          county = input$daf_county_selector,
          cbsa = input$daf_cbsa_selector,
          subsector_level = input$daf_subsector_level,
          subsectors = input$daf_subsector_select,
          asset_size_level = input$daf_size_level,
          asset_sizes = input$daf_size_select,
          time_series = FALSE,
          year_start = NULL,
          year_end = NULL
        )
        setProgress(2, message = "Creating Tables...")
        tables <- summarise_data(
          data = filtered_data,
          groupby_var = "Metric",
          sum_var = "Value",
          geo_level = input$daf_geo_level,
          subsector_level = input$daf_subsector_level,
          asset_size_level = input$daf_size_level
        )
        tables_daf_num <- summarise_data(
          data = filtered_data_daf_num,
          groupby_var = "Metric",
          sum_var = "Value",
          geo_level = input$daf_geo_level,
          subsector_level = input$daf_subsector_level,
          asset_size_level = input$daf_size_level
        )
        setProgress(3, message = "Creating Graphs...")
        plots <- create_plots(
          table_ls = tables,
          single_plot_func = create_single_facet_bar_plot,
          group_plot_func = create_group_facet_bar_plot,
          geo_level = input$daf_geo_level,
          subsector_level = input$daf_subsector_level,
          asset_size_level = input$daf_size_level,
          title = plot_title_daf,
          subtitle = plot_subtitle_daf
        )
        plots_daf_num <- create_plots(
          table_ls = tables_daf_num,
          single_plot_func = create_single_facet_bar_plot_int,
          group_plot_func = daf_num_plot,
          geo_level = input$daf_geo_level,
          subsector_level = input$daf_subsector_level,
          asset_size_level = input$daf_size_level,
          title = plot_title_daf,
          subtitle = plot_subtitle_daf
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
        output$plot_overall_num_daf <- renderPlot({
          plots_daf_num[["default"]]
        })
        # Stage 5 Displaying Results - By Subsector
        output$daf_plot_subsector <- renderPlot({
          plots[["by_subsector"]]
        })
        output$daf_table_subsector <- renderReactable({
          if (input$daf_subsector_level == "individual") {
            reactable(
              tables[["by_subsector"]],
              groupBy = "Subsector",
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        output$plot_subsector_num_daf <- renderPlot({
          plots_daf_num[["by_subsector"]]
        })
        # Stage 5 Displaying Results - Geography
        output$daf_plot_geo <- renderPlot({
          plots[["by_geo"]]
        })
        output$daf_table_geo <- renderReactable({
          if (input$daf_geo_level != "all") {
            reactable(
              tables[["by_geo"]],
              groupBy = var_rename_ls[[input$daf_geo_level]],
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          } 
        })
        output$plot_geo_num_daf <- renderPlot({
          plots_daf_num[["by_geo"]]
        })
        output$daf_plot_size <- renderPlot({
          plots[["by_asset_size"]]
        })
        # Stage 5 Displaying Results - Asset Size
        output$daf_table_size <- renderReactable({
          if (input$daf_size_level == "individual") {
            reactable(
              tables[["by_asset_size"]],
              groupBy = "Asset Size",
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        output$plot_size_num_daf <- renderPlot({
          plots_daf_num[["by_asset_size"]]
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
