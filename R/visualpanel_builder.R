#' @title Function to create nav panel template for each visual page
#' @param title The title of the visual page
#' @param panel_header The header of the visual page
#' @param panel_desc The description of the visual page
#' @param panelid The id of the visual page
#' @param start_year The start year of the data
#' @param end_year The end year of the data
visualpanel_builder <- function(title,
                                panel_header,
                                panel_desc,
                                panelid,
                                start_year,
                                end_year,
                                parquet_file) {
  choices <- choice_builder(panelid)
  all_cards <- data_ui(panelid, choices, start_year, end_year)
  panel <- bslib::nav_panel(
    title = title,
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
    plot_ui(panelid)
  )
  return(panel)
}


