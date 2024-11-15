#' @title Caption for DAF plots
#' @param caption A character string containing the plot caption
#' @param agg_var A character string indicating the aggregation variable
#' @return A character string with the plot caption edited in place
caption_daf <- function(caption, agg_var) {
  if (grepl("DAF", agg_var)) {
    caption <- paste(
      caption,
      "DAF: A donor advised fund (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time.",
      "\n"
    )
  }
  return(caption)
}