plots_build_all <- function(tables_ls,
                            groupby_vars,
                            title,
                            caption,
                            yvar,
                            xvar,
                            ytitle,
                            xtitle,
                            year_var) {
  purrr::map2(
    tables_ls,
    groupby_vars,
    purrr::possibly(plots_build_single, blank_plot()),
    title = title,
    caption = caption,
    yvar = yvar,
    xvar = xvar,
    ytitle = ytitle,
    xtitle = xtitle,
    year_var = year_var
  )
}