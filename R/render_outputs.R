#' @title Render outputs
#' @param plots list of plots
#' @param tables list of tables
#' @param output list of shiny outputs
#' @param query list query
#' @param agg_var character scalar. The variable to aggregate
#' @param year_var character scalar. The variable to use as year
#' @param table_title_prefix character scalar. The prefix title of the table
#' @return list of shiny outputs
render_outputs <- function(plots, tables, output, query, agg_var, year_var, table_title_prefix){
  output_plots <- render_plots(plots)
  output_tables <- render_tables(tables,
                                 agg_var = agg_var,
                                 groupbys = list(NULL, "Organization Type",query$geo_level, "Subsector", "Asset Size"),
                                 year_var = year_var)
  output_downloads <- render_download(tables)
  output$plot_overall <- output_plots$default
  output$plot_ctype <- output_plots$by_ctype
  output$plot_subsector <- output_plots$by_subsector
  output$plot_geo <- output_plots$by_geo
  output$plot_size <- output_plots$by_asset_size
  
  output$table_overall <- output_tables$default
  output$table_ctype <- output_tables$by_ctype
  output$table_subsector <- output_tables$by_subsector
  output$table_geo <- output_tables$by_geo
  output$table_size <- output_tables$by_asset_size
  #TODO: Refactor this to use a map function
  output$table_overall_title <- renderText(table_title_prefix)
  output$table_ctype_title <- renderText(paste0(table_title_prefix, ", by Organization Type"))
  output$table_subsector_title <- renderText(paste0(table_title_prefix, ", by Subsector"))
  output$table_geo_title <- renderText(paste0(table_title_prefix, ", by Geography"))
  output$table_size_title <- renderText(paste0(table_title_prefix, ", by Asset Size"))
  
  output$dl_overall <- output_downloads$default
  output$dl_ctype <- output_downloads$by_ctype
  output$dl_subsector <- output_downloads$by_subsector
  output$dl_geo <- output_downloads$by_geo
  output$dl_size <- output_downloads$by_asset_size
  

}