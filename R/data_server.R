data_server <- function(id,
                        geo_df,
                        data,
                        groupby_var,
                        sum_var,
                        title_prefix,
                        ytitle,
                        xtitle,
                        time_series = TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
    geo_filters <- geo_filter_server("geo_filter", geo_df)
    shiny::observeEvent(input$org_reset, {
      shiny::updateSelectizeInput(
        inputId = "org_level",
        selected = "501(c)(3) Public Charities"
      )
    })
    shiny::observeEvent(input$subsector_reset, {
      shiny::updateCheckboxGroupInput(
        inputId = "subsector_select",
        selected = ""
      )
    })
    shiny::observeEvent(input$size_reset, {
      shiny::updateCheckboxGroupInput(
        inputId = "size_filter",
        selected = ""
      )
    })
    shiny::observeEvent(input$date_reset, {
      shiny::updateSliderInput(
        inputId = "date_range",
        value = c(2000, 2020)
      )
    })
    observeEvent(input$process_data, {
      # Gather all inputs
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
        year_var = groupby_var
      )
      # Validate inputs
      input_validation_msg <- validate_inputs(inputs)
      if (input_validation_msg != TRUE) {
        shiny::showModal(modal(input_validation_msg))
      }
      else {
        # Create plot title and subtitle
        title <- plot_title(inputs)
        subtitle <- plot_subtitle(inputs)
        shiny::withProgress(min = 1, max = 5, {
          setProgress(1, message = "Filtering Data...")
          query <- query_builder(inputs, geo_df)
          filtered_data <- filter_data(data = data, filter_ls = query$filters)
          setProgress(2, message = "Creating Tables...")
          tables <- summarise_data(
            data = filtered_data,
            groupby_var = groupby_var,
            sum_var = sum_var,
            query = query
          )
          setProgress(3, message = "Creating Graphs...")
          plots <- plots_build_all(
            tables_ls = tables,
            groupby_vars = list(NULL, query$geo_level, "Subsector", "Asset Size"),
            title = title,
            subtitle = subtitle,
            yvar = sum_var,
            xvar = groupby_var,
            ytitle = ytitle,
            xtitle = xtitle,
            year_var = groupby_var
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
    })
  })
}
