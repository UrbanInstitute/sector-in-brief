#' @title Edit plot caption if plotting private foundations
#' @param caption A character string containing the plot caption
#' @param ctype A character string indicating the 501c type
#' @return A character string with the plot caption edited in place
caption_pf <- function(caption, ctype) {
  if ("501(c)(3) - Private Foundations" %in% ctype) {
    caption <- paste(
      caption,
      "•	The IRS has not released 990 PF tax records for tax years 2016 through 2018. Missing data points from these years are represented with a dotted line.",
      "\n"
    )
  }
  return(caption)
}