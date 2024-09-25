plots_build_single <- function(table,
                               groupby_var,
                               title,
                               subtitle,
                               yvar,
                               xvar,
                               ytitle,
                               xtitle,
                               year_var) {
  if (length(unique(table[[year_var]]) > 1)) {
    if (is.null(groupby_var)) {
      single_line_plot(table = table, 
                       title = title, 
                       subtitle = subtitle, 
                       yvar = yvar, 
                       xvar = xvar, 
                       ytitle = ytitle, 
                       xtitle = xtitle)
    }
    else {
      group_line_plot(table = table,
                      groupby_var = groupby_var,
                      title = title, 
                      subtitle = subtitle, 
                      yvar = yvar, 
                      xvar = xvar, 
                      ytitle = ytitle, 
                      xtitle = xtitle)
    }
  } else {
    if (is.null(groupby_var)) {
      single_col_plot(table = table, 
                      title = title, 
                      subtitle = subtitle, 
                      yvar = yvar, 
                      xvar = xvar, 
                      ytitle = ytitle, 
                      xtitle = xtitle)
    }
    else {
      group_col_plot(table = table,
                     groupby_var = groupby_var,
                     title = title, 
                     subtitle = subtitle, 
                     yvar = yvar, 
                     xvar = xvar, 
                     ytitle = ytitle, 
                     xtitle = xtitle)
    }
  }
}
