plots_build_single <- function(table,
                               groupby_var,
                               title,
                               caption,
                               yvar,
                               xvar,
                               ytitle,
                               xtitle,
                               year_var) {
  if (is.null(table) || nrow(table) == 0 || !(year_var %in% names(table))) {
    return(blank_plot())
  }
  if (length(unique(table[[year_var]])) > 1) {
    if (is.null(groupby_var)) {
      single_line_plot(table = table, 
                       title = title, 
                       caption = caption, 
                       yvar = yvar, 
                       xvar = xvar, 
                       ytitle = ytitle, 
                       xtitle = xtitle)
    }
    else {
      group_line_plot(table = table,
                      groupby_var = groupby_var,
                      title = title, 
                      caption = caption, 
                      yvar = yvar, 
                      xvar = xvar, 
                      ytitle = ytitle, 
                      xtitle = xtitle,
                      num_groups = unique(table[[groupby_var]]) |> length()) 
    }
  } else {
    if (is.null(groupby_var)) {
      single_col_plot(table = table, 
                      title = title, 
                      caption = caption, 
                      yvar = yvar, 
                      xvar = xvar, 
                      ytitle = ytitle, 
                      xtitle = xtitle)
    }
    else if (length(unique(table[[groupby_var]])) == 1) {
      single_col_plot(table = table, 
                      title = title, 
                      caption = caption, 
                      yvar = yvar, 
                      xvar = xvar, 
                      ytitle = ytitle, 
                      xtitle = xtitle)
    }
    else {
      group_col_plot(table = table,
                     groupby_var = groupby_var,
                     title = title, 
                     caption = caption, 
                     yvar = yvar, 
                     xvar = xvar, 
                     ytitle = ytitle, 
                     xtitle = xtitle,
                     num_groups = unique(table[[groupby_var]]) |> length())
    }
  }
}
