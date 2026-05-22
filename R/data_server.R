# Per-panel Shiny module server. One instance is created for each of
# the 11 visualization panels (driven by data_server_args.R). Wires the
# panel's filter UI to data_pipeline() via three observers:
#
#   1. A one-shot observer that fires when input$ctype first appears
#      (i.e. after the lazy panel UI has mounted), to render the
#      default view without requiring a user click.
#   2. A per-click observer on the UPDATE DATA task button.
#   3. A "Reset filters" observer that snaps every filter back to its
#      panel-specific default.
#
# Also renders an active-filter chip row above the plot, driven by
# `filter_chip_labels()` from the live input snapshot.

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
#' @param choices Per-panel filter choices from `choice_builder()` —
#'   used by the reset observer to restore defaults.
#' @param start_year,end_year Date-slider bounds passed to the same
#'   reset observer.
data_server <- function(id,
                        geo_df,
                        data,
                        year_var,
                        agg_var,
                        title_prefix,
                        ytitle,
                        xtitle,
                        time_series = TRUE,
                        choices,
                        start_year,
                        end_year) {
  shiny::moduleServer(id, function(input, output, session) {
    geo_filters <- geo_filter_server("geo_filter", geo_df)

    # Static defaults from the panel config — used by the reset
    # observer to drive update*Input() calls.
    ctype_default     <- choices$ctype
    subsector_default <- choices$subsector
    size_default      <- choices$size
    year_default      <- c(start_year, end_year)

    # Realized defaults captured the FIRST time the panel mounts and
    # the filter inputs materialize. urbn_tree expands a parent
    # selection into all descendant leaves, so comparing chip-state
    # against the static `choices$ctype` (which is the parent labels)
    # mis-flags the unfiltered default as narrowed. Capturing the
    # realized values once gives the chip helper a baseline to diff
    # against from then on.
    realized_defaults <- shiny::reactiveValues(
      ctype = NULL, subsector = NULL, size = NULL, year_range = NULL
    )

    # Reset all filters to panel defaults. Replaces the cluster of
    # per-card reset observers that referenced inputs that never
    # existed in the UI (dead code from an older design).
    shiny::observeEvent(input$reset_filters, {
      shinyWidgets::updateTreeInput(
        session = session, inputId = "ctype", selected = ctype_default
      )
      shiny::updateCheckboxGroupInput(
        session = session, inputId = "subsector",
        selected = unlist(subsector_default)
      )
      shiny::updateCheckboxGroupInput(
        session = session, inputId = "size",
        selected = unlist(size_default)
      )
      shiny::updateSliderInput(
        session = session, inputId = "date_range",
        value = year_default
      )
      shiny::updateRadioButtons(
        session = session, inputId = "geo_filter-geo_level",
        selected = "National"
      )
      # Clear any stale validation messages so the reset feels clean.
      render_validation_messages(list(), output)
    })

    # Active-filter chip row, recomputed reactively from the input
    # snapshot. Empty when no filter is narrowed.
    output$filter_chips <- shiny::renderUI({
      inputs <- list(
        ctype            = input$ctype,
        geo_level        = geo_filters$geo_level(),
        geo_region       = geo_filters$region(),
        geo_state_single = geo_filters$state_single(),
        geo_state_mult   = geo_filters$state_mult(),
        geo_county       = geo_filters$county(),
        geo_cbsa         = geo_filters$cbsa(),
        subsector        = input$subsector,
        size             = input$size,
        year_range       = input$date_range
      )
      defaults <- list(
        ctype_default     = realized_defaults$ctype,
        subsector_default = realized_defaults$subsector,
        size_default      = realized_defaults$size,
        year_default      = realized_defaults$year_range,
        size_choices      = choices$size
      )
      chips <- filter_chip_labels(inputs, defaults)
      if (length(chips) == 0) return(NULL)
      htmltools::tagList(
        lapply(chips, function(label) {
          htmltools::span(class = "filter-chip", label)
        })
      )
    })

    # Auto-render the default view ONCE after the lazy UI mounts and
    # filter inputs exist. observeEvent(once = TRUE, ignoreNULL = TRUE)
    # waits for input$ctype to become available, runs the pipeline, then
    # destroys itself. Pre-lazy-UI this was an unconditional call here,
    # which broke under lazy UI because inputs hadn't been rendered yet
    # when data_server initialized.
    shiny::observeEvent(input$ctype, once = TRUE, ignoreNULL = TRUE, {
      # Snapshot the realized initial selections — what urbn_tree
      # actually returned with the panel's defaults applied. These
      # become the baseline for chip-narrowing detection.
      realized_defaults$ctype      <- input$ctype
      realized_defaults$subsector  <- input$subsector
      realized_defaults$size       <- input$size
      realized_defaults$year_range <- input$date_range

      data_pipeline(
        input, geo_filters, time_series, title_prefix,
        agg_var, year_var, ytitle, xtitle, data, geo_df, output
      )
    })
    shiny::observeEvent(input$process_data, {
      data_pipeline(
        input, geo_filters, time_series, title_prefix,
        agg_var, year_var, ytitle, xtitle, data, geo_df, output
      )
    })
  })
}
