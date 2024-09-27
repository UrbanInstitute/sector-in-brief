tooltip_text <- function(table, groupby_var, yvar, xvar) {
  text <- paste(
    "<b>",
    groupby_var,
    "</b>: ",
    table[[groupby_var]],
    "<br><b>",
    yvar,
    "</b>: ",
    scales::comma(table[[yvar]]),
    "<br><b>",
    xvar,
    "</b>: ",
    table[[xvar]]
  )
  return(text)
}