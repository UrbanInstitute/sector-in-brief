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

var_ls <- list(
  "Number" = c(default_vars, "Number of Nonprofits", "Year"),
  "Assets" = c(default_vars, "Total Assets", "Tax Year"),
  "Revenues" = c(default_vars, "Total Revenues", "Tax Year"),
  "Expenses" = c(default_vars, "Total Expenses", "Tax Year"),
  "Benefits" = c(default_vars, "Total Benefits", "Tax Year"),
  "Payroll Taxes" = c(default_vars, "Total Payroll Taxes", "Tax Year")
  )