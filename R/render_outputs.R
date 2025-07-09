#------------------------------------------------------------------------------
# File: render_outputs.R
# Author: Thiyaghessan Poongundranar [tpoongundranar@urban.org]
# Date Created: 2024-06-01
# Date Last Modified: 2025-07-09
#
# Purpose: This script contains functions used to render outputs in a Shiny app.
#
# Usage: This script is sourced in the main app file. It renders and maps the 
# outputs of plots, tables, and download handlers based on the user inputs to the
# shiny list of reactive outputs.
#
# Dependencies:
# - purrr
# - ggiraph
# - reactable
# - shiny
# - shinycssloaders
# - R/urbn_ui_elements.R
#-------------------------------------------------------------------------------

#' @title Main rendering function
#' 
#' @description This function orchestrates the rendering of plots, tables, and
#' download handlers in a Shiny app. It takes a list of plots, tables, and
#' outputs, along with a query and configuration parameters, and returns a list
#' of shiny outputs.
#' 
#' @param plots list of plots
#' @param tables list of tables
#' @param output list of shiny outputs
#' @param query list query
#' @param config list configuration parameters
#' 
#' @return list of shiny outputs
render_outputs <- function(plots, tables, output, query, config){
  # Plots
  output_plots <- render_plots(plots)
  output <- map_outputs(output, "plot", output_plots)
  # Tables
  output_tables <- render_tables(tables,
                                 agg_var = config$agg_var,
                                 groupbys = list(NULL, "Organization Type",query$geo_level, "Subsector", "Size"),
                                 year_var = config$year_var)
  output <- map_outputs(output, "table", output_tables)
  # Download links
  output_downloads <- render_download(tables)
  output <- map_outputs(output, "dl", output_downloads)
  # Table Titles
  output_titles <- render_titles(config$title_prefix)
  output <- map_outputs(output, "title", output_titles)

}

#' @title Render titles for the downloadable tables
#' 
#' @description This function generates titles for the downloadable tables based
#' on the provided prefix. It returns a list of titles for different groupings
#' 
#' @param prefix A character string to prefix the titles
#' 
#' @return A list of titles for the downloadable tables
render_titles <- function(prefix){
  output_titles <- c(
    by_overall = "",
    by_ctype = ", by Organization Type",
    by_subsector = ", by Subsector",
    by_geo = ", by Geography",
    by_size = ", by Size"
  )
  output_titles <- purrr::map(
    output_titles,
    .f = function(title) {
      renderText(paste0(prefix, title))
    }
  )
  return(output_titles)
}

#' @title Map outputs to the output list
#' 
#' @description This function maps the outputs of plots, tables, and download
#' handlers to the output list based on the specified output type. It edits the
#' output list in place since it is called repeatedly to overwrite the existing
#' output list with new outputs.
#' 
#' @param output_ls A list of outputs to be updated
#' @param output_type A character string specifying the type of output to map
#' @param render_ls A list of rendered outputs (plots, tables, or download handlers)
#' 
#' @return A list of outputs with the specified output type mapped
map_outputs <- function(output_ls, output_type, render_ls) {
  opts <- c("overall", "ctype", "subsector", "geo", "size")
  if (output_type == "title"){
    for (opt in opts){
      output_ls[[paste0("table_", opt, "_title")]] <- render_ls[[paste0("by_", opt)]]
    }
  } else{
    for (opt in opts) {
      output_ls[[paste0(output_type, "_", opt)]] <- render_ls[[paste0("by_", opt)]]
    }
  }
  return(output_ls)
}

render_plots <- function(plots){
  purrr::map(plots, .f = function(plot){ggiraph::renderGirafe({plot})})
}

#' @title Render a list of reactable objects
#' 
#' @param tables A list of data frames
#' @param groupbys A list of character vectors defining groupby columns
#' @param agg_var A character vector defining the column to sum
#' @param year_var A character vector defining the column to group by
#' 
#' @return A list of reactable objects
render_tables <- function(tables, groupbys, agg_var, year_var) {
  #' @title Convert data.frame to reactable object
  format_reactable <- function(table, groupby, agg_var, year_var) {
    if (length(unique(table[[year_var]])) == 1){
      groupby <- NULL
    }
    table <- reactable(
      data = table,
      columns = format_reactable_columns(agg_var),
      defaultSorted = year_var,
      groupBy = groupby,
      outlined = TRUE,
      defaultPageSize = 10,
      defaultColDef = colDef(align = "left", headerClass = "summary-table-title"),
      rowClass = "summary-table-row"
    )
    reactable::renderReactable({
      table
    })
  }
  
  purrr::map2(
    tables,
    groupbys,
    .f = format_reactable,
    agg_var = agg_var,
    year_var = year_var
  )
}

#' @title Column formatting for reactable columns
#' 
#' @description Adds unit prefixes to column values
#' 
#' @param agg_var A character vector defining the names of column to format
#' 
#' @return A list of column formatting configurations
format_reactable_columns <- function(agg_var) {
  prefix_ls = list(
    "Number of Nonprofits" = "",
    "Total Assets" = "$",
    "Total Revenues" = "$",
    "Total Expenses" = "$",
    "Total Benefits" = "$",
    "Total Government Grants" = "$",
    "Total Payroll Taxes" = "$",
    "Total Contributions" = "$",
    "Total Investments" = "$",
    "Number of DAFs" = "",
    "Total Grants" = "$",
    "Total Value" = "$",
    "Proportion with DAFs" = ""
  )
  
  format_ls <- list()
  format_ls[[agg_var]] <- reactable::colDef(format = reactable::colFormat(prefix = prefix_ls[[agg_var]], separators = TRUE))
  return(format_ls)
}

#' @title Render download handlers for tables
#' 
#' @param tables A list of data frames to be downloaded
#' 
#' @return A list of download handlers for each table
render_download <- function(tables){
  purrr::imap(
    tables,
    .f = function(table, name) {
      downloadHandler(
        filename = paste0(name, ".csv"),
        content = function(file) {
          write.csv(table, file)
        }
      )
    }
  )
}