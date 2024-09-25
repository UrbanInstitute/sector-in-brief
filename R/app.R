app <- function(...) {
  navpanels <- purrr::pmap(navpanels, navpanel_wrapper)
  ui <- bslib::page_navbar(
    title = "Nonprofit Sector In Brief",
    id = "tabs",
    bg = "#a2d4ec",
    fillable = FALSE,
    htmltools::tags$head(
      htmltools::includeCSS("www/sib_style.css"),
      htmltools::tags$style(
        htmltools::HTML(
          "
        .pageheader {
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
          margin-left: 0px;
          margin:0;
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
    exec_summary,
    bslib::nav_menu(
      title = "Visualise Data",
      navpanels[[1]],
      navpanels[[2]],
      navpanels[[3]],
      navpanels[[4]]
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
        data <- dataloader("data/number_nonprofits.parquet")
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
      else if(input$tabs == "Assets"){
        loadingpage("data/Total_Assets.parquet")
        data_server(
          "assets",
          geo_df,
          data_select,
          "Tax Year",
          "Total Assets",
          create_single_line_plot,
          create_group_line_plot,
          "Total Assets For: "
        )
      }
      else if(input$tabs == "Donor Advised Funds"){
        loadingpage("data/daf.parquet")
        data_server(
          "daf_contributions",
          geo_df,
          data_select,
          "Year",
          "Total Contributions",
          create_single_col_plot,
          create_group_col_plot,
          daf_title_prefix,
          FALSE
        )
        data_server(
          "daf_num",
          geo_df,
          data_select,
          "Year",
          "Number of DAFs",
          create_single_col_plot,
          create_group_col_plot,
          daf_title_prefix,
          FALSE
        )
        data_server(
          "daf_proportion",
          geo_df,
          data_select,
          "Year",
          "Proportion With DAFs",
          create_single_col_plot,
          create_group_col_plot,
          daf_title_prefix,
          FALSE
        )
        data_server(
          "daf_value",
          geo_df,
          data_select,
          "Year",
          "Total Value",
          create_single_col_plot,
          create_group_col_plot,
          daf_title_prefix,
          FALSE
        )
        data_server(
          "daf_grants",
          geo_df,
          data_select,
          "Year",
          "Total Grants",
          create_single_col_plot,
          create_group_col_plot,
          daf_title_prefix,
          FALSE
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
