# Bridge between visualpanel_content (which knows only the panel title)
# and data_server() (which needs the full per-panel config). Looks up
# the panel's row in data_server_args, loads the parquet via
# dataloader(), and starts the moduleServer.

#' Mount the per-panel data server for a given panel title.
#'
#' @param page Panel title — must match a name in `data_server_args`.
#' @param data_server_args The driver list defined in
#'   `R/data_server_args.R`.
#' @param geo_df Nested geographies lookup, passed through to the
#'   server module for state → county/CBSA cascading.
#' @param visualpanel_args The visualpanel driver tibble — used to
#'   look up the panel's year-range bounds for the reset observer.
data_server_wrapper <- function(page, data_server_args,
                                geo_df, visualpanel_args) {
  cfg <- data_server_args[[page]]
  data <- dataloader(path = cfg[["path"]], cols = cfg[["vars"]])
  vp_row <- visualpanel_args[visualpanel_args$title == page, ]
  data_server(
    id            = cfg[["id"]],
    data          = data,
    geo_df        = geo_df,
    year_var      = cfg[["year_var"]],
    agg_var       = cfg[["agg_var"]],
    ytitle        = cfg[["ytitle"]],
    xtitle        = cfg[["xtitle"]],
    title_prefix  = cfg[["title_prefix"]],
    time_series   = cfg[["time_series"]],
    choices       = choice_builder(cfg[["id"]]),
    start_year    = vp_row$start_year,
    end_year      = vp_row$end_year
  )
}
