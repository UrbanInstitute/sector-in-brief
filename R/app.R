app <- function(...) {
  sibtheme <- bslib::bs_theme(
    bg = "#ffffff",
    fg = "#000",
    primary = "#1696d2",
    secondary = "#fdbf11",
    success = "#55b748",
    warning = "#ec008b",
    danger = "#db2b27",
    info = "#d2d2d2",
    base_font = bslib::font_google("Lato"),
    version = 5
  )
  ui <- bslib::page_navbar(
    title = "Nonprofit Sector In Brief",
    id = "tabs",
    fillable = FALSE,
    bg = "#a2d4ec",
    htmltools::tags$head(
      htmltools::tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css"),
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
      visual_panel(
        title = "Number",
        panel_header = "Total number of nonprofits",
        panel_desc = "The number of organizations that are registered with the Internal Revenue Service (IRS).",
        panelid = "nn_data"
      ),
      visual_panel(
        title = "Assets",
        panel_header = "Total Assets",
        panel_desc = "Total assets – The aggregate value of everything nonprofits own.",
        panelid = "assets"
      ),
     visual_pill_panel(
        title = "Donor Advised Funds",
        panel_header = "Donor Advised Funds",
        panel_desc = "Donor Advised Funds (DAFs) are charitable giving accounts that allow donors to make contributions to a public charity that sponsors a DAF program."
      )
    ),
    bslib::nav_panel(title = "Download Data", div(
      br(),
      h2("Download Data", class = "pageheader"),
      br(),
      h3("Download the data used in the visualizations above."),
      br(),
      downloadButton("downloadData", "Download Data", class = "btn-download")
    ))
  )
  
  server <- function(input, output, session) {
    # Server modules to update county and cbsa options based on State
    # Data Wrangling
    daf_title_prefix <- "Donor Advised Funds For: "
    
    data_select <- observeEvent( input$tabs, {
      if(input$tabs == "Number"){
        shinycssloaders::showPageSpinner()
        data_select <- arrow::read_parquet("data/number_nonprofits.parquet")
        shinycssloaders::hidePageSpinner()
        data_server(
          "nn_data",
          geo_df,
          data_select,
          "Year",
          "Number of Nonprofits",
          create_single_line_plot,
          create_group_line_plot,
          "Number of"
        )
      }
      else if(input$tabs == "Assets"){
        shinycssloaders::showPageSpinner()
        data_select <- arrow::read_parquet("data/Total_Assets.parquet")
        shinycssloaders::hidePageSpinner()
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
        shinycssloaders::showPageSpinner()
        data_select <- arrow::read_parquet("data/daf.parquet") |>
          dplyr::mutate(
            Year = 2021
          ) |>
          dplyr::collapse()
        shinycssloaders::hidePageSpinner()
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
  }
  shinyApp(ui = ui, server = server)
}
