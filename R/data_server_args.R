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

data_server_args <- list(
  "Number" = list(
    path = "data/number_nonprofits.parquet",
    vars = c(default_vars, "Number of Nonprofits", "Year"),
    id = "number",
    year_var = "Year",
    agg_var = "Number of Nonprofits",
    ytitle = "Number of Nonprofits",
    xtitle = "Year",
    title_prefix = "Number of Nonprofits",
    time_series = TRUE
  ),
  "Assets" = list(
    path = "data/finances.parquet",
    vars = c(default_vars, "Total Assets", "Tax Year"),
    id = "assets",
    year_var = "Tax Year",
    agg_var = "Total Assets",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Assets",
    time_series = TRUE
  ),
  "Revenues" = list(
    path = "data/finances.parquet",
    vars = c(default_vars, "Total Revenues", "Tax Year"),
    id = "revenues",
    year_var = "Tax Year",
    agg_var = "Total Revenues",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Revenues",
    time_series = TRUE
  ),
  "Expenses" = list(
    path = "data/finances.parquet",
    vars = c(default_vars, "Total Expenses", "Tax Year"),
    id = "expenses",
    year_var = "Tax Year",
    agg_var = "Total Expenses",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Expenses",
    time_series = TRUE
  ),
  "Benefits" = list(
    path = "data/finances.parquet",
    vars = c(default_vars, "Total Benefits", "Tax Year"),
    id = "benefits",
    year_var = "Tax Year",
    agg_var = "Total Benefits",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Benefits",
    time_series = TRUE
  ),
  "Payroll Taxes" = list(
    path = "data/finances.parquet",
    vars = c(default_vars, "Total Payroll Taxes", "Tax Year"),
    id = "payroll",
    year_var = "Tax Year",
    agg_var = "Total Payroll Taxes",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Payroll Taxes",
    time_series = TRUE
  ),
  "Private Foundation Grants" = list(
    path = "data/pf_grants.parquet",
    vars = c(default_vars, "Total Contributions", "Tax Year"),
    id = "pf_amount",
    year_var = "Tax Year",
    agg_var = "Total Contributions",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Grants Made By Private Foundations",
    time_series = TRUE
  ),
  "Average Foundation Grantmaking" = list(
    path = "data/pf_grants.parquet",
    vars = c(default_vars, "Total Contributions", "Tax Year"),
    id = "pf_avg",
    year_var = "Tax Year",
    agg_var = "Total Contributions",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Average Grantmaking for",
    time_series = TRUE
  ),
  "Number of DAFs" = list(
    path = "data/daf.parquet",
    vars = c(default_vars, "Number of DAFs", "Tax Year"),
    id = "daf_number",
    year_var = "Tax Year",
    agg_var = "Number of DAFs",
    ytitle = "Number of DAFs",
    xtitle = "Tax Year",
    title_prefix = "Number of DAFs",
    time_series = FALSE
  ),
  "DAF Contributions" = list(
    path = "data/daf.parquet",
    vars = c(default_vars, "Total Contributions", "Tax Year"),
    id = "daf_contributions",
    year_var = "Tax Year",
    agg_var = "Total Contributions",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total DAF Contributions",
    time_series = FALSE
  ),
  "DAF Grants" = list(
    path = "data/daf.parquet",
    vars = c(default_vars, "Total Grants", "Tax Year"),
    id = "daf_grants",
    year_var = "Tax Year",
    agg_var = "Total Grants",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total DAF Grants",
    time_series = FALSE
  ),
  "DAF Value" = list(
    path = "data/daf.parquet",
    vars = c(default_vars, "Total Value", "Tax Year"),
    id = "daf_value",
    year_var = "Tax Year",
    agg_var = "Total Value",
    ytitle = "Dollars",
    xtitle = "Tax Year",
    title_prefix = "Total Value of DAFs",
    time_series = FALSE
  ),
  "DAF Proportion" = list(
    path = "data/daf.parquet",
    vars = c(default_vars, "Has DAF", "Number of Nonprofits", "Number of DAFs", "Tax Year"),
    id = "daf_proportion",
    year_var = "Tax Year",
    agg_var = "Proportion with DAFs",
    ytitle = "Percentage",
    xtitle = "Tax Year",
    title_prefix = "Percentage of Nonprofits with DAFs",
    time_series = FALSE
  )
)