#-------------------------------------------------------------------------------
# File: R/options_nogeo.R
# Author: Thiyaghessan Poongundranar [tpoongundranar@urban.org]
# Date Created: 2024-06-01
# Date Modified: 2025-07-02
# Purpose: Contains the options used in the bslib card filters for the visuals
# tab for all filters except geography.
# Usage: Creates internal objects containing disaggregation options for each 
# filter, triggered using choice_builder()
# Dependencies:
#   - tibble
#   - stringr
#   - usethis
# Notes:
#  - organization type: options for 501c type filters based on tab selected
#  - subsector: options for 12 NTEE code major groups based on tab selected
#  - size: options for expense size based on tab selected
#-------------------------------------------------------------------------------

# Tibble of options used in organization type tree diagram filter
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

ctype_pf_tree_df <- tibble::tribble(
  ~level1, ~level2,
  "501(c)(3) Organizations", "501(c)(3) - Private Foundations"
)

ctype_daf_tree_df <- tibble::tribble(
  ~level1, ~level2,
  "501(c)(3) Organizations", "501(c)(3) - Public Charities"
)

# List of options for each 501c type with descriptions
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

# Vector of parent options for primary 501c type groupings
ctype_root <- c("501(c)(3) Organizations", 
                "501(c)(4) - Social Welfare Organizations",
                "Other Nonprofits")
# Vector of options for the different 501c3 types
ctype_501c3 <- c("501(c)(3) Public Charities", "501(c)(3) Private Foundations")
# Vector of options for all non 501c3 organization types
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

# List of options for 12 NTEE Major groups
ntee_maj_12_ls <- list(
  "Arts, Culture, and Humanities - ART" = "ART", 
  "Education (minus Universities) - EDU" = "EDU",
  "Health (minus Hospitals) - HEL" = "HEL",
  "Human Services - HMS" = "HMS",
  "International, Foreign Affairs - IFA" = "IFA",
  "Public, Societal Benefit - PSB" = "PSB",
  "Religion Related - REL" = "REL",
  "Mutual/Membership Benefit - MMB" = "MMB",
  "Universities - UNI" = "UNI",
  "Hospitals - HOS" = "HOS",
  "Environment and Animals - ENV" = "ENV",
  "Other" = "UNU"
)

# List of options used for expense size filters
size_encode_ls <- list(
  "Under $100,000" = 1,
  "$100,000 - $499,999" = 2,
  "$500,000 - $999,999" = 3,
  "$1 Million - $4.99 Million" = 4,
  "$5 Million - $9.99 Million" = 5,
  "Above $10 Million" = 6
)
size_decode_ls <- list(
  "1" = "Under $100,000",
  "2" = "$100,000 - $499,999",
  "3" = "$500,000 - $999,999",
  "4" = "$1 Million - $4.99 Million",
  "5" = "$5 Million - $9.99 Million",
  "6" = "Above $10 Million"
)

usethis::use_data(
  ctype_tree_df,
  ctype_pf_tree_df,
  ctype_daf_tree_df,
  ctype_id,
  ctype_root,
  ctype_501c3,
  ctype_other,
  ntee_maj_12_ls,
  size_encode_ls,
  size_decode_ls,
  overwrite = TRUE,
  internal = TRUE
)


#' @title Build a list of choices for filters based on panelid
#' 
#' @description This function builds a list of choices for filters based on the
#' panelid provided. It returns a list containing the organization type tree,
#' organization type id, organization type options, subsector options, and size
#' options.
#' 
#' @param panelid The id of the visual page
#' 
#' @return A list containing the choices for filters
choice_builder <- function(panelid){
  choice_ls <- list(
    ctype_tree_df = ctype_tree_df,
    ctype_id = ctype_id,
    ctype = ctype_root,
    subsector = ntee_maj_12_ls,
    size = size_encode_ls
  )
  # Change organization type filter options for PF and DAF tabs
  if (panelid %in% c("pf_amount", "pri")){
    choice_ls$ctype_tree_df <- ctype_pf_tree_df
    choice_ls$ctype <- "501(c)(3) Organizations"
  }
  else if (stringr::str_starts(panelid, "daf")){
    choice_ls$ctype_tree_df <- ctype_daf_tree_df
    choice_ls$ctype <- "501(c)(3) Organizations"
  }
  return(choice_ls)
}