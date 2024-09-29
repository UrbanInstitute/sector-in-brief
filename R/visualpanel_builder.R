# Function to create nav panel template for each visual page
visualpanel_builder <- function(title, panel_header, panel_desc, panelid) {
  all_cards <- data_ui(panelid, org_type_choices, date = TRUE)
  panel <- bslib::nav_panel(
    title = title,
    page_header_card(panel_header, panel_desc),
    bslib::card(
      bslib::card_title("Select Your Filters", class = "var-select-header"),
      title = "",
      if (title %in% c("Number", "Assets", "Revenues", "Expenses", "Benefits", "Payroll Taxes")) {
        bslib::layout_column_wrap(all_cards[["org_card"]], all_cards[["date_card"]], all_cards[["subsector_card"]], all_cards[["size_card"]], all_cards[["geo_card"]])
      } else if (title %in% c("Private Foundation Grants")) {
        bslib::layout_column_wrap(all_cards[["date_card"]], all_cards[["subsector_card"]], all_cards[["size_card"]], all_cards[["geo_card"]], )
      } else if (grepl("DAF", title)) {
        bslib::layout_column_wrap(all_cards[["subsector_card"]], all_cards[["size_card"]], all_cards[["geo_card"]])
      },
      all_cards[["process_button"]]
    ),
    plot_ui(panelid)
  )
  return(panel)
}

                 
  