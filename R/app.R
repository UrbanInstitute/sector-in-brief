app <- function(...) {
  # Load elements
  visualpanels <- visualpanel_mapper(visualpanel_args)
  geo_df <- read.csv("data/nested_geographies.csv")
  ui <- bslib::page_navbar(
    title = "NCCS | 990 Data Explorer",
    id = "tabs",
    bg = "black",
    fillable = FALSE,
    htmltools::tags$head(
      htmltools::includeCSS("www/sib_style.css")
    ),
    exec_summary,
    bslib::nav_menu(
      title = "Visualise Data",
      visualpanels[["Number"]],
      bslib::nav_panel(
        title = "Finances",
        bslib::navset_card_pill(
          id = "finances",
          visualpanels[["Assets"]],
          visualpanels[["Revenues"]],
          visualpanels[["Expenses"]],
          visualpanels[["Benefits"]],
          visualpanels[["Payroll Taxes"]]        )
      ),
      visualpanels[["Private Foundation Grants"]],
      bslib::nav_panel(
        title = "Donor Advised Funds",
        bslib::navset_card_pill(
          id = "daf",
          visualpanels[["Number of DAFs"]],
          visualpanels[["DAF Contributions"]],
          visualpanels[["DAF Grants"]],
          visualpanels[["DAF Value"]],
          visualpanels[["DAF Proportion"]]        )
      )
    ),
    bslib::nav_panel(title = "Download Data",
                     dataRequestUI("data_download"))
  )
  
  server <- function(input, output, session) {
    # Server modules to update county and cbsa options based on State
    # Data Wrangling
    daf_title_prefix <- "Donor Advised Funds For: "
    data_select <- observeEvent( input$tabs, {
      if (input$tabs == "Finances"){
        observeEvent(input$finances, {
          data_server_wrapper(input$finances, data_server_args, geo_df)
        })
      } else if (input$tabs == "Donor Advised Funds"){
        observeEvent(input$daf, {
          data_server_wrapper(input$daf, data_server_args, geo_df)
        })
      } else if (input$tabs %in% c("Number", "Private Foundation Grants")){
        data_server_wrapper(input$tabs, data_server_args, geo_df)
      }
    })

    output$downloadData <- downloadHandler(
      filename = "nonprofit.csv",
      content = function(file) {
        write.csv(tables[["default"]], file)
      }
    )
    
    dataRequestServer("data_download")
  }
  shinyApp(ui = ui, server = server)
}
