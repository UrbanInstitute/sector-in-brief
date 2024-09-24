# Module for data processing in Shiny App
data_ui <- function(id, org_type_choices, date) {
  tagList(
  bslib::card(
    card_header("Select Your Variables"),
    title = "",
    bslib::layout_columns(
      bslib::card(
        bslib::card_header("Organization Type"),
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
      bslib::card(
        card_header("Geography"),
        geo_filter_ui(NS(id, "geo_filter"), state_choices),
      ),
      bslib::card(
        bslib::card_header("Subsector"),
        shiny::checkboxGroupInput(
          inputId = shiny::NS(id, "subsector_select"),
          label = NULL,
          choices = subsector_choices,
          selected = subsector_choices,
          inline = FALSE
        )
      ),
      bslib::card(
        card_header("Asset Size"),
        shiny::checkboxGroupInput(
          inputId = shiny::NS(id, "size_filter"),
          label = NULL,
          inline = FALSE,
          choices = size_choices,
          selected = size_choices
        )
      ),
      if (date == TRUE){
        bslib::card(
          card_header("Date Range"),
          shiny::sliderInput(
            inputId = shiny::NS(id, "date_range"),
            label = NULL,
            min = 1989,
            max = 2024,
            value = c(1989, 2024),
            step = NULL,
            ticks = FALSE,
            sep = "",
            dragRange = TRUE
          )
        )
      }
    )
  )
  )
}