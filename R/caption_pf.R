#' @title Edit plot caption if plotting private foundations
#' @param caption A character string containing the plot caption
#' @param ctype A character string indicating the 501c type
#' @return A character string with the plot caption edited in place
caption_pf <- function(caption, ctype) {
  if ("501(c)(3) Private Foundations" %in% ctype) {
    caption <- paste(
      caption,
      "Organization Type: Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.",
      "\n",
      "The IRS has not released 990 PF tax records for tax years 2016 – 2018, thus points from these years are represented with a dotted line to indicate their incompleteness.",
      "\n"
    )
  }
  return(caption)
}