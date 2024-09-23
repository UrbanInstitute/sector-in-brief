# This function creates a data.frame containing the data selections
# made by the user.
data_selection_text <- function(org_level,
                                other_orgs,
                                geo_level,
                                region,
                                state_single,
                                state_mult,
                                county,
                                cbsa,
                                subsector_select,
                                size_select,
                                date_range) {
  
  if (org_level == "Other Nonprofits") {
    org_level <- other_orgs
  }
  
  if (geo_level == "all") {
    geo_level <- NA
    geo_selection <- NA
  } else if (geo_level == "Census Region") {
    geo_selection <- paste(region, collapse = ", ")
  } else if (geo_level == "Census State") {
    if (length(state_mult) > 0) {
      geo_selection <- paste(state_mult, collapse = ", ")
    } else {
      geo_selection <- state_single
    }
  } else if (geo_level == "Census County") {
    geo_selection <- paste(county, collapse = ", ")
  } else if (geo_level == "Census CBSA") {
    geo_selection <- paste(cbsa, collapse = ", ")
  }
  
  df <- tibble::tribble(
    ~Variable, ~Selections,
    "Organization Level", org_level,
    geo_level, geo_selection,
    "Subsector", subsector_select,
    "Asset Size", names(size_choices)[size_choices %in% size_select]
  ) |>
    na.omit()
    
  return(reactable(df))
}