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
                                end_year) {
  choices <- choice_builder(panelid)
  all_cards <- data_ui(panelid, choices, start_year, end_year)
  panel <- bslib::nav_panel(
    title = title,
    page_header_card(panel_header, panel_desc),
    plot_ui(panelid),
    bslib::card(
      bslib::card_title("Select Your Filters", class = "var-select-header"),
      title = "",
      if (title %in% c("Number",
                       "Assets",
                       "Revenues",
                       "Expenses",
                       "Benefits",
                       "Payroll Taxes")) {
        bslib::layout_column_wrap(all_cards[["org_card"]], all_cards[["date_card"]], all_cards[["subsector_card"]], all_cards[["size_card"]], all_cards[["geo_card"]])
      } else if (title %in% c("Private Foundation Grants")) {
        bslib::layout_column_wrap(all_cards[["date_card"]], all_cards[["subsector_card"]], all_cards[["size_card"]], all_cards[["geo_card"]], )
      } else if (grepl("DAF", title)) {
        bslib::layout_column_wrap(all_cards[["subsector_card"]], all_cards[["size_card"]], all_cards[["geo_card"]])
      },
      all_cards[["process_button"]]
    )
  )
  return(panel)
}


