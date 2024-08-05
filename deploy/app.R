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
library(arrow)
library(dplyr)
set_urbn_defaults(style = "print")

# Create state list
state_ls <- setNames(as.list(as.character(usdata::state_stats$abbr)), usdata::state_stats$state)
state_ls[["All States"]] = "all_states"
# Create org_ls
org_ls <- as.list(sprintf("501(c)(%s)", c(1:10, "d", "e", "f", "k")))
org_ls[["All Organizations"]] = "all_orgs"
setNames(org_ls, unlist(org_ls))

filter_parquet <- function(pq, 
                           org_type,
                           state,
                           industry_group,
                           geo_level,
                           county_cbsa,
                           size,
                           series){
  if (org_type != "all_orgs") {
    pq <- pq |> dplyr::filter(CTYPE == org_type)
  }
  if (state != "all_states") {
    pq <- pq |> dplyr::filter(CENSUS_STATE_ABBR == state)
    if (geo_level == "county"){
      pq <- pq |> dplyr::filter(CENSUS_COUNTY_NAME == county_cbsa)
    } else if (geo_level == "cbsa") {
      pq <- pq |> dplyr::filter(CENSUS_CBSA_NAME == county_cbsa)
    }
  }
  if (industry_group != "all_groups") {
    pq <- pq |> dplyr::filter(NTEE_INDUSTRY_GROUP == industry_group)
  }
  if (size  > 0){
    pq <- pq |> dplyr::filter(SIZE == size)
  }
  if (series == "fiscal"){
    pq <- pq |> 
      dplyr::group_by(YEAR) |> 
      dplyr::summarise(COUNT = sum(num_nonprofit, na.rm = TRUE),
                       ASSETS = sum(total_assets, na.rm = TRUE),
                       REVENUES = sum(total_revenues, na.rm = TRUE),
                       EXPENSES = sum(total_expenses, na.rm = TRUE)) |> 
      dplyr::collect()
  } else if (series == "pf") {
    pq <- pq |> 
      dplyr::group_by(YEAR) |> 
      dplyr::summarise(TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
                       MEDIAN_GRANT_AMT = sum(MEDIAN_GRANT_AMT, na.rm = TRUE),
                       NUM_GRANTS = sum(NUM_GRANTS, na.rm = TRUE)) |> 
      dplyr::collect()
  } else if (series == "efile") {
    pq <- pq |>
      dplyr::summarise(TOTAL_NUM_DAFS = sum(NUM_DAFS, na.rm = TRUE),
                       TOTAL_CONTRIBUTIONS = sum(TOTAL_CONTRIBUTIONS, na.rm = TRUE),
                       TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
                       TOTAL_VALUE = sum(TOTAL_VALUE, na.rm = TRUE),
                       TOTAL_HAVE_DAFS = sum(HAS_DAF, na.rm = TRUE),
                       MEAN_DAF_PROPORTION = mean(DAF_PROPORTION, na.rm = TRUE)) |>
      dplyr::collect()
  } else if (series == "labor") {
    pq <- pq |> 
      dplyr::group_by(YEAR) |> 
      dplyr::summarise(TOTAL_EMPLOYEES = sum(total_employees, na.rm = TRUE),
                       TOTAL_BENEFITS = sum(total_benefits, na.rm = TRUE),
                       TOTAL_PAYROLL = sum(total_payroll, na.rm = TRUE)) |> 
      dplyr::collect()
  }
  
  return(pq)
}

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

# List of states mapped to County / CBSA
geo_df <- read.csv(
  "nested_geographies.csv"
)
# Default data set
fiscal_agg <- read.csv(
  "test.csv"
)
# fiscal metrics
fiscal <- arrow::open_dataset("s3://nccsdata/sector-in-brief/fiscal_metrics.parquet")
# labor metrics
labor <- arrow::open_dataset("s3://nccsdata/sector-in-brief/labor_metrics.parquet")
# pf data
pf <- arrow::open_dataset("s3://nccsdata/sector-in-brief/pf_grants_metrics.parquet")
# efile data
efile <- arrow::open_dataset("s3://nccsdata/sector-in-brief/efile_daf_metrics.parquet")

# Cards

# Sector Size
cards_sector_size <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Nonprofits"),
    plotly::plotlyOutput("npnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Revenues (Real 2021 $)"),
    plotly::plotlyOutput("nprev")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Expenses ( Real 2021 $)"),
    plotly::plotlyOutput("npexp")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Assets (Real 2021 $)"),
    plotly::plotlyOutput("npass")
  )  
)

# Private Foundations
cards_private_foundation <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Grants"),
    plotly::plotlyOutput("grantnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Median Grant Size (Real 2021 $)"),
    plotly::plotlyOutput("medgrantsize")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Amount of Grants Paid ( Real 2021 $)"),
    plotly::plotlyOutput("grantamt")
  )  
)

# Labor
cards_labor <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Employees"),
    plotly::plotlyOutput("empnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Benefits (Real 2021 $)"),
    plotly::plotlyOutput("empbenefits")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Payroll Taxes ( Real 2021 $)"),
    plotly::plotlyOutput("emppayroll")
  )  
)

# DAF
vbs_daf <- list(
  bslib::value_box(
    title = "Percentage of Organizations with a DAF",
    value = textOutput("daf_pct"),
    showcase = bsicons::bs_icon("percent")
  ),
  bslib::value_box(
    title = "Total Number of DAFs",
    value = textOutput("daf_num"),
    showcase = bsicons::bs_icon("building")
  ),
  bslib::value_box(
    title = "Total DAF Contributions (Real 2021 $)",
    value = textOutput("daf_cntrb"),
    showcase = bsicons::bs_icon("currency-dollar")
  ),
  bslib::value_box(
    title = "Total DAF Grants (Real 2021 $)",
    value = textOutput("daf_grants"),
    showcase = bsicons::bs_icon("currency-dollar")
  ),
  bslib::value_box(
    title = "Total DAF Value (Real 2021 $)",
    value = textOutput("daf_value"),
    showcase = bsicons::bs_icon("currency-dollar")
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
  
  geo_filters <- shiny::reactive({
    list(input$geo_selector, 
         input$state_selector)
  }
  )
  
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
  
  shiny::observeEvent(input$update_plot, ignoreNULL = FALSE, {
    # Get Inputs
    org_type <- input$org_type_selector
    state <- input$state_selector
    industry_group <- input$industry_group_selector
    geo_level <- input$geo_selector
    county_cbsa <- input$county_cbsa_selector
    size <- input$size_selector
    if (input$tabs == "Sector Summary") {
      if (all(grepl("ball", c(org_type, state, industry_group))) &
          size == 0) {
        fiscal_agg
      } else {
        data <- filter_parquet(fiscal,
                       org_type,
                       state,
                       industry_group,
                       geo_level,
                       county_cbsa,
                       size,
                       series = "fiscal")
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
      }
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
