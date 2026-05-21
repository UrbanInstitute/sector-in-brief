#' @title Lazy nav_panel shell for a visualization page.
#'
#' Returns just the title + a uiOutput placeholder. The actual content
#' (filter cards, plot panels, coverage notes) is rendered on demand by
#' a server-side renderUI tied to `panel_ui_<panelid>`. Shiny's default
#' suspendWhenHidden=TRUE means inactive tabs never run the builder.
#'
#' Other arguments (panel_header, panel_desc, start_year, end_year,
#' parquet_file) are accepted for purrr::pmap compatibility with
#' visualpanel_args but consumed later by visualpanel_content() at
#' render time.
visualpanel_builder <- function(title,
                                panel_header,
                                panel_desc,
                                panelid,
                                start_year,
                                end_year,
                                parquet_file) {
  bslib::nav_panel(
    title = title,
    shiny::uiOutput(paste0("panel_ui_", panelid))
  )
}
