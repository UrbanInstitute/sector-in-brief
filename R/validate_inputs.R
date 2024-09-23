validate_inputs <- function(org_type,
                            other_org_type,
                            geo_level,
                            geo_region,
                            geo_state_multi,
                            geo_state_single,
                            geo_county,
                            geo_cbsa,
                            subsector,
                            size,
                            start_date,
                            end_date){
  message <- TRUE
  if (geo_level == "Census Region"){
    if (length(geo_region) == 0){
      message <- "Please select at least one region."
    }
  }
  if (geo_level == "Census State"){
    if (length(geo_state_multi) == 0){
      message <- "Please select at least one state."
    }
  }
  if (geo_level == "Census County"){
    if (length(geo_state_single) == 0){
      message <- "Please select a state."
    }
    if (length(geo_county) == 0){
      message <- "Please select at least one county."
    }
  }
  if (geo_level == "Census CBSA"){
    if (length(geo_state_single) == 0){
      message <- "Please select a state."
    }
    if (length(geo_cbsa) == 0){
      message <- "Please select at least one CBSA."
    }
  }
  if (length(subsector) == 0){
    message <- "Please select at least one subsector."
  }
  if (length(size) == 0){
    message <- "Please select at least one asset size category."
  }
  return(message)
}