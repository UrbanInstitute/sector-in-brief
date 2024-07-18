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
set_urbn_defaults(style = "print")
library(plotly)

# Scripts
source("R/config.R")

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
num_nonprofits_by_year <- data.table::fread(
  "data/num_nonprofits_by_year.csv"
)
num_nonprofits_dt <- data.table::fread(
  "data/num_nonprofits_full.csv"
)

geo_dt <- data.table::fread(
  "data/nested_geographies.csv"
)

fiscal_full_dt <- data.table::fread(
  "data/full_fiscal_metrics.csv"
)

# Cards
cards_sector_size <- list(
  card(
    full_screen = TRUE,
    card_header("Number of Nonprofits"),
    plotOutput("npnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Revenues ($)"),
    plotOutput("nprev")
  ),
  card(
    full_screen = TRUE,
    card_header("Expenses ($)"),
    plotOutput("npexp")
  ),
  card(
    full_screen = TRUE,
    card_header("Assets ($)"),
    plotOutput("npass")
  )  
)

# Filters
org_filter <- selectizeInput(
  "org_type_selector",
  NULL,
  choices = org_ls,
  options = list(
    placeholder = 'Select a 501(c) type...',
    onInitialize = I('function() { this.setValue(""); }')
  )
)

state_filter <- div(selectizeInput(
  "state_selector",
  NULL,
  choices = state_ls,
  selected = state_ls$`All States`
))

nested_geo_filter <- div(
  shiny::radioButtons(
    "geo_selector",
    label = "Select Additional Geographic Units",
    choices = list(
      "Counties" = "county",
      "Metro / Micro Areas" = "cbsa",
      "Entire State" = "state"
    )
  )
)

county_cbsa_filter <- div(
  selectizeInput(
    "county_cbsa_selector", 
    NULL, 
    choices = NULL
  )
)

industry_group_filter <- div(selectizeInput(
  "industry_group_selector",
  NULL,
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
  options = list(
    placeholder = "Select an industry...",
    onInitialize = I('function() { this.setValue(""); }')
  )
))

size_filter <- div(selectizeInput(
  "size_selector",
  label = "Size of Assets",
  choices = list(
    "All Sizes" = 0, 
    "Under $100,000" = 1,
    "$100,000 - $499,999" = 2,
    "$500,000 - $999,999" = 3,
    "$1 Million - $4.99 Million" = 4,
    "$5 Million - $9.99 Million" = 5,
    "Above $10 Million" = 6
  ),
  options = list(
    placeholder = "Select an asset size...",
    onInitialize = I('function() { this.setValue(""); }')
  )
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
        "State",
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
        "Industry Groups",
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
    # Update Data
    org_type <- input$org_type_selector
    state <- input$state_selector
    industry_group <- input$industry_group_selector
    geo_level <- input$geo_selector
    county_cbsa <- input$county_cbsa_selector
    size <- input$size_selector
    dt <- fiscal_full_dt
    if (!grepl("all", org_type) & org_type != "") {
      dt <- dt[CTYPE == org_type, ]
    }
    if (!grepl("all", state) & state != "") {
      dt <- dt[CENSUS_STATE_ABBR == state, ]
      if (geo_level == "county"){
        dt <- dt[CENSUS_COUNTY_NAME == county_cbsa,]
      } else if (geo_level == "cbsa") {
        dt <- dt[CENSUS_CBSA_NAME == county_cbsa,]
      }
    }
    if (!grepl("all", industry_group) & industry_group != "") {
      dt <- dt[NTEE_INDUSTRY_GROUP == industry_group, ]
    }
    if (size  > 0){
      dt <- dt[SIZE == size,]
    }
    dt <- dt[, .(COUNT = sum(num_nonprofit),
                 ASSETS = sum(total_assets, na.rm = TRUE),
                 REVENUES = sum(total_revenues, na.rm = TRUE),
                 EXPENSES = sum(total_expenses, na.rm = TRUE)), 
             by = "YEAR"]
    return(dt)
  }
  )
  # Make Plots
  output$npnum <- renderPlot({
    shiny::req(data())
    ggplot(data(), aes(x= YEAR, y= COUNT)) +
      geom_line(group = 1, size=2, color="#1696d2") +
      geom_point(size=5) +
      ggplot2::xlim(1989, 2024) +
      scale_y_continuous(
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
  })
  
  output$nprev <- renderPlot({
    shiny::req(data())
    ggplot(data(), aes(x= YEAR, y= REVENUES)) +
      ggplot2::xlim(1989, 2021) +
      geom_line(group = 1, size=2, color="#55b748") +
      geom_point(size=5, color="#55b748") +
      scale_y_continuous(
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
  })
  
  output$npexp <- renderPlot({
    shiny::req(data())
    ggplot(data(), aes(x= YEAR, y= EXPENSES)) +    
    geom_line(group = 1, size=2, color="#fdbf11") +
      geom_point(size=5, color = "#fdbf11") +
      ggplot2::xlim(1989, 2021) +
      scale_y_continuous(
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
  })
  
  output$npass <- renderPlot({
    shiny::req(data())
    ggplot(data(), aes(x= YEAR, y= ASSETS)) +
      geom_line(group = 1, size=2, color = "#ec008b") +
      geom_point(size=5, color = "#ec008b") +
      ggplot2::xlim(1989, 2021) +
      scale_y_continuous(
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
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
