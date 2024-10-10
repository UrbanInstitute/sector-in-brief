#' @title Function to create a subtitle for plot based on groupby variable
#' @param groupby_var A character string that is the name of the variable to group by
#' @return A character string that is the subtitle for the plot
plot_subtitle <- function(groupby_var){
  if (is.null(groupby_var)) {
    subtitle <- ""
  } else {
    subtitle <- paste("By ", groupby_var) 
  }
  return(subtitle)
}