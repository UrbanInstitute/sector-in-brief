# Function to create nav panels
navpanel_wrapper <- function(title, panel_header, panel_desc, panelid) {
  all_cards <- data_ui(panelid, org_type_choices, date = TRUE)
  panel <- bslib::nav_panel(
    title = title,
    page_header_card(panel_header, panel_desc),
    bslib::card(
      card_header("Select Your Variables"),
      title = "",
      if (title == "Number" | title == "Finances"){
        bslib::layout_column_wrap(
          all_cards[["org_card"]],
          all_cards[["date_card"]],
          all_cards[["subsector_card"]],
          all_cards[["size_card"]],
          all_cards[["geo_card"]]
        )
      } else if (title == "PF_Grants"){
        bslib::layout_column_wrap(
          all_cards[["date_card"]],
          all_cards[["subsector_card"]],
          all_cards[["size_card"]],
          all_cards[["geo_card"]],
        )
      } else if (title == "DAF"){
        bslib::layout_column_wrap(
          all_cards[["subsector_card"]],
          all_cards[["size_card"]],
          all_cards[["geo_card"]]
        )
      },
      all_cards[["download_button"]]
    ),
    plot_ui(panelid)
  )
  return(panel)
}

navpanels <- tibble::tribble(
  ~title, ~panel_header, ~panel_desc, ~panelid,
  "Number", "Total Number of Nonprofits", "The number of organizations that are registered with the Internal Revenue Service (IRS).", "number",
  "Finances", "Financial indicators for nonprofits (including private foundations)", "XXX", "finances",
  "PF_Grants", "Private Foundation Grants", "XXX", "pf_grants",
  "DAF", "Donor Advised Funds (DAFs)", "XXX", "daf",
)
                 
  