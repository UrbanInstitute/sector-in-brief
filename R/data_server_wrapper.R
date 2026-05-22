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
data_server_wrapper <- function(page, data_server_args, geo_df) {
  data <- dataloader(
    path = data_server_args[[page]][["path"]],
    cols = data_server_args[[page]][["vars"]]
  )
  data_server(
    id = data_server_args[[page]][["id"]],
    data = data,
    geo_df = geo_df,
    year_var = data_server_args[[page]][["year_var"]],
    agg_var = data_server_args[[page]][["agg_var"]],
    ytitle = data_server_args[[page]][["ytitle"]],
    xtitle = data_server_args[[page]][["xtitle"]],
    title_prefix = data_server_args[[page]][["title_prefix"]],
    time_series = data_server_args[[page]][["time_series"]]
  )
}
