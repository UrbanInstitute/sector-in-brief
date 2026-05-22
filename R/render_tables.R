# Convert the five summary tibbles into reactable widgets for the
# panel's table_* output slots. Single-year tables suppress the
# rowGroup (no point grouping by year when there's only one). Number
# formatting is dollar-aware: agg_vars in format_reactable_columns'
# dollar list get a "$" prefix, everything else gets thousands
# separators only.

#' Wrap a list of tibbles as reactable render objects.
#'
#' @param tables Named list of 5 tibbles from `summarise_data()`.
#' @param groupbys Length-5 list naming the rowGroup column for each
#'   table (NULL = no grouping).
#' @param agg_var Metric column name — drives the prefix lookup.
#' @param year_var Time column name — sets defaultSorted.
#' @return Named list of `reactable::renderReactable` outputs.
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

#' Return the reactable column-formatting list for one metric.
#'
#' @param agg_var Metric column name.
#' @return A named list keyed by column name, value is a reactable
#'   colDef with thousands-separators and (for dollar metrics) a "$"
#'   prefix.
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