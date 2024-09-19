# Single function to query geographic levels
geo_query <- function(data, geo_level, region, state_single, state_mult, county, cbsa) {
  if (geo_level == "Census Region") {
    data <- filter(data, `Census Region` %in% region)
  } else if (geo_level == "Census State") {
    data <- filter(data, `Census State` %in% state_mult)
  } else if (geo_level == "Census County") {
    data <- filter(data, `Census State` %in% state_single)
    data <- filter(data, `Census County` %in% county)
  } else if (geo_level == "Census CBSA") {
    data <- filter(data, `Census CBSA` %in% cbsa)
  }
  return(data)
}