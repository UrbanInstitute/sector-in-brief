# Script Header
# Description: This script contains functions used by the R scripts in this folder
# Programmer(s): Thiyaghessan - tpoongundranar@urban.org
# Date Created: 06-08-2024
# Date Last Edited: 09-11-2024

#' @title Function to provide labels to subsection codes
#' in Unified BMF.
#' @param subsection_code integer. Subsection code assigned
#' by IRS
#' @param level1 character scalar. NCCS Level 1 classification
#' @returns ctype character scalar. Verbose labels for 
#' subsection codes.
derive_501c_type <- function(subsection_code, level1) {
  subsection_code <- as.integer(subsection_code)
  if (is.na(subsection_code)) {
    ctype <- "Unknown"
  } else if (any(subsection_code == 0 | subsection_code > 70)) {
    ctype <- "Unknown"
  } else if (subsection_code == 3) {
    if (level1 == "501C3 PRIVATE FOUNDATION") {
      ctype <- "501(c)(3) Private Foundations"
    } else {
      ctype <- "501(c)(3) Public Charities"
    } 
  } else if (subsection_code < 30) {
    ctype <- sprintf("501(c)(%s)", subsection_code)
  } else if (subsection_code ==  40) {
    ctype <- "501(c)(d)"
  } else if (subsection_code == 50) {
    ctype <- "501(c)(e)"
  } else if (subsection_code == 60) {
    ctype <- "501(c)(f)"
  } else if (subsection_code == 70) {
    ctype <- "501(c)(k)"
  }
  return(ctype)
}

#' @title Function to create longitudinal panel from unified bmf
#' @description This function subsets the unified BMF year by year and
#' stacks the results to create a longitudinal panel data set.
#' @param year integer scalar. year to subset data
#' @param unified data.table object. unified BMF
#' @return yr_dat data.table object. Summarized bmf by year containing number of
#' nonprofits
create_year_table <- function(year, unified) {
  yr_dat <- unified[ORG_YEAR_FIRST <= year, ]
  yr_dat <- yr_dat[ORG_YEAR_LAST >= year, ]
  yr_dat <- yr_dat[, .(num_nonprofit = length(unique(EIN2))), by = list(
    CENSUS_STATE_ABBR,
    Subsector,
    Organization_Type,
    CENSUS_COUNTY_NAME,
    CENSUS_CBSA_NAME,
    Asset_Size
  )]
  yr_dat <- yr_dat[, Year := year]
  return(yr_dat)
}

#' @title Function to derve asset size classes
#' @param total_assets numeric scalar. F990 total assets
#' @returns size. integer scalar of size category.
derive_size_category <- function(total_assets) {
  if (total_assets < 100000){
    size <- 1
  } else if (total_assets < 499999) {
    size <- 2
  } else if (total_assets < 999999) {
    size <- 3
  } else if (total_assets < 4999999) {
    size <- 4
  } else if (total_assets < 9999999) {
    size <- 5
  } else {
    size <- 6
  }
  return(size)
}

#' @title Derive tax tear from tax period column
#' @description Subsets the first four characters of tax year
#' @returns tax_year. character scalar of tax year.
derive_tax_year <- function(tax_year) {
  tax_year <- substr(tax_year, 1, 4)
  return(tax_year)
}

#' @title Format EIN to EIN2
#' @param ein 9 character original EIN
#' @returns character scalar EIN2. EIN-XX-XXXXXXX
derive_ein2 <- function(ein){
  ein2 <- format_ein(ein)
  ein2 <- paste0("EIN-", substr(ein2, 1, 2), "-", substr(ein2, 3, 9))
  return(ein2)
}

#' @title Function to format EIN to 9 characters long
#' @description Appends leading zeros until EIN has 9 characters
#' @param ein integer scalar. Original EIN
#' @returns character scalar. EIN with 9 characters.
format_ein <- function(ein) {
  if (is.na(ein)){
    ein <- "000000000"
    return(ein)
  } else {
    ein_len <- nchar(ein)
    if (ein_len == 9){
      return(ein)
    } else {
      diff = 9 - ein_len
      diff = rep("0", diff)
      diff = paste0(diff, collapse = "")
      ein <- paste0(diff, ein, collapse = "")
      return(ein)
    }
  }
}


filter_data <- function(fiscal_dat, 
                        org_type,
                        state,
                        industry_group,
                        geo_level,
                        county_cbsa,
                        size){
  
  if (org_type != "all_orgs") {
    fiscal_dat <- fiscal_dat[CTYPE == org_type, ]
  }
  if (state != "all_states") {
    fiscal_dat <- fiscal_dat[CENSUS_STATE_ABBR == state, ]
    if (geo_level == "county"){
      fiscal_dat <- fiscal_dat[CENSUS_COUNTY_NAME == county_cbsa,]
    } else if (geo_level == "cbsa") {
      fiscal_dat <- fiscal_dat[CENSUS_CBSA_NAME == county_cbsa,]
    }
  }
  if (industry_group != "all_groups") {
    fiscal_dat <- fiscal_dat[NTEE_INDUSTRY_GROUP == industry_group, ]
  }
  if (size  > 0){
    fiscal_dat <- fiscal_dat[SIZE == size,]
  }
  fiscal_dat <- fiscal_dat[, .(COUNT = sum(num_nonprofit),
               ASSETS = sum(total_assets, na.rm = TRUE),
               REVENUES = sum(total_revenues, na.rm = TRUE),
               EXPENSES = sum(total_expenses, na.rm = TRUE)), 
           by = "YEAR"]
  return(fiscal_dat)
}

filter_parquet <- function(pq, 
                        org_type,
                        state,
                        industry_group,
                        geo_level,
                        county_cbsa,
                        size){
  
  if (org_type != "all_orgs") {
    pq <- pq %>% dplyr::filter(CTYPE == org_type)
  }
  if (state != "all_states") {
    pq <- pq %>% dplyr::filter(CENSUS_STATE_ABBR == state)
    if (geo_level == "county"){
      pq <- pq %>% dplyr::filter(CENSUS_COUNTY_NAME == county_cbsa)
    } else if (geo_level == "cbsa") {
      pq <- pq %>% dplyr::filter(CENSUS_CBSA_NAME == county_cbsa)
    }
  }
  if (industry_group != "all_groups") {
    pq <- pq %>% dplyr::filter(NTEE_INDUSTRY_GROUP == industry_group)
  }
  if (size  > 0){
    pq <- pq %>% dplyr::filter(SIZE == size)
  }
  pq <- pq %>% 
    dplyr::group_by(YEAR) %>% 
    dplyr::summarise(COUNT = sum(num_nonprofit, na.rm = TRUE),
                     ASSETS = sum(total_assets, na.rm = TRUE),
                     REVENUES = sum(total_revenues, na.rm = TRUE),
                     EXPENSES = sum(total_expenses, na.rm = TRUE)) %>% 
    dplyr::collect()
  return(pq)
}
