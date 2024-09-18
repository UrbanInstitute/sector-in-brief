# Dataa Wrangling
daf <- arrow::read_parquet("data/efile_daf_metrics.parquet")

# Create Region Column - need to add into 00_data_download
daf <- daf |>
  mutate(census_region = case_when(
    CENSUS_STATE_ABBR %in% c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA") ~ "Northeast",
    CENSUS_STATE_ABBR %in% c("IL", "IN", "MI", "OH", "WI", "IA", "KS", "MN", "MO", "NE", "ND", "SD") ~ "Midwest",
    CENSUS_STATE_ABBR %in% c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "WV", "AL", "KY", "MS", "TN", "AR", "LA", "OK", "TX") ~ "South",
    CENSUS_STATE_ABBR %in% c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "AK", "CA", "HI", "OR", "WA") ~ "West"
  )) |>
  rename(
    "Asset_Size" = SIZE,
    "Organization_Type" = CTYPE,
    "Subsector" = NTEE_INDUSTRY_GROUP,
    "Total Contributions" = TOTAL_CONTRIBUTIONS,
    "Total Grants" = TOTAL_GRANTS,
    "Total Value" = TOTAL_VALUE,
    "Number of DAFs" = NUM_DAFS,
    "Proportion of Nonprofits with DAFs" = DAF_PROPORTION,
  ) |>
  mutate(
    Organization_Type = ifelse(Organization_Type == "501(c)(3)", "501(c)(3) Public Charities", Organization_Type),
    Year = 2021
  )

daf_contributions <- daf |>
  dplyr::select(
    CENSUS_STATE_ABBR,
    Subsector,
    Organization_Type,
    Asset_Size,
    census_region,
    CENSUS_STATE_ABBR,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME,
    Year,
    `Total Contributions`
  )

daf_grants <- daf |>
  dplyr::select(
    CENSUS_STATE_ABBR,
    Subsector,
    Organization_Type,
    Asset_Size,
    census_region,
    CENSUS_STATE_ABBR,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME,
    Year,
    `Total Grants`
  )

daf_value <- daf |>
  dplyr::select(
    CENSUS_STATE_ABBR,
    Subsector,
    Organization_Type,
    Asset_Size,
    census_region,
    CENSUS_STATE_ABBR,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME,
    Year,
    `Total Value`
  )

daf_number <- daf |>
  dplyr::select(
    CENSUS_STATE_ABBR,
    Subsector,
    Organization_Type,
    Asset_Size,
    census_region,
    CENSUS_STATE_ABBR,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME,
    Year,
    `Number of DAFs`
  )

daf_proportion <- daf |>
  dplyr::select(
    CENSUS_STATE_ABBR,
    Subsector,
    Organization_Type,
    Asset_Size,
    census_region,
    CENSUS_STATE_ABBR,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME,
    Year,
    `Proportion of Nonprofits with DAFs`
  )