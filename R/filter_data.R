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
                        subsectors = NULL,
                        asset_sizes = NULL,
                        time_series = FALSE,
                        year_start = NULL,
                        year_end = NULL,
                        yearvar = "Year") {
  if (org_level != "All Nonprofits") {
    data <- orgtype_query(data, org_level, other_orgs)
  }
  if (geo_level != "all"){
    data <- geo_query(data, geo_level, region, state_single, state_mult, county, cbsa)
  }
  data <- general_query(data, "Subsector",subsectors)
  data <- general_query(data, "Asset Size", asset_sizes)
  if (time_series){
    if (year_start != 1989) {
      data <- filter(data, !!sym(yearvar) >= year_start)
    }
    if (year_end != 2024) {
      data <- filter(data, !!sym(yearvar) <= year_end)
    }
  }
  return(data)
}