plots_build_all <- function(tables_ls,
                            groupby_vars,
                            title,
                            subtitle,
                            yvar,
                            xvar,
                            ytitle,
                            xtitle,
                            year_var) {
  purrr::map2(
    tables_ls,
    groupby_vars,
    plots_build_single,
    title = title,
    subtitle = subtitle,
    yvar = yvar,
    xvar = xvar,
    ytitle = ytitle,
    xtitle = xtitle,
    year_var = year_var
  )
}