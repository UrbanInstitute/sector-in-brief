# Filter sections for one panel: Organization Type, Subsector, Size,
# Geographic Filters, Date Range, plus the UPDATE DATA / Reset
# buttons. Returned as a named tagList so `visualpanel_content()` can
# place the sections inside its sidebar.
#
# Each section is a plain div (no card wrapper) so it renders cleanly
# inside the sidebar without nested-card chrome. Each section also
# carries a `uiOutput(ns("validation_<key>"))` slot below it for
# render_validation_messages.R.

#' Build the filter-section tagList for one panel.
#'
#' @param id Parent panel's module id.
#' @param choices Named list of filter choices from `choice_builder()`
#'   (ctype tree, subsectors, size bands).
#' @param start_year,end_year Date-slider bounds (manifest-derived).
#' @return Named tagList with one entry per filter section plus the
#'   process button (`org_card`, `geo_card`, `subsector_card`,
#'   `size_card`, `date_card`, `process_button`). Names preserved
#'   for backwards compatibility with `visualpanel_content`.
data_ui <- function(id, choices, start_year, end_year) {
  ns <- shiny::NS(id)

  filter_section <- function(...) {
    htmltools::div(class = "filter-section", ...)
  }

  htmltools::tagList(
    org_card = filter_section(
      filter_card_header(
        "Organization Type",
        htmltools::tagList("Categories from ", html_orgtype, ".")
      ),
      urbn_tree(
        ns = ns,
        id = "ctype",
        choice_df = choices$ctype_tree_df,
        selected = choices$ctype
      )
    ),
    geo_card = filter_section(
      geo_filter_ui(shiny::NS(id, "geo_filter"), state_choices),
      shiny::uiOutput(ns("validation_geo"))
    ),
    subsector_card = filter_section(
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
      ),
      shiny::uiOutput(ns("validation_subsector"))
    ),
    size_card = filter_section(
      filter_card_header(
        "Organization Size",
        "Total expenses from NCCS's Core Series (Forms 990 and 990-PF), grouped in six categories. Size=0 indicates an organization with BMF metadata but no CORE filing on record."
      ),
      urbn_checkboxgroup(
        ns = ns,
        id = "size",
        choices = choices$size,
        selected = choices$size
      ),
      shiny::uiOutput(ns("validation_size"))
    ),
    date_card = filter_section(
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
