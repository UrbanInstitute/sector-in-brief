create_plot_title <- function(org_level, other_orgs, date_range, time_series, title_prefix) {
  if (org_level == "Other Nonprofits") {
    title <- paste(title_prefix, other_orgs)
  } else {
    title <- paste(title_prefix, org_level)
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
