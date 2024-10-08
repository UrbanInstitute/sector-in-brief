plotpanel_builder <- function(id, title, plot_id, table_id, download_id){
  bslib::nav_panel(
    title = title,
    layout_column_wrap(
      width = NULL,
      heigh = 650,
      style = htmltools::css(grid_template_columns = "3fr 1fr"),
      bslib::card(
        bslib::card_body(
          shinycssloaders::withSpinner(
            ggiraph::girafeOutput(NS(id, plot_id), width = "100%"),
            type = 1
          )
        )
      ),
      bslib::card(
        bslib::card_body(reactable::reactableOutput(NS(id, table_id))),
        bslib::card_body(
          downloadButton(NS(id, download_id), "DOWNLOAD", class = "btn-download", icon = NULL)
        )
      )
    )
  )
}