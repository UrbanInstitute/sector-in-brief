render_outputs <- function(plots, tables, output, query){
  output_plots <- render_plots(plots)
  output_tables <- render_tables(tables,
                                 groupbys = list(NULL, query$geo_level, "Subsector", "Asset Size"))
  output$plot_overall <- output_plots$default
  output$plot_subsector <- output_plots$by_subsector
  output$plot_geo <- output_plots$by_geo
  output$plot_size <- output_plots$by_asset_size
  output$table_overall <- output_tables$default
  output$table_subsector <- output_tables$by_subsector
  output$table_geo <- output_tables$by_geo
  output$table_size <- output_tables$by_asset_size
}