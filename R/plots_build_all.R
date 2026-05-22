# Dispatcher: turn the five tables from summarise_data() into five
# ggiraph plots. Errors on any individual table degrade to a blank_plot
# placeholder via purrr::possibly so one bad group-by doesn't take the
# whole panel down.

#' Build all five plots for a panel.
#'
#' @param tables_ls Named list of 5 tibbles from `summarise_data()`.
#' @param groupby_vars Length-5 list naming the second group column
#'   for each table (NULL for the overall view).
#' @param title,caption Pre-computed strings shared across the panel.
#' @param yvar,xvar Column names for the y and x aesthetics.
#' @param ytitle,xtitle Axis label strings.
#' @param year_var Time column name — used by `plots_build_single()`
#'   to decide line-vs-bar.
#' @return Named list of 5 ggiraph plot objects.
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
