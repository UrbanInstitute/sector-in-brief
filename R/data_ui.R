# Filter sections for one panel: Date Range, Organization Type,
# Geographic Filters, Subsector, Size, plus the UPDATE DATA / Reset
# buttons.
#
# Sections live inside a `bslib::accordion` so analysts aren't faced
# with five wide blocks at once. Defaults: Date / Org Type /
# Geography open; Subsector and Size collapsed (less commonly
# touched). Ordering puts Date first because every panel-level
# question starts with "what time window?". Geography follows since
# it's the next most common filter for an analyst.
#
# Each section also carries a `uiOutput(ns("validation_<key>"))`
# slot below its body (or alongside, for the geo cascade) for
# render_validation_messages.R.

#' Build the filter-section tagList for one panel.
#'
#' @param id Parent panel's module id.
#' @param choices Named list of filter choices from `choice_builder()`.
#' @param start_year,end_year Date-slider bounds (manifest-derived).
#' @return Named tagList with `filter_accordion` (the
#'   bslib::accordion containing all five sections) and
#'   `process_button` (the Update/Reset row). Names preserved for
#'   compatibility with `visualpanel_content`.
data_ui <- function(id, choices, start_year, end_year) {
  ns <- shiny::NS(id)

  panel <- function(title, ..., value = title) {
    bslib::accordion_panel(title = title, value = value, ...)
  }

  htmltools::tagList(
    filter_accordion = bslib::accordion(
      id    = ns("filter_accordion"),
      open  = c("Date Range", "Organization Type", "Geography"),
      panel("Date Range",
        htmltools::p(
          class = "filter-hint",
          "Tax years lag calendar years by ~2 years."
        ),
        urbn_slider(ns, "date_range", start_year, end_year)
      ),
      panel("Organization Type",
        htmltools::p(
          class = "filter-hint",
          "Categories from ", html_orgtype, "."
        ),
        urbn_tree(
          ns        = ns,
          id        = "ctype",
          choice_df = choices$ctype_tree_df,
          selected  = choices$ctype
        )
      ),
      panel("Geography",
        geo_filter_ui(shiny::NS(id, "geo_filter"), state_choices),
        shiny::uiOutput(ns("validation_geo"))
      ),
      panel("Subsector",
        htmltools::p(
          class = "filter-hint",
          "12 categories of the ",
          htmltools::a(
            href = "https://urbaninstitute.github.io/nccs-legacy/ntee/ntee-history.html",
            "NTEE"
          ),
          " code system."
        ),
        urbn_checkboxgroup(
          ns       = ns,
          id       = "subsector",
          choices  = choices$subsector,
          selected = choices$subsector
        ),
        shiny::uiOutput(ns("validation_subsector"))
      ),
      panel("Organization Size",
        htmltools::p(
          class = "filter-hint",
          "Six expense bands from NCCS's Core Series."
        ),
        urbn_checkboxgroup(
          ns       = ns,
          id       = "size",
          choices  = choices$size,
          selected = choices$size
        ),
        shiny::uiOutput(ns("validation_size"))
      )
    ),
    process_button = htmltools::div(
      class = "filter-actions",
      urbn_task_button(
        ns        = ns,
        id        = "process_data",
        label     = "UPDATE DATA",
        label_busy = "VISUALIZING..."
      ),
      shiny::actionButton(
        inputId = ns("reset_filters"),
        label   = "Reset filters",
        class   = "btn-reset"
      )
    )
  )
}
