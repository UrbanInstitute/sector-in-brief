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
source("ui_plots.R")
source("utils.R")

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

# Datasets
geo_df <- read.csv("data/nested_geographies.csv")

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
        color: #000000;
        background-color: #fdbf11;
        border-color: #fdbf11;
        font-size: 18px;
        }
        .btn-download:hover {
        color: #000000;
        background-color: #fccb41;
        border-color: #fccb41;
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
  bslib::accordion(
    bslib::accordion_panel(
      title = "Data Selection",
      bslib::card(
        bslib::layout_columns(
          bslib::card(
            card_header("Organization Type"),
            selectizeInput(
              "org_selector",
              label = NULL,
              choices = c("501(c)(3) Public Charities", 
                          "501(c)(3) Private Foundations", 
                          "501(c)(4) Social Welfare Organizations", 
                          "Other Nonprofits")
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "501c_selector",
                width = "500px",
                label = "Other 501(c) Types",
                choices = tax_exempt_orgs <- c(
                  "501(c)(1) - Corporations Organized Under Act of Congress (including Federal Credit Unions)",
                  "501(c)(2) - Title Holding Corporations for Exempt Organization",
                  "501(c)(5) - Labor, Agricultural and Horticultural Organizations",
                  "501(c)(6) - Business Leagues, etc.",
                  "501(c)(7) - Social and Recreation Clubs",
                  "501(c)(8) - Fraternal Beneficiary Societies",
                  "501(c)(9) - Voluntary Employees' Beneficiary Associations",
                  "501(c)(10) - Domestic Fraternal Societies",
                  "501(c)(11) - Teachers' Retirement Fund Associations",
                  "501(c)(12) - Benevolent Life Insurance Associations, Mutual Ditch or Irrigation Companies, Mutual or Cooperative Telephone Companies, or Like Organizations (if 85 percent or more of the organization's income consists of amounts collected from members for the sole purpose of meeting losses and expenses)",
                  "501(c)(13) - Cemetery Companies (owned and operated exclusively for the benefit of their members or which are not operated for profit)",
                  "501(c)(14) - State Chartered Credit Unions, Mutual Reserve Funds",
                  "501(c)(15) - Mutual Insurance Companies or Associations",
                  "501(c)(16) - Cooperative Organizations to Finance Crop Operations",
                  "501(c)(17) - Supplemental Unemployment Benefit Trusts",
                  "501(c)(18) - Employee Funded Pension Trusts (created before June 25, 1959)",
                  "501(c)(19) - Veterans' Organizations",
                  "501(c)(21) - Black Lung Benefit Trusts",
                  "501(c)(22) - Withdrawal Liability Payment Funds",
                  "501(c)(25) - Title Holding Corporations or Trusts with Multiple Parents",
                  "501(c)(26) - State-Sponsored High-Risk Health Coverage Organizations",
                  "501(c)(27) - State-Sponsored Worker's Compensation Reinsurance Organizations",
                  "501(c)(28) - National Railroad Retirement Investment Trust (45 U.S.C. 231n(j)",
                  "501(c)(29) - Qualified Nonprofit Health Insurance Issuers",
                  "501(d) - Religious and Apostolic Associations",
                  "501(e) - Cooperative Hospital Service Organizations",
                  "501(f) - Cooperative Service Organizations of Operating Educational Organizations",
                  "501(k) - Child Care Organizations",
                  "521(a) - Farmers' Cooperative Associations"
                )
              ),
              condition = "input.org_selector == 'Other Nonprofits'"
            )
          ),
          bslib::card(
            card_header("Geography"),
            radioButtons(
              "geo_selector",
              inline = FALSE,
              "Select Geographic Level",
              choices = c("Entire USA", "Region", "State", "County", "Metro/Micro Area")
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "region_selector",
                label = "Select Region(s)",
                choices = c("Northeast", "South", "Midwest", "West", "All Regions"),
                multiple = TRUE
              ),
              condition = "input.geo_selector == 'Region'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "state_selector_multi",
                label = "Select State(s)",
                choices = list(
                  "AL" = "Alabama", "AK" = "Alaska", "AZ" = "Arizona", "AR" = "Arkansas", "CA" = "California",
                  "CO" = "Colorado", "CT" = "Connecticut", "DE" = "Delaware", "DC" = "District of Columbia", "FL" = "Florida",
                  "GA" = "Georgia", "HI" = "Hawaii", "ID" = "Idaho", "IL" = "Illinois", "IN" = "Indiana",
                  "IA" = "Iowa", "KS" = "Kansas", "KY" = "Kentucky", "LA" = "Louisiana", "ME" = "Maine",
                  "MD" = "Maryland", "MA" = "Massachusetts", "MI" = "Michigan", "MN" = "Minnesota", "MS" = "Mississippi",
                  "MO" = "Missouri", "MT" = "Montana", "NE" = "Nebraska", "NV" = "Nevada", "NH" = "New Hampshire",
                  "NJ" = "New Jersey", "NM" = "New Mexico", "NY" = "New York", "NC" = "North Carolina", "ND" = "North Dakota",
                  "OH" = "Ohio", "OK" = "Oklahoma", "OR" = "Oregon", "PA" = "Pennsylvania", "RI" = "Rhode Island",
                  "SC" = "South Carolina", "SD" = "South Dakota", "TN" = "Tennessee", "TX" = "Texas", "UT" = "Utah",
                  "VT" = "Vermont", "VA" = "Virginia", "WA" = "Washington", "WV" = "West Virginia", "WI" = "Wisconsin",
                  "WY" = "Wyoming", "all" = "All States"
                ),
                multiple = TRUE
              ),
              condition = "input.geo_selector == 'State'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "state_selector_single",
                label = "Select State",
                choices = list(
                  "Alabama" = "AL", "Alaska" = "AK", "Arizona" = "AZ", "Arkansas" = "AR", "California" = "CA",
                  "Colorado" = "CO", "Connecticut" = "CT", "Delaware" = "DE", "District of Columbia" = "DC", "Florida" = "FL",
                  "Georgia" = "GA", "Hawaii" = "HI", "Idaho" = "ID", "Illinois" = "IL", "Indiana" = "IN",
                  "Iowa" = "IA", "Kansas" = "KS", "Kentucky" = "KY", "Louisiana" = "LA", "Maine" = "ME",
                  "Maryland" = "MD", "Massachusetts" = "MA", "Michigan" = "MI", "Minnesota" = "MN", "Mississippi" = "MS",
                  "Missouri" = "MO", "Montana" = "MT", "Nebraska" = "NE", "Nevada" = "NV", "New Hampshire" = "NH",
                  "New Jersey" = "NJ", "New Mexico" = "NM", "New York" = "NY", "North Carolina" = "NC", "North Dakota" = "ND",
                  "Ohio" = "OH", "Oklahoma" = "OK", "Oregon" = "OR", "Pennsylvania" = "PA", "Rhode Island" = "RI",
                  "South Carolina" = "SC", "South Dakota" = "SD", "Tennessee" = "TN", "Texas" = "TX", "Utah" = "UT",
                  "Vermont" = "VT", "Virginia" = "VA", "Washington" = "WA", "West Virginia" = "WV", "Wisconsin" = "WI",
                  "Wyoming" = "WY"
                ),
                multiple = FALSE
              ),
              condition = "input.geo_selector == 'County' | input.geo_selector == 'Metro/Micro Area'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "county_selector",
                label = "Select Counties",
                choices = NULL,
                multiple = TRUE,
                options = list(maxItems = 5)
              ),
              condition = "input.geo_selector == 'County'"
            ),
            shiny::conditionalPanel(
              selectizeInput(
                "cbsa_selector",
                label = "Select Metro/Micro Area(s)",
                choices = NULL,
                multiple = TRUE,
                options = list(maxItems = 5)
              ),
              condition = "input.geo_selector == 'Metro/Micro Area'"
            )
          ),
          bslib::card(
            card_header("Subsector"),
            selectizeInput(
              inputId = "subsector_select",
              label = NULL,
              selected = "all_groups",
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
              multiple = TRUE,
              options = list(maxItems = 5)
            )
          ),
          bslib::card(
            card_header("Asset Size"),
            selectizeInput(
              inputId = "size_select",
              label = NULL,
              choices = list(
                "Under $100,000" = 1,
                "$100,000 - $499,999" = 2,
                "$500,000 - $999,999" = 3,
                "$1 Million - $4.99 Million" = 4,
                "$5 Million - $9.99 Million" = 5,
                "Above $10 Million" = 6,
                "All Asset Sizes" = 0
              )
            ),
            multiple = TRUE,
            options = list(maxItems = 5)
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
          style = "margin-top: 1px; margin-left: 32px; margin-right: 32px; margin-bottom: 1px; font-size: 16px; padding: 4px; border-radius: 0; font-size: 18px; color: #ffffff",
          label = "RETRIEVE DATA",
          label_busy = "Updating Plots",
          type = "primary"
        )
      )
    )
  ),
  bslib::navset_card_tab(
    title =   "Step 2: Results",
    height = "100%",
    bslib::nav_panel(
      "Overall",
      bslib::card(
        h3(textOutput("value")),
        layout_column_wrap(
          width = NULL,
          height = 650,
          style = css(grid_template_columns = "3fr 1fr"),
          card_body(plotOutput("plot")),
          card_body(div(class = "tableheader", "Table"),
                    reactable::reactableOutput("table"))
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
      "By Subsector",
      bslib::card(
        h3(textOutput("value")),
        layout_column_wrap(
          width = NULL,
          height = 650,
          style = css(grid_template_columns = "3fr 1fr"),
          card_body(plotOutput("plot_subsector")),
          card_body(div(class = "tableheader", "Table"),
                    reactable::reactableOutput("table_subsector"))
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
    bslib::nav_panel("By Asset Size"),
    bslib::nav_panel("By Geography")
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
  output$plot <- renderPlot({
    ggplot(num_nonprofits, aes(x = YEAR, y = `Number of Nonprofits`)) +
      geom_line(size = 1.5,
                linetype = 1,
                color = "#1696d2") +
      geom_point(size = 3, color = "#1696d2", fill = "white", shape = 21, stroke = 1.2) +
      scale_y_continuous(
        limits = c(0, NA),
        expand = expansion(mult = 0.1),
        labels = scales::unit_format(unit = "m", scale = 1e-6)
      ) +
      labs(subtitle = NULL, 
           x = "Fiscal Year",
           title = "Line Chart of Yearly Trends",
           y = "Number of Nonprofits (millions)") +
      scale_x_continuous(breaks = seq(1990, 2024, 4)) +
      theme_classic() +
      theme(
        text = element_text(family = "Lato"),
        plot.title = element_text(size = 20, face = "bold", hjust = 0),
        plot.subtitle = element_text(size = 16, hjust = 0, margin = margin(b = 20)),
        axis.text = element_text(size = 12, color = "#000000"),
        axis.title.y = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 0.5, margin = margin(r = 10)),
        axis.line.y = element_blank(),
        axis.title.x = element_text(size = 12, margin = margin(t = 10), color = "#000000"),
        panel.grid.major.y = element_line(color = "#dcdcdc"),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        plot.caption = element_text(hjust = 0, size = 10, color = "grey50", margin = margin(t = 20)),
        plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
      )
  })
  output$plot_subsector <- renderPlot({
    ggplot(num_nonprofits_subsector, aes(x = YEAR, y = `Number of Nonprofits`, color = NTEE_INDUSTRY_GROUP)) +
      geom_line(size = 1.5,
                linetype = 1) +
      geom_point(size = 3, fill = "white", shape = 21, stroke = 1.2) +
      scale_y_continuous(
        limits = c(0, NA),
        expand = expansion(mult = 0.1),
        labels = scales::unit_format(unit = "m", scale = 1e-6)
      ) +
      labs(subtitle = NULL, 
           x = "Fiscal Year",
           title = "Line Chart of Yearly Trends",
           y = "Number of Nonprofits (millions)") +
      scale_x_continuous(breaks = seq(1990, 2024, 4)) +
      theme_classic() +
      theme(
        text = element_text(family = "Lato"),
        plot.title = element_text(size = 20, face = "bold", hjust = 0),
        plot.subtitle = element_text(size = 16, hjust = 0, margin = margin(b = 20)),
        axis.text = element_text(size = 12, color = "#000000"),
        axis.title.y = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 0.5, margin = margin(r = 10)),
        axis.line.y = element_blank(),
        axis.title.x = element_text(size = 12, margin = margin(t = 10), color = "#000000"),
        panel.grid.major.y = element_line(color = "#dcdcdc"),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        plot.caption = element_text(hjust = 0, size = 10, color = "grey50", margin = margin(t = 20)),
        plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
      )
  })
  output$table <- renderReactable({
    reactable(num_nonprofits, 
              outlined = TRUE, 
              defaultPageSize = 10,
              defaultColDef = colDef(
                align = "center"
              ))
  })
  output$table_subsector <- renderReactable({
    reactable(num_nonprofits_subsector,
              groupBy = "NTEE_INDUSTRY_GROUP",
              outlined = TRUE, 
              defaultPageSize = 10,
              defaultColDef = colDef(
                align = "center"
              ))
  })
  output$downloadData <- downloadHandler(
    filename = "nonprofit.csv",
    content = function(file) {
      write.csv(num_nonprofits, file)
    }
  )
  output$value <- renderText({"Number of 501(c)(3) Public Charities, 1989 - 2024"})
}

shinyApp(ui = ui, server = server)
