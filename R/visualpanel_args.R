###############################################################################
# File: visualpanel_args.R
# Author: Thiyaghessan [tpoongundranar@urban.org]
# Date created: 2024-06-01
# Date last edited: 2025-07-02
# Purpose: Define the arguments for visual panels in the application.
# Usage: This file is sourced by the main application to create visual panels in
# conjunction with the visualpanel_mapper.R and visualpanel_builder.R scripts.
# Details:
# Provides the following arguments: Title, text in panel head, description text
# for each panel, unique object id, start and end years to filer datasets.
################################################################################

visualpanel_args <- tibble::tribble(
  ~title, ~panel_header, ~panel_desc, ~panelid, ~start_year, ~end_year,
  "Numbers", "Number of Nonprofits", number_of_nonprofits, "number", 1989, 2024,
  "Assets", "Assets", assets_desc, "assets", 1989, 2021,
  "Revenues", "Revenues", revenue_desc, "revenues", 1989, 2021,
  "Expenses", "Expenses", expenses_desc, "expenses", 1989, 2021,
  "Benefits", "Benefits", benefits_desc, "benefits", 1989, 2021,
  "Government Grants", "Government Grants", gov_grants_desc, "gov_grants", 2021, 2021,
  "Private Foundation Grants", "Grants", grants_desc, "pf_amount", 1989, 2021,
  "Program Related Investments", "Program Related Investments", pri_desc, "pri", 2020, 2023,
  "Number of DAFs", "Number of DAFs", daf_number_desc, "daf_number", 2021, 2021,
  "DAF Contributions", "DAF Contributions", daf_contributions_desc,"daf_contributions", 2021, 2021,
  "DAF Grants", "DAF Grants", daf_grants_desc, "daf_grants", 2021, 2021,
  "DAF Value", "DAF Value", daf_value_desc, "daf_value", 2021, 2021,
  "DAF Proportion", "Percentage of organizations that maintain a DAF", daf_proportion_desc, "daf_proportion", 2021, 2021,
)