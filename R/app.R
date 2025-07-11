source("R/text-visuals.R", local = FALSE)

app <- function(...) {
  # Load elements
  visualpanels <- visualpanel_mapper(visualpanel_args)
  geo_df <- read.csv("data/nested_geographies.csv")
  ui <- bslib::page_navbar(
    id = "tabs",
    padding = "10px",
    title = navbar_title(title = "     | NCCS"),
    bg = "#0096d2",
    fillable = FALSE,
    htmltools::tags$head(
      htmltools::includeCSS("www/sib_style.css")
    ),
    bslib::nav_spacer(),
    welcomeUI,
    aboutUI(), 
    bslib::nav_menu(
      title = "Data Visualizations",
      visualpanels[["Numbers"]],
      bslib::nav_panel(
        title = "Finances",
        finance_header,
        bslib::navset_card_pill(
          id = "finances",
          visualpanels[["Assets"]],
          visualpanels[["Revenues"]],
          visualpanels[["Expenses"]],
          visualpanels[["Benefits"]],
          visualpanels[["Government Grants"]]
        )
      ),
      bslib::nav_panel(
        title = "Private Foundation Giving",
        pf_header,
        bslib::navset_card_pill(
          id = "private_foundation_grants",
          visualpanels[["Private Foundation Grants"]],
          visualpanels[["Program Related Investments"]]
        )
      ),
      bslib::nav_panel(
        title = "Donor Advised Funds",
        daf_header,
        bslib::navset_card_pill(
          id = "daf",
          visualpanels[["Number of DAFs"]],
          visualpanels[["DAF Contributions"]],
          visualpanels[["DAF Grants"]],
          visualpanels[["DAF Value"]],
          visualpanels[["DAF Proportion"]]        )
      )
    ),
    bslib::nav_panel(
      title = "Custom Panel Datasets",
      card_header_text(header = download_title, 
                       subheader = download_subtitle),
      dataRequestUI("data_download", geo_df)
    ),
    footer = text_footer
  )
  
  server <- function(input, output, session) {
    # Server modules to update county and cbsa options based on State
    # Data Wrangling
    daf_title_prefix <- "Donor Advised Funds For: "
    curr_data <- shiny::reactiveVal(NULL)
    curr_config <- shiny::reactiveVal(NULL)
    trigger <- NULL
    data_select <- observeEvent(input$tabs, {
      if (input$tabs == "Finances") {
        observeEvent(input$finances, {
          results <-  data_load(input$finances, data_server_args, geo_df)
          curr_data(results$data)
          curr_config(results$config)
        })
      } else if (input$tabs == "Donor Advised Funds") {
        observeEvent(input$daf, {
          results <-  data_load(input$daf, data_server_args, geo_df)
          curr_data(results$data)
          curr_config(results$config)
        })
      } else if (input$tabs == "Private Foundation Giving") {
        observeEvent(input$private_foundation_grants, {
          results <-  data_load(input$private_foundation_grants, data_server_args, geo_df)
          curr_data(results$data)
          curr_config(results$config)
        })
      } else if (input$tabs == "Numbers") {
        results <-  data_load(input$tabs, data_server_args, geo_df)
        curr_data(results$data)
        curr_config(results$config)
      }
      shiny::observe({
        req(curr_data())
        config <- curr_config()
        render_data <- curr_data()()
        render_outputs(
          plots = render_data$plots,
          tables = render_data$tables,
          output = render_data$output,
          query = render_data$query,
          config = config
        )
      })
    })
    dataRequestServer("data_download", geo_df)
    observeEvent(input$visual_link, {
      shiny::updateTabsetPanel(session, "tabs", selected = visual_link_page)
    })
    observeEvent(input$download_link, {
      shiny::updateTabsetPanel(session, "tabs", selected = download_link_page)
    })
  }
  shinyApp(ui = ui, server = server)
}
