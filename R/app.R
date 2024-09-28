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
      bslib::nav_panel(
        title = "Private Foundations",
        visualpanels[["Total Grant Amount"]]
      ),
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
      if(input$tabs == "Number"){
        data <- dataloader("data/number_nonprofits.parquet",
                           cols = var_ls[[input$tabs]])
        data_server(
          id = "number",
          geo_df = geo_df,
          data = data,
          groupby_var = "Year",
          sum_var = "Number of Nonprofits",
          ytitle = "Number of Nonprofits",
          xtitle = "Year",
          title_prefix = "Number of"
        )
      }
      else if (input$tabs == "Finances"){
        observeEvent(input$finances, {
          if (input$finances == "Assets"){
            data <- dataloader("data/finances.parquet",
                               cols = var_ls[[input$finances]])
            data_server(
              id = "assets",
              geo_df = geo_df,
              data = data,
              groupby_var = "Tax Year",
              sum_var = "Total Assets",
              ytitle = "Dollars",
              xtitle = "Tax Year",
              title_prefix = "Total Assets For"
            )
          } else if (input$finances == "Revenues"){
            data <- dataloader("data/finances.parquet",
                               cols = var_ls[[input$finances]])
            data_server(
              id = "revenues",
              geo_df = geo_df,
              data = data,
              groupby_var = "Tax Year",
              sum_var = "Total Revenues",
              ytitle = "Dollars",
              xtitle = "Tax Year",
              title_prefix = "Total Revenues For"
            )
          } else if (input$finances == "Expenses"){
            data <- dataloader("data/finances.parquet",
                               cols = var_ls[[input$finances]])
            data_server(
              id = "expenses",
              geo_df = geo_df,
              data = data,
              groupby_var = "Tax Year",
              sum_var = "Total Expenses",
              ytitle = "Dollars",
              xtitle = "Tax Year",
              title_prefix = "Total Expenses For"
            )
          } else if (input$finances == "Benefits"){
            data <- dataloader("data/finances.parquet",
                               cols = var_ls[[input$finances]])
            data_server(
              id = "benefits",
              geo_df = geo_df,
              data = data,
              groupby_var = "Tax Year",
              sum_var = "Total Benefits",
              ytitle = "Dollars",
              xtitle = "Tax Year",
              title_prefix = "Total Benefits For"
            )
          } else if (input$finances == "Payroll Taxes"){
            data <- dataloader("data/finances.parquet",
                               cols = var_ls[[input$finances]])
            data_server(
              id = "payroll_taxes",
              geo_df = geo_df,
              data = data,
              groupby_var = "Tax Year",
              sum_var = "Total Payroll Taxes",
              ytitle = "Dollars",
              xtitle = "Tax Year",
              title_prefix = "Total Payroll Taxes For"
            )
          }
        })
      } else if (input$tabs == "Private Foundations"){
        data <- dataloader("data/pf_grants.parquet",
                           cols = var_ls[[input$tabs]])
        data_server(
          id = "pf_amount",
          geo_df = geo_df,
          data = data,
          groupby_var = "Tax Year",
          sum_var = "Total Contributions",
          ytitle = "Total Number of Grants",
          xtitle = "Tax Year",
          title_prefix = "Total Private Foundation Grant Contributions For"
        )
      }
      else if(input$tabs == "Donor Advised Funds"){
        data <- dataloader("data/daf.parquet",
                           cols = var_ls[[input$tabs]])
        data <- data |> dplyr::mutate(`Tax Year` = 2021)
        print(head(data))
        data_server(
          id = "daf_number",
          geo_df = geo_df,
          data = data,
          groupby_var = "Tax Year",
          sum_var = "Number of DAFs",
          ytitle = "Number of Donor Advised Funds",
          xtitle = "Tax Year",
          title_prefix = "Number of Donor Advised Funds For",
          time_series = FALSE
        )
        data_server(
          id = "daf_contributions",
          geo_df = geo_df,
          data = data,
          groupby_var = "Tax Year",
          sum_var = "Total Contributions",
          ytitle = "Dollars",
          xtitle = "Tax Year",
          title_prefix = "Total Contributions to Donor Advised Funds For",
          time_series = FALSE
        )
        data_server(
          id = "daf_grants",
          geo_df = geo_df,
          data = data,
          groupby_var = "Tax Year",
          sum_var = "Total Grants",
          ytitle = "Dollars",
          xtitle = "Tax Year",
          title_prefix = "Total Grants from Donor Advised Funds For",
          time_series = FALSE
        )
        data_server(
          id = "daf_value",
          geo_df = geo_df,
          data = data,
          groupby_var = "Tax Year",
          sum_var = "Total Value",
          ytitle = "Dollars",
          xtitle = "Tax Year",
          title_prefix = "Total Value of Donor Advised Funds For",
          time_series = FALSE
        )
        data_server(
          id = "daf_proportion",
          geo_df = geo_df,
          data = data,
          groupby_var = "Tax Year",
          sum_var = "Proportion With DAFs",
          ytitle = "Percentage",
          xtitle = "Tax Year",
          title_prefix = "Percentage of Nonprofits that maintain a DAF For",
          time_series = FALSE
        )
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
