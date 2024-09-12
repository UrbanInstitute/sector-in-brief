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
source("ui_data.R")
source("utils.R")

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
  version = 5,
  preset = NULL
)

# Datasets
geo_df <- read_csv("data/nested_geographies.csv")
#num_nonprofits <- arrow::read_csv("data/num_nonprofits.csv")

# User Interface
ui <- bslib::page_navbar(
  title = "Nonprofit Sector In Brief",
  id = "tabs",
  theme = sibtheme,
  fillable = FALSE,
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css"),
    tags$style(
      HTML(
        "
        h2 {
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
          margin-left: 100px;
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
  div(
    br(),
    h2("Total number of nonprofits"),
    br(),
    h3("The number of organizations that are registered with the Internal Revenue Service (IRS)."),
    br()
  ),
  sidebar = bslib::sidebar(
    open = FALSE
  ),
  bslib::card(
    card_header("Step 1: Filters"),
        title = "",
        bslib::layout_columns(
          bslib::card(
            card_header("Organization Type"),
            selectizeInput(
              "org_level",
              label = NULL,
              choices = c("501(c)(3) Public Charities", 
                          "501(c)(3) Private Foundations", 
                          "501(c)(4) Social Welfare Organizations", 
                          "Other Nonprofits",
                          "All Nonprofits")
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "other_orgs",
                width = "500px",
                label = "Other 501(c) Types",
                choices = org_type_choices,
              ),
              condition = "input.org_level == 'Other Nonprofits'"
            )
          ),
          bslib::card(
            card_header("Geography"),
            radioButtons(
              "geo_level",
              inline = FALSE,
              "Select Geographic Level",
              choices = list("Entire USA" = "all", 
                             "Region" = "census_region", 
                             "State" = "CENSUS_STATE_ABBR", 
                             "County" = "CENSUS_COUNTY_NAME", 
                             "Metro/Micro Area" = "CENSUS_CBSA_NAME")
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "region_selector",
                label = "Select Region(s)",
                choices = c("Northeast", "South", "Midwest", "West"),
                multiple = TRUE
              ),
              condition = "input.geo_level == 'census_region'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "state_selector_multi",
                label = "Select State(s)",
                choices = state_choices,
                multiple = TRUE
              ),
              condition = "input.geo_level == 'CENSUS_STATE_ABBR'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "state_selector_single",
                label = "Select State",
                choices = state_choices,
                multiple = FALSE
              ),
              condition = "input.geo_level == 'CENSUS_COUNTY_NAME' | input.geo_selector == 'CENSUS_CBSA_NAME'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "county_selector",
                label = "Select Counties",
                choices = NULL,
                multiple = TRUE,
                options = list(maxItems = 5)
              ),
              condition = "input.geo_level == 'CENSUS_COUNTY_NAME'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "cbsa_selector",
                label = "Select Metro/Micro Area(s)",
                choices = NULL,
                multiple = TRUE,
                options = list(maxItems = 5)
              ),
              condition = "input.geo_level == 'CENSUS_CBSA_NAME'"
            )
          ),
          bslib::card(
            bslib::card_header("Subsector"),
            shiny::radioButtons(
              inputId = "subsector_level",
              label = NULL,
              inline = TRUE,
              choices = list(
                "All Subsectors" = "all", 
                "Individual Subsectors" = "individual"
              )
            ),
            shiny::conditionalPanel(
              selectizeInput(
                inputId = "subsector_select",
                label = NULL,
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
                  "Hospitals" = "HOS"
                ),
                multiple = TRUE,
                options = list(maxItems = 5)
              ),
              condition = "input.subsector_level == 'individual'"
            )
          ),
          bslib::card(
            card_header("Asset Size"),
            shiny::radioButtons(
              inputId = "size_level",
              label = NULL,
              inline = TRUE,
              choices = list(
                "All Asset Sizes" = "all", 
                "Individual Asset Sizes" = "individual"
              )
            ),
            shiny::conditionalPanel(
              selectizeInput(
                inputId = "size_select",
                label = NULL,
                multiple = TRUE,
                options = list(maxItems = 5),
                choices = list(
                  "Under $100,000" = 1,
                  "$100,000 - $499,999" = 2,
                  "$500,000 - $999,999" = 3,
                  "$1 Million - $4.99 Million" = 4,
                  "$5 Million - $9.99 Million" = 5,
                  "Above $10 Million" = 6
                )
              ),
              condition = "input.size_level == 'individual'"
            )
          ),
          bslib::card(
            card_header("Date Range"),
            sliderInput(
              "date_range",
              label = NULL,
              min = 1989,
              max = 2024,
              value = c(1989, 2024),
              step = NULL,
              ticks = FALSE,
              sep = "",
              dragRange = TRUE
            )
          )
        ),
        bslib::input_task_button(
          id = "update_plot",
          style = "border-radius: 0; font-size: 18px; color: #ffffff; margin: auto;",
          label = "RETRIEVE DATA",
          label_busy = "UPDATING PLOTS",
          type = "primary"
        )
      ),
  bslib::navset_card_tab(
    title =   "Step 2: Results",
    height = "100%",
    bslib::nav_panel(
      "Overall",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(plotOutput("plot"))
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("table")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Subsector",
      bslib::card(
        layout_column_wrap(
          width = NULL,
          height = 650,
          style = htmltools::css(grid_template_columns = "3fr 1fr"),
          plotOutput("plot_subsector"),
          reactable::reactableOutput("table_subsector")
        ),
        div(
          p(tags$b("Source"), ": IRS Business Master File"),
          p(tags$b("Notes"), ": Data on the total number of nonprofits are displayed by fiscal year, meaning January through December of a given calendar year. They come from the IRS’s Exempt Organization Business Master File. ")
        ),
        downloadButton("downloadData", 
                       "DOWNLOAD",
                       class = "btn-download")
      )
    ),
    bslib::nav_panel(
      "By Geography",
      bslib::card(
        layout_column_wrap(
          width = NULL,
          height = 650,
          style = htmltools::css(grid_template_columns = "3fr 1fr"),
          plotOutput("plot_geo"),
          reactable::reactableOutput("table_geo")
        ),
        div(
          p(tags$b("Source"), ": IRS Business Master File"),
          p(tags$b("Notes"), ": Data on the total number of nonprofits are displayed by fiscal year, meaning January through December of a given calendar year. They come from the IRS’s Exempt Organization Business Master File. ")
        ),
        downloadButton("downloadData", 
                       "DOWNLOAD",
                       class = "btn-download")
      )
    ),
    bslib::nav_panel(
      "By Asset Size",
      bslib::card(
        layout_column_wrap(
          width = NULL,
          height = 650,
          style = htmltools::css(grid_template_columns = "3fr 1fr"),
          plotOutput("plot_size"),
          reactable::reactableOutput("table_size")
        ),
        div(
          p(tags$b("Source"), ": IRS Business Master File"),
          p(tags$b("Notes"), ": Data on the total number of nonprofits are displayed by fiscal year, meaning January through December of a given calendar year. They come from the IRS’s Exempt Organization Business Master File. ")
        ),
        downloadButton("downloadData", 
                       "DOWNLOAD",
                       class = "btn-download")
      )
    )
  )
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
      subtitle <- paste(subtitle, "Asset Size(s):", paste(input$size_select, collapse = ", "), "\n")
    }
    print(subtitle)
  })
  # Data Wrangling
  shiny::observeEvent(input$update_plot, {
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
          year_start = input$date_range[1],
          year_end = input$date_range[2]
        )
        setProgress(2, message = "Creating Tables...")
        tables <- summarise_data(
          data = filtered_data,
          geo_level = input$geo_level,
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level
        )
        setProgress(3, message = "Creating Graphs...")
        plots <- create_plots(
          table_ls = tables,
          geo_level = input$geo_level,
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level,
          title = plot_title(),
          subtitle = plot_subtitle()
        )
        setProgress(4, message = "Displays Results...")
        output$plot <- renderPlot({
            plots[["default"]]
          })
        output$table <- renderReactable({
          reactable(
            tables[["default"]],
            outlined = TRUE,
            defaultPageSize = 10,
            defaultColDef = colDef(align = "center")
          )
        })
        # Stage 5 Displaying Results - By Subsector
        output$plot_subsector <- renderPlot({
          plots[["by_subsector"]]
        })
        output$table_subsector <- renderReactable({
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
        output$plot_geo <- renderPlot({
          plots[["by_geo"]]
        })
        output$table_geo <- renderReactable({
          if (input$geo_level != "all") {
            reactable(
              tables[["by_geo"]],
              groupBy = input$geo_level,
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          } 
        })
        output$plot_size <- renderPlot({
          plots[["by_asset_size"]]
        })
        # Stage 5 Displaying Results - Asset Size
        output$table_size <- renderReactable({
          if (input$size_level == "individual") {
            reactable(
              tables[["by_asset_size"]],
              groupBy = "Asset_Size",
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
