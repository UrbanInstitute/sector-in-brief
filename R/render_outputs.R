render_plots <- function(plots){
  purrr::map(plots, .f = function(plot){ggiraph::renderGirafe({plot})})
}

render_tables <- function(tables, groupbys) {
  purrr::map2(
    tables,
    groupbys,
    .f = function(table, groupby) {
      reactable::renderReactable({
        reactable(
          data = table,
          groupBy = groupby,
          outlined = TRUE,
          defaultPageSize = 10,
          defaultColDef = colDef(align = "left",
                                 headerClass = "summary-table-title"),
          rowClass = "summary-table-row"
        )
      })
    }
  )
}