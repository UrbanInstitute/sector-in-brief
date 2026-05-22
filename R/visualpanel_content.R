# Build the inside of a visualization panel — header + sidebar of
# accordioned filters + main column with coverage notes, chips, and
# plot/table UI. Returned as a tagList so a wrapping uiOutput can
# drop it in.
#
# Splitting this out from visualpanel_builder means a tab's heavy
# widgets (plot_ui, data_ui, coverage_notes_card) only run when the
# tab activates, not at app boot.
#
# Layout:
#
#   [page_header_card — full width]
#   [-------- bslib::layout_sidebar --------]
#   [ sidebar       ] [ main                  ]
#   [               ] [                       ]
#   [ ▸ Date Range  ] [ coverage notes        ]
#   [ ▸ Org Type    ] [ chip row              ]
#   [ ▸ Geography   ] [ plot/table sub-tabs   ]
#   [ ▹ Subsector   ] [                       ]
#   [ ▹ Size        ] [                       ]
#   [ Update/Reset  ] [                       ]
#   [---------------] [-----------------------]
#
# Sidebar contents come from data_ui() as a bslib::accordion +
# action-button block; chevrons signal progressive disclosure
# (Subsector and Size start collapsed).

#' Render the lazy contents of one visualization panel.
#'
#' @param panel_header Bold heading shown above the filters.
#' @param panel_desc Descriptive paragraph below the header.
#' @param panelid Module id (also used as the parent uiOutput slot).
#' @param start_year,end_year Date-slider bounds (resolved from the
#'   manifest at boot — see `resolve_visualpanel_year_ranges()`).
#' @param parquet_file Source filename, used by the coverage-notes
#'   card to look up per-file notes from `data_dictionary.parquet`.
#' @return A `htmltools::tagList`.
visualpanel_content <- function(panel_header,
                                panel_desc,
                                panelid,
                                start_year,
                                end_year,
                                parquet_file) {
  choices <- choice_builder(panelid)
  ui_parts <- data_ui(panelid, choices, start_year, end_year)
  ns <- shiny::NS(panelid)
  meta <- manifest_meta()
  vintage_line <- if (!is.null(meta$vintage)) {
    parts <- c(
      sprintf("Data through tax year %d", end_year),
      sprintf("vintage %s", meta$vintage),
      if (!is.null(meta$built_at_date)) sprintf("refreshed %s", meta$built_at_date)
    )
    htmltools::p(
      class = "vintage-indicator",
      paste(parts, collapse = " · ")
    )
  } else NULL

  htmltools::tagList(
    page_header_card(panel_header, panel_desc),
    vintage_line,
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        title = "Filters",
        width = 320,
        class = "panel-filter-sidebar",
        ui_parts[["filter_accordion"]],
        ui_parts[["process_button"]]
      ),
      coverage_notes_card(parquet_file),
      # Active-filter chips, rendered by data_server() from the inputs
      # snapshot. Empty when no filter is narrowed from default.
      shiny::uiOutput(ns("filter_chips"), class = "filter-chip-row"),
      plot_ui(panelid)
    )
  )
}
