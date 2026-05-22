# Filter cards for one panel: Organization Type, Subsector, Size,
# Geographic Filters, Date Range, plus the UPDATE DATA task button.
# Returned as a named tagList so `visualpanel_content()` can place the
# cards in a specific layout (column_wrap) rather than receiving a
# pre-laid-out container.
#
# Each card includes a `uiOutput(ns("validation_<key>"))` slot below
# it (see render_validation_messages.R) where invalid-selection
# messages appear inline rather than via modal.

#' Build the filter-card tagList for one panel.
#'
#' @param id Parent panel's module id.
#' @param choices Named list of filter choices from `choice_builder()`
#'   (ctype tree, subsectors, size bands).
#' @param start_year,end_year Date-slider bounds (manifest-derived).
#' @return Named tagList with one entry per filter card plus the
#'   process button (`org_card`, `geo_card`, `subsector_card`,
#'   `size_card`, `date_card`, `process_button`).
data_ui <- function(id, choices, start_year, end_year) {
  ns <- shiny::NS(id)
  htmltools::tagList(
    org_card = bslib::card(
      filter_card_header(
        "Organization Type",
        htmltools::tagList("Categories from ", html_orgtype, ".")
      ),
      urbn_tree(
        ns = ns,
        id = "ctype",
        choice_df = choices$ctype_tree_df,
        selected = choices$ctype,
        width = "500px"
      )
    ),
    geo_card = htmltools::tagList(
      geo_filter_ui(shiny::NS(id, "geo_filter"), state_choices),
      shiny::uiOutput(ns("validation_geo"))
    ),
    subsector_card = htmltools::tagList(
      bslib::card(
        filter_card_header(
          "Subsector",
          htmltools::tagList(
            "12 general categories of the ",
            htmltools::a(
              href = "https://urbaninstitute.github.io/nccs-legacy/ntee/ntee-history.html",
              "National Taxonomy of Exempt Entities (NTEE)"
            ),
            " code system."
          )
        ),
        urbn_checkboxgroup(
          ns = ns,
          id = "subsector",
          choices = choices$subsector,
          selected = choices$subsector
        )
      ),
      shiny::uiOutput(ns("validation_subsector"))
    ),
    size_card = htmltools::tagList(
      bslib::card(
        filter_card_header(
          "Organization Size",
          "Total expenses from NCCS's Core Series (Forms 990 and 990-PF), grouped in six categories. Size=0 indicates an organization with BMF metadata but no CORE filing on record."
        ),
        urbn_checkboxgroup(
          ns = ns,
          id = "size",
          choices = choices$size,
          selected = choices$size
        )
      ),
      shiny::uiOutput(ns("validation_size"))
    ),
    date_card = bslib::card(
      filter_card_header(
        "Date Range",
        "Dates are tax years, which lag calendar years by two years on average (e.g., tax year 2024 is for calendar year 2022)."
      ),
      urbn_slider(ns, "date_range", start_year, end_year)
    ),
    process_button = htmltools::div(
      class = "filter-actions",
      urbn_task_button(
        ns = ns,
        id = "process_data",
        label = "UPDATE DATA",
        label_busy = "VISUALIZING..."
      ),
      shiny::actionButton(
        inputId = ns("reset_filters"),
        label = "Reset filters",
        class = "btn-reset"
      )
    )
  )
}