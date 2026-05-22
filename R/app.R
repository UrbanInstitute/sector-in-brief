# Top-level Shiny app. Returns a shinyApp object — the script in
# `app.R` (repo root) calls this with `app()` to launch.
#
# Boot path (runs once when app() is called):
#   1. ensure_data_local()       — pull or reuse the pinned data vintage
#   2. validate_parquet_schemas()— hard-stop on producer schema drift
#   3. publish_data_dictionary() — write www/data_dictionary.csv for downloads
#   4. resolve_visualpanel_year_ranges() — fill NA year overrides from manifest
#   5. visualpanel_mapper()      — build 11 LAZY nav_panel shells
#   6. read.csv(nested_geographies) — geo lookup
#   7. assemble bslib::page_navbar UI with welcome/about/visualizations/
#      custom-download tabs
#   8. server() — bind lazy renderUI per panel + per-section observers
#      that dispatch to data_server_wrapper() when a tab activates
#
# Each visualization panel is a per-panel Shiny module (see
# data_server.R + data_pipeline.R); the modules only construct when
# their tab is first visited (PR #28 lazy-UI optimization).

#' Construct the sector-in-brief shinyApp object.
#'
#' @param ... Accepted for symmetry with `shiny::shinyApp`; currently
#'   ignored.
#' @return A `shiny::shinyApp` object ready to pass to `runApp()`.
app <- function(...) {
  sync_result <- ensure_data_local()
  validate_parquet_schemas()
  publish_data_dictionary()
  # Resolve year ranges from the freshly-synced manifest (NA cells in
  # visualpanel_args get manifest-derived bounds; integer cells stay).
  visualpanel_args <- resolve_visualpanel_year_ranges(visualpanel_args)
  visualpanels <- visualpanel_mapper(visualpanel_args)
  geo_df <- read.csv("data/nested_geographies.csv")

  stale_banner <- if (identical(sync_result$status, "stale")) {
    htmltools::div(
      class = "alert alert-warning",
      role = "alert",
      style = "margin: 0; border-radius: 0; text-align: center;",
      htmltools::strong("Data may be stale. "),
      sprintf("The latest data sync from S3 failed; showing vintage %s. ",
              sync_result$vintage),
      "Reported metrics remain accurate as of that vintage."
    )
  } else NULL

  # tags$head() goes outside page_navbar in a tagList; passing it
  # positionally inside page_navbar's `...` triggers a bslib warning
  # because that slot expects nav_panel / nav_menu children.
  ui <- htmltools::tagList(
  htmltools::tags$head(
    htmltools::includeCSS("www/sib_style.css")
  ),
  bslib::page_navbar(
    id = "tabs",
    padding = "10px",
    title = navbar_title(title = "     | NCCS"),
    bg = "#0096d2",
    fillable = FALSE,
    header = stale_banner,
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
          visualpanels[["Benefits"]]      )
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
      title = "Custom Panel Datasets",
      page_header_card(header = download_title, 
                       subheader = download_subtitle),
      dataRequestUI("data_download", geo_df)
    ),
    footer = text_footer
  )
  )

  server <- function(input, output, session) {
    # Lazy panel UIs: bind a renderUI for each panel's placeholder. Shiny's
    # default suspendWhenHidden = TRUE means each one only fires when its
    # tab becomes visible, so app cold-start no longer pays the cost of
    # building 11 panels up front (~1.8s).
    for (i in seq_len(nrow(visualpanel_args))) {
      local({
        row <- visualpanel_args[i, ]
        output[[paste0("panel_ui_", row$panelid)]] <- shiny::renderUI({
          visualpanel_content(
            panel_header = row$panel_header[[1]],
            panel_desc   = row$panel_desc[[1]],
            panelid      = row$panelid,
            start_year   = row$start_year,
            end_year     = row$end_year,
            parquet_file = row$parquet_file
          )
        })
      })
    }

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
    observeEvent(input$visual_link, {
      shiny::updateTabsetPanel(session, "tabs", selected = visual_link_page)
    })
    observeEvent(input$download_link, {
      shiny::updateTabsetPanel(session, "tabs", selected = download_link_page)
    })
  }
  shinyApp(ui = ui, server = server)
}
