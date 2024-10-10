plot_caption <- function(inputs) {
  # Params
  subtitle <- ""
  org_level <- inputs$org_level
  geo_level <- inputs$geo_level
  region_selector <- inputs$geo_region
  state_selector_single <- inputs$geo_state_single
  state_selector_multi <- inputs$geo_state_multi
  county_selector <- inputs$geo_county
  cbsa_selector <- inputs$geo_cbsa
  subsector_select <- inputs$subsector
  size_select <- inputs$size
  agg_var <- inputs$agg_var
  year_var <- inputs$year_var
  
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
  
  if (! is.null(org_level)){
    if (org_level == "501(c)(3) Private Foundations"){
      subtitle <- paste(subtitle, 
                        "Notes: Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.",
                        "\n")
    }
  }
  
  if(year_var == "Tax Year"){
    subtitle <- paste(subtitle, "Year: Tax Years refer to the accounting period for which the tax return was submitted", 
                      "\n")
  }
  
  return(subtitle)
}