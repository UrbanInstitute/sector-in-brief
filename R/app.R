app <- function(...) {
  # Load elements
  visualpanels <- visualpanel_mapper(visualpanel_args)
  geo_df <- read.csv("data/nested_geographies.csv")
  ui <- bslib::page_navbar(
    id = "tabs",
    title = navbar_title(title = "     | National Center for Charitable Statistics", 
                         height="60px"),
    bg = "#0096d2",
    fillable = FALSE,
    htmltools::tags$head(
      htmltools::includeCSS("www/sib_style.css")
    ),
    bslib::nav_spacer(),
    welcome,
    about(), 
    bslib::nav_menu(
      title = "Visualise Data",
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
          visualpanels[["Payroll Taxes"]]        )
      ),
      bslib::nav_panel(
        title = "Private Foundation Grantmaking",
        pf_header,
        bslib::navset_card_pill(
          id = "private_foundation_grants",
          visualpanels[["Private Foundation Grants"]]
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
      title = "Download Data",
      page_header_card(header = download_title, 
                       subheader = download_subtitle),
      dataRequestUI("data_download", geo_df)
    ),
    footer = text_footer
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
      } else if (input$tabs == "Private Foundation Grantmaking") {
        observeEvent(input$private_foundation_grants, {
          data_server_wrapper(input$private_foundation_grants, data_server_args, geo_df)
        })    
      } else if (input$tabs == "Numbers"){
        data_server_wrapper(input$tabs, data_server_args, geo_df)
      }
    })
    dataRequestServer("data_download", geo_df)
  }
  shinyApp(ui = ui, server = server)
}
