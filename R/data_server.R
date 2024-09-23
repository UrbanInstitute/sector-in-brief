data_server <- function(id, geo_df, data, groupby_var, sum_var, single_plot_func, group_plot_func, title_prefix, time_series=TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
    geo_filters <- geo_filter_server("geo_filter", geo_df)
    output$data_selection <- renderReactable({
      shiny::req(geo_filters$geo_level())
      data_selection_text(
        input$org_level,
        input$other_orgs,
        geo_filters$geo_level(),
        geo_filters$region_selector(),
        geo_filters$state_selector_single(),
        geo_filters$state_selector_multi(),
        geo_filters$county_selector(),
        geo_filters$cbsa_selector(),
        input$subsector_select,
        input$size_filter,
        input$date_range
      )

    })
    observeEvent(input$process_data, {
      input_validation_msg <- validate_inputs(
        input$org_level,
        input$other_orgs,
        geo_filters$geo_level(),
        geo_filters$region_selector(),
        geo_filters$state_selector_multi(),
        geo_filters$state_selector_single(),
        geo_filters$county_selector(),
        geo_filters$cbsa_selector(),
        input$subsector_select,
        input$size_filter,
        input$date_range[1],
        input$date_range[2]
      )
      if (input_validation_msg != TRUE) {
        shiny::showModal(modal(input_validation_msg))
      }
      else {
        title <- create_plot_title(input$org_level, input$other_orgs, input$date_range, time_series, title_prefix)
        subtitle <- create_plot_subtitle(
          geo_filters$geo_level(),
          geo_filters$region_selector(),
          geo_filters$state_selector_single(),
          geo_filters$state_selector_multi(),
          geo_filters$county_selector(),
          geo_filters$cbsa_selector(),
          input$subsector_select,
          input$size_filter
        )
        geo_highlight_ls <- list(
          "all" = state_choices,
          "Census Region" = geo_filters$region_selector(),
          "Census State" = geo_filters$state_selector_multi(),
          "Census County" = geo_filters$county_selector(),
          "Census CBSA" = geo_filters$cbsa_selector()
        )
        highlights <- highlight_server("geo_highlight", geo_highlight_ls[[geo_filters$geo_level()]])
        subsector_highlight <- highlight_server("subsector_highlight", input$subsector_select)
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
            subsectors = input$subsector_select,
            asset_sizes = input$size_filter,
            time_series = time_series,
            year_start = input$date_range[1],
            year_end = input$date_range[2],
            yearvar = groupby_var
          )
          setProgress(2, message = "Creating Tables...")
          tables <- summarise_data(
            data = filtered_data,
            groupby_var = groupby_var,
            sum_var = sum_var,
            geo_level = geo_filters$geo_level(),
            subsector_choices = input$subsector_select,
            size_choices = input$size_filter
          )
          setProgress(3, message = "Creating Graphs...")
          plots <- create_plots(
            table_ls = tables,
            single_plot_func = single_plot_func,
            group_plot_func = group_plot_func,
            geo_level = geo_filters$geo_level(),
            subsector_choices = input$subsector_select,
            size_choices = input$size_filter,
            title = title,
            subtitle = subtitle,
            yvar = sum_var,
            xvar = groupby_var
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
            plots[["by_subsector"]] + gghighlight::gghighlight(
              all(`Subsector` %in% subsector_highlight$highlights()),
            )
          })
          output$table_subsector <- renderReactable({
            if (length(input$subsector_select) > 0) {
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
            if (geo_filters$geo_level() == "all") {
              plots[["by_geo"]]
            } else{
              plots[["by_geo"]] + gghighlight::gghighlight(
                all(!!sym(geo_filters$geo_level()) %in% highlights$highlights())
              )
            }
          })
          output$table_geo <- renderReactable({
            if (geo_filters$geo_level() != "all") {
              reactable(
                tables[["by_geo"]],
                groupBy = geo_filters$geo_level(),
                outlined = TRUE,
                defaultPageSize = 10,
                defaultColDef = colDef(align = "center")
              )
            }
          })
          # Stage 5 Displaying Results - Asset Size
          size_highlights <- highlight_server("size_highlight", size_choices[size_choices %in% input$size_filter])
          output$table_size <- renderReactable({
            if (length(input$size_filter) > 0){
              reactable(
                tables[["by_asset_size"]],
                groupBy = "Asset Size",
                outlined = TRUE,
                defaultPageSize = 10,
                defaultColDef = colDef(align = "center")
              )
            }
          })
          output$plot_size <- renderPlot({
            plots[["by_asset_size"]] +
              gghighlight::gghighlight(
                all(`Asset Size` %in% names(size_choices)[size_choices %in% size_highlights$highlights()])
              )
          })
          setProgress(5, message = "Done!")
        })
      }
    })
  })
}
