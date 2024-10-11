plot_title <- function(inputs) {
  title <- inputs$title_prefix
  if (! is.null(inputs$ctype_level1)){
    if (inputs$ctype_level1 == "Other Nonprofits") {
      title <- paste(title, inputs$ctype_level2)
    } else {
      title <- paste(title, inputs$ctype_level1)
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
