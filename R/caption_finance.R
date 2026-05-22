#' Add a finance-specific definition line to a plot caption when the
#' panel's metric is Total Assets / Total Revenues / Total Expenses
#' (expands what "Other" means in the underlying breakdown). No-op for
#' any other metric.
#'
#' @param caption Running caption string.
#' @param agg_var Panel's metric column name.
#' @return Updated caption string.
caption_finance <- function(caption, agg_var) {
  if (agg_var == "Total Assets") {
    caption <- paste(
      caption,
      stringr::str_wrap("•	Other assets include secured mortgages and notes payable to unrelated third parties, escrow or custodial account liability, unsecured notes and loans, capital stock or trust principal, retained earnings, endowment, accumulated income, and net assets with or without donor restrictions.", width = 200),
      "\n"
    )
  } else if (agg_var == "Total Revenues") {
    caption <- paste(
      caption,
      stringr::str_wrap(
      "•	Other revenue sources include income from tax-exempt bond proceeds, gross rents, gross amount from sales of assets other than inventories, gross income from fundraising events, gross income from gaming activities, and gross sales of inventory.", width = 200),
      "\n"
    )
  } else if (agg_var == "Total Expenses") {
    caption <- paste(
      caption,
      stringr::str_wrap(
      "•	Other expenses include spending on employee services; advertising and promotion; royalties; IT; occupancy; travel, conferences; interest; affiliate payments; depreciation, depletion, and amortization; and insurance.", width = 200),
      "\n"
    )
  }
  return(caption)
}