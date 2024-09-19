# Script to build organization filters

source("R/build_filters.R")

org_type_choices <- list(
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

daf_org_choices <- c(
  "501(c)(3) Public Charities",
  "501(c)(4) Social Welfare Organizations",
  "Other Nonprofits",
  "All Nonprofits"
)
nn_org_choices <- c(
  "501(c)(3) Public Charities",
  "501(c)(3) Private Foundations",
  "501(c)(4) Social Welfare Organizations",
  "Other Nonprofits",
  "All Nonprofits"
)

vars <- tibble::tribble(
  ~ inputId, ~ label, ~ choices, ~ width,
  "daf_org_level", NULL, daf_org_choices, NULL,
  "nn_org_level", NULL, nn_org_choices, NULL,
  "daf_other_orgs", "Other 501(c) Types", org_type_choices, "500px",
  "nn_other_orgs", "Other 501(c) Types", org_type_choices, "500px"
)

org_filters <- build_filters(selectizeInput, vars)
