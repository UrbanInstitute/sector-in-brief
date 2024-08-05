# Script Header
# Description: This script contains utility functions used in deployment of the 
# shiny app
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-08-05
# Date Last Edited: 2024-08-05

#' @title This function filters a parquet file based on filter inputs
#' @description It checks if each filter is not the "all" option before filtering
#' the parquet file
#' @param pq parquet file. Data set to filter
#' @param org_type character scalar. 501c type
#' @param state character scalar. State
#' @param industry_group character scalar. NTEE Major Group
#' @param geo_level character scalar. County, or cbsa level filtering
#' @param county_cbsa character scalar. County or CBSA unit level filtering
#' @param size integer. Asset size class
#' @param series character scalar. Type of data being queries for summary
#' @returns pq parquet object. Filtered parquet file.
filter_parquet <- function(pq,
                           org_type,
                           state,
                           industry_group,
                           geo_level,
                           county_cbsa,
                           size,
                           series) {
  if (org_type != "all_orgs") {
    pq <- pq |> dplyr::filter(CTYPE == org_type)
  }
  if (state != "all_states") {
    pq <- pq |> dplyr::filter(CENSUS_STATE_ABBR == state)
    if (geo_level == "county") {
      pq <- pq |> dplyr::filter(CENSUS_COUNTY_NAME == county_cbsa)
    } else if (geo_level == "cbsa") {
      pq <- pq |> dplyr::filter(CENSUS_CBSA_NAME == county_cbsa)
    }
  }
  if (industry_group != "all_groups") {
    pq <- pq |> dplyr::filter(NTEE_INDUSTRY_GROUP == industry_group)
  }
  if (size  > 0) {
    pq <- pq |> dplyr::filter(SIZE == size)
  }
  if (series == "efile") {
    pq <- pq |>
      dplyr::summarise(
        TOTAL_NUM_DAFS = sum(NUM_DAFS, na.rm = TRUE),
        TOTAL_CONTRIBUTIONS = sum(TOTAL_CONTRIBUTIONS, na.rm = TRUE),
        TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
        TOTAL_VALUE = sum(TOTAL_VALUE, na.rm = TRUE),
        TOTAL_HAVE_DAFS = sum(HAS_DAF, na.rm = TRUE),
        MEAN_DAF_PROPORTION = mean(DAF_PROPORTION, na.rm = TRUE)
      ) |>
      dplyr::collapse()
  } else {
    pq <- pq |> dplyr::group_by(YEAR)
    if (series == "fiscal") {
      pq <- pq |>
        dplyr::summarise(
          COUNT = sum(num_nonprofit, na.rm = TRUE),
          ASSETS = sum(total_assets, na.rm = TRUE),
          REVENUES = sum(total_revenues, na.rm = TRUE),
          EXPENSES = sum(total_expenses, na.rm = TRUE)
        ) |>
        dplyr::collapse()
    } else if (series == "pf") {
      pq <- pq |>
        dplyr::summarise(
          TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
          MEDIAN_GRANT_AMT = sum(MEDIAN_GRANT_AMT, na.rm = TRUE),
          NUM_GRANTS = sum(NUM_GRANTS, na.rm = TRUE)
        ) |>
        dplyr::collapse()
    } else if (series == "labor") {
      pq <- pq |>
        dplyr::summarise(
          TOTAL_EMPLOYEES = sum(total_employees, na.rm = TRUE),
          TOTAL_BENEFITS = sum(total_benefits, na.rm = TRUE),
          TOTAL_PAYROLL = sum(total_payroll, na.rm = TRUE)
        ) |>
        dplyr::collapse()
    }
  }
  return(pq)
}
