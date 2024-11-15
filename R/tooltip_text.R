tooltip_text <- function(table, yvar, xvar, groupby_var = NULL) {
  if (is.null(groupby_var)) {
    text <- paste("<b>",
                  yvar,
                  "</b>: ",
                  scales::comma(table[[yvar]]),
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
      scales::comma(table[[yvar]]),
      "<br><b>",
      xvar,
      "</b>: ",
      table[[xvar]]
    )
  }
  return(text)
}