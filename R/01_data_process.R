# Script Header
# Description: This script facilitates the processing of the data sets needed for the 
# nonprofit sector in brief. All processed data is saved in both .csv and 
# parquet formats
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-07-02
# Date Last Edited: 2024-08-12
# Details:
# (1) - CORE and BMF Data for sector size and workforce pages
# (2) - Private Foundation Data
# (3) - EFile Data
# (4) - Aggregated Data
# (5) - Upload to S3

# Packages
library(blscrapeR)
library(data.table)
library(dplyr)
library(arrow)
library(purrr)

# Helper Scripts
source("R/utils.R")

# (1) - Processing Form 990 Data Needed for sector in brief

# (1.1) - CORE data

core_subset_url <-   "https://nccsdata.s3.amazonaws.com/harmonized/sector-in-brief/core_metrics.csv"
core_subset_dt <- data.table::fread(core_subset_url, key = "EIN2")
# Only load necessary columns for faster processing and smaller memory use
num_cols <- c(
  "F9_08_REV_TOT_TOT", 
  "F9_09_EXP_TOT_TOT", 
  "F9_10_ASSET_TOT_EOY",
  "F9_05_NUM_EMPL",
  "F9_09_EXP_COMP_DTK_TOT",
  "F9_09_EXP_COMP_DSQ_PERS_TOT",
  "F9_09_EXP_OTH_SAL_WAGE_TOT",
  "F9_09_EXP_PAYROLL_TAX_TOT",
  "F9_09_EXP_PENSION_CONTR_TOT",
  "F9_09_EXP_OTH_EMPL_BEN_TOT"
)
benefit_cols <- c(
  "F9_09_EXP_COMP_DSQ_PERS_TOT",
  "F9_09_EXP_PENSION_CONTR_TOT",
  "F9_09_EXP_OTH_EMPL_BEN_TOT",
  "F9_09_EXP_OTH_SAL_WAGE_TOT",
  "F9_09_EXP_COMP_DTK_TOT"
)
# Convert all numbers to numeric
core_subset_dt[, (num_cols) := lapply(.SD, as.numeric), .SDcols = num_cols]
# Replace NA values with 0
data.table::setnafill(core_subset_dt, fill = 0, cols = num_cols)
# Replace negative values with 0
core_subset_dt[, (num_cols) := lapply(.SD, function(x){x <- ifelse(x < 0, 0, x)}), .SDcols = num_cols]
# Compute total benefits
core_subset_dt[, BENEFITS := rowSums(.SD, na.rm = T), .SDcols = benefit_cols]
# Remove benefit columns and only keeep total benefits
core_subset_dt[, (benefit_cols) :=  NULL]
# Create asset size column
core_subset_dt[, SIZE := derive_size_category(F9_10_ASSET_TOT_EOY), by = 1:nrow(core_subset_dt)]

# (1.2) BMF Data

bmf_metadata_dat <- data.table::fread(
  "data/raw/bmf_metadata.csv",
  select = c(
    "EIN2",
    "NTEE_INDUSTRY_GROUP",
    "CTYPE",
    "CENSUS_STATE_ABBR",
    "CENSUS_COUNTY_NAME",
    "CENSUS_CBSA_NAME"
  )
)

# (1.3) Merge CORE and BMF Data

core_subset_dt <- bmf_metadata[core_subset_dt, on = "EIN2"]
core_subset_dt <- core_subset_dt[, .(
  total_assets = sum(F9_10_ASSET_TOT_EOY, na.rm = TRUE),
  total_revenues = sum(F9_08_REV_TOT_TOT, na.rm = TRUE),
  total_expenses = sum(F9_09_EXP_TOT_TOT, na.rm = TRUE),
  total_employees = sum(F9_05_NUM_EMPL, na.rm = TRUE),
  total_payroll = sum(F9_09_EXP_PAYROLL_TAX_TOT, na.rm = TRUE),
  total_benefits = sum(BENEFITS)
), by = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME,
  TAX_YEAR
)]
# Rename columns for merging
data.table::setnames(core_subset_dt, "TAX_YEAR", "YEAR")
core_subset_dt <- core_subset_dt[num_nonprofits_dt, on = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME,
  YEAR
)]
# Fill NAs for easier plots
data.table::setnafill(
  core_subset_dt, 
  fill = 0,
  cols = c(
    "total_assets",
    "total_revenues",
    "total_expenses",
    "total_employees",
    "total_payroll",
    "total_benefits"
  )
)
data.table::fwrite(core_subset_dt, "data/intermediate/core_variables.csv")

# (1.4) Split Into Fiscal and Labor Metrics and save in parquet format

fiscal_cols <- c(
  "CENSUS_STATE_ABBR",
  "NTEE_INDUSTRY_GROUP",
  "CTYPE",
  "SIZE",
  "CENSUS_COUNTY_NAME",
  "CENSUS_CBSA_NAME",
  "YEAR",
  "num_nonprofit",
  "total_assets",
  "total_revenues",
  "total_expenses"
)
fiscal_dt <- core_subset_dt[, ..fiscal_cols]
data.table::fwrite(fiscal_dt, "data/intermediate/fiscal_metrics.csv")

labour_cols <- c(
  "CENSUS_STATE_ABBR",
  "NTEE_INDUSTRY_GROUP",
  "CTYPE",
  "SIZE",
  "CENSUS_COUNTY_NAME",
  "CENSUS_CBSA_NAME",
  "YEAR",
  "total_employees",
  "total_benefits",
  "total_payroll"
)
labor_dt <- core_subset_dt[, ..labor_cols]
data.table::fwrite(labor_dt, "data/processed/labor_metrics.csv")

# Save to parquet files for optimized storage and reading
labor <- arrow::write_csv_arrow("data/processed/labor_metrics.csv")
arrow::write_parquet(labor, "data/processed/labor_metrics.parquet")

# (1.4) Inflation Adjustment for fiscal metrics

# Load BLS Data
cpi <- readr::read_csv("data/raw/bls_inflation_data.csv")
cpi <- cpi %>%
  dplyr::group_by(year) %>%
  dplyr::summarise(inf_adj = mean(adj_dollar_value))
cpi.2021 <- cpi %>%
  dplyr::filter(year == 2021) %>%
  dplyr::pull("inf_adj")
cpi <- cpi %>%
  dplyr::rename("YEAR" = year) %>%
  dplyr::mutate(YEAR = as.integer(YEAR)) %>%
  dplyr::mutate(inf_adj = cpi.2021 / inf_adj)
data.table::fwrite(cpi, "data/processed/bls_inflation_data.csv")

# Perform inflation adjustmenht
cpi <- data.table::fread("data/processed/bls_inflation_data.csv")
fiscal_dt <- cpi[fiscal_full_dt, on = "YEAR"]
fiscal_dt <- fiscal_full_dt[, total_assets := total_assets * inf_adj, by = 1:nrow(fiscal_full_dt)]
fiscal_dt <- fiscal_full_dt[, total_revenues := total_revenues * inf_adj, by = 1:nrow(fiscal_full_dt)]
fiscal_dt <- fiscal_full_dt[, total_expenses := total_expenses * inf_adj, by = 1:nrow(fiscal_full_dt)]
data.table::fwrite(fiscal_dt, "data/processed/fiscal_metrics.csv")

# Read in and save to parquet
fiscal <- arrow::write_csv_arrow("data/processed/fiscal_metrics.csv")
arrow::write_parquet(fiscal, "data/processed/fiscal_metrics.parquet")

# (2) - Private Foundation Data

pf_grant_data <- data.table::fread("https://nccsdata.s3.amazonaws.com/sector-in-brief/pf_grant_data.csv")
# Merge with BMF Data
pf_grant_data <- bmf_metadata_dat[pf_grant_data, on = "EIN2"]
pf_grant_data <- unique(pf_grant_data)
data.table::fwrite(pf_grant_data, "data/intermediate/pf_grant_data.csv")
# Create final data set grouped by all filter variables
data.table::setnames(pf_grant_data, "TAX_YEAR", "YEAR")
pf_grant_data <- pf_grant_data[, .(
  TOTAL_GRANTS = sum(GRANTS, na.rm = TRUE),
  MEDIAN_GRANT_AMT = median(GRANTS, na.rm = TRUE),
  NUM_GRANTS = .N
), by = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME,
  YEAR
)]
data.table::fwrite(pf_grant_data, "data/processed/pf_grants_data.csv")
# Read and save to parquet
pf_grant_data <- arrow::read_csv_arrow("data/processed/pf_grants_data.csv")
arrow::write_parquet(pf_grant_data, "data/processed/pf_grants_metrics.parquet")

# (3) DAF Data

daf_cols <- c(
  "SD_01_TOT_NUM_EOY_DAF",
  "SD_01_TOT_NUM_EOY_OTH",
  "SD_01_AGGREGATE_CONTR_DAF",
  "SD_01_AGGREGATE_CONTR_OTH",
  "SD_01_AGGREGATE_GRANT_DAF",
  "SD_01_AGGREGATE_GRANT_OTH",
  "SD_01_AGGREGATE_VALUE_EOY_DAF",
  "SD_01_AGGREGATE_VALUE_EOY_OTH"

)

# Read in raw data
efile_daf <- data.table::fread("data/raw/efile_2021_daf.csv")
efile_assets_df <- data.table::fread("data/raw/efile_2021_assets.csv")
# Add EIN2
efile_daf <- efile_daf[, EIN2 := derive_ein2(ORG_EIN), by = 1:nrow(efile_daf)]
efile_assets_df <- efile_assets_df[, EIN2 := derive_ein2(ORG_EIN), by = 1:nrow(efile_assets_df)]
# Subset Tax Year
efile_daf <- efile_daf[TAX_YEAR == 2021, ]
# Set NA Values to 0
data.table::setnafill(efile_daf, fill = 0, cols = daf_cols)
data.table::setnafill(efile_assets_df, fill = 0, cols = c("F9_10_ASSET_TOT_EOY"))
# Replace negative values with 0
efile_daf[, (daf_cols) := lapply(.SD, function(x){x <- ifelse(x < 0, 0, x)}), .SDcols = daf_cols]
efile_assets_df[, F9_10_ASSET_TOT_EOY := ifelse(F9_10_ASSET_TOT_EOY < 0, 0, F9_10_ASSET_TOT_EOY)]
# Perform summations
efile_daf <- efile_daf[, .(
  EIN2 = EIN2,
  NUM_DAFS = sum(SD_01_TOT_NUM_EOY_DAF, SD_01_TOT_NUM_EOY_OTH, na.rm = TRUE),
  TOTAL_CONTRIBUTIONS = sum(SD_01_AGGREGATE_CONTR_DAF, SD_01_AGGREGATE_CONTR_OTH, na.rm = TRUE),
  TOTAL_GRANTS = sum(SD_01_AGGREGATE_GRANT_DAF, SD_01_AGGREGATE_GRANT_OTH, na.rm = TRUE),
  TOTAL_VALUE = sum(
    SD_01_AGGREGATE_VALUE_EOY_DAF,
    SD_01_AGGREGATE_VALUE_EOY_OTH,
    na.rm = TRUE
  )
), by = 1:nrow(efile_daf)]
#  Compute who Has DAF
efile_daf <- efile_daf[, HAS_DAF := ifelse(NUM_DAFS > 0, 1, 0), by = 1:nrow(efile_daf)]
# Merge Asset Data
efile_daf = efile_assets_df[efile_daf, on = "EIN2"]
# Merge BMF Data
efile_daf <- bmf_metadata_dat[efile_daf, on = "EIN2"]
# Create asset size column
efile_daf[, SIZE := derive_size_category(F9_10_ASSET_TOT_EOY), by = 1:nrow(efile_daf)]
# Create Intermediate Data Set
efile_daf <- efile_daf[, .(
  NUM_DAFS = sum(NUM_DAFS, na.rm = TRUE),
  TOTAL_CONTRIBUTIONS = sum(TOTAL_CONTRIBUTIONS, na.rm = TRUE),
  TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
  TOTAL_VALUE = sum(TOTAL_VALUE, na.rm = TRUE),
  HAS_DAF = sum(HAS_DAF, na.rm = TRUE)
), by = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME
)]
# Create final variable: Percentage of nonprofits with DAF
bmf_metadata_raw <- arrow::read_csv_arrow("data/raw/bmf_metadata.csv")
num_nonprofit <- bmf_metadata_raw %>%
  dplyr::group_by(
    CENSUS_STATE_ABBR,
    NTEE_INDUSTRY_GROUP,
    CTYPE,
    SIZE,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME
  ) %>% 
  dplyr::summarise(
    num_nonprofit = n()
  ) %>% 
  dplyr::collapse()
# Save intermediate data set
arrow::write_csv_arrow(num_nonprofit, "data/intermediate/num_nonprofits.csv")
# Re-read in data.table for efficient merging
num_nonprofit <- data.table::as.data.table(num_nonprofit)
efile_daf <- num_nonprofit[efile_daf, on = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME
)]
# Create proportion variable
efile_daf[, DAF_PROPORTION := round(HAS_DAF / num_nonprofit, 2), by = 1:nrow(efile_daf)]
# Avoid NA errors in plots
data.table::setnafill(efile_daf,
                      fill = 0,
                      cols = c("DAF_PROPORTION"))
data.table::fwrite(efile_daf, "data/intermediate/efile_daf_metrics.csv")
# Remove unnecessary columns to reduce storage size
efile_daf[, num_nonprofit := NULL]
data.table::fwrite(efile_daf, "data/processed/efile_daf_metrics.csv")
# Save to parquet format
efile_daf <- arrow::read_csv_arrow("data/processed/efile_daf_metrics.csv")
arrow::write_parquet(efile_daf, "data/processed/efile_daf_metrics.parquet")

# (4) - Aggregated Data Sets for Default Loading

# Fiscal Metrics
fiscal <- arrow::read_parquet("data/processed/fiscal_metrics.parquet")
fiscal_agg <- fiscal |>
  dplyr::group_by(YEAR) |>
  dplyr::summarise(
    `Number of Nonprofits` = sum(num_nonprofit, na.rm = TRUE),
    `Total Assets` = sum(total_assets, na.rm = TRUE),
    `Total Revenues` = sum(total_revenues, na.rm = TRUE),
    `Total Expenses` = sum(total_expenses, na.rm = TRUE)
  ) |>
  dplyr::collapse()
# Write small data sets to csv to avoid parquet overhead
arrow::write_csv_arrow(fiscal_agg, "data/processed/fiscal_metrics_agg.csv")

# Labor Metrics
labor <- arrow::read_parquet("data/processed/labor_metrics.parquet")
labor_agg <- labor |>
  dplyr::group_by(YEAR) |>
  dplyr::summarise(
    `Total Benefits` = sum(total_benefits, na.rm = TRUE),
    `Total Payroll Taxes` = sum(total_payroll, na.rm = TRUE)
  ) |>
  dplyr::collapse()
arrow::write_csv_arrow(labor_agg, "data/processed/labor_metrics_agg.csv")

# Private Foundation Metrics
pf_grants <- arrow::read_parquet("data/processed/pf_grants_metrics.parquet")
pf_grants_agg <- pf_grants |>
  dplyr::group_by(YEAR) |>
  dplyr::summarise(
    `Total Grants` = sum(TOTAL_GRANTS, na.rm = TRUE),
    `Median Grant Amount` = sum(MEDIAN_GRANT_AMT, na.rm = TRUE),
    `Number of Grants` = sum(NUM_GRANTS, na.rm = TRUE)
  ) |>
  dplyr::collapse()
arrow::write_csv_arrow(pf_grants_agg, "data/processed/pf_grants_agg.csv")

# efile DAF Metrics
efile_daf <- arrow::read_parquet("data/processed/efile_daf_metrics.parquet")
efile_daf_agg <- efile_daf |>
  dplyr::summarise(
    TOTAL_NUM_DAFS = sum(NUM_DAFS, na.rm = TRUE),
    TOTAL_CONTRIBUTIONS = sum(TOTAL_CONTRIBUTIONS, na.rm = TRUE),
    TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
    TOTAL_VALUE = sum(TOTAL_VALUE, na.rm = TRUE),
    TOTAL_HAVE_DAFS = sum(HAS_DAF, na.rm = TRUE),
    MEAN_DAF_PROPORTION = mean(DAF_PROPORTION, na.rm = TRUE)
  ) |>
  dplyr::collapse()
arrow::write_csv_arrow(efile_daf_agg, "data/processed/efile_daf_agg.csv")

# (5) Upload to S3

# Currently Manual Upload: To-do programmatic upload