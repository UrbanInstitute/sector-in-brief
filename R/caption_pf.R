#' Add the private-foundation disclosure to a plot caption when the
#' active org type includes 990-PF filers. Explains that 2016-2018
#' data are missing from IRS releases (see `table_builder_pf()`).
#'
#' @param caption Running caption string.
#' @param ctype Active org-type selection(s).
#' @return Updated caption string.
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