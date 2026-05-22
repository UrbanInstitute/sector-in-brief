#' Build one lazy nav_panel shell.
#'
#' Returns just the title + a `uiOutput("panel_ui_<panelid>")`
#' placeholder. The actual content (filter cards, plot panels,
#' coverage notes) is rendered on demand by a server-side renderUI
#' tied to that slot. Shiny's default `suspendWhenHidden = TRUE` means
#' inactive tabs never run the heavy builder.
#'
#' The non-id arguments are accepted for `purrr::pmap` compatibility
#' with `visualpanel_args`; the renderUI uses them later via
#' `visualpanel_content()`.
#'
#' @param title Tab title.
#' @param panelid Unique slug used to namespace the Shiny module and
#'   the renderUI output slot.
#' @param panel_header,panel_desc,start_year,end_year,parquet_file
#'   Consumed by `visualpanel_content()` at render time.
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
