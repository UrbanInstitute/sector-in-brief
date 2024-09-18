create_plot_title <- function(org_level, other_orgs, date_range, time_series) {
  if (org_level == "Other Nonprofits") {
    title <- paste("Number of", other_orgs)
  } else {
    title <- paste("Number of", org_level)
  }
  if (time_series){
    if (date_range[1] != date_range[2] ) {
      title <- paste(title, ",", date_range[1], "-", date_range[2])
    } else {
      title <- paste(title, ",", date_range[1])
    }
  }
  return(title)
}
