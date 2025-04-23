#' @title Function to create a subtitle for plot based on groupby variable
#' @param groupby_var A character string that is the name of the variable to group by
#' @param selected_groups A character vector of the selected groups
#' @return A character string that is the subtitle for the plot
plot_subtitle <- function(groupby_var, selected_groups){
  subtitle <- ""
  if (is.null(groupby_var)) {
    subtitle <- ""
  } else {
    subtitle <- paste("By ", groupby_var)
    subtitle <- gsub("Census ", "", subtitle)
  }
  return(subtitle)
}