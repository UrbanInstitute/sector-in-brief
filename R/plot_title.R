# Compose the plot title from the panel's title prefix and the user's
# date-range selection. Time-series panels append the year range
# (e.g. ", 2000 - 2022"); single-year panels append just the year.

#' Build the plot title for a panel.
#'
#' @param inputs Formatted input list from `format_input()`.
#' @return A character scalar.
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
