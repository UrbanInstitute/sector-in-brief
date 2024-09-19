# Module for data processing in Shiny App
data_ui <- function(id, org_type_choices, date) {
  bslib::card(
    card_header("Step 1: Filters"),
    title = "",
    bslib::layout_columns(
      bslib::card(
        card_header("Organization Type"),
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
        shiny::radioButtons(
          inputId = shiny::NS(id, "subsector_level"),
          label = NULL,
          choices = subsector_level_choices,
          inline = TRUE
        ),
        shiny::conditionalPanel(
          shiny::selectizeInput(
            inputId = shiny::NS(id, "subsector_select"),
            label = NULL,
            choices = subsector_choices,
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.subsector_level == 'individual'",
          ns = shiny::NS(id)
        )
      ),
      bslib::card(
        card_header("Asset Size"),
        shiny::radioButtons(
          inputId = shiny::NS(id, "size_level"),
          label = NULL,
          inline = TRUE,
          choices = size_level_choices
        ),
        shiny::conditionalPanel(
          shiny::selectizeInput(
            inputId = shiny::NS(id, "size_select"),
            label = NULL,
            choices = size_choices,
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.size_level == 'individual'",
          ns = shiny::NS(id)
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
    ),
    bslib::input_task_button(
      id = shiny::NS(id, "process_data"),
      style = "border-radius: 0; font-size: 18px; color: #ffffff; margin: auto; background-color: #1696d2; border-color: #1696d2;",
      label = "RETRIEVE DATA",
      label_busy = "UPDATING PLOTS",
      type = "primary"
    )
  )
}