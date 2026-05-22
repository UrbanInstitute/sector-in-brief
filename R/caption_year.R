#' Add the tax-year disclosure to a plot caption.
#'
#' NOTE: the literal year in the disclosure text is stale (says "until
#' tax year 2021"); the actual cutoff now comes from the manifest. A
#' future PR could derive this from `year_range.R` so the caption
#' tracks the producer.
#'
#' @param caption Running caption string.
#' @param year_var Time column name ("Year"); other values are no-op.
#' @return Updated caption string.
caption_year <- function(caption, year_var){
  if(year_var == "Year"){
    caption <- paste(caption, 
                     "•	The charts only include data until tax year 2021 because the IRS has only partially released tax records for tax year 2022.", 
                      "\n")
  }
  return(caption)
}