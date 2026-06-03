#' Add the private-foundation disclosure to a plot caption when the
#' active org type includes 990-PF filers AND the metric is the Core
#' Series PF Grants figure (the only PF metric that spans 2016-2018).
#' Explains that 2016-2018 data are missing from IRS releases (see
#' `table_builder_pf()`). The PRI panel is also restricted to private
#' foundations but only covers 2021-2023, so it must not pick up this
#' note — hence the agg_var guard.
#'
#' @param caption Running caption string.
#' @param ctype Active org-type selection(s).
#' @param agg_var Panel's metric column name.
#' @return Updated caption string.
caption_pf <- function(caption, ctype, agg_var) {
  if ("501(c)(3) - Private Foundations" %in% ctype &&
      identical(agg_var, "Total Contributions")) {
    caption <- paste(
      caption,
      "•	The IRS has not released 990 PF tax records for tax years 2016 through 2018. Missing data points from these years are represented with a dotted line.",
      "\n"
    )
  }
  return(caption)
}