dataRequestUI <- function(id, geo_df) {
  ns <- NS(id)
  choices <- choice_builder("download")
  size <- names(choices$size)
  subsector <- choices$subsector
  bslib::card(
    bslib::card_title("Ready To Get Started?", class = "var-select-header"),
    urban_button(ns, "start_form", "REQUEST DATA"),
    bslib::accordion(
      id = ns("accordion"),
      open = FALSE,
      bslib::accordion_panel(
        title = "Select Form Type",
        download_formtype_para,
        htmltools::div(
          class = "banner-light__small",
          download_table
        ),
        htmltools::br(),
        download_formtype_qn,
        htmltools::br(),
        htmltools::div(
          class = "btn-radio-header",
          shiny::radioButtons(
            inputId = ns("form_select"),
            label = NULL,
            choices = c("Data from Form 990", 
                        "Data from both Form 990 and Form 990EZ"),
            inline = TRUE
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_type", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Organization, Subsector, and Size",
        download_orgtype_para,
        htmltools::br(),
        htmltools::div(
          class = "form-header",
          "What Type of Nonprofit Are You Interested In?"
        ),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("org_select"),
              label = "501(c) Types",
              choices = ctype_full,
              multiple = TRUE,
              options = list(`actions-box` = TRUE,
                             "size" = 5),
              choicesOpt = list(
                content = choice_formatter(ctype_full, 100)
              )
            )
          ),
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("size_select"),
              label = "Value of Assets",
              choices = size,
              multiple = TRUE,
              options = list(`actions-box` = TRUE)
            )
          ),
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("subsector_select"),
              label = "Subsector(s)",
              choices = subsector,
              multiple = TRUE,
              options = list(`actions-box` = TRUE)
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_geo", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Geographic Scope",
        download_geo_para,
        download_geo_qn,
        bslib::layout_column_wrap(
          urban_virtualselect(ns, "geo_select", "Select State(s) First", unique(geo_df[["Census.State"]])),
          shiny::conditionalPanel(
            condition = "input.geo_select.length > 0",
            shinyWidgets::virtualSelectInput(
              inputId = ns("county_select"),
              label = "Optional - Select Specific County(s)",
              choices = unique(geo_df[["Census.County"]]),
              showValueAsTags = TRUE,
              search = TRUE,
              multiple = TRUE
            ),
            ns = ns
          ),
          shiny::conditionalPanel(
            condition = "input.geo_select.length > 0",
            shinyWidgets::virtualSelectInput(
              inputId = ns("cbsa_select"),
              label = "Optional - Select Specific Metro Area(s)",
              choices = unique(geo_df[["Census.CBSA"]]),
              showValueAsTags = TRUE,
              search = TRUE,
              multiple = TRUE
            ),
            ns = ns
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_time", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Date Range",
        download_date_para,
        htmltools::div(
          class = "form-header",
          "Which Tax Years Are You Interested In?"
        ),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("start_year"),
              label = "Staring Tax Year",
              choices = c(1989:2022),
              multiple = FALSE,
              options = list(`actions-box` = TRUE)
            )
          ),
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("end_year"),
              label = "End Tax Year",
              choices = c(1989:2022),
              multiple = FALSE,
              options = list(`actions-box` = TRUE)
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_data", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Form 990 Fields",
        download_fields_para,
        htmltools::br(),
        htmltools::div(
          class = "form-header",
          "Which Form 990 Fields Are You Interested In?"
        ),
        htmltools::br(),
        htmltools::div(
          class = "form-header",
          bslib::input_switch(ns("all_data"), "All Data", TRUE)
        ),
        bslib::layout_column_wrap(
          htmltools::div(),
          htmltools::div(
            class = "urbn-checkbox",
            shiny::checkboxGroupInput(
              inputId = ns("data_select"),
              label = NULL,
              width = "100%",
              choices = c(
                "Program Service Accomplishments - Information on the major programs and services",
                "Required Schedules - Schedules required by the IRS",
                "Statements - Tax compliance statements reported to the IRS",
                "Governance - Information on the board of directors and governance structure",
                "Compensation - Compensation for key individuals reported to the IRS",
                "Revenue Statement - A breakdown of revenue sourced reported to the IRS",
                "Functional Expenses - An accounting of all expenses reported to the IRS.",
                "Balance Sheet - An accounting of asssets and liabilities.",
                "Public Charity Status - Information on the organization's public charity status",
                "Lobbying - Information on lobbying activities"
              ),
              inline = FALSE
            )
          ),
          htmltools::div()
        ),
        htmltools::br(),
        urban_button(ns, "next_user", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Contact Information",
        htmltools::div(
          class = "form-text",
          "A link to the requested data will be sent to your email address. Information on your use-case will help us both understand who uses the Nonprofit Sector-In-Brief Explorer and improve future use."
        ),
        htmltools::br(),
        htmltools::div(
          class = "form-choice-header",
          bslib::layout_column_wrap(
            width = 0.5,
            shiny::textInput(
              inputId = ns("first_name"),
              label = "First Name",
              placeholder = "First Name",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("last_name"),
              label = "Last Name",
              placeholder = "Last Name",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("email"),
              label = "Email",
              placeholder = "Email",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("organization"),
              label = "Organization",
              placeholder = "Organization",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("purpose"),
              label = "Role",
              placeholder = "Purpose",
              value = ""
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_review", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Review Your Request",
        htmltools::div(
          class = "form-text",
          "Please review your request before submitting. If you need to make any changes, you can navigate back to the appropriate section using the drop-down menus above."
        ),
        htmltools::br(),
        bslib::layout_column_wrap(
          width = 1/3,
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Form"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_form"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Organization Type"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_org"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Asset Size"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_size"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Subsector(s)"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_subsector"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "State(s)"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_state"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "County(s)"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_county"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Metro Area(s)"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_cbsa"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Timeframe"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_timeframe"))
            )
          ),
          htmltools::div(
            htmltools::div(
              class = "form-header",
              "Variables"
            ),
            htmltools::div(
              class = "form-header-text",
              shiny::textOutput(ns("selected_variables"))
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "start_data_download", "SUBMIT REQUEST")
      )
    )
  )
}

# Server function for the module
dataRequestServer <- function(id, geo_df) {
  moduleServer(id, function(input, output, session) {
    # Update the open panel
    observeEvent(input$start_form, {
      bslib::accordion_panel_set(id = "accordion", value = "Select Form Type")
    })
    observeEvent(input$next_type, {
      bslib::accordion_panel_set(id = "accordion", value = "Organization, Subsector, and Size")
    })
    observeEvent(input$next_geo, {
      bslib::accordion_panel_set(id = "accordion", value = "Geographic Scope")
    })
    observeEvent(input$next_time, {
      bslib::accordion_panel_set(id = "accordion", value = "Date Range")
    })
    observeEvent(input$next_data, {
      bslib::accordion_panel_set(id = "accordion", value = "Form 990 Fields")
    })
    observeEvent(input$next_user, {
      bslib::accordion_panel_set(id = "accordion", value = "Contact Information")
    })
    observeEvent(input$next_review, {
      bslib::accordion_panel_set(id = "accordion", value = "Review Your Request")
    })
    
    # Update CBSA/County Inputs
    observeEvent(input$geo_select, {
      if (length(input$geo_select) > 0) {
        shinyWidgets::updateVirtualSelect(
          inputId = "county_select",
          choices = unique(geo_df[["Census.County"]][geo_df[["Census.State"]] %in% input$geo_select])
        )
        shinyWidgets::updateVirtualSelect(
          inputId = "cbsa_select",
          choices = unique(geo_df[["Census.CBSA"]][geo_df[["Census.State"]] %in% input$geo_select])
        )
      }
    })
    
    # Select all variables
    observeEvent(input$all_data, {
      if (input$all_data) {
        shiny::updateCheckboxGroupInput(
          session = session,
          inputId = "data_select",
          selected = c(
            "Program Service Accomplishments - Information on the major programs and services",
            "Required Schedules - Schedules required by the IRS",
            "Statements - Tax compliance statements reported to the IRS",
            "Governance - Information on the board of directors and governance structure",
            "Compensation - Compensation for key individuals reported to the IRS",
            "Revenue Statement - A breakdown of revenue sourced reported to the IRS",
            "Functional Expenses - An accounting of all expenses reported to the IRS.",
            "Balance Sheet - An accounting of asssets and liabilities.",
            "Public Charity Status - Information on the organization's public charity status",
            "Lobbying - Information on lobbying activities"
          )
        )
      }
    })
    
    output$selected_form <- renderText({
      input$form_select
    })
    output$selected_org <- renderText({
      paste(input$org_select, collapse = ", ")
    })
    output$selected_size <- renderText({
      paste(input$size_select, collapse = ", ")
    })
    output$selected_subsector <- renderText({
      paste(input$subsector_select, collapse = ", ")
    })
    output$selected_state <- renderText({
      paste(input$geo_select, collapse = ", ")
    })
    output$selected_county <- renderText({
      if (length(input$county_select) == 0) {
        "All Counties"
      } else {
      paste(input$county_select, collapse = ", ")
      }
    })
    output$selected_cbsa <- renderText({
      if (length(input$cbsa_select) == 0) {
        "All Metro Areas"
      } else {
      paste(input$cbsa_select, collapse = ", ")
      }
    })
    output$selected_timeframe <- renderText({
      paste(input$start_year, input$end_year, sep = " - ")
    })
    output$selected_variables <- renderText({
      if (input$all_data) {
        "All Data"
      } else {
        paste(input$data_select, collapse = ", ")
      }
    })
 })
}