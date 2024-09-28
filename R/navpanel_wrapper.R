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
      } else if (title %in% c("Total Grant Amount")) {
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

visualpanel_args <- tibble::tribble(
  ~title, ~panel_header, ~panel_desc, ~panelid,
  "Number", "Total Number of Nonprofits", "The number of organizations that are registered with the Internal Revenue Service (IRS).", "number",
  "Assets", "Total Assets", "The aggregate value of everything nonprofits own", "assets",
  "Revenues", "Total Revenues", "The total amount of money that nonprofits receive", "revenues",
  "Expenses", "Total Expenses", "The total amount of money that nonprofits spend", "expenses",
  "Benefits", "Total Benefits", "The aggregate value of salaries, wages, benefits, and pension plan contributions nonprofits and private foundations pay to/on behalf of employees.", "benefits",
  "Payroll Taxes", "Total Payroll Taxes", "The estimated aggregate value of the taxes nonprofits and private foundations pay on employee earnings.", "payroll",
  "Total Grant Amount", "Total Amount of Grants Paid", "Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.", "pf_amount",
  "Number of DAFs", "Total Number of Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_number",
  "DAF Contributions", "Total Contributions to Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_contributions",
  "DAF Grants", "Total Grants from Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_grants",
  "DAF Value", "Total Value of Donor Advised Funds", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_value",
  "DAF Proportion", "Percentage of nonprofits that maintain a DAF", "Donor-advised funds (DAFs) are charitable giving accounts that allow donors to receive an immediate tax benefit and recommend grants from the fund over time.", "daf_proportion"
)
                 
  