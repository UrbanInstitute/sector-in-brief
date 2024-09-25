create_plot_subtitle <- function(inputs) {
  # Params
  subtitle <- ""
  geo_level <- inputs$geo_level
  region_selector <- inputs$region
  state_selector_single <- inputs$state_single
  state_selector_multi <- inputs$state_mult
  county_selector <- inputs$county
  cbsa_selector <- inputs$cbsa
  subsector_select <- inputs$subsector_select
  size_select <- inputs$size_filter
  
  if (geo_level == "Census Region") {
    subtitle <- paste("Region(s):", paste(region_selector, collapse = ", "), "\n")
  }
  else if (geo_level == "Census State") {
    subtitle <- paste("State(s):",
                      paste(state_selector_multi, collapse = ", "),
                      "\n")
  }
  else if (geo_level == "Census County") {
    subtitle <- paste(
      "State:",
      state_selector_single,
      "\n",
      "County(s):",
      paste(county_selector, collapse = ", "),
      "\n"
    )
  }
  else if (geo_level == "Census CBSA") {
    subtitle <- paste(
      "State:",
      state_selector_single,
      "\n",
      "Metro/Micro Area(s):",
      paste(cbsa_selector, collapse = ", "),
      "\n"
    )
  }
  
  subtitle <- paste(subtitle,
                    "Subsector(s):",
                    paste(subsector_select, collapse = ", "),
                    "\n")
  sizes <- unlist(purrr::map(
    size_select,
    .f = function(x) {
      asset_size_ls[[x]]
    }
  ))
  subtitle <- paste(subtitle, "Asset Size(s):", paste(sizes, collapse = ", "), "\n")
  return(subtitle)
}