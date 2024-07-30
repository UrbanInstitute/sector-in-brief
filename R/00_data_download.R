# Script Header
# Description: This script facilitates the downloading of the data sets needed for the
# nonprofit sector in brief
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-07-02
# Date Last Edited: 2024-07-26
# Details:
# (1) - BMF Data
# (2) - CORE Data
# (3) - Wrangle CORE Data to get Assets, Revenues, Expenses, Employment Numbers
# (4) - PF Data for Grant Information
# (5) - Efile Data for DAF information from 2021

# Packages
library(data.table)
library(arrow)

# Scripts
source("R/utils.R")

# Global Variables
BMF_YEARS <- 1989:2024
CORE_YEARS <- 1989:2021
PF_YEARS <- 1989:2019

unified_bmf_url <- "https://nccsdata.s3.amazonaws.com/harmonized/bmf/unified/BMF_UNIFIED_V1.1.csv"

# (1) Download and save raw BMF Data

unified_bmf <- data.table::fread(unified_bmf_url, key = "EIN2")
# State - County - CBSA Nested table
geo_cols <- c("CENSUS_STATE_ABBR",
              "CENSUS_COUNTY_NAME",
              "CENSUS_CBSA_NAME")
geo_dt <- unified_bmf[, ..geo_cols]
geo_dt <- unique(geo_dt)
data.table::fwrite(geo_dt, "data/processed/nested_geographies.csv")
rm(geo_dt)
# Data set with number of nonprofits
metadata_cols <-
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
# Subset and create new columns
bmf_metadata_dat <- unified_bmf[, ..metadata_cols]
bmf_metadata_dat[, NTEE_INDUSTRY_GROUP := substr(NTEEV2, 1, 3), by = 1:nrow(bmf_metadata_dat)]
bmf_metadata_dat[, CTYPE := derive_501c_type(BMF_SUBSECTION_CODE), by = 1:nrow(bmf_metadata_dat)]
bmf_metadata_dat[, (asset_col) := lapply(.SD, function(x) {
  x <- ifelse(x < 0, 0, x)
}), .SDcols = asset_col]
data.table::setnafill(bmf_metadata_dat, fill = 0, cols = asset_col)
bmf_metadata_dat[, SIZE := derive_size_category(F990_TOTAL_ASSETS_RECENT), by = 1:nrow(bmf_metadata_dat)]
data.table::fwrite(bmf_metadata_dat, "data/raw/bmf_metadata.csv")
# Disaggregate by Tax Year
yr_dat_ls <- purrr::map(BMF_YEARS,
                        create_year_table,
                        unified = bmf_metadata_dat,
                        .progress = TRUE)
num_nonprofits_dt <- purrr::list_rbind(yr_dat_ls)
data.table::fwrite(num_nonprofits_dt,
                   "data/intermediate/num_nonprofits_full.csv")

# (2) Core Data
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

# Retrieve file paths to CORE Files on S3
file_paths_c3 <- sprintf("core-501c3-pz/CORE-%s-501C3-CHARITIES-PZ-HRMN.csv", YEARS)
file_paths_ce <- sprintf("core-501ce-pz/CORE-%s-501CE-NONPROFIT-PZ-HRMN.csv", YEARS)
file_paths <- c(file_paths_c3, file_paths_ce)

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

data.table::fwrite(data.table::rbindlist(core_pz_ls, fill = TRUE),
                   "data/raw/core_metrics.csv")

# (3) BLS Data

cpi <- blscrapeR::inflation_adjust(base_date = "1989-01-01")
readr::write_csv(cpi, "data/raw/bls_inflation_data.csv")

# (4) Private Foundation Data

# (4.1): Reproducible steps for wrangling raw data from CORE-PF Legacy Files

# Download all legacy core files or access from S3
pf_files <-
  sprintf("data/raw/CORE-%s-501C3-PRIVFOUND-PF.csv", pf_years)

pf_files_ls <- purrr::map(
  .x = pf_files,
  .f = function(path) {
    if (file.exists(path)) {
      dt <- data.table::fread(
        path,
        key = "EIN",
        select = c("EIN", "P1CONTPD", "P2TOTAST", "TAXPER")
      )
      return(dt)
    }
  },
  .progress = TRUE
)

pf_dt <- data.table::rbindlist(pf_files_ls, fill = TRUE)

# Derive metadata
pf_dt[, EIN2 := derive_ein2(EIN), by = 1:nrow(pf_dt)]
pf_dt[, TAX_YEAR := derive_tax_year(TAXPER), by = 1:nrow(pf_dt)]
pf_dt[, SIZE := derive_size_category(P2TOTAST), by = 1:nrow(pf_dt)]
data.table::setnames(pf_dt, "P1CONTPD", "GRANTS")

pf_cols <- c("EIN2", "GRANTS", "SIZE", "TAX_YEAR")
pf_dt <- pf_dt[, ..pf_cols]

data.table::fwrite(pf_dt, "data/intermediate/pf_metrics.csv")

# (4.2) Append data from SOI extracts to PFs

soi_pf_urls <- c(
  "https://www.irs.gov/pub/irs-soi/22eoextract990pf.xlsx",
  "https://www.irs.gov/pub/irs-soi/21eoextract990pf.xlsx",
  "https://www.irs.gov/pub/irs-soi/20eoextract990pf.xlsx"
)

soi_cols <- c("EIN", "CONTRPDPBKS", "TOTASSETSEND", "TAX_PRD")

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
    dt[, SIZE := derive_size_category(TOTASSETSEND), by = 1:nrow(dt)]
    data.table::setnames(dt, "CONTRPDPBKS", "GRANTS")
    dt <- dt[, ..pf_cols]
  },
  .progress = TRUE
)

soi_pf_dt <- data.table::rbindlist(soi_pf_ls_proc)

# (4.3): Bring legacy PF and SOI PF together
soi_full_dt <-
  data.table::rbindlist(list(pf_dt, soi_pf_dt))
soi_full_dt <- unique(soi_full_dt)

data.table::fwrite(soi_full_dt, "data/processed/pf_grant_data.csv")

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

# (5.1) Download Efile Data

# Schedule D
efile_daf <- data.table::fread(
  "https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/SD-P01-T00-ORGS-DONOR-ADVISED-FUNDS-OTH-2021.csv",
  select = daf_cols
)
data.table::fwrite(efile_daf, "data/raw/efile_2021_daf.csv")
# Part 10
efile_assets_df <- data.table::fread(
  "https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/F9-P10-T00-BALANCE-SHEET-2021.csv",
  select = c("ORG_EIN", "F9_10_ASSET_TOT_EOY")
)
data.table::fwrite(efile_assets_df, "data/raw/efile_2021_assets.csv")