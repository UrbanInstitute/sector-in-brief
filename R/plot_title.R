plot_title <- function(inputs) {
  if (inputs$org_level == "Other Nonprofits") {
    title <- paste(inputs$title_prefix, inputs$other_orgs)
  } else {
    title <- paste(inputs$title_prefix, inputs$org_level)
  }
  if (inputs$time_series){
    start_year <- inputs$year_range[1]
    end_year <- inputs$year_range[2]
    if (start_year != end_year) {
      title <- paste(title, ",", start_year, "-", end_year)
    } else {
      title <- paste(title, ",", start_year)
    }
  }
  return(title)
}
