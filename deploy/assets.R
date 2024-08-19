# Script Header
# Title: Dashboard Assets
# Description: This script contains assets used in the shiny dashboard, such
# as cards and filters
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-08-05
# Date Last Edited: 2024-08-05

# Load Package
library(usdata)

# Scientific Notation
options(scipen=999)

# Create state list
state_ls <- setNames(as.list(as.character(usdata::state_stats$abbr)), usdata::state_stats$state)
state_ls[["All States"]] = "all_states"
# Create org_ls
org_ls <- as.list(sprintf("501(c)(%s)", c(1:10, "d", "e", "f", "k")))
org_ls[["All Organizations"]] = "all_orgs"
setNames(org_ls, unlist(org_ls))

# Cards

# Sector Size
cards_sector_size <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Nonprofits"),
    plotly::plotlyOutput("npnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Revenues (Real 2021 Million $)"),
    plotly::plotlyOutput("nprev")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Expenses ( Real 2021 Million $)"),
    plotly::plotlyOutput("npexp")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Assets (Real 2021 Million $)"),
    plotly::plotlyOutput("npass")
  )  
)

# Private Foundations
cards_private_foundation <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Grants"),
    plotly::plotlyOutput("grantnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Median Grant Size (Real 2021 $)"),
    plotly::plotlyOutput("medgrantsize")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Amount of Grants Paid ( Real 2021 $)"),
    plotly::plotlyOutput("grantamt")
  )  
)

# Labor
cards_labor <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Employees"),
    plotly::plotlyOutput("empnum")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Benefits (Real 2021 $)"),
    plotly::plotlyOutput("empbenefits")
  ),
  card(
    full_screen = TRUE,
    card_header("Total Payroll Taxes ( Real 2021 $)"),
    plotly::plotlyOutput("emppayroll")
  )  
)

# DAF
vbs_daf <- list(
  bslib::value_box(
    title = "Percentage of Organizations with a DAF",
    value = textOutput("daf_pct"),
    showcase = bsicons::bs_icon("percent"),
    theme = "primary"
  ),
  bslib::value_box(
    title = "Total Number of DAFs",
    value = textOutput("daf_num"),
    showcase = bsicons::bs_icon("building"),
    theme = "secondary"
  ),
  bslib::value_box(
    title = "Total DAF Contributions (Real 2021 $)",
    value = textOutput("daf_cntrb"),
    showcase = bsicons::bs_icon("currency-dollar"),
    theme = "info"
  ),
  bslib::value_box(
    title = "Total DAF Grants (Real 2021 $)",
    value = textOutput("daf_grants"),
    showcase = bsicons::bs_icon("currency-dollar"),
    theme = value_box_theme(bg = "#0a4c6a")
  ),
  bslib::value_box(
    title = "Total DAF Value (Real 2021 $)",
    value = textOutput("daf_value"),
    showcase = bsicons::bs_icon("currency-dollar"),
    theme = value_box_theme(bg = "#000000")
  )
)

# General
vbs_general <- bslib::value_box(
  title = "",
  value = textOutput("general")
)

# Filters
org_filter <- selectizeInput(
  "org_type_selector",
  label = "Select a 501(c) type",
  choices = org_ls,
  selected = org_ls$`All Organizations`
)

state_filter <- div(selectizeInput(
  "state_selector",
  label = "Select a State",
  choices = state_ls,
  selected = state_ls$`All States`
))

nested_geo_filter <- div(
  shiny::radioButtons(
    "geo_selector",
    label = "Additional Geographic Units",
    choices = list(
      "Counties" = "county",
      "Metro / Micro Areas" = "cbsa",
      "Entire State" = "state"
    ),
    selected = "state"
  )
)

county_cbsa_filter <- div(
  selectizeInput(
    "county_cbsa_selector", 
    label = "Select County/Metro", 
    choices = NULL
  )
)

industry_group_filter <- div(selectizeInput(
  "industry_group_selector",
  label = "Select an Industry",
  choices = list(
    "Arts, Culture, and Humanities" = "ART", 
    "Education (minus Universities)" = "EDU",
    "Health (minus Hospitals)" = "HEL",
    "Human Services" = "HMS",
    "International, Foreign Affairs" = "IFA",
    "Public, Societal Benefit" = "PSB",
    "Religion Related" = "REL",
    "Mutual/Membership Benefit" = "MMB",
    "Universities" = "UNI",
    "Hospitals" = "HOS",
    "All Groups" = "all_groups"
  ),
  selected = "all_groups"
))

size_filter <- div(selectizeInput(
  "size_selector",
  label = "Select an Asset Size",
  choices = list(
    "All Sizes" = 0, 
    "Under $100,000" = 1,
    "$100,000 - $499,999" = 2,
    "$500,000 - $999,999" = 3,
    "$1 Million - $4.99 Million" = 4,
    "$5 Million - $9.99 Million" = 5,
    "Above $10 Million" = 6
  ),
  selected = 0
))
