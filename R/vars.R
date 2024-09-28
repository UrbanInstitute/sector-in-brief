# List of vars to load for each data set
default_vars <- c(
  "Organization Type", 
  "Subsector", 
  "Asset Size", 
  "Census Region", 
  "Census State",
  "Census County",
  "Census CBSA"
)


daf_vars <- c(
  "Number of Nonprofits",
  "Has DAF",
  "Number of DAFs",
  "Total Contributions",
  "Total Grants",
  "Total Value",
  "Proportion With DAFs"
)

var_ls <- list(
  "Number" = c(default_vars, "Number of Nonprofits", "Year"),
  "Assets" = c(default_vars, "Total Assets", "Tax Year"),
  "Revenues" = c(default_vars, "Total Revenues", "Tax Year"),
  "Expenses" = c(default_vars, "Total Expenses", "Tax Year"),
  "Benefits" = c(default_vars, "Total Benefits", "Tax Year"),
  "Payroll Taxes" = c(default_vars, "Total Payroll Taxes", "Tax Year"),
  "Private Foundations" = c(default_vars, "Total Contributions", "Tax Year"),
  "Donor Advised Funds" = c(default_vars, daf_vars)
)