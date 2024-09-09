# Script Header
# Description: This script contains all sidebar objects
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-08-23
# Date Last Edited: 2024-08-23

sidebar <- bslib::sidebar(
  title = "Select Data for Nonprofits by:",
  id = "sidebar",
  open = FALSE,
  bslib::accordion(
    bslib::accordion_panel(
      "Organization Type",
      org_filter
    ),
    bslib::accordion_panel(
      "Geography",
      state_filter,
      shiny::conditionalPanel(
        nested_geo_filter,
        condition = "input.state_selector != 'all_states'"
      ),
      shiny::conditionalPanel(
        county_cbsa_filter,
        condition = "input.geo_selector == 'county' | input.geo_selector == 'cbsa'"
      ),
      shiny::conditionalPanel(
        state_compare_filter,
        condition = "input.geo_selector == 'statecompare'"
      )
    ),
    bslib::accordion_panel(
      "Subsector",
      industry_group_filter
    ),
    bslib::accordion_panel(
      "Size",
      size_filter
    ),
    bslib::input_task_button(
      id = "update_plot",
      style = "margin-top: 32px; margin-left: 32px",
      label = "Retrieve Data",
      label_busy = "Updating Plots",
      type = "primary"
    )
  ),
  shiny::img(src="ui-logo-rgb.png")
)