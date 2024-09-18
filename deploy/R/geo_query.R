# Single function to query geographic levels
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