#-------------------------------------------------------------------------------
# File: data_server.R
# Author: Thiyaghessan Poongundranar [tpoongundranar@urban.org]
# Date Created: 2024-06-01
# Date Last Modified: 2025-07-03
#
# Purpose: This script contains the functions that execute server side 
# logic to process and load the data requested in the UI.
#
# Usage: This script is sourced in the main app file. data_load() first
# loads data from the desired path with data_extract(). Next, data_transform()
# filters and aggregates the data based on user inputs. 
#
# Dependencies:
# - shinycssloaders
# - arrow
# - R/geo_filter_server.R
# - R/data_pipeline.R
#-------------------------------------------------------------------------------

#' @title Extract data from parquet files
#' 
#' @description This function reads data from a parquet file and returns a
#' arrow table for faster querying.
#' 
#' @param path The file path to the parquet file.
#' @param cols Optional vector of column names to select from the parquet file.
#' 
#' @return An arrow table containing the selected columns from the parquet file.
data_extract <- function(path, cols=NULL) {
  shinycssloaders::showPageSpinner()
  data_select <- arrow::read_parquet(path, as_data_frame = FALSE, col_select = cols)
  shinycssloaders::hidePageSpinner()
  return(data_select)
}

#' @title Transform and filter data based on user inputs
#' 
#' @description This function processes the data based on user inputs, applying
#' filters and aggregations as specified. It also handles the display of
#' visualizations and tables in the Shiny app based on user inputs. A reactive
#' trigger is used to reprocess the data whenever the user clicks the
#' 'update data' button.
#' 
#' @param id The ID of the Shiny module.
#' @param geo_df A data frame containing geographic information for filtering.
#' @param data The data to be processed, typically an arrow table.
#' @param config A list containing configuration parameters for the output
#' 
#' @return A Shiny module server function that processes the data and updates
#' the UI with the results.
data_transform <- function(id, geo_df, data, config) {
  shiny::moduleServer(id, function(input, output, session) {
    # This ensures data is processed at the start and when the trigger is activated
    process_trigger <- shiny::reactiveVal(0)
    shiny::observeEvent(input$process_data, {
      process_trigger(process_trigger() + 1)
    })
    geo_filters <- geo_filter_server("geo_filter", geo_df)
    output_data_reactive <- shiny::reactive({data_pipeline(input, geo_filters, config, data, geo_df, output)}) |>
      shiny::bindEvent(process_trigger())
    return(output_data_reactive)
  })
}

#' @title Load and process data for the Shiny app
#' 
#' @description This function serves as a wrapper to load data based on the
#' specified page and process it using the data_transform function.
#' 
#' @param page The page identifier for which data needs to be loaded.
#' @param data_server_args A list containing the arguments for data loading and
#' transformation, including file paths and variable names.
#' @param geo_df A data frame containing geographic information for filtering.
#' 
#' @return Processed data frames ready for visualization in the Shiny app.
data_load <- function(page, data_server_args, geo_df) {
  config <- list(
    year_var = data_server_args[[page]][["year_var"]],
    agg_var = data_server_args[[page]][["agg_var"]],
    ytitle = data_server_args[[page]][["ytitle"]],
    xtitle = data_server_args[[page]][["xtitle"]],
    title_prefix = data_server_args[[page]][["title_prefix"]],
    time_series = data_server_args[[page]][["time_series"]]
  )
  data_extracted <- data_extract(path = data_server_args[[page]][["path"]], cols = data_server_args[[page]][["vars"]])
  processed_data_reactive <- data_transform(id = data_server_args[[page]][["id"]], geo_df, data_extracted, config)
  rs_ls <- list(config = config, data = processed_data_reactive)
  return(rs_ls)
}

# TODO
# Filter anomalous values in the Number of DAFs and Total Assets during 
# preprocessing.
