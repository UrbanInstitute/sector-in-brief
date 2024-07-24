# Script Header
# Description: This script facilitates the downloading of the data sets needed for the 
# nonprofit sector in brief
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-07-02
# Date Last Edited: 2024-07-18
# Details:
# (1) - Table of nested geographies for Shiny filters
# (2) - Count of number of nonprofits
# (3) - Wrangle CORE Data to get Assets, Revenues, Expenses, Employment Numbers
# (4) - PF Data for Grant Information
# (5) - Efile Data for DAF information from 2021
# (6) - Save files as parquet format with arrow


# Packages
library(data.table)
library(tidyverse)
library(arrow)

# Scripts
source("R/utils.R")

# Global Variables
BMF_YEARS <- 1989:2024
CORE_YEARS <- 1989:2021
PF_YEARS <- 1989:2019

# Necessary Data Sets
unified_bmf_url <- "https://nccsdata.s3.amazonaws.com/harmonized/bmf/unified/BMF_UNIFIED_V1.1.csv"
unified_bmf <- data.table::fread(unified_bmf_url, key = "EIN2")
core_subset_url <-   "https://nccsdata.s3.amazonaws.com/harmonized/sector-in-brief/core_metrics.csv"
core_subset_dt <- data.table::fread(
  core_subset_url,
  key = "EIN2"
)

# (1): Nested geographies
geo_cols <- c(
  "CENSUS_STATE_ABBR",
  "CENSUS_COUNTY_NAME",
  "CENSUS_CBSA_NAME"
)
geo_dt <- unified_bmf[, ..geo_cols]
geo_dt <- unique(geo_dt)
data.table::fwrite(
  geo_dt,
  "data/nested_geographies.csv"
)

# (2): Number of Nonprofits - by geography, industry, 501c type, size
# Dataset: Unified BMF for NTEE Major Group, 501c type, Size
num_nonprofit_cols <-
  c(
    "EIN2",
    "NTEEV2",
    "BMF_SUBSECTION_CODE",
    "CENSUS_STATE_ABBR",
    "CENSUS_COUNTY_NAME",
    "CENSUS_CBSA_NAME",
    "F990_TOTAL_ASSETS_RECENT",
    "ORG_YEAR_FIRST",
    "ORG_YEAR_LAST"
  )
asset_col <- "F990_TOTAL_ASSETS_RECENT"

num_nonprofits_dt <- unified_bmf[, ..num_nonprofit_cols]
num_nonprofits_dt[, NTEE_INDUSTRY_GROUP := substr(NTEEV2, 1, 3), by = 1:nrow(num_nonprofits_dt)]
num_nonprofits_dt[, CTYPE := derive_501c_type(BMF_SUBSECTION_CODE), by = 1:nrow(num_nonprofits_dt)]

# Create Asset Size Column

# Replace NA values with 0
data.table::setnafill(num_nonprofits_dt, fill = 0, cols = asset_col)
# Replace negative values with 0
num_nonprofits_dt[, (asset_col) := lapply(.SD, function(x){x <- ifelse(x < 0, 0, x)}), .SDcols = asset_col]
# Create Size Category
num_nonprofits_dt[, SIZE := derive_size_category(F990_TOTAL_ASSETS_RECENT), by = 1:nrow(num_nonprofits_dt)]

# Create longitudinal data set
yr_dat_ls <- purrr::map(BMF_YEARS,
                        create_year_table,
                        unified = num_nonprofits_dt,
                        .progress = TRUE)
num_nonprofits_dt <- purrr::list_rbind(yr_dat_ls)
data.table::fwrite(
  num_nonprofits_dt,
  "data/num_nonprofits_full.csv"
)

# Create Yearly Table for base plot
num_nonprofits_by_year <- num_nonprofits_dt[, .(total = sum(num_nonprofit)), by = YEAR]
data.table::fwrite(
  num_nonprofits_by_year,
  "data/num_nonprofits_by_year.csv"
)

# (3): Prepare fiscal metrics from CORE data

# (3.1): Reproduce core_subset_dt data set
core_cols <- c(
  "EIN2",
  "F9_08_REV_TOT_TOT", 
  "F9_09_EXP_TOT_TOT", 
  "F9_10_ASSET_TOT_EOY",
  "F9_05_NUM_EMPL",
  "F9_01_ACT_GVRN_VOL_TOT",
  "F9_09_EXP_COMP_DTK_TOT",
  "F9_09_EXP_COMP_DSQ_PERS_TOT",
  "F9_09_EXP_OTH_SAL_WAGE_TOT",
  "F9_09_EXP_PAYROLL_TAX_TOT",
  "F9_09_EXP_PENSION_CONTR_TOT",
  "F9_09_EXP_OTH_EMPL_BEN_TOT",
  "TAX_YEAR"
)

# Retrieve file paths to core files
file_paths_c3 <- sprintf(
  "core-501c3-pz/CORE-%s-501C3-CHARITIES-PZ-HRMN.csv",
  YEARS
)
file_paths_ce <- sprintf(
  "core-501ce-pz/CORE-%s-501CE-NONPROFIT-PZ-HRMN.csv",
  YEARS
)
file_paths <- c(
  file_paths_c3,
  file_paths_ce
)
# Subset core files
core_pz_ls <- purrr::map(
  .x = file_paths,
  .f = function(path) {
    dt <- data.table::fread(path, key = "EIN2")
    cols <- intersect(names(dt), core_cols)
    dt <- dt[, ..cols]
    return(dt)
  },
  .progress = TRUE
)
# Save Data
data.table::fwrite(
  data.table::rbindlist(core_pz_ls, fill = TRUE),
  "core_metrics.csv"
)

# (3.2): Wrangle core_subset_dt

# Sum benefit columna into single benefir variable
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

# (3.3): Merge with bmf metadata 

# Wrangle BMF Data
metadata_cols <- c(
  "EIN2",
  "NTEEV2",
  "BMF_SUBSECTION_CODE",
  "CENSUS_STATE_ABBR",
  "CENSUS_COUNTY_NAME",
  "CENSUS_CBSA_NAME"
)
bmf_metadata <- unified_bmf[, ..metadata_cols]
bmf_metadata[, NTEE_INDUSTRY_GROUP := substr(NTEEV2, 1, 3), by = 1:nrow(bmf_metadata)]
bmf_metadata[, CTYPE := derive_501c_type(BMF_SUBSECTION_CODE), by = 1:nrow(bmf_metadata)]

# Merge bmf metadata with CORE fiscal data
core_fiscal_dt <- bmf_metadata[core_subset_dt, on = "EIN2"]
core_fiscal_dt <- core_fiscal_dt[, .(total_assets = sum(F9_10_ASSET_TOT_EOY, na.rm = TRUE),
                       total_revenues = sum(F9_08_REV_TOT_TOT, na.rm = TRUE),
                       total_expenses = sum(F9_09_EXP_TOT_TOT, na.rm = TRUE),
                       total_employees = sum(F9_05_NUM_EMPL, na.rm = TRUE),
                       total_payroll = sum(F9_09_EXP_PAYROLL_TAX_TOT, na.rm = TRUE),
                       total_benefits = sum(BENEFITS)
                       ), 
                   by = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME,
  TAX_YEAR
)]

# (3.4): Second Merge with the number of nonprofits data set 

data.table::setnames(core_fiscal_dt, "TAX_YEAR", "YEAR")
fiscal_full_dt <- core_fiscal_dt[num_nonprofits_dt, on = list(
  CENSUS_STATE_ABBR,
  NTEE_INDUSTRY_GROUP,
  CTYPE,
  SIZE,
  CENSUS_COUNTY_NAME,
  CENSUS_CBSA_NAME,
  YEAR)]

# Remove NAs
data.table::setnafill(
  fiscal_full_dt, 
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

data.table::fwrite(
  fiscal_full_dt,
  "data/full_fiscal_metrics.csv"
)

# (4) Private Foundation Data

# (4.1): Reproducible steps for wrangling raw data from CORE-PF Legacy Files
pf_files <- 
  sprintf(
    "core-legacy/CORE-%s-501C3-PRIVFOUND-PF.csv",
    pf_years
  )
pf_cols <- c(
  "EIN",
  "P1CONTPD",
  "TAXPER"
)

pf_files_ls <- purrr::map(
  .x = pf_files,
  .f = function(path) {
    if (file.exists(path)) {
      dt <- data.table::fread(path, key = "EIN")
      dt <- dt[, ..pf_cols]
      return(dt) 
    }
  },
  .progress = TRUE
)
pf_dt <- data.table::rbindlist(
  pf_files_ls,
  fill = TRUE
)

# Derive metadata
pf_dt[, EIN2 := derive_ein2(EIN), by = 1:nrow(pf_dt)]
pf_dt[, TAX_YEAR := derive_tax_year(TAXPER), by = 1:nrow(pf_dt)]

pf_cols <- c(
  "EIN2",
  "P1CONTPD",
  "TAX_YEAR"
)

pf_dt <- pf_dt[, ..pf_cols]

data.table::fwrite(
  pf_dt,
  "pf-data/pf_metrics.csv"
)
soi_cols <- c(
  "EIN",
  "CONTRPDPBKS",
  "TAX_PRD"
)

# (4.2) Append data from SOI extracts to PFs
soi_pf_urls <- c(
  "https://www.irs.gov/pub/irs-soi/22eoextract990pf.xlsx",
  "https://www.irs.gov/pub/irs-soi/21eoextract990pf.xlsx",
  "https://www.irs.gov/pub/irs-soi/20eoextract990pf.xlsx"
)

soi_pf_ls <- purrr::map(
  .x = soi_pf_urls,
  .f = function(url) {
    df <- rio::import(url)
    dt <- data.table::as.data.table(df)
    return(dt)
  },
  .progress = TRUE
)
soi_pf_ls_proc <- purrr::map(
  .x = soi_pf_ls,
  .f = function(dt) {
    dt <- dt[, ..soi_cols]
    dt[, EIN2 := derive_ein2(EIN), by = 1:nrow(dt)]
    dt[, TAX_YEAR := derive_tax_year(TAX_PRD), by = 1:nrow(dt)]
    data.table::setnames(dt, "CONTRPDPBKS", "P1CONTPD")
    dt <- dt[, ..pf_cols]
  },
  .progress = TRUE
)

soi_pf_dt <- data.table::rbindlist(soi_pf_ls_proc)

# (4.3): Bring legacy PF and SOI PF together
soi_full_dt <- 
  data.table::rbindlist(
    list(pf_dt, soi_pf_dt)
  )
soi_full_dt <- unique(soi_full_dt)
data.table::fwrite(
  soi_full_dt,
  "pf-data/pf_metrics.csv"
)

# (5) Efile Data - Donor Advised Funds (2021)
daf_cols <- c(
  "ORG_EIN",
  "TAX_YEAR",
  "SD_01_TOT_NUM_EOY_DAF",
  "SD_01_TOT_NUM_EOY_OTH",
  "SD_01_AGGREGATE_CONTR_DAF",
  "SD_01_AGGREGATE_CONTR_OTH",
  "SD_01_AGGREGATE_GRANT_DAF",
  "SD_01_AGGREGATE_GRANT_OTH",
  "SD_01_AGGREGATE_VALUE_EOY_DAF",
  "SD_01_AGGREGATE_VALUE_EOY_OTH"
)
# (5.1) Download Efile Data and process
efile_daf <- data.table::fread(
  "https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/SD-P01-T00-ORGS-DONOR-ADVISED-FUNDS-OTH-2021.csv",
  select = daf_cols
)
# Add EIN2
efile_daf <- efile_daf[, EIN2 := derive_ein2(ORG_EIN), by = 1:nrow(efile_daf)]
# Perform summations
efile_daf <- efile_daf[,
                       .(
                         EIN2 = EIN2,
                         NUM_DAFS = sum(SD_01_TOT_NUM_EOY_DAF, SD_01_TOT_NUM_EOY_OTH),
                         TOTAL_CONTRIBUTIONS = sum(SD_01_AGGREGATE_CONTR_DAF, SD_01_AGGREGATE_CONTR_OTH),
                         TOTAL_GRANTS = sum(SD_01_AGGREGATE_GRANT_DAF, SD_01_AGGREGATE_GRANT_OTH),
                         TOTAL_VALUE = sum(SD_01_AGGREGATE_VALUE_EOY_DAF, SD_01_AGGREGATE_VALUE_EOY_OTH)
                       ),
                       by = 1:nrow(efile_daf)]

# (5.2) Append BMF Metadata

# (5.3) Append CORE Asset Data

# (5.4) Process Data and summarize for point estimates

# •	Percentage of organizations that maintained any donor advised funds or any 
# similar funds or accounts for which donors have the right to provide advice 
# on the distribution or investment of amounts in such funds or accounts 
library(blscrapeR)

cpi <- blscrapeR::inflation_adjust(base_date = "1989-01-01")
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
cpi <- data.table::as.data.table(cpi)

fiscal_full_dt <- cpi[fiscal_full_dt, on = "YEAR"]
fiscal_full_dt

fiscal_cols <- c(
  "total_assets",
  "total_revenues",
  "total_expenses"
)

fiscal_full_dt <- fiscal_full_dt[, total_assets := total_assets * inf_adj, by = 1:nrow(fiscal_full_dt)]
fiscal_full_dt <- fiscal_full_dt[, total_revenues := total_revenues * inf_adj, by = 1:nrow(fiscal_full_dt)]

# (6) Write files in parquet format
fiscal <- arrow::read_csv_arrow("data/full_fiscal_metrics.csv")
arrow::write_parquet(fiscal, "data/full_fiscal_metrics.parquet")

