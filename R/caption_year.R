#' @title function to add year information to plot caption
#' @param caption A character string containing the plot caption
#' @param year_var A character string indicating the year variable
#' @return A character string with the plot caption edited in place
caption_year <- function(caption, year_var){
  if(year_var == "Tax Year"){
    caption <- paste(caption, 
                     "•	The charts only include data until tax year 2021 because the IRS has only partially released tax records for tax year 2022.", 
                      "\n")
  }
  return(caption)
}