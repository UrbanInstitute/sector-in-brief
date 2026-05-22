# Build one of the 5 plot/table sub-tabs inside a visualization panel.
# Each sub-tab pairs a girafe plot (with spinner) and a collapsible
# accordion showing the reactable table + download button.

#' Build one plot/table sub-tab.
#'
#' @param id Parent panel's module id (used by `shiny::NS`).
#' @param title Sub-tab title shown in the navset_card_underline.
#' @param plot_id,table_id,download_id,table_title_id Output slot IDs
#'   the corresponding girafe/reactable/downloadButton/textOutput
#'   widgets bind to — set by `render_outputs()`.
#' @return A `bslib::nav_panel`.
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
