plot_ui <- function(id) {
  bslib::navset_card_tab(
    title =   "View Results",
    height = "100%",
    bslib::nav_panel(
      "Overall",
      layout_column_wrap(
        width = NULL,
        heigh = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(shinycssloaders::withSpinner(plotOutput(NS(id, "plot_overall"),
                                                                   height = "500px"))),
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
          bslib::card_body(shinycssloaders::withSpinner(plotOutput(NS(id, "plot_subsector"),
                                                                   height = "500px"))),
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
          bslib::card_body(shinycssloaders::withSpinner(plotOutput(NS(id, "plot_geo"),
                                                                   height = "500px"))),
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
          bslib::card_body(shinycssloaders::withSpinner(plotOutput(NS(id, "plot_size"),
                                                                   height = "500px"))),
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