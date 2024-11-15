#' @title function to add year information to plot caption
#' @param caption A character string containing the plot caption
#' @param year_var A character string indicating the year variable
#' @return A character string with the plot caption edited in place
caption_year <- function(caption, year_var){
  if(year_var == "Tax Year"){
    caption <- paste(caption, "Year: Tax Years refer to the accounting period for which the tax return was submitted", 
                      "\n")
  }
  return(caption)
}