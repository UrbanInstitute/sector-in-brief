# Static choice lists for the non-geo filters:
#   - ctype_tree_df: two-level tree of 501(c) types feeding urbn_tree()
#     in data_ui(). Top-level node groups child types and selecting it
#     in the UI cascades to all children.
#   - ctype_id: map from user-facing label → list of values stored in
#     the parquet's `Organization Type` column. Used by ctype_query().
#   - ctype_501c3 / ctype_other: groupings used by table_builder_ctype
#     for roll-up rules ("All 501(c)(3)" merge and "Other" tail collapse).
#
# `choice_builder(panelid)` below returns the panel-specific subset
# (e.g. PF panels offer only the private-foundation org type).

ctype_tree_df <- tibble::tribble(
  ~level1, ~level2,
  "501(c)(3) Organizations", "501(c)(3) - Public Charities",
  "501(c)(3) Organizations", "501(c)(3) - Private Foundations",
  "501(c)(4) - Social Welfare Organizations", NA,
  "Other Nonprofits", "501(c)(1) - Corporations Organized Under Act of Congress (including Federal Credit Unions)",
  "Other Nonprofits", "501(c)(2) - Title Holding Corporations for Exempt Organizations",
  "Other Nonprofits", "501(c)(5) - Labor, Agricultural, and Horticultural Organizations",
  "Other Nonprofits", "501(c)(6) - Business Leagues, etc.",
  "Other Nonprofits", "501(c)(7) - Social and Recreation Clubs",
  "Other Nonprofits", "501(c)(8) - Fraternal Beneficiary Societies",
  "Other Nonprofits", "501(c)(9) - Voluntary Employees' Beneficiary Associations",
  "Other Nonprofits", "501(c)(10) - Domestic Fraternal Societies",
  "Other Nonprofits", "501(c)(11) - Teachers' Retirement Fund Associations",
  "Other Nonprofits", "501(c)(12) - Benevolent Life Insurance Associations, Mutual Ditch or Irrigation Companies, Mutual or Cooperative Telephone Companies, or Like Organizations (if 85 percent or more of the organization's income consists of amounts collected from members for the sole purpose of meeting losses and expenses)",
  "Other Nonprofits", "501(c)(13) - Cemetery Companies (owned and operated exclusively for the benefit of their members or which are not operated for profit)",
  "Other Nonprofits", "501(c)(14) - State Chartered Credit Unions, Mutual Reserve Funds",
  "Other Nonprofits", "501(c)(15) - Mutual Insurance Companies or Associations",
  "Other Nonprofits", "501(c)(16) - Cooperative Organizations to Finance Crop Operations",
  "Other Nonprofits", "501(c)(17) - Supplemental Unemployment Benefit Trusts",
  "Other Nonprofits", "501(c)(18) - 501(c)(18) - Employee Funded Pension Trusts (created before June 25, 1959)",
  "Other Nonprofits", "501(c)(19) - Veterans' Organizations",
  "Other Nonprofits", "501(c)(20) - Group Legal Services Plan Organizations",
  "Other Nonprofits", "501(c)(21) - Black Lung Benefit Trusts",
  "Other Nonprofits", "501(c)(23) - Veterans' Organizations (created before 1880)",
  "Other Nonprofits", "501(c)(24) - Section 4049 ERISA Trusts",
  "Other Nonprofits", "501(c)(25) - Title Holding Corporations or Trusts with Multiple Parents",
  "Other Nonprofits", "501(c)(26) - State-Sponsored High-Risk Health Coverage Organizations",
  "Other Nonprofits", "501(c)(27) - State-Sponsored Worker's Compensation Reinsurance Organizations",
  "Other Nonprofits", "501(c)(29) - Qualified Nonprofit Health Insurance Issuers",
  "Other Nonprofits", "501(c)(d) - Religious and Apostolic Associations",
  "Other Nonprofits", "501(c)(e) - Cooperative Hospital Service Organizations",
  "Other Nonprofits", "501(c)(k) - Child Care Organizations"
)

ctype_id <- list(
  "501(c)(1) - Corporations Organized Under Act of Congress (including Federal Credit Unions)" = "501(c)(1)",
  "501(c)(2) - Title Holding Corporations for Exempt Organization" = "501(c)(2)", 
  "501(c)(3) - Public Charities" = "501(c)(3) Public Charities",
  "501(c)(3) - Private Foundations" = "501(c)(3) Private Foundations",
  "501(c)(4) - Social Welfare Organizations" = "501(c)(4)",
  "501(c)(5) - Labor, Agricultural, and Horticultural Organizations" = "501(c)(5)",
  "501(c)(6) - Business Leagues, etc." = "501(c)(6)",
  "501(c)(7) - Social and Recreation Clubs" = "501(c)(7)",
  "501(c)(8) - Fraternal Beneficiary Societies" = "501(c)(8)",
  "501(c)(9) - Voluntary Employees' Beneficiary Associations" = "501(c)(9)",
  "501(c)(10) - Domestic Fraternal Societies" = "501(c)(10)",
  "501(c)(11) - Teachers' Retirement Fund Associations" = "501(c)(11)",
  "501(c)(12) - Benevolent Life Insurance Associations, Mutual Ditch or Irrigation Companies, Mutual or Cooperative Telephone Companies, or Like Organizations (if 85 percent or more of the organization's income consists of amounts collected from members for the sole purpose of meeting losses and expenses)" = "501(c)(12)",
  "501(c)(13) - Cemetery Companies (owned and operated exclusively for the benefit of their members or which are not operated for profit)" = "501(c)(13)",
  "501(c)(14) - State Chartered Credit Unions, Mutual Reserve Funds" = "501(c)(14)",
  "501(c)(15) - Mutual Insurance Companies or Associations" = "501(c)(15)",
  "501(c)(16) - Cooperative Organizations to Finance Crop Operations" = "501(c)(16)",
  "501(c)(17) - Supplemental Unemployment Benefit Trusts" = "501(c)(17)",
  "501(c)(18) - Employee Funded Pension Trusts (created before June 25, 1959)" = "501(c)(18)", 
  "501(c)(19) - Veterans' Organizations" = "501(c)(19)",
  "501(c)(20) - Group Legal Services Plan Organizations" = "501(c)(20)",
  "501(c)(21) - Black Lung Benefit Trusts" = "501(c)(21)",
  "501(c)(23) - Veterans' Organizations (created before 1880)" = "501(c)(23)",
  "501(c)(24) - Section 4049 ERISA Trusts" = "501(c)(24)",
  "501(c)(25) - Title Holding Corporations or Trusts with Multiple Parents" = "501(c)(25)",
  "501(c)(26) - State-Sponsored High-Risk Health Coverage Organizations" = "501(c)(26)",
  "501(c)(27) - State-Sponsored Worker's Compensation Reinsurance Organizations" = "501(c)(27)",
  "501(c)(29) - Qualified Nonprofit Health Insurance Issuers" = "501(c)(29)",
  "501(c)(d) - Religious and Apostolic Associations" = "501(c)(d)",
  "501(c)(e) - Cooperative Hospital Service Organizations" = "501(c)(e)",
  "501(c)(k) - Child Care Organizations" = "501(c)(k)"
)

ctype_501c3 <- c("501(c)(3) Public Charities", "501(c)(3) Private Foundations")
ctype_other <- c(
  "501(c)(1)",
  "501(c)(2)",
  "501(c)(5)",
  "501(c)(6)",
  "501(c)(7)",
  "501(c)(8)",
  "501(c)(9)",
  "501(c)(10)",
  "501(c)(11)",
  "501(c)(12)",
  "501(c)(13)",
  "501(c)(14)",
  "501(c)(15)",
  "501(c)(16)",
  "501(c)(17)",
  "501(c)(18)",
  "501(c)(19)",
  "501(c)(20)",
  "501(c)(21)",
  "501(c)(23)",
  "501(c)(24)",
  "501(c)(25)",
  "501(c)(26)",
  "501(c)(27)",
  "501(c)(28)",
  "501(c)(29)",
  "501(c)(d)",
  "501(c)(e)",
  "501(c)(k)"
)


#' Build the per-panel filter choice list.
#'
#' Most panels share the same choices; PF panels override `ctype` to
#' offer only private foundations, and the download flow uses a
#' panelid of `"download"` to get a different size/subsector preset.
#'
#' @param panelid The active panel id from `visualpanel_args`, or
#'   `"download"` for the Custom Panel Datasets flow.
#' @return Named list with `ctype_tree_df`, `ctype_id`, `ctype`,
#'   `subsector`, `size`.
choice_builder <- function(panelid){
  choice_ls <- list(
    ctype_tree_df = ctype_tree_df,
    ctype_id = ctype_id,
    ctype = c(
      "501(c)(3) Organizations",
      "501(c)(4) - Social Welfare Organizations",
      "Other Nonprofits"
    ),
    # Subsector labels drop the trailing " - CODE" suffix that used to
    # double as a key hint. The 3-letter codes still appear in the
    # chip row (where space is at a premium) and in downloads; the
    # full name is what users want when scanning the filter list.
    subsector = list(
      "Arts, Culture, and Humanities" = "ART",
      "Education (minus Universities)" = "EDU",
      "Health (minus Hospitals)"       = "HEL",
      "Human Services"                 = "HMS",
      "International, Foreign Affairs" = "IFA",
      "Public, Societal Benefit"       = "PSB",
      "Religion Related"               = "REL",
      "Mutual/Membership Benefit"      = "MMB",
      "Universities"                   = "UNI",
      "Hospitals"                      = "HOS",
      "Environment and Animals"        = "ENV",
      "Other"                          = "UNU"
    ),
    size = list(
      "Under $100,000" = 1,
      "$100,000 - $499,999" = 2,
      "$500,000 - $999,999" = 3,
      "$1 Million - $4.99 Million" = 4,
      "$5 Million - $9.99 Million" = 5,
      "Above $10 Million" = 6
    )
  )
  # pf_amount (PF grants) and pri (program-related investments) are both
  # 990-PF-only metrics, so restrict the org-type tree to private
  # foundations.
  if (panelid %in% c("pf_amount", "pri")){
    choice_ls$ctype_tree_df <- tibble::tribble(
      ~level1, ~level2,
      "501(c)(3) Organizations", "501(c)(3) - Private Foundations"
    )
    choice_ls$ctype <- "501(c)(3) Organizations"
  }
  if (stringr::str_starts(panelid, "daf")){
    choice_ls$ctype_tree_df <- tibble::tribble(
      ~level1, ~level2,
      "501(c)(3) Organizations", "501(c)(3) - Public Charities"
    )
    choice_ls$ctype <- "501(c)(3) Organizations"
  }
  return(choice_ls)
}

ctype_level1 <- list(
  "501(c)(3) - Public Charities" = "501(c)(3) PUBLIC CHARITIES",
  "501(c)(3) - Private Foundations" = "501(c)(3) PRIVATE FOUNDATIONS",
  "501(c)(3) Public Charities and Private Foundations" = "501(c)(3)",
  "501(c)(4) - Social Welfare Organizations" = "501(c)(4)",
  "Other Nonprofits" = "Other Nonprofits"
)

ctype_level2 <- list(
  "501(c)(1) - Corporations Organized Under Act of Congress (including Federal Credit Unions)" = "501(c)(1)",
  "501(c)(2) - Title Holding Corporations for Exempt Organization" = "501(c)(2)", 
  "501(c)(5) - Labor, Agricultural and Horticultural Organizations" = "501(c)(5)",
  "501(c)(6) - Business Leagues, etc." = "501(c)(6)",
  "501(c)(7) - Social and Recreation Clubs" = "501(c)(7)",
  "501(c)(8) - Fraternal Beneficiary Societies" = "501(c)(8)",
  "501(c)(9) - Voluntary Employees' Beneficiary Associations" = "501(c)(9)",
  "501(c)(10) - Domestic Fraternal Societies" = "501(c)(10)",
  "501(c)(11) - Teachers' Retirement Fund Associations" = "501(c)(11)",
  "501(c)(12) - Benevolent Life Insurance Associations, Mutual Ditch or Irrigation Companies, Mutual or Cooperative Telephone Companies, or Like Organizations (if 85 percent or more of the organization's income consists of amounts collected from members for the sole purpose of meeting losses and expenses)" = "501(c)(12)",
  "501(c)(13) - Cemetery Companies (owned and operated exclusively for the benefit of their members or which are not operated for profit)" = "501(c)(13)",
  "501(c)(14) - State Chartered Credit Unions, Mutual Reserve Funds" = "501(c)(14)",
  "501(c)(15) - Mutual Insurance Companies or Associations" = "501(c)(15)",
  "501(c)(16) - Cooperative Organizations to Finance Crop Operations" = "501(c)(16)",
  "501(c)(17) - Supplemental Unemployment Benefit Trusts" = "501(c)(17)",
  "501(c)(18) - Employee Funded Pension Trusts (created before June 25, 1959)" = "501(c)(18)", 
  "501(c)(19) - Veterans' Organizations" = "501(c)(19)",
  "501(c)(21) - Black Lung Benefit Trusts" = "501(c)(21)",
  "501(c)(22) - Withdrawal Liability Payment Funds" = "501(c)(22)",
  "501(c)(25) - Title Holding Corporations or Trusts with Multiple Parents" = "501(c)(25)",
  "501(c)(26) - State-Sponsored High-Risk Health Coverage Organizations" = "501(c)(26)",
  "501(c)(27) - State-Sponsored Worker's Compensation Reinsurance Organizations" = "501(c)(27)",
  "501(c)(28) - National Railroad Retirement Investment Trust (45 U.S.C. 231n(j)" = "501(c)(28)",
  "501(c)(29) - Qualified Nonprofit Health Insurance Issuers" = "501(c)(29)",
  "501(d) - Religious and Apostolic Associations" = "501(d)",
  "501(e) - Cooperative Hospital Service Organizations" = "501(e)",
  "501(f) - Cooperative Service Organizations of Operating Educational Organizations" = "501(f)",
  "501(k) - Child Care Organizations" = "501(k)",
  "521(a) - Farmers' Cooperative Associations" = "521(a)"
)

state_choices <- list(
  "Alabama" = "AL",
  "Alaska" = "AK", 
  "Arizona" = "AZ",
  "Arkansas" = "AR",
  "California" = "CA",
  "Colorado" = "CO",
  "Connecticut" = "CT",
  "Delaware" = "DE",
  "District of Columbia" = "DC",
  "Florida" = "FL",
  "Georgia" = "GA",
  "Hawaii" = "HI",
  "Idaho" = "ID",
  "Illinois" = "IL",
  "Indiana" = "IN",
  "Iowa" = "IA",
  "Kansas" = "KS",
  "Kentucky" = "KY",
  "Louisiana" = "LA",
  "Maine" = "ME",
  "Maryland" = "MD",
  "Massachusetts" = "MA",
  "Michigan" = "MI",
  "Minnesota" = "MN",
  "Mississippi" = "MS",
  "Missouri" = "MO",
  "Montana" = "MT",
  "Nebraska" = "NE",
  "Nevada" = "NV",
  "New Hampshire" = "NH",
  "New Jersey" = "NJ",
  "New Mexico" = "NM",
  "New York" = "NY",
  "North Carolina" = "NC",
  "North Dakota" = "ND",
  "Ohio" = "OH",
  "Oklahoma" = "OK",
  "Oregon" = "OR",
  "Pennsylvania" = "PA",
  "Rhode Island" = "RI",
  "South Carolina" = "SC",
  "South Dakota" = "SD",
  "Tennessee" = "TN",
  "Texas" = "TX",
  "Utah" = "UT",
  "Vermont" = "VT",
  "Virginia" = "VA",
  "Washington" = "WA",
  "West Virginia" = "WV",
  "Wisconsin" = "WI",
  "Wyoming" = "WY"
)

asset_size_ls <- list(
  "1" = "Under $100,000",
  "2" = "$100,000 - $499,999",
  "3" = "$500,000 - $999,999",
  "4" = "$1 Million - $4.99 Million",
  "5" = "$5 Million - $9.99 Million",
  "6" = "Above $10 Million"
)

asset_sizes <- list(
  "Under $100,000",
  "$100,000 - $499,999",
  "$500,000 - $999,999",
  "$1 Million - $4.99 Million",
  "$5 Million - $9.99 Million",
  "Above $10 Million"
)