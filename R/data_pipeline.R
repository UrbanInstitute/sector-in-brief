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
                         year_var = year_var)
  input_validation_msg <- validate_inputs(inputs)
  if (input_validation_msg != TRUE) {
    shiny::showModal(modal(input_validation_msg))
  }
  else {
    title <- plot_title(inputs)
    subtitle <- plot_subtitle(inputs)
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
        groupby_vars = list(NULL, query$geo_level, "Subsector", "Asset Size"),
        title = title,
        subtitle = subtitle,
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
                     agg_var = agg_var)
      setProgress(5, message = "Done!")
    })
  }
}