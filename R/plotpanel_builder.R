plotpanel_builder <- function(id, title, plot_id, table_id, download_id, table_title_id){
  bslib::nav_panel(
    title = title,
    bslib::layout_column_wrap(
      width = 1,
      heights_equal = "row",
      bslib::card(
        bslib::card_body(
          shinycssloaders::withSpinner(
            ggiraph::girafeOutput(shiny::NS(id, plot_id), width = "100%"),
            type = 1
          )
        )
      ),
      bslib::accordion(
        bslib::accordion_panel(
          title = accordion_title("View Data"),
          value = "view_table",
          id = "reactable",
          htmltools::div(
            class = "form-header",
            shiny::textOutput(shiny::NS(id, table_title_id))
          ),
          reactable::reactableOutput(shiny::NS(id, table_id)),
          htmltools::br(),
          shiny::downloadButton(shiny::NS(id, download_id), "DOWNLOAD TABLE", class = "btn-download", icon = NULL)
        ),
        open = FALSE
      )
    )
  )
}
