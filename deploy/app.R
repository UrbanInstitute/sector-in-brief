# Script Header
# Description: This script contains deployment code for shiny prototype
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-07-05
# Date Last Edited: 2024-08-05
# Details: Change file paths to dpeloy to shiny

library(shiny)
library(bslib)
library(ggplot2)
library(urbnthemes)
library(plotly)
library(arrow)
library(dplyr)
set_urbn_defaults(style = "print")

# Load cards and filter
source("deploy/assets.R")
# Load helper functions
source("deploy/utils.R")

# Datasets
# List of states mapped to County / CBSA
geo_df <- read.csv("deploy/nested_geographies.csv")
# Default data sets
fiscal_agg <- read.csv("deploy/data/fiscal_aggregate.csv")
efile_agg <- read.csv("deploy/data/efile_aggregate.csv")
pf_agg <- read.csv("deploy/data/pf_aggregate.csv")
labor_agg <- read.csv("deploy/data/labor_aggregate.csv")
# Full Parquet Files
fiscal <- arrow::open_dataset("s3://nccsdata/sector-in-brief/fiscal_metrics.parquet")
labor <- arrow::open_dataset("s3://nccsdata/sector-in-brief/labor_metrics.parquet")
pf <- arrow::open_dataset("s3://nccsdata/sector-in-brief/pf_grants_metrics.parquet")
efile <- arrow::open_dataset("s3://nccsdata/sector-in-brief/efile_daf_metrics.parquet")

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
  theme = sibtheme,
  bslib::nav_spacer(),
  bslib::nav_item(tags$a("NCCS", href = "https://nccs.urban.org")),
  sidebar = sidebar(
    title = "Select Data for Nonprofits by:",
    bslib::accordion(
      bslib::accordion_panel(
        "Organization Type",
        org_filter
      ),
      bslib::accordion_panel(
        "Geography",
        state_filter,
        shiny::conditionalPanel(
          nested_geo_filter,
          condition = "input.state_selector != 'all_states'"
        ),
        shiny::conditionalPanel(
          county_cbsa_filter,
          condition = "input.geo_selector != 'state'"
        )
      ),
      bslib::accordion_panel(
        "Industry Group",
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
    )
  ),
  bslib::navset_tab(
    id = "tabs",
    bslib::nav_panel(
      "Sector Summary",
      bslib::layout_columns(
        cards_sector_size[[1]],
        cards_sector_size[[2]]
      ),
      bslib::layout_columns(
        cards_sector_size[[3]],
        cards_sector_size[[4]]
      ),
    ),
    bslib::nav_panel(
      "Private Foundations",
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
        cards_labor[[1]],
        cards_labor[[2]]
      ),
      bslib::layout_columns(
        cards_labor[[3]]
      )
    ),
    bslib::nav_panel(
      "Donor Advised Funds (DAF)",
      bslib::layout_columns(
        vbs_daf[[1]],
        vbs_daf[[2]],
        vbs_daf[[3]]
      ),
      bslib::layout_columns(
        vbs_daf[[4]],
        vbs_daf[[5]]
      )
    )
  )
 )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
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
    # Process data based on input tab
    if (input$tabs == "Sector Summary") {
      if (all(grepl("all", c(org_type, state, industry_group))) &
          size == 0) {
        data <- fiscal_agg # Default data set for first page
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
            dplyr::select(YEAR, COUNT) |>
            dplyr::collect()
          p <- ggplot(plot_data, aes(x = YEAR, y = COUNT)) +
            geom_line(group = 1,
                      size = 1,
                      color = "#1696d2") +
            geom_point(size = 2) +
            scale_y_continuous(
              expand = expansion(mult = 0.5),
              labels = scales::unit_format(unit = "", scale = 1)
            ) +
            labs(caption = "Source: NCCS Core Data",
                 y = "",
                 x = "Fiscal Year") +
            theme(
              axis.title.x = element_text(size = 14),
              axis.title.y = element_text(size = 14),
              axis.text = element_text(size = 12)
            )
          plotly::ggplotly(p)
        })
        
        output$nprev <- plotly::renderPlotly({
          plot_data <- data |>
            dplyr::filter(YEAR <= 2021) |>
            dplyr::select(YEAR, REVENUES) |>
            dplyr::collect()
          p <- ggplot(plot_data, aes(x = YEAR, y = REVENUES)) +
            geom_line(group = 1,
                      size = 1,
                      color = "#55b748") +
            geom_point(size = 2, color = "#55b748") +
            scale_y_continuous(
              expand = expansion(mult = 0.5),
              labels = scales::unit_format(unit = "m", scale = 1e-6)
            ) +
            labs(caption = "Source: NCCS Core Data",
                 y = "",
                 x = "Tax Year") +
            theme(
              axis.title.x = element_text(size = 14),
              axis.title.y = element_text(size = 14),
              axis.text = element_text(size = 12)
            )
          plotly::ggplotly(p)
        })
        
        output$npexp <- plotly::renderPlotly({
          plot_data <- data |>
            dplyr::filter(YEAR <= 2021) |>
            dplyr::select(YEAR, EXPENSES) |>
            dplyr::collect()
          p <- ggplot(plot_data, aes(x = YEAR, y = EXPENSES)) +
            geom_line(group = 1,
                      size = 1,
                      color = "#fdbf11") +
            geom_point(size = 2, color = "#fdbf11") +
            scale_y_continuous(
              expand = expansion(mult = 0.5),
              labels = scales::unit_format(unit = "m", scale = 1e-6)
            ) +
            labs(caption = "Source: NCCS Core Data",
                 y = "",
                 x = "Tax Year") +
            theme(
              axis.title.x = element_text(size = 14),
              axis.title.y = element_text(size = 14),
              axis.text = element_text(size = 12)
            )
          plotly::ggplotly(p)
        })
        
        output$npass <- plotly::renderPlotly({
          plot_data <- data |>
            dplyr::filter(YEAR <= 2021) |>
            dplyr::select(YEAR, ASSETS) |>
            dplyr::collect()
          p <- ggplot(plot_data, aes(x = YEAR, y = ASSETS)) +
            geom_line(group = 1,
                      size = 1,
                      color = "#ec008b") +
            geom_point(size = 2, color = "#ec008b") +
            scale_y_continuous(
              expand = expansion(mult = 0.5),
              labels = scales::unit_format(unit = "m", scale = 1e-6)
            ) +
            labs(caption = "Source: NCCS Core Data",
                 y = "",
                 x = "Tax Year") +
            theme(
              axis.title.x = element_text(size = 14),
              axis.title.y = element_text(size = 14),
              axis.text = element_text(size = 12)
            )
          plotly::ggplotly(p)
        })
      } else if (input$tabs == "Private Foundations") {
      data <- filter_parquet(pf,
                     org_type,
                     state,
                     industry_group,
                     geo_level,
                     county_cbsa,
                     size,
                     series = "pf")
      output$grantnum <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, NUM_GRANTS) |>
          dplyr::collect()
        p <- ggplot(plot_data, aes(x = YEAR, y = NUM_GRANTS)) +
          geom_line(group = 1,
                    size = 1,
                    color = "#1696d2") +
          geom_point(size = 2) +
          scale_y_continuous(
            expand = expansion(mult = 0.5),
            labels = scales::unit_format(unit = "", scale = 1)
          ) +
          labs(caption = "Source: NCCS Core Data",
               y = "",
               x = "Fiscal Year") +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            axis.text = element_text(size = 12)
          )
        plotly::ggplotly(p)
      })
      
      output$medgrantsize <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, MEDIAN_GRANT_AMT) |>
          dplyr::collect()
        p <- ggplot(plot_data, aes(x = YEAR, y = MEDIAN_GRANT_AMT)) +
          geom_line(group = 1,
                    size = 1,
                    color = "#fdbf11") +
          geom_point(size = 2, color = "#fdbf11") +
          scale_y_continuous(
            expand = expansion(mult = 0.5),
            labels = scales::unit_format(unit = "", scale = 1)
          ) +
          labs(caption = "Source: NCCS Core Data",
               y = "",
               x = "Fiscal Year") +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            axis.text = element_text(size = 12)
          )
        plotly::ggplotly(p)
      })
      
      output$grantamt <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, TOTAL_GRANTS) |>
          dplyr::collect()
        p <- ggplot(plot_data, aes(x = YEAR, y = TOTAL_GRANTS)) +
          geom_line(group = 1,
                    size = 1,
                    color = "#ec008b") +
          geom_point(size = 2, color = "#ec008b") +
          scale_y_continuous(
            expand = expansion(mult = 0.5),
            labels = scales::unit_format(unit = "", scale = 1)
          ) +
          labs(caption = "Source: NCCS Core Data",
               y = "",
               x = "Fiscal Year") +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            axis.text = element_text(size = 12)
          )
        plotly::ggplotly(p)
      })
    } else if (input$tabs == "Donor Advised Funds (DAF)") {
      data <- filter_parquet(efile,
                     org_type,
                     state,
                     industry_group,
                     geo_level,
                     county_cbsa,
                     size,
                     series = "efile")
      output$daf_pct = renderText({
        data %>% dplyr::pull("MEAN_DAF_PROPORTION")
      })
      output$daf_num = renderText({
        data %>% dplyr::pull("TOTAL_NUM_DAFS")
      })
      output$daf_cntrb = renderText({
        data %>% dplyr::pull("TOTAL_CONTRIBUTIONS")
      })
      output$daf_grants = renderText({
        data %>% dplyr::pull("TOTAL_GRANTS")
      })
      output$daf_value = renderText({
        data %>% dplyr::pull("TOTAL_VALUE")
      })
    } else if (input$tabs == "Employment") {
      data <- filter_parquet(labor,
                     org_type,
                     state,
                     industry_group,
                     geo_level,
                     county_cbsa,
                     size,
                     series = "labor")
      output$empnum <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, TOTAL_EMPLOYEES) |>
          dplyr::collect()
        p <- ggplot(plot_data, aes(x = YEAR, y = TOTAL_EMPLOYEES)) +
          geom_line(group = 1,
                    size = 1,
                    color = "#1696d2") +
          geom_point(size = 2) +
          scale_y_continuous(
            expand = expansion(mult = 0.5),
            labels = scales::unit_format(unit = "", scale = 1)
          ) +
          labs(caption = "Source: NCCS Core Data",
               y = "",
               x = "Fiscal Year") +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            axis.text = element_text(size = 12)
          )
        plotly::ggplotly(p)
      })
      
      output$empbenefits <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, TOTAL_BENEFITS) |>
          dplyr::collect()
        p <- ggplot(plot_data, aes(x = YEAR, y = TOTAL_BENEFITS)) +
          geom_line(group = 1,
                    size = 1,
                    color = "#fdbf11") +
          geom_point(size = 2, color = "#fdbf11") +
          scale_y_continuous(
            expand = expansion(mult = 0.5),
            labels = scales::unit_format(unit = "", scale = 1)
          ) +
          labs(caption = "Source: NCCS Core Data",
               y = "",
               x = "Fiscal Year") +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            axis.text = element_text(size = 12)
          )
        plotly::ggplotly(p)
      })
      
      output$emppayroll <- plotly::renderPlotly({
        plot_data <- data |>
          dplyr::select(YEAR, TOTAL_PAYROLL) |>
          dplyr::collect()
        p <- ggplot(plot_data, aes(x = YEAR, y = TOTAL_PAYROLL)) +
          geom_line(group = 1,
                    size = 1,
                    color = "#ec008b") +
          geom_point(size = 2, color = "#ec008b") +
          scale_y_continuous(
            expand = expansion(mult = 0.5),
            labels = scales::unit_format(unit = "", scale = 1)
          ) +
          labs(caption = "Source: NCCS Core Data",
               y = "",
               x = "Fiscal Year") +
          theme(
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            axis.text = element_text(size = 12)
          )
        plotly::ggplotly(p)
      })
      
    }
  })
  # Make Plots
}

# Run the application 
shinyApp(ui = ui, server = server)
