#' @title Render a list of reactable objects
#' @param tables A list of data frames
#' @param groupbys A list of character vectors defining groupby columns
#' @param agg_var A character vector defining the column to sum
render_tables <- function(tables, groupbys, agg_var) {
  #' @title Convert data.frame to reactable object
  format_reactable <- function(table, groupby, agg_var) {
    reactable::renderReactable({
      reactable(
        data = table,
        columns = format_reactable_columns(agg_var),
        groupBy = groupby,
        outlined = TRUE,
        defaultPageSize = 10,
        defaultColDef = colDef(align = "left", headerClass = "summary-table-title"),
        rowClass = "summary-table-row"
      )
    })
  }
  
  purrr::map2(
    tables,
    groupbys,
    .f = format_reactable,
    agg_var = agg_var
  )
}

#' @title Column formatting for reactable
#' @param agg_var A character vector defining the column to format
#' @return A list of column formatting configurations
format_reactable_columns <- function(agg_var) {
  prefix_ls = list(
    "Number of Nonprofits" = "",
    "Total Assets" = "$",
    "Total Revenues" = "$",
    "Total Expenses" = "$",
    "Total Benefits" = "$",
    "Total Payroll Taxes" = "$",
    "Total Contributions" = "$",
    "Number of DAFs" = "",
    "Total Grants" = "$",
    "Total Value" = "$",
    "Proportion with DAFs" = ""
  )
  
  format_ls <- list()
  format_ls[[agg_var]] <- reactable::colDef(format = reactable::colFormat(prefix = prefix_ls[[agg_var]], separators = TRUE))
  return(format_ls)
}