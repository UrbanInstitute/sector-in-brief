visualpanel_args <- tibble::tribble(
  ~title, ~panel_header, ~panel_desc, ~panelid, ~start_year, ~end_year, ~parquet_file,
  "Numbers", "Number of Nonprofits", number_of_nonprofits, "number", 1989, 2024, "number_nonprofits.parquet",
  "Assets", "Assets", assets_desc, "assets", 1989, 2021, "finances.parquet",
  "Revenues", "Revenues", revenue_desc, "revenues", 1989, 2021, "finances.parquet",
  "Expenses", "Expenses", expenses_desc, "expenses", 1989, 2021, "finances.parquet",
  "Benefits", "Benefits", benefits_desc, "benefits", 1989, 2021, "finances.parquet",
  "Private Foundation Grants", "Grants", grants_desc, "pf_amount", 1989, 2021, "pf_grants.parquet",
  "Number of DAFs", "Number of DAFs", daf_number_desc, "daf_number", 2021, 2021, "daf.parquet",
  "DAF Contributions", "DAF Contributions", daf_contributions_desc,"daf_contributions", 2021, 2021, "daf.parquet",
  "DAF Grants", "DAF Grants", daf_grants_desc, "daf_grants", 2021, 2021, "daf.parquet",
  "DAF Value", "DAF Value", daf_value_desc, "daf_value", 2021, 2021, "daf.parquet",
  "DAF Proportion", "Percentage of organizations that maintain a DAF", daf_proportion_desc, "daf_proportion", 2021, 2021, "daf.parquet",
)