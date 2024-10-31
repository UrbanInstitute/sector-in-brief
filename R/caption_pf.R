#' @title Edit plot caption if plotting private foundations
#' @param caption A character string containing the plot caption
#' @param ctype_level1 A character string indicating the level 1 organization type
#' @return A character string with the plot caption edited in place
caption_pf <- function(caption, ctype_level1) {
  if ("501(c)(3) Private Foundations" %in% ctype_level1) {
    caption <- paste(
      caption,
      "Organization Type: Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.",
      "\n"
    )
  }
  return(caption)
}