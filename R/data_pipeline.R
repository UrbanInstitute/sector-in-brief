# Orchestrator for a single panel update. Runs the
#   format_input → validate_inputs → query_builder
#   → cached_filter_and_summarise (filter + summarise)
#   → plots_build_all → render_outputs
# chain inside a withProgress() wrapper for the spinner, with a
# tryCatch() that converts unexpected errors into a friendly modal
# (added in PR #25). Validation errors are surfaced inline under the
# offending filter section in the sidebar accordion (PR #30), not
# via modal.

#' Run the panel pipeline for one UPDATE DATA click.
#'
#' @param input Shiny `input` reactive object for the panel module.
#' @param geo_filters Reactive list from `geo_filter_server()`.
#' @param time_series TRUE → line plots; FALSE → bar plots.
#' @param title_prefix Title prefix for plots and tables.
#' @param agg_var Metric column to aggregate.
#' @param year_var Time column ("Year").
#' @param ytitle,xtitle Axis labels.
#' @param data Lazy arrow Dataset from `dataloader()`.
#' @param geo_df Nested geographies lookup, used by `query_builder()`.
#' @param output The module's `output` object — written by
#'   `render_outputs()` (plots) and `render_validation_messages()`.
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
  validation <- validate_inputs(inputs)
  render_validation_messages(validation$errors, output)
  if (!validation$valid) {
    return(invisible())
  }
  tryCatch({
    title <- plot_title(inputs)
    caption <- plot_caption(inputs)
    shiny::withProgress(min = 1, max = 5, {
      setProgress(1, message = "Filtering Data...")
      query <- query_builder(inputs, geo_df)
      setProgress(2, message = "Creating Tables...")
      tables <- cached_filter_and_summarise(
        data = data,
        query = query,
        year_var = year_var,
        agg_var = agg_var
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
      # Per-state note for records with no assignable county/metro
      # (NA geography), excluded from the breakdown above.
      unassigned <- unassigned_geo_note(data, inputs, query, agg_var)
      output$geo_unassigned_note <- shiny::renderUI({
        if (is.null(unassigned)) return(NULL)
        htmltools::div(class = "geo-data-note", unassigned)
      })
      setProgress(5, message = "Done!")
    })
  }, error = function(e) {
    # Server-side log gets the full error for debugging.
    message(sprintf("[data_pipeline] panel=%s err=%s",
                    title_prefix, conditionMessage(e)))
    shiny::showModal(error_modal(conditionMessage(e)))
  })
}