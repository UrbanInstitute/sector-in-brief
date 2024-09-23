create_plot_subtitle <- function(geo_level,
                                 region_selector,
                                 state_selector_single,
                                 state_selector_multi,
                                 county_selector,
                                 cbsa_selector,
                                 subsector_select,
                                 size_select) {
  subtitle <- ""
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