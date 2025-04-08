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