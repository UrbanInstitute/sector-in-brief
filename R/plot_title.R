#' @title Function to create plot title
#' @param inputs list of inputs
#' @return title for plot
plot_title <- function(inputs) {
  title <- inputs$title_prefix
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
