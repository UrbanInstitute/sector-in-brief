# Script Header
# Description: This script contains deployment code for shiny prototype
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-07-05
# Date Last Edited: 2024-08-19
# Details: Change file paths to dpeloy to shiny
library(shiny)
library(bslib)
library(ggplot2)
library(urbnthemes)
library(plotly)
library(arrow)
library(dplyr)
set_urbn_defaults(style = "print")

# Load assets
source("assets/assets.R")
source("assets/sidebar.R")
source("assets/home.R")
source("assets/about.R")
source("assets/methodology.R")
# Load helper functions
source("utils.R")

# Datasets
# List of states mapped to County / CBSA
geo_df <- read.csv("data/nested_geographies.csv")
# Default data sets
fiscal_agg <- read.csv("data/fiscal_metrics_agg.csv") |> 
  rename_all(list(~ gsub("\\.", " ", .))) 
efile_agg <- read.csv("data/efile_daf_agg.csv") |> 
  rename_all(list(~ gsub("\\.", " ", .)))
pf_agg <- read.csv("data/pf_grants_agg.csv") |> 
  rename_all(list(~ gsub("\\.", " ", .)))
labor_agg <- read.csv("data/labor_metrics_agg.csv") |> 
  rename_all(list(~ gsub("\\.", " ", .)))
# Full Parquet Files s3://nccsdata/sector-in-brief
fiscal <- arrow::read_parquet("data/fiscal_metrics.parquet")
labor <- arrow::read_parquet("data/labor_metrics.parquet")
pf <- arrow::read_parquet("data/pf_grants_metrics.parquet")
efile <- arrow::read_parquet("data/efile_daf_metrics.parquet")

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

# UI for sector in brief dashboard
ui <- bslib::page_navbar(
  title = "Nonprofit Sector In Brief",
  id = "tabs",
  theme = sibtheme,
  sidebar = sidebar,
  bslib::nav_spacer(),
  page_home,
  bslib::nav_menu(
    title = "Explore Data",
    bslib::nav_panel(
      "Sector Summary",
      bslib::layout_columns(
        vbs_general_ss
      ),
      bslib::layout_column_wrap(
        width = 1/2,
        cards_sector_size[[1]],
        cards_sector_size[[2]],
        cards_sector_size[[3]],
        cards_sector_size[[4]]
      ),
    ),
    bslib::nav_panel(
      "Private Foundations",
      bslib::layout_columns(
        vbs_general_pf
      ),
      bslib::layout_columns(
        cards_private_foundation[[1]],
        cards_private_foundation[[2]]
      ),
      bslib::layout_columns(
        cards_private_foundation[[3]]
      )
    ),
    bslib::nav_panel(
      "Employment",
      bslib::layout_columns(
        vbs_general_emp
      ),
      bslib::layout_columns(
        cards_labor[[2]]
      ),
      bslib::layout_columns(
        cards_labor[[3]]
      )
    ),
    bslib::nav_panel(
      "Donor Advised Funds (DAF)",
      bslib::layout_columns(
        vbs_general_daf
      ),
      bslib::layout_column_wrap(
        width = 1/2,
        vbs_daf[[1]],
        vbs_daf[[2]],
        vbs_daf[[3]],
        vbs_daf[[4]],
        vbs_daf[[5]],
        vbs_daf[[6]],
        vbs_daf[[7]],
        vbs_daf[[8]],
        vbs_daf[[9]],
        vbs_daf[[10]]
      )
    )
  ),
  page_about,
  page_methodology,
  bslib::nav_item(tags$a("NCCS Website", href = "https://nccs.urban.org")),
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Toggle Side Bar
  observe({
    toggle_sidebar(
      id = "sidebar",
      open = input$tabs %in% c(
        "Sector Summary",
        "Private Foundations",
        "Employment",
        "Donor Advised Funds (DAF)"
      )
    )
  })
  
  # Home page buttons
  observeEvent(input$to_sector, {
    updateTabsetPanel(session, inputId = "tabs", "Sector Summary")
  })
  observeEvent(input$to_pf, {
    updateTabsetPanel(session, inputId = "tabs", "Private Foundations")
  })
  observeEvent(input$to_emp, {
    updateTabsetPanel(session, inputId = "tabs", "Employment")
  })
  observeEvent(input$to_daf, {
    updateTabsetPanel(session, inputId = "tabs", "Donor Advised Funds (DAF)")
  })
  
  
  # Geographic Inputs by user
  geo_filters <- shiny::reactive({
    list(input$geo_selector, 
         input$state_selector)
  }
  )
  # Change filters in response to user queries
  observeEvent(
    geo_filters(),
    {
      state_df <- geo_df |> 
        dplyr::filter(CENSUS_STATE_ABBR == input$state_selector)
      counties <- state_df$CENSUS_COUNTY_NAME
      cbsa <- state_df$CENSUS_CBSA_NAME
      if (input$geo_selector == "county"){
        updateSelectizeInput(session, "county_cbsa_selector", choices = counties, server = TRUE)
      } else if (input$geo_selector == "cbsa"){
        updateSelectizeInput(session, "county_cbsa_selector", choices = cbsa, server = TRUE)
      }
    }
  )
  # Update plot base on button click
  shiny::observeEvent(input$update_plot, ignoreNULL = FALSE, {
    # Get Inputs
    org_type <- input$org_type_selector
    state <- input$state_selector
    industry_group <- input$industry_group_selector
    geo_level <- input$geo_selector
    county_cbsa <- input$county_cbsa_selector
    size <- input$size_selector
    statement <- create_header_statement(org_type, state, industry_group, geo_level, county_cbsa, size)
    # Process data based on input tab
    if (input$tabs == "Sector Summary") {
      output$general_ss <- renderText({
        statement
      })
      if (all(grepl("all", c(org_type, state, industry_group))) &
          size == 0) {
        data <- fiscal_agg
        # Default data set for first page
      } else {
        data <- filter_parquet(fiscal,
                               org_type,
                               state,
                               industry_group,
                               geo_level,
                               county_cbsa,
                               size,
                               series = "fiscal")
      }
      output$npnum <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::filter(YEAR >= 1995) |>
          dplyr::select(YEAR, `Number of Nonprofits`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Number of Nonprofits",
          color = "#1696d2",
          scale_unit = "",
          scale_factor = 1,
          xlab = "Filing Year"
        )
        plotly::ggplotly(p)
      })
      
      output$nprev <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::filter(YEAR <= 2021) |>
          dplyr::select(YEAR, `Total Revenues`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Total Revenues",
          color = "#55b748",
          scale_unit = "m",
          scale_factor = 1e-6,
          xlab = "Tax Year"
        )
        plotly::ggplotly(p)
      })
      
      output$npexp <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::filter(YEAR <= 2021) |>
          dplyr::select(YEAR, `Total Expenses`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Total Expenses",
          color = "#fdbf11",
          scale_unit = "m",
          scale_factor = 1e-6,
          xlab = "Tax Year"
        )
        plotly::ggplotly(p)
      })
      
      output$npass <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::filter(YEAR <= 2021) |>
          dplyr::select(YEAR, `Total Assets`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Total Assets",
          color = "#ec008b",
          scale_unit = "m",
          scale_factor = 1e-6,
          xlab = "Tax Year"
        )
        plotly::ggplotly(p)
      })
    } else if (input$tabs == "Private Foundations") {
      output$general_pf <- renderText({
        statement
      })
      if (all(grepl("all", c(org_type, state, industry_group))) &
          size == 0) {
        data <- pf_agg |>
          dplyr::filter(! YEAR %in% c(1987:1988, 2022))
        # Default data set for first page
      } else {
        data <- filter_parquet(pf,
                               org_type,
                               state,
                               industry_group,
                               geo_level,
                               county_cbsa,
                               size,
                               series = "pf") |>
          dplyr::filter(! YEAR %in% c(1987:1988, 2022))
      }
      output$grantnum <- shiny::renderPlot({
        plot_data <- data |>
          dplyr::select(YEAR, `Number of Grants`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Number of Grants",
          color = "#1696d2",
          scale_unit = "",
          scale_factor = 1,
          xlab = "Tax Year",
          missing_data = TRUE
        )
        p
      })
      
      output$medgrantsize <- shiny::renderPlot({
        plot_data <- data |>
          dplyr::select(YEAR, `Median Grant Amount`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Median Grant Amount",
          color = "#fdbf11",
          scale_unit = "",
          scale_factor = 1,
          xlab = "Tax Year",
          missing_data = TRUE
        )
        p
      })
      
      output$grantamt <- shiny::renderPlot({
        plot_data <- data |>
          dplyr::select(YEAR, `Total Grants`) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Total Grants",
          color = "#ec008b",
          scale_unit = "",
          scale_factor = 1,
          xlab = "Tax Year",
          missing_data = TRUE
        )
        p
      })
    } else if (input$tabs == "Donor Advised Funds (DAF)") {
      output$general_daf <- renderText({
        statement
      })
      data <- filter_parquet(efile,
                             org_type,
                             state,
                             industry_group,
                             geo_level,
                             county_cbsa,
                             size,
                             series = "efile")
      output$daf_pct = renderText({
        data %>% 
          dplyr::pull("MEAN_DAF_PROPORTION") %>% 
          scales::percent(scale = 1e3)
      })
      output$daf_num = renderText({
        data %>% dplyr::pull("TOTAL_NUM_DAFS") %>% 
          scales::comma()
      })
      output$daf_cntrb = renderText({
        data %>% dplyr::pull("TOTAL_CONTRIBUTIONS") %>% 
          scales::dollar(scale = 1)
      })
      output$daf_grants = renderText({
        data %>% dplyr::pull("TOTAL_GRANTS") %>% 
          scales::dollar(scale = 1)
      })
      output$daf_value = renderText({
        data %>% dplyr::pull("TOTAL_VALUE") %>% 
          scales::dollar(scale = 1)
      })
    } else if (input$tabs == "Employment") {
      output$general_emp <- renderText({
        statement
      })
      data <- filter_parquet(labor,
                     org_type,
                     state,
                     industry_group,
                     geo_level,
                     county_cbsa,
                     size,
                     series = "labor") |>
        dplyr::filter(YEAR < 2022)
      output$empbenefits <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, `Total Benefits`) |>
          dplyr::filter(YEAR >= 2000) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Total Benefits",
          color = "#fdbf11",
          scale_unit = "",
          scale_factor = 1,
          xlab = "Tax Year",
          missing_data = FALSE
        )
        plotly::ggplotly(p)
      })
      
      output$emppayroll <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, `Total Payroll Taxes`) |>
          dplyr::filter(YEAR >= 2000) |>
          dplyr::collect()
        p <- create_line_graph(
          data = plot_data,
          xvar = "YEAR",
          yvar = "Total Payroll Taxes",
          color = "#ec008b",
          scale_unit = "",
          scale_factor = 1,
          xlab = "Tax Year",
          missing_data = FALSE
        )
        plotly::ggplotly(p)
      })
      
    }
  })
  # Make Plots
}

# Run the application 
shinyApp(ui = ui, server = server)

