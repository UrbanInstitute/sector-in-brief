# Last step of data_pipeline(): wire the five built plots, tables, and
# download handlers into the panel module's `output` object. Each
# panel UI exposes five (plot, table, download) triplets with fixed
# IDs (plot_overall, plot_ctype, plot_subsector, plot_geo, plot_size
# and matching table_*/dl_* IDs) — this function assigns each
# rendered object to the right slot.

#' Wire built plots/tables/downloads into a panel's outputs.
#'
#' @param plots Named list from `plots_build_all()` (5 entries).
#' @param tables Named list from `summarise_data()` (5 entries).
#' @param output Shiny module `output` object.
#' @param query Query spec — used here for the by_geo column name.
#' @param agg_var Metric column name (drives number/dollar formatting).
#' @param year_var Time column name.
#' @param table_title_prefix Prefix for the per-table titles.
render_outputs <- function(plots, tables, output, query, agg_var, year_var, table_title_prefix){
  output_plots <- render_plots(plots)
  output_tables <- render_tables(tables,
                                 agg_var = agg_var,
                                 groupbys = list(NULL, "Organization Type",query$geo_level, "Subsector", "Size"),
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
  output$table_size_title <- renderText(paste0(table_title_prefix, ", by Size"))
  
  output$dl_overall <- output_downloads$default
  output$dl_ctype <- output_downloads$by_ctype
  output$dl_subsector <- output_downloads$by_subsector
  output$dl_geo <- output_downloads$by_geo
  output$dl_size <- output_downloads$by_asset_size

  # Inline note for explicitly-selected geographies that returned no data
  # (NA-dropped). renderUI returns NULL → slot clears when nothing missing.
  note <- missing_geo_note(query, tables, agg_var)
  output$geo_data_note <- shiny::renderUI({
    if (is.null(note)) return(NULL)
    htmltools::div(class = "geo-data-note", note)
  })
}