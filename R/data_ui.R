# Module for data processing in Shiny App
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
    geo_card = geo_filter_ui(shiny::NS(id, "geo_filter"), state_choices),
    subsector_card = bslib::card(
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
    size_card = bslib::card(
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
    date_card = bslib::card(
      filter_card_header(
        "Date Range",
        "Dates are tax years, which lag calendar years by two years on average (e.g., tax year 2024 is for calendar year 2022)."
      ),
      urbn_slider(ns, "date_range", start_year, end_year)
    ),
    process_button = urbn_task_button(
      ns = ns,
      id = "process_data",
      label = "UPDATE DATA",
      label_busy = "VISUALIZING..."
    )
  )
}