# Module for data processing in Shiny App
data_ui <- function(id, org_type_choices, date) {
  htmltools::tagList(
    org_card = bslib::card(
      bslib::card_header("Organization Type", 
                         shiny::actionLink(shiny::NS(id, "org_reset"), "Reset", style = "float: right;")),
      shiny::selectizeInput(
        inputId = shiny::NS(id, "org_level"),
        label = NULL,
        choices = c(
          "501(c)(3) Public Charities",
          "501(c)(3) Private Foundations",
          "501(c)(4) Social Welfare Organizations",
          "Other Nonprofits",
          "All Nonprofits"
        ),
        width = "500px"
      ),
      shiny::conditionalPanel(
        shiny::selectizeInput(
          inputId = shiny::NS(id, "other_orgs"),
          label = "Other 501(c) Types",
          choices = org_type_choices,
          width = "500px"
        ),
        condition = "input.org_level == 'Other Nonprofits'",
        ns = shiny::NS(id)
      )
    ),
    geo_card = geo_filter_ui(NS(id, "geo_filter"), state_choices),
    subsector_card = bslib::card(
      bslib::card_header("Subsector", shiny::actionLink(shiny::NS(id, "subsector_reset"), "Reset", style = "float: right;")),
      htmltools::div(
        class = "filter-options",
        shiny::checkboxGroupInput(
          inputId = shiny::NS(id, "subsector_select"),
          label = NULL,
          choices = subsector_choices,
          selected = subsector_choices,
          inline = FALSE
        )
      )
    ),
    size_card = bslib::card(
      bslib::card_header("Asset Size", shiny::actionLink(shiny::NS(id, "size_reset"), "Reset", style = "float: right;")),
      htmltools::div(
        class = "filter-options",
        shiny::checkboxGroupInput(
          inputId = shiny::NS(id, "size_filter"),
          label = NULL,
          inline = FALSE,
          choices = size_choices,
          selected = size_choices
        )
      )
    ),
    date_card = bslib::card(
      bslib::card_header("Date Range", shiny::actionLink(shiny::NS(id, "date_reset"), "Reset", style = "float: right;")),
      htmltools::div(
       class = "slider",
       shiny::sliderInput(
         inputId = shiny::NS(id, "date_range"),
         label = NULL,
         min = 1989,
         max = 2024,
         value = c(1989, 2024),
         step = NULL,
         ticks = FALSE,
         sep = "",
         dragRange = TRUE,
         width = "100%"
       )
      )
    ),
    process_button = bslib::input_task_button(
      id = shiny::NS(id, "process_data"),
      style = "border-radius: 0; font-size: 18px; color: #ffffff; margin: auto; background-color: #1696d2; border-color: #1696d2;",
      label = "RETRIEVE DATA",
      label_busy = "UPDATING PLOTS",
      type = "primary"
    )
  )
}