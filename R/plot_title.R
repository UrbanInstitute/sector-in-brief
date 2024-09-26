plot_title <- function(inputs) {
  title <- input$title_prefix
  if (! is.null(inputs$org_level)){
    if (inputs$org_level == "Other Nonprofits") {
      title <- paste(title, inputs$other_orgs)
    } else {
      title <- paste(title, inputs$org_level)
    } 
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
