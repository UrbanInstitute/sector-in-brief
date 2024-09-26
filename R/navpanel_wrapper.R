# Function to create nav panels
navpanel_wrapper <- function(title, panel_header, panel_desc, panelid) {
  all_cards <- data_ui(panelid, org_type_choices, date = TRUE)
  panel <- bslib::nav_panel(
    title = title,
    page_header_card(panel_header, panel_desc),
    bslib::card(
      card_header("Select Your Variables"),
      title = "",
      if (title %in% c("Number", "Assets")){
        bslib::layout_column_wrap(
          all_cards[["org_card"]],
          all_cards[["date_card"]],
          all_cards[["subsector_card"]],
          all_cards[["size_card"]],
          all_cards[["geo_card"]]
        )
      } else if (grepl("PF", title)){
        bslib::layout_column_wrap(
          all_cards[["date_card"]],
          all_cards[["subsector_card"]],
          all_cards[["size_card"]],
          all_cards[["geo_card"]],
        )
      } else if (grepl("DAF", title)){
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
  "Assets", "Total Assets", "The aggregate value of everything nonprofits own", "assets",
  "PF_Number", "Total Number of Grants", "Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.", "pf_number",
  "PF_Median", "Median Grant Size", "Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.", "pf_median",
  "PF_Amount", "Total Amount of Grants Paid", "Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.", "pf_amount",
  "DAF_number", "Total Number of Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_number",
  "DAF_contributions", "Total Contributions to Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_contributions",
  "DAF_grants", "Total Grants from Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_grants",
  "DAF_value", "Total Value of Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_value",
  "DAF_proportion", "Percentage of nonprofits that maintain a DAF", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_proportion"
)
                 
  