data_server <- function(id, geo_df, data, groupby_var, sum_var, single_plot_func, group_plot_func, title_prefix, time_series=TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
    geo_filters <- geo_filter_server("geo_filter", geo_df)
    observeEvent(input$process_data, {
      title <- create_plot_title(input$org_level, input$other_orgs, input$date_range, time_series, title_prefix)
      print("title created")
      subtitle <- create_plot_subtitle(
        geo_filters$geo_level(),
        geo_filters$region_selector(),
        geo_filters$state_selector_single(),
        geo_filters$state_selector_multi(),
        geo_filters$county_selector(),
        geo_filters$cbsa_selector(),
        input$subsector_level,
        input$subsector_select,
        input$size_level,
        input$size_select
      )
      shiny::withProgress(min = 1, max = 5, {
        setProgress(1, message = "Filtering Data...")
        filtered_data <- filter_data(
          data = data,
          org_level = input$org_level,
          other_orgs = input$other_orgs,
          geo_level = geo_filters$geo_level(),
          region = geo_filters$region_selector(),
          state_single = geo_filters$state_selector_single(),
          state_mult = geo_filters$state_selector_multi(),
          county = geo_filters$county_selector(),
          cbsa = geo_filters$cbsa_selector(),
          subsector_level = input$subsector_level,
          subsectors = input$subsector_select,
          asset_size_level = input$size_level,
          asset_sizes = input$size_select,
          time_series = time_series,
          year_start = input$date_range[1],
          year_end = input$date_range[2]
        )
        print("data filtered")
        setProgress(2, message = "Creating Tables...")
        tables <- summarise_data(
          data = filtered_data,
          groupby_var = groupby_var,
          sum_var = sum_var,
          geo_level = geo_filters$geo_level(),
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level
        )
        print("tables created")
        setProgress(3, message = "Creating Graphs...")
        plots <- create_plots(
          table_ls = tables,
          single_plot_func = single_plot_func,
          group_plot_func = group_plot_func,
          geo_level = geo_filters$geo_level(),
          subsector_level = input$subsector_level,
          asset_size_level = input$size_level,
          title = title,
          subtitle = subtitle,
          yvar = sum_var
        )
        setProgress(4, message = "Displaying Results...")
        output$plot_overall <- renderPlot({
          plots[["default"]]
        })
        output$table_overall <- renderReactable({
          reactable(
            tables[["default"]],
            outlined = TRUE,
            defaultPageSize = 10,
            defaultColDef = colDef(align = "left")
          )
        })
        # Stage 5 Displaying Results - By Subsector
        output$plot_subsector <- renderPlot({
          plots[["by_subsector"]]
        })
        output$table_subsector <- renderReactable({
          if (input$subsector_level == "individual") {
            shiny::req(tables[["by_subsector"]])
            reactable(
              tables[["by_subsector"]],
              groupBy = "Subsector",
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        # Stage 5 Displaying Results - Geography
        output$plot_geo <- renderPlot({
          plots[["by_geo"]]
        })
        output$table_geo <- renderReactable({
          if (geo_filters$geo_level() != "all") {
            reactable(
              tables[["by_geo"]],
              groupBy = var_rename_ls[[input$geo_level]],
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        output$plot_size <- renderPlot({
          plots[["by_asset_size"]]
        })
        # Stage 5 Displaying Results - Asset Size
        output$table_size <- renderReactable({
          if (input$size_level == "individual") {
            reactable(
              tables[["by_asset_size"]],
              groupBy = "Asset Size",
              outlined = TRUE,
              defaultPageSize = 10,
              defaultColDef = colDef(align = "center")
            )
          }
        })
        setProgress(5, message = "Done!")
      })
    })
  })
}
