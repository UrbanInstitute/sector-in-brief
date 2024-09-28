plot_ui <- function(id, selected_geographies) {
  bslib::navset_card_tab(
    title =   "",
    height = "100%",
    bslib::card_title("Visualize Your Results", class = "viz-header"),
    bslib::nav_panel(
      "Overall",
      layout_column_wrap(
        width = NULL,
        heigh = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(
            shinycssloaders::withSpinner(
              ggiraph::girafeOutput(NS(id, "plot_overall"), width = "100%"),
              type = 1
            )
          ),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput(NS(id, "table_overall"))),
          bslib::card_body(
            downloadButton(NS(id, "downloadData"), "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Subsector",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(
            shinycssloaders::withSpinner(
              ggiraph::girafeOutput(NS(id, "plot_subsector"), width = "100%"),
              type = 1
            )
          ),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput(NS(id, "table_subsector"))),
          bslib::card_body(
            downloadButton(NS(id, "downloadData"), "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Geography",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(
            shinycssloaders::withSpinner(
              ggiraph::girafeOutput(NS(id, "plot_geo"), width = "100%"),
              type = 1
            )
          ),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput(NS(id, "table_geo"))),
          bslib::card_body(
            downloadButton(NS(id, "downloadData"), "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Asset Size",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(
            shinycssloaders::withSpinner(
              ggiraph::girafeOutput(NS(id, "plot_size"), width = "100%"),
              type = 1
            )
          ),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput(NS(id, "table_size"))),
          bslib::card_body(
            downloadButton(NS(id, "downloadData"), "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    )
  )
}