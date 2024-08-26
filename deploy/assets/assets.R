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
    card_header("Total Number of Nonprofits by Year (1995 - 2024)"),
    plotly::plotlyOutput("npnum"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total number of nonprofits – The number of organizations that are 
      registered with the Internal Revenue Service (IRS)."),
      p("Filing Year - The year the tax return was filed")
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Total Revenues by Year (1989 - 2021)"),
    plotly::plotlyOutput("nprev"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total revenues – The aggregate funds nonprofits receive from  all 
        sources."),
      p("Tax Year -  Accounting period of tax return")
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Total Expenses by Year (1989 - 2021)"),
    plotly::plotlyOutput("npexp"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total Expenses – The aggregate money nonprofits pay to achieve their 
      missions and operate their organizations."),
      p("Tax Year -  Accounting period of tax return")
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Total Assets by Year (1989 - 2021)"),
    plotly::plotlyOutput("npass"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total assets – The aggregate value of everything nonprofits own."),
      p("Tax Year -  Accounting period of tax return")
    )
  )  
)

# Private Foundations
cards_private_foundation <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Grants by Year (1989 - 2021)"),
    shiny::plotOutput("grantnum"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total number of grants – The aggregate number of grants that private 
        foundations reported making."),
      p("Tax Year -  Accounting period of tax return")
    ),
    card_footer(
      "Note: Dotted lines indicate missing data"
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Median Grant Size by Year (1989 - 2021)"),
    shiny::plotOutput("medgrantsize"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Median grant size – The median value of all grants that private 
        foundations reported making."),
      p("Tax Year -  Accounting period of tax return")
    ),
    card_footer(
      "Note: Dotted lines indicate missing data"
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Total Amount of Grants Paid by Year (1989 - 2021)"),
    shiny::plotOutput("grantamt"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total amount of grants paid – The aggregate value of all grants that 
        private foundations reported making."),
      p("Tax Year -  Accounting period of tax return")
    ),
    card_footer(
      "Note: Dotted lines indicate missing data"
    )
  )  
)

# Labor
cards_labor <- list(
  card(
    full_screen = TRUE,
    card_header("Total Number of Employees"),
    plotly::plotlyOutput("empnum"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total amount of grants paid – The aggregate value of all grants that 
        private foundations reported making."),
      p("Tax Year -  Accounting period of tax return")
    ),
    card_footer(
      "Note: Accurate data is only available for 2000 and beyond"
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Total Benefits (Real 2021 $)"),
    plotly::plotlyOutput("empbenefits"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total benefits – The aggregate value of the salaries and wages, 
        benefits, pension plan accruals and contributions, and 401(k) and 403(b)
        contributions nonprofits and private foundations pay to/on behalf of 
        employees."),
      p("Tax Year -  Accounting period of tax return")
    ),
    card_footer(
      "Note: Accurate data is only available for 2000 and beyond"
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Total Payroll Taxes ( Real 2021 $)"),
    plotly::plotlyOutput("emppayroll"),
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Variables"),
      p("Total payroll taxes – The estimated aggregate value of the taxes 
        nonprofits and private foundations pay on employee earnings."),
      p("Tax Year -  Accounting period of tax return")
    ),
    card_footer(
      "Note: Accurate data is only available for 2000 and beyond"
    )
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
  bslib::card(
    id = "daf_pct_desc",
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Description"),
      p("Percentage of organizations that maintain a DAF – The percentage of 
         nonprofits that sponsor a DAF, meaning they hold and operate funds 
         for donors."),
    )
  ),
  bslib::value_box(
    title = "Total Number of DAFs",
    value = textOutput("daf_num"),
    showcase = bsicons::bs_icon("building"),
    theme = "secondary"
  ),
  bslib::card(
    id = "daf_num_desc",
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Description"),
      p("Total number of DAFs – The aggregate number of DAF accounts that 
        nonprofits sponsor. One DAF sponsor can hold multiple DAF accounts."),
    )
  ),
  bslib::value_box(
    title = "Total DAF Contributions (Real 2021 $)",
    value = textOutput("daf_cntrb"),
    showcase = bsicons::bs_icon("currency-dollar"),
    theme = "info"
  ),
  bslib::card(
    id = "daf_cntrb_desc",
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Description"),
      p("Total DAF contributions – The aggregate value of the money that 
        donors put into the DAFs that nonprofits sponsor."),
    )
  ),  
  bslib::value_box(
    title = "Total DAF Grants (Real 2021 $)",
    value = textOutput("daf_grants"),
    showcase = bsicons::bs_icon("currency-dollar"),
    theme = value_box_theme(bg = "#0a4c6a")
  ),
  bslib::card(
    id = "daf_grants_desc",
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Description"),
      p("Total DAF grants – The aggregate value of the money that DAF sponsors 
         disburse at the recommendation of donors.")
    )
  ),
  bslib::value_box(
    title = "Total DAF Value (Real 2021 $)",
    value = textOutput("daf_value"),
    showcase = bsicons::bs_icon("currency-dollar"),
    theme = value_box_theme(bg = "#000000")
  ),
  bslib::card(
    id = "daf_value_desc",
    card_body(
      fill = FALSE,
      gap = 0,
      card_title("Description"),
      p("Total DAF value – The aggregate value of the money that nonprofits 
        hold in the DAFs they sponsor.")
    )
  )
)

# General Statements
vbs_general_ss <- bslib::value_box(
  title = "",
  value = textOutput("general_ss")
)

vbs_general_pf <- bslib::value_box(
  title = "",
  value = textOutput("general_pf")
)

vbs_general_emp <- bslib::value_box(
  title = "",
  value = textOutput("general_emp")
)

vbs_general_daf <- bslib::value_box(
  title = "",
  value = textOutput("general_daf")
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

state_compare_filter <- div(selectizeInput(
  "state_compare_selector",
  label = "Select another state for comparison",
  choices = setNames(as.list(as.character(usdata::state_stats$abbr)), usdata::state_stats$state),
  selected = NULL
))

nested_geo_filter <- div(
  shiny::radioButtons(
    "geo_selector",
    label = "Additional Geographic Units",
    choices = list(
      "Counties" = "county",
      "Metro / Micro Areas" = "cbsa",
      "Entire State" = "state",
      "State Comparison" = "statecompare"
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
  label = "Select a Subsector",
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
