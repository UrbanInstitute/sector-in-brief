# Wrapper function for data_server() and dataloader()
data_server_wrapper <- function(page, data_server_args, geo_df){
  data <- dataloader(path = data_server_args[[page]][["path"]], 
                     cols = data_server_args[[page]][["vars"]])
  data_server(
    id = data_server_args[[page]][["id"]],
    data = data,
    geo_df = geo_df,
    year_var = data_server_args[[page]][["year_var"]],
    agg_var = data_server_args[[page]][["agg_var"]],
    ytitle = data_server_args[[page]][["ytitle"]],
    xtitle = data_server_args[[page]][["xtitle"]],
    title_prefix = data_server_args[[page]][["title_prefix"]]
  )
}