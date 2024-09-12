# One single script for data wrangling functions

# Single function to query organization types
orgtype_query <- function(data, org, other_orgs = NULL) {
  if (org == "501(c)(3) Public Charities"){
    data <- filter(data, Organization_Type == org)
  } else if (org == "501(c)(3) Private Foundations"){
    data <- filter(data, Organization_Type == org)
  } else if (org == "501(c)(4) Social Welfare Organizations") {
    data <- filter(data, Organization_Type == "501(c)(4)")
  } else if (org == "Other Nonprofits") {
    data <- filter(data, Organization_Type == other_orgs)
  }
  return(data)
}

geo_query <- function(data, geo_level, region, state_single, state_mult, county, cbsa) {
  if (geo_level == "census_region") {
    data <- filter(data, census_region %in% region)
  } else if (geo_level == "CENSUS_STATE_ABBR") {
    data <- filter(data, CENSUS_STATE_ABBR %in% state_mult)
  } else if (geo_level == "CENSUS_COUNTY_NAME") {
    data <- filter(data, CENSUS_STATE_ABBR %in% state_single)
    data <- filter(data, CENSUS_COUNTY_NAME %in% county)
  } else if (geo_level == "CENSUS_CBSA_NAME") {
    data <- filter(data, CENSUS_CBSA_NAME %in% cbsa)
  }
  return(data)
}

subsector_query <- function(data, subsector) {
  data <- filter(data, Subsector %in% subsector)
  return(data)
}

filter_asset_size <- function(data, asset_size){
  data <- filter(data, Asset_Size %in% asset_size)
  return(data)
}

filter_data <- function(data,
                        org_level = "All Nonprofits",
                        other_orgs = NULL,
                        geo_level = "all",
                        region = NULL,
                        state_single = NULL,
                        state_mult = NULL,
                        county = NULL,
                        cbsa = NULL,
                        subsector_level = "all",
                        subsectors = NULL,
                        asset_size_level = "all",
                        asset_sizes = NULL,
                        time_series = TRUE,
                        year_start = NULL,
                        year_end = NULL) {
  if (org_level != "All Nonprofits") {
    data <- orgtype_query(data, org_level, other_orgs)
  }
  if (geo_level != "all"){
    data <- geo_query(data, geo_level, region, state_single, state_mult, county, cbsa)
  }
  if (subsector_level != "all") {
    data <- subsector_query(data, subsectors)
  }
  if (asset_size_level != "all") {
    data <- filter_asset_size(data, asset_sizes)
  }
  if (time_series){
    if (year_start != 1989) {
      data <- filter(data, Year >= year_start)
    }
    if (year_end != 2024) {
      data <- filter(data, Year <= year_end)
    }
  }
  return(data)
}