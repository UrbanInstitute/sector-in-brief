#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)
library(ggplot2)
library(urbnthemes)
library(plotly)
library(dplyr)
library(arrow)
library(data.table)
set_urbn_defaults(style = "print")

# Scripts
source("R/config.R")
source("R/utils.R")

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

# Data Sets
geo_dt <- data.table::fread(
  "data/nested_geographies.csv"
)

fiscal <- arrow::read_parquet("data/full_fiscal_metrics.parquet")

# Cards
cards_sector_size <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Nonprofits"),
    plotly::plotlyOutput("npnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Revenues ($)"),
    plotly::plotlyOutput("nprev")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Expenses ($)"),
    plotly::plotlyOutput("npexp")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Assets ($)"),
    plotly::plotlyOutput("npass")
  )  
)

# Filters
org_filter <- selectizeInput(
  "org_type_selector",
  label = "Select a 501(c) type",
  choices = org_ls,
  selected = org_ls$`All Organizations`
)

state_filter <- div(selectizeInput(
  "state_selector",
  label = "Select a State",
  choices = state_ls,
  selected = state_ls$`All States`
))

nested_geo_filter <- div(
  shiny::radioButtons(
    "geo_selector",
    label = "Additional Geographic Units",
    choices = list(
      "Counties" = "county",
      "Metro / Micro Areas" = "cbsa",
      "Entire State" = "state"
    ),
    selected = "state"
  )
)

county_cbsa_filter <- div(
  selectizeInput(
    "county_cbsa_selector", 
    label = "Select County/Metro", 
    choices = NULL
  )
)

industry_group_filter <- div(selectizeInput(
  "industry_group_selector",
  label = "Select an Industry",
  choices = list(
    "Arts, Culture, and Humanities" = "ART", 
    "Education (minus Universities)" = "EDU",
    "Health (minus Hospitals)" = "HEL",
    "Human Services" = "HMS",
    "International, Foreign Affairs" = "IFA",
    "Public, Societal Benefit" = "PSB",
    "Religion Related" = "REL",
    "Mutual/Membership Benefit" = "MMB",
    "Universities" = "UNI",
    "Hospitals" = "HOS",
    "All Groups" = "all_groups"
  ),
  selected = "all_groups"
))

size_filter <- div(selectizeInput(
  "size_selector",
  label = "Select an Asset Size",
  choices = list(
    "All Sizes" = 0, 
    "Under $100,000" = 1,
    "$100,000 - $499,999" = 2,
    "$500,000 - $999,999" = 3,
    "$1 Million - $4.99 Million" = 4,
    "$5 Million - $9.99 Million" = 5,
    "Above $10 Million" = 6
  ),
  selected = 0
))

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
  )
 )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  geo_filters <- shiny::reactive({
    list(input$geo_selector, 
         input$state_selector)
  }
  )
  
  observeEvent(
    geo_filters(),
    {
      counties <- geo_dt[CENSUS_STATE_ABBR == input$state_selector, "CENSUS_COUNTY_NAME"][[1]]
      cbsa <- unique(geo_dt[CENSUS_STATE_ABBR == input$state_selector, "CENSUS_CBSA_NAME"][[1]])
      if (input$geo_selector == "county"){
        updateSelectizeInput(session, "county_cbsa_selector", choices = counties, server = TRUE)
      } else if (input$geo_selector == "cbsa"){
        updateSelectizeInput(session, "county_cbsa_selector", choices = cbsa, server = TRUE)
      }
    }
  )
  
  data <- shiny::eventReactive(input$update_plot, ignoreNULL = FALSE, {
    # Get Inputs
    org_type <- input$org_type_selector
    state <- input$state_selector
    industry_group <- input$industry_group_selector
    geo_level <- input$geo_selector
    county_cbsa <- input$county_cbsa_selector
    size <- input$size_selector
    # Filter data set
    filter_parquet(
      fiscal,
      org_type,
      state,
      industry_group,
      geo_level,
      county_cbsa,
      size
    )
  })
  # Make Plots
  output$npnum <- plotly::renderPlotly({
    plot_data <- data() %>% 
      dplyr::filter(YEAR >= 1995) %>% 
      dplyr::select(YEAR, COUNT) %>% 
      dplyr::collect()
    p <- ggplot(plot_data, 
                aes(x= YEAR, y= COUNT)) +
      geom_line(group = 1, size=1, color="#1696d2") +
      geom_point(size=2) +
      scale_y_continuous(
        expand = expansion(mult = 0.5),
        labels = scales::unit_format(unit = "thousand", scale=1e-3)
      ) +
      labs(
        caption = "Source: NCCS Core Data",
        y = "",
        x = "Fiscal Year"
      ) +
      theme(
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size=12)
      )
    plotly::ggplotly(p)
  })
  
  output$nprev <- plotly::renderPlotly({
    plot_data <- data() %>% 
      dplyr::filter(YEAR <= 2021) %>% 
      dplyr::select(YEAR, REVENUES) %>% 
      dplyr::collect()
    p <- ggplot(plot_data, 
                aes(x= YEAR, y= REVENUES)) +
      geom_line(group = 1, size=1, color="#55b748") +
      geom_point(size=2, color="#55b748") +
      scale_y_continuous(
        expand = expansion(mult = 0.5),
        labels = scales::unit_format(unit = "m", scale=1e-6)
      ) +
      labs(
        caption = "Source: NCCS Core Data",
        y = "",
        x = "Tax Year"
      ) +
      theme(
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size=12)
      )
    plotly::ggplotly(p)
  })
  
  output$npexp <- plotly::renderPlotly({
    plot_data <- data() %>% 
      dplyr::filter(YEAR <= 2021) %>% 
      dplyr::select(YEAR, EXPENSES) %>% 
      dplyr::collect()
    p <- ggplot(plot_data, 
                aes(x= YEAR, y= EXPENSES)) +    
    geom_line(group = 1, size=1, color="#fdbf11") +
      geom_point(size=2, color = "#fdbf11") +
      scale_y_continuous(
        expand = expansion(mult = 0.5),
        labels = scales::unit_format(unit = "m", scale=1e-6)
      ) +
      labs(
        caption = "Source: NCCS Core Data",
        y = "",
        x = "Tax Year"
      ) +
      theme(
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size=12)
      )
    plotly::ggplotly(p)
  })
  
  output$npass <- plotly::renderPlotly({
    plot_data <- data() %>% 
      dplyr::filter(YEAR <= 2021) %>% 
      dplyr::select(YEAR, ASSETS) %>% 
      dplyr::collect()
    p <- ggplot(plot_data,
                aes(x= YEAR, y= ASSETS)) +
      geom_line(group = 1, size=1, color = "#ec008b") +
      geom_point(size=2, color = "#ec008b") +
      scale_y_continuous(
        expand = expansion(mult = 0.5),
        labels = scales::unit_format(unit = "m", scale=1e-6)
      ) +
      labs(
        caption = "Source: NCCS Core Data",
        y = "",
        x = "Tax Year"
      ) +
      theme(
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size=12)
      )
    plotly::ggplotly(p)
  })
}

# Run the application 
app <- shinyApp(ui = ui, server = server)
profvis({
  runApp(shinyApp(ui = ui, server = server))
})
