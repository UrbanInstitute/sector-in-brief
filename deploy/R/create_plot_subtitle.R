create_plot_subtitle <- function(geo_level,
                                 region_selector,
                                 state_selector_single,
                                 state_selector_multi,
                                 county_selector,
                                 cbsa_selector,
                                 subsector_level,
                                 subsector_select,
                                 size_level,
                                 size_select) {
  asset_size_ls <- list(
    "1" = "Under $100,000",
    "2" = "$100,000 - $499,999",
    "3" = "$500,000 - $999,999",
    "4" = "$1 Million - $4.99 Million",
    "5" = "$5 Million - $9.99 Million",
    "6" = "Above $10 Million"
  )
  subtitle <- ""
  if (geo_level == "census_region") {
    subtitle <- paste("Region(s):", paste(region_selector, collapse = ", "), "\n")
  }
  else if (geo_level == "CENSUS_STATE_ABBR") {
    subtitle <- paste("State(s):",
                      paste(state_selector_multi, collapse = ", "),
                      "\n")
  }
  else if (geo_level == "CENSUS_COUNTY_NAME") {
    subtitle <- paste(
      "State:",
      state_selector_single,
      "\n",
      "County(s):",
      paste(county_selector, collapse = ", "),
      "\n"
    )
  }
  else if (geo_level == "CENSUS_CBSA_NAME") {
    subtitle <- paste(
      "State:",
      state_selector_single,
      "\n",
      "Metro/Micro Area(s):",
      paste(cbsa_selector, collapse = ", "),
      "\n"
    )
  }
  
  if (subsector_level == "individual") {
    subtitle <- paste(subtitle,
                      "Subsector(s):",
                      paste(subsector_select, collapse = ", "),
                      "\n")
  }
  if (size_level == "individual") {
    sizes <- unlist(purrr::map(
      size_select,
      .f = function(x) {
        asset_size_ls[[x]]
      }
    ))
    subtitle <- paste(subtitle,
                      "Asset Size(s):",
                      paste(sizes, collapse = ", "),
                      "\n")
  }
  return(subtitle)
}