data_server <- function(id,
                        geo_df,
                        data,
                        year_var,
                        agg_var,
                        title_prefix,
                        ytitle,
                        xtitle,
                        time_series = TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
    geo_filters <- geo_filter_server("geo_filter", geo_df)
    shiny::observeEvent(input$org_reset, {
      shiny::updateSelectizeInput(inputId = "org_level", selected = "501(c)(3) Public Charities")
    })
    shiny::observeEvent(input$subsector_reset, {
      shiny::updateCheckboxGroupInput(inputId = "subsector_select", selected = "")
    })
    shiny::observeEvent(input$size_reset, {
      shiny::updateCheckboxGroupInput(inputId = "size_filter", selected = "")
    })
    shiny::observeEvent(input$date_reset, {
      shiny::updateSliderInput(inputId = "date_range", value = c(2000, 2020))
    })
    # Auto-render the default view ONCE after the lazy UI mounts and
    # filter inputs exist. observeEvent(once = TRUE, ignoreNULL = TRUE)
    # waits for input$ctype to become available, runs the pipeline, then
    # destroys itself. Pre-lazy-UI this was an unconditional call here,
    # which broke under lazy UI because inputs hadn't been rendered yet
    # when data_server initialized.
    shiny::observeEvent(input$ctype, once = TRUE, ignoreNULL = TRUE, {
      data_pipeline(
        input,
        geo_filters,
        time_series,
        title_prefix,
        agg_var,
        year_var,
        ytitle,
        xtitle,
        data,
        geo_df,
        output
      )
    })
    observeEvent(input$process_data, {
      # Gather all inputs
      # Validate inputs
      data_pipeline(
        input,
        geo_filters,
        time_series,
        title_prefix,
        agg_var,
        year_var,
        ytitle,
        xtitle,
        data,
        geo_df,
        output
      )
    })
  })
}
