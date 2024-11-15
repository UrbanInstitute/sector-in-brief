#' @title Plot captions for finances
caption_finance <- function(caption, agg_var) {
  if (agg_var == "Total Assets") {
    caption <- paste(
      caption,
      "•	Other assets include secured mortgages and notes payable to unrelated third parties, escrow or custodial account liability, unsecured notes and loans, capital stock or trust principal, retained earnings, endowment, accumulated income and net assets with/without donor restrictions.",
      "\n"
    )
  } else if (agg_var == "Total Revenues") {
    caption <- paste(
      caption,
      "•	Other revenue sources include income from tax-exempt bond proceeds, gross rents, gross amount from sales of assets other than inventories, gross income from fundraising events, gross income from gaming activities and gross sales of inventory.",
      "\n"
    )
  } else if (agg_var == "Total Expenses") {
    caption <- paste(
      caption,
      "•	Other expenses include spending on employee services, advertising and promotion, royalties, IT, occupancy, travel, conferences, interest, affiliate payments, depreciation, depletion and amortization and insurance.",
      "\n"
    )
  }
  return(caption)
}