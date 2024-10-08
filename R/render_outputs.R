render_outputs <- function(plots, tables, output, query, agg_var){
  output_plots <- render_plots(plots)
  output_tables <- render_tables(tables,
                                 agg_var = agg_var,
                                 groupbys = list(NULL, query$geo_level, "Subsector", "Asset Size"))
  output_downloads <- render_download(tables)
  output$plot_overall <- output_plots$default
  output$plot_subsector <- output_plots$by_subsector
  output$plot_geo <- output_plots$by_geo
  output$plot_size <- output_plots$by_asset_size
  
  output$table_overall <- output_tables$default
  output$table_subsector <- output_tables$by_subsector
  output$table_geo <- output_tables$by_geo
  output$table_size <- output_tables$by_asset_size
  
  output$dl_overall <- output_downloads$default
  output$dl_subsector <- output_downloads$by_subsector
  output$dl_geo <- output_downloads$by_geo
  output$dl_size <- output_downloads$by_asset_size
  
  
}