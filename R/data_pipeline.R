#' @title pipeline for server side data processing
#' @param input list of input values
#' @param geo_filters list of geo filters
#' @param time_series boolean. If TRUE, the data is time series
#' @param title_prefix character scalar. The prefix for the plot title
#' @param agg_var character scalar. The variable to aggregate
#' @param year_var character scalar. The variable to use as year
#' @param ytitle character scalar. The title for the y-axis
#' @param xtitle character scalar. The title for the x-axis
#' @param data arrow table. The filtered data to render in output tables and plots
#' @param geo_df data.frame. data set of nested geographies
#' @param output list of shiny outputs
#' @return list of shiny outputs
data_pipeline <- function(input,
                          geo_filters,
                          time_series,
                          title_prefix,
                          agg_var,
                          year_var,
                          ytitle,
                          xtitle,
                          data,
                          geo_df,
                          output) {
  inputs <- format_input(input = input, 
                         geo_filters = geo_filters, 
                         time_series = time_series, 
                         title_prefix = title_prefix, 
                         year_var = year_var,
                         agg_var = agg_var)
  input_validation_msg <- validate_inputs(inputs)
  if (input_validation_msg != TRUE) {
    shiny::showModal(modal(input_validation_msg))
    return(invisible())
  }
  tryCatch({
    title <- plot_title(inputs)
    caption <- plot_caption(inputs)
    shiny::withProgress(min = 1, max = 5, {
      setProgress(1, message = "Filtering Data...")
      query <- query_builder(inputs, geo_df)
      filtered_data <- filter_data(data = data, filter_ls = query$filters)
      setProgress(2, message = "Creating Tables...")
      tables <- summarise_data(
        data = filtered_data,
        groupby_var = year_var,
        sum_var = agg_var,
        query = query
      )
      setProgress(3, message = "Creating Graphs...")
      plots <- plots_build_all(
        tables_ls = tables,
        groupby_vars = list(NULL, "Organization Type", query$geo_level, "Subsector", "Size"),
        title = title,
        caption = caption,
        yvar = agg_var,
        xvar = year_var,
        ytitle = ytitle,
        xtitle = xtitle,
        year_var = year_var
      )
      setProgress(4, message = "Displaying Results...")
      render_outputs(plots = plots,
                     tables = tables,
                     output = output,
                     query = query,
                     agg_var = agg_var,
                     year_var = year_var,
                     table_title_prefix = title)
      setProgress(5, message = "Done!")
    })
  }, error = function(e) {
    # Server-side log gets the full error for debugging.
    message(sprintf("[data_pipeline] panel=%s err=%s",
                    title_prefix, conditionMessage(e)))
    shiny::showModal(error_modal(conditionMessage(e)))
  })
}