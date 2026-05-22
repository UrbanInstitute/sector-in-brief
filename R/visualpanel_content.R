# Build the inside of a visualization panel — header, coverage notes,
# filter card, plot/table UI. Returned as a tagList so a wrapping
# uiOutput can drop it in. Splitting this out from visualpanel_builder
# means a tab's heavy widgets (plot_ui, data_ui, coverage_notes_card)
# only run when the tab activates, not at app boot.

#' Render the lazy contents of one visualization panel.
#'
#' @param panel_header Bold heading shown above the filters.
#' @param panel_desc Descriptive paragraph below the header.
#' @param panelid Module id (also used as the parent uiOutput slot).
#' @param start_year,end_year Date-slider bounds (resolved from the
#'   manifest at boot — see `resolve_visualpanel_year_ranges()`).
#' @param parquet_file Source filename, used by the coverage-notes
#'   card to look up per-file notes from `data_dictionary.parquet`.
#' @return A `htmltools::tagList`.
visualpanel_content <- function(panel_header,
                                panel_desc,
                                panelid,
                                start_year,
                                end_year,
                                parquet_file) {
  choices <- choice_builder(panelid)
  all_cards <- data_ui(panelid, choices, start_year, end_year)
  ns <- shiny::NS(panelid)
  htmltools::tagList(
    page_header_card(panel_header, panel_desc),
    coverage_notes_card(parquet_file),
    bslib::card(
      class = "card-filter",
      bslib::card_title("Select Your Filters", class = "bg-light-gray"),
      title = "",
      bslib::layout_column_wrap(
        all_cards[["org_card"]],
        all_cards[["subsector_card"]],
        all_cards[["size_card"]],
        all_cards[["geo_card"]],
        all_cards[["date_card"]]
      ),
      all_cards[["process_button"]]
    ),
    # Active-filter chips, rendered by data_server() from the inputs
    # snapshot. Empty when no filter is narrowed from default.
    shiny::uiOutput(ns("filter_chips"), class = "filter-chip-row"),
    plot_ui(panelid)
  )
}
