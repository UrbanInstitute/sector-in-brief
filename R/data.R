# Data Loading
num_nonprofit_data <- arrow::read_parquet("data/num_nonprofits.parquet")
geo_df <- arrow::read_csv_arrow("data/nested_geographies.csv")
daf <- arrow::read_parquet("data/daf.parquet") |>
  dplyr::mutate(
    Year = 2021
  ) |>
  dplyr::collapse()
assets <- arrow::read_parquet("data/Total_Assets.parquet")
revenue <- arrow::read_parquet("data/Total_Revenue.parquet")
expenses <- arrow::read_parquet("data/Total_Expenses.parquet")
pf_grants <- arrow::read_parquet("data/pf_grants.parquet")