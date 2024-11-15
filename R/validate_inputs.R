validate_inputs <- function(inputs){
  message <- TRUE
  if (inputs$geo_level == "Census Region"){
    if (length(inputs$geo_region) == 0){
      message <- "Please select at least one region."
    }
  }
  if (inputs$geo_level == "Census State"){
    if (length(inputs$geo_state_mult) == 0){
      message <- "Please select at least one state."
    }
  }
  if (inputs$geo_level == "Census County"){
    if (length(inputs$geo_state_single) == 0){
      message <- "Please select a state."
    }
    if (length(inputs$geo_county) == 0){
      message <- "Please select at least one county."
    }
  }
  if (inputs$geo_level == "Census CBSA"){
    if (length(inputs$geo_state_single) == 0){
      message <- "Please select a state."
    }
    if (length(inputs$geo_cbsa) == 0){
      message <- "Please select at least one CBSA."
    }
  }
  if (length(inputs$subsector) == 0){
    message <- "Please select at least one subsector."
  }
  if (length(inputs$size) == 0){
    message <- "Please select at least one asset size category."
  }
  return(message)
}














