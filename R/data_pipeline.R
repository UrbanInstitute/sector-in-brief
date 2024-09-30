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
  inputs <- list(
    org_level = input$org_level,
    other_orgs = input$other_orgs,
    geo_level = geo_filters$geo_level(),
    geo_region = geo_filters$region_selector(),
    geo_state_single = geo_filters$state_selector_single(),
    geo_state_multi = geo_filters$state_selector_multi(),
    geo_county = geo_filters$county_selector(),
    geo_cbsa = geo_filters$cbsa_selector(),
    subsector = input$subsector_select,
    size = input$size_filter,
    year_range = input$date_range,
    time_series = time_series,
    title_prefix = title_prefix,
    year_var = year_var
  )
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
      print(query)
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
      setProgress(5, message = "Done!")
    })
  }
}