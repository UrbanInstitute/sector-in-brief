# Compose the HTML tooltip body shown when a user hovers a ggiraph
# data point. Dollar metrics get a "$1,234" format; counts get a
# thousands-separator. Includes the group identity when called from
# group_*_plot.R.

#' Build tooltip HTML for one data point.
#'
#' @param table Tibble being plotted.
#' @param yvar y-axis column name.
#' @param xvar x-axis column name.
#' @param groupby_var Group column, or NULL for single-series plots.
#' @return A character vector (one tooltip per row of `table`).
tooltip_text <- function(table, yvar, xvar, groupby_var = NULL) {
  if (yvar %in% c(
    "Total Assets",
    "Total Revenues",
    "Total Expenses",
    "Total Benefits",
    "Total Contributions",
    "Total Grants",
    "Total Value"
  )) {
    yvar_formatted <- scales::dollar(table[[yvar]], prefix = "$")
  } else {
    yvar_formatted <- scales::comma(table[[yvar]])
  }
  if (is.null(groupby_var)) {
    text <- paste("<b>",
                  yvar,
                  "</b>: ",
                  yvar_formatted,
                  "<br><b>",
                  xvar,
                  "</b>: ",
                  table[[xvar]])
  } else {
    text <- paste(
      "<b>",
      groupby_var,
      "</b>: ",
      table[[groupby_var]],
      "<br><b>",
      yvar,
      "</b>: ",
      yvar_formatted,
      "<br><b>",
      xvar,
      "</b>: ",
      table[[xvar]]
    )
  }
  return(text)
}