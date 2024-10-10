plotpanel_builder <- function(id, title, plot_id, table_id, download_id){
  bslib::nav_panel(
    title = title,
    layout_column_wrap(
      width = 1,
      heights_equal = "row",
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