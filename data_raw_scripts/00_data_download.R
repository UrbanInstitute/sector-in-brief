# Script Header
# Description: This script facilitates the downloading of the data sets needed for the
# nonprofit sector in brief
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-07-02
# Date Last Edited: 2024-09-18
# Details:
# (1) - BMF Data
# (2) - CORE Data
# (3) - PF Data
# (4) - Deriving financials and PF Grants Info
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

geo_cols <- c("CENSUS_STATE_ABBR",
              "CENSUS_COUNTY_NAME",
              "CENSUS_CBSA_NAME")
bmf_metadata_cols <-
  c(
    "EIN2",
    "NTEEV2",
    "BMF_SUBSECTION_CODE",
    "CENSUS_STATE_ABBR",
    "CENSUS_COUNTY_NAME",
    "CENSUS_CBSA_NAME",
    "F990_TOTAL_ASSETS_RECENT",
    "ORG_YEAR_FIRST",
    "ORG_YEAR_LAST",
    "NCCS_LEVEL_1"
  )
asset_col <- "F990_TOTAL_ASSETS_RECENT"
# (1) Read raw bmf data to get metadata, geographic columns, and number of nonprofits
unified_bmf <- arrow::read_csv(unified_bmf_url)
# (1.1) Region-State - County - CBSA Nested Data Frame
geo_df <- unified_bmf |>
  dplyr::select(all_of(geo_cols)) |>
  dplyr::distinct() |>
  dplyr::mutate(
    "Census Region" = dplyr::case_when(
      CENSUS_STATE_ABBR %in% c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA") ~ "Northeast",
      CENSUS_STATE_ABBR %in% c("IL", "IN", "MI", "OH", "WI", "IA", "KS", "MN", "MO", "NE", "ND", "SD") ~ "Midwest",
      CENSUS_STATE_ABBR %in% c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "WV", "AL", "KY", "MS", "TN", "AR", "LA", "OK", "TX") ~ "South",
      CENSUS_STATE_ABBR %in% c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "AK", "CA", "HI", "OR", "WA") ~ "West"
    )
  ) |>
  dplyr::rename(
    "Census State" = "CENSUS_STATE_ABBR",
    "Census County" = "CENSUS_COUNTY_NAME",
    "Census CBSA" = "CENSUS_CBSA_NAME"
  ) |>
  dplyr::filter_all(dplyr::any_vars(!is.na(.))) |>
  dplyr::collapse()
arrow::write_csv_arrow(geo_df, "data/nested_geographies.csv")

# (1.2 BMF metadata)
bmf_metadata <- unified_bmf |>
  dplyr::select(all_of(bmf_metadata_cols)) |>
  dplyr::mutate(
    "Census Region" = dplyr::case_when(
      CENSUS_STATE_ABBR %in% c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA") ~ "Northeast",
      CENSUS_STATE_ABBR %in% c("IL", "IN", "MI", "OH", "WI", "IA", "KS", "MN", "MO", "NE", "ND", "SD") ~ "Midwest",
      CENSUS_STATE_ABBR %in% c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "WV", "AL", "KY", "MS", "TN", "AR", "LA", "OK", "TX") ~ "South",
      CENSUS_STATE_ABBR %in% c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "AK", "CA", "HI", "OR", "WA") ~ "West"
      ),
    "Subsector" = substr(NTEEV2, 1, 3),
    "Asset Size" = dplyr::case_when(
      F990_TOTAL_ASSETS_RECENT < 100000 ~ 1,
      F990_TOTAL_ASSETS_RECENT < 499999 ~ 2,
      F990_TOTAL_ASSETS_RECENT < 999999 ~ 3,
      F990_TOTAL_ASSETS_RECENT < 4999999 ~ 4,
      F990_TOTAL_ASSETS_RECENT < 9999999 ~ 5,
      F990_TOTAL_ASSETS_RECENT > 9999999 ~ 6,
      is.na(F990_TOTAL_ASSETS_RECENT) ~ 0,
      .default = 0
    ),
    "Organization Type" = dplyr::case_when(
      BMF_SUBSECTION_CODE == 3 & NCCS_LEVEL_1 == "501C3 PRIVATE FOUNDATION" ~ "501(c)(3) Private Foundations",
      BMF_SUBSECTION_CODE == 3 & NCCS_LEVEL_1 == "501C3 CHARITY" ~ "501(c)(3) Public Charities",
      BMF_SUBSECTION_CODE < 30 ~ sprintf("501(c)(%s)", BMF_SUBSECTION_CODE),
      BMF_SUBSECTION_CODE == 40 ~ "501(c)(d)",
      BMF_SUBSECTION_CODE == 50 ~ "501(c)(e)",
      BMF_SUBSECTION_CODE == 60 ~ "501(c)(f)",
      BMF_SUBSECTION_CODE == 70 ~ "501(c)(k)",
      is.na(BMF_SUBSECTION_CODE) ~ "501(c)(3) Public Charities",
      .default = "501(c)(3) Public Charities"
    )
    ) |>
  dplyr::rename(
    "Census State" = "CENSUS_STATE_ABBR",
    "Census County" = "CENSUS_COUNTY_NAME",
    "Census CBSA" = "CENSUS_CBSA_NAME"
  ) |>
  dplyr::select(
    "EIN2",
    "Subsector",
    "Organization Type",
    "Asset Size",
    "Census Region",
    "Census State",
    "Census County",
    "Census CBSA",
    "ORG_YEAR_FIRST",
    "ORG_YEAR_LAST"
  ) |>
  dplyr::collapse()
arrow::write_parquet(bmf_metadata,
                     "data_raw/intermediate/bmf_metadata.parquet")

# Disaggregate by Tax Year
num_nonprofits <- bmf_metadata |>
  dplyr::mutate(
    "Year" = purrr::map2(
      ORG_YEAR_FIRST,
      ORG_YEAR_LAST,
      ~ seq(.x, .y, by = 1)
    )
  ) |>
  tidyr::unnest(Year) |>
  dplyr::group_by(
    Year,
    `Census Region`,
    `Census State`,
    Subsector,
    `Organization Type`,
    `Census County`,
    `Census CBSA`,
    `Asset Size`
  ) |>
  dplyr::summarize(
    "Number of Nonprofits" = dplyr::n_distinct(EIN2)
  ) |>
  dplyr::collapse()

arrow::write_parquet(num_nonprofits,
                     "data/num_nonprofits.parquet")
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

num_cols <- c(
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
  "F9_09_EXP_OTH_EMPL_BEN_TOT"
)

file_paths_c3 <- sprintf("core/501c3-pz/CORE-%s-501C3-CHARITIES-PZ-HRMN.csv", CORE_YEARS)
file_paths_ce <- sprintf("core/501ce-pz/CORE-%s-501CE-NONPROFIT-PZ-HRMN.csv", CORE_YEARS)
file_paths <- c(file_paths_c3, file_paths_ce)

core_ls <- purrr::map(
  .x = file_paths,
  .f = function(path) {
    df <- arrow::read_csv_arrow(path)
    df <- df |>
      dplyr::select(
        dplyr::any_of(core_cols)
      ) |>
      dplyr::mutate(
        dplyr::across(
          dplyr::any_of(num_cols),
          as.numeric
        )
      ) |>
      dplyr::rename(
        "Tax Year" = "TAX_YEAR"
      ) |>
      dplyr::collapse()
    return(df)
  },
  .progress = TRUE
)

core <- purrr::list_rbind(core_ls)

core <- core |>
  dplyr::mutate(
    "Asset Size" = dplyr::case_when(
      F9_10_ASSET_TOT_EOY < 100000 ~ 1,
      F9_10_ASSET_TOT_EOY < 499999 ~ 2,
      F9_10_ASSET_TOT_EOY < 999999 ~ 3,
      F9_10_ASSET_TOT_EOY < 4999999 ~ 4,
      F9_10_ASSET_TOT_EOY < 9999999 ~ 5,
      F9_10_ASSET_TOT_EOY > 9999999 ~ 6,
      is.na(F9_10_ASSET_TOT_EOY) ~ 0,
      .default = 0
    )
  ) |>
  dplyr::rename(
    "Total Revenues" = "F9_08_REV_TOT_TOT",
    "Total Expenses" = "F9_09_EXP_TOT_TOT",
    "Total Assets" = "F9_10_ASSET_TOT_EOY"    
  )

arrow::write_parquet(core, "sector-in-brief/core_vars.parquet")

# (3) Private Foundation Data

# (3.1): Reproducible steps for wrangling raw data from CORE-PF Legacy Files
# aws s3 sync s3://nccsdata/legacy/core legacy 

pf_files <-sprintf("legacy/CORE-%s-501C3-PRIVFOUND-PF.csv", PF_YEARS)
pf_cols <- c("EIN", "P1CONTPD", "P2TOTAST", "TAXPER", "P1TOTREV", "P1TOTEXP")
pf_num_cols <- c("P1CONTPD", "P2TOTAST", "TAXPER", "P1TOTREV", "P1TOTEXP")

pf_files_ls <- purrr::map(
  .x = pf_files,
  .f = function(path) {
    if (file.exists(path)) {
      df <- arrow::read_csv_arrow(path)
      df <- df |>
        dplyr::select(
          dplyr::any_of(pf_cols)
        ) |>
        dplyr::mutate(
          dplyr::across(
            dplyr::any_of(pf_num_cols),
            as.numeric
          ),
          "Tax Year" := substr(TAXPER, 1, 4)
        ) |>
        dplyr::rename(
          "Total Contributions" = "P1CONTPD",
          "Total Assets" = "P2TOTAST",
          "Total Revenues" = "P1TOTREV",
          "Total Expenses" = "P1TOTEXP"
        ) |>
        dplyr::rowwise() |>
        dplyr::mutate(
          EIN2 := derive_ein2(EIN)
        ) |>
        dplyr::select(
          EIN2,
          `Total Contributions`,
          `Total Assets`,
          `Total Revenues`,
          `Total Expenses`,
          `Tax Year`
        ) |>
        dplyr::mutate(
          "Asset Size" = dplyr::case_when(
            `Total Assets` < 100000 ~ 1,
            `Total Assets` < 499999 ~ 2,
            `Total Assets` < 999999 ~ 3,
            `Total Assets` < 4999999 ~ 4,
            `Total Assets` < 9999999 ~ 5,
            `Total Assets` > 9999999 ~ 6,
            is.na(`Total Assets`) ~ 0,
            .default = 0
          )
        ) |>
        dplyr::collapse()
      return(df)
    }
  },
  .progress = TRUE
)

pf_legacy <- purrr::list_rbind(pf_files_ls)

# (3.2) SOI PF Data

soi_pf_urls <- c(
  "https://www.irs.gov/pub/irs-soi/22eoextract990pf.xlsx",
  "https://www.irs.gov/pub/irs-soi/21eoextract990pf.xlsx",
  "https://www.irs.gov/pub/irs-soi/20eoextract990pf.xlsx"
)

soi_pf_cols <- c("EIN", "CONTRPDPBKS", "TOTASSETSEND", "TAX_PRD", "TOTRCPTPERBKS", "TOTEXPNSPBKS")
soi_pf_num_cols <- c("CONTRPDPBKS", "TOTASSETSEND", "TOTRCPTPERBKS", "TOTEXPNSPBKS")

soi_pf_files_ls <- purrr::map(
  .x = soi_pf_urls,
  .f = function(url) {
    df <- rio::import(url)
    df <- df |>
      dplyr::select(
        dplyr::any_of(soi_pf_cols)
      ) |>
      dplyr::mutate(
        dplyr::across(
          dplyr::any_of(soi_pf_num_cols),
          as.numeric
        ),
        "Tax Year" := substr(TAX_PRD, 1, 4)
      ) |>
      dplyr::rename(
        "Total Contributions" = "CONTRPDPBKS",
        "Total Assets" = "TOTASSETSEND",
        "Total Revenues" = "TOTRCPTPERBKS",
        "Total Expenses" = "TOTEXPNSPBKS"
      ) |>
      dplyr::rowwise() |>
      dplyr::mutate(
        EIN2 := derive_ein2(EIN)
      ) |>
      dplyr::select(
        EIN2,
        `Total Contributions`,
        `Total Assets`,
        `Total Revenues`,
        `Total Expenses`,
        `Tax Year`
      ) |>
      dplyr::mutate(
        "Asset Size" = dplyr::case_when(
          `Total Assets` < 100000 ~ 1,
          `Total Assets` < 499999 ~ 2,
          `Total Assets` < 999999 ~ 3,
          `Total Assets` < 4999999 ~ 4,
          `Total Assets` < 9999999 ~ 5,
          `Total Assets` > 9999999 ~ 6,
          is.na(`Total Assets`) ~ 0,
          .default = 0
        )
      ) |>
      dplyr::collapse()
    return(df)
  },
  .progress = TRUE
)

soi_pf <- purrr::list_rbind(soi_pf_files_ls)

# (3.3) Combine PF Data

pf <- purrr::list_rbind(list(soi_pf, pf_legacy))
pf <- pf |>
  dplyr::mutate(`Tax Year` = as.integer(`Tax Year`)) |>
  dplyr::collapse()
arrow::write_parquet(pf, "sector-in-brief/pf_vars.parquet")

# aws s3 sync sector-in-brief s3://nccsdata/sector-in-brief

# (4) Derive Financials and PF Grants Info

#(4.1) Financial Data

metadata_cols <- c(
  "EIN2",
  "Subsector",
  "Organization Type",
  "Census Region",
  "Census State",
  "Census County",
  "Census CBSA"
)

vars <- c(
  "Total Assets",
  "Total Revenues",
  "Total Expenses"
)

rs <- purrr::map(
  vars,
  create_financial_data,
  bmf_cols = metadata_cols,
  core = core,
  pf = pf,
  bmf = bmf_metadata,
  destfolder = "sector-in-brief/",
  .progress = TRUE
)

# (4.2) PF Grants Info

grants <- pf |>
  dplyr::select(
    EIN2,
    `Total Contributions`,
    `Tax Year`,
    `Asset Size`
  ) |>
  dplyr::collapse()

bmf_merge <- bmf_metadata |>
  dplyr::select(
    dplyr::all_of(
      metadata_cols
    )
  ) |>
  dplyr::collapse()

grants <- grants |>
  tidylog::left_join(bmf_merge,
                     by = "EIN2") |>
  dplyr::distinct()

arrow::write_parquet(grants, "sector-in-brief/pf_grants.parquet")


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