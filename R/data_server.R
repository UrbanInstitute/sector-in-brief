# Per-panel Shiny module server. One instance is created for each of
# the 11 visualization panels (driven by data_server_args.R). Wires the
# panel's filter UI to data_pipeline() via two observers:
#
#   1. A one-shot observer that fires when input$ctype first appears
#      (i.e. after the lazy panel UI has mounted), to render the
#      default view without requiring a user click.
#   2. A per-click observer on the UPDATE DATA task button.
#
# Also handles the per-filter "reset" buttons.

#' Per-panel server module.
#'
#' @param id Module id (matches the panel's `id` in `data_server_args`).
#' @param geo_df Nested geographies lookup (state → county/CBSA).
#' @param data Lazy arrow Dataset from `dataloader()` for this panel.
#' @param year_var Column to plot on the x-axis ("Year").
#' @param agg_var Column to aggregate (panel-specific metric).
#' @param title_prefix Title shown above the panel's plots.
#' @param ytitle,xtitle Axis labels.
#' @param time_series TRUE for multi-year line plots; FALSE for
#'   single-year bar plots (DAF panels).
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
