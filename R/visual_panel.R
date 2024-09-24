# Function to create nav panels
navpanel_wrapper <- function(title, panel_header, panel_desc, panelid) {
  panel <- bslib::nav_panel(
    title = title,
    page_header_card(panel_header, panel_desc),
    data_ui(panelid, org_type_choices, date = TRUE),
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

navpanels <- purrr::pmap(navpanels, navpanel_wrapper)