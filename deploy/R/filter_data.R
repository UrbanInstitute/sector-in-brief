# Function to filter data
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
                        time_series = FALSE,
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