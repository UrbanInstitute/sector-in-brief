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
        title = "Option 1: Form Type",
        htmltools::br(),
        htmltools::div(
          class = "banner-light__small",
          download_table
        ),
        htmltools::br(),
        htmltools::div(
          class = "btn-radio-header",
          shiny::radioButtons(
            inputId = ns("form_select"),
            label = "Select one option *",
            choices = list("Form 990 Filers" = "990", 
                        "Form 990 and Form 990-EZ Filers" = "990EZ"),
            inline = TRUE
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_type", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Option 2: Organization, Subsector, and Size",
        htmltools::br(),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "form-choice-text",
            shinyWidgets::pickerInput(
              inputId = ns("org_select"),
              label = htmltools::div(
                htmltools::tags$b("Organization Type *"),
                htmltools::p("Section 501(c) of the Internal Revenue Code")
              ),
              choices = ctype_id,
              multiple = TRUE,
              options = list(`actions-box` = TRUE,
                             "size" = 5),
              choicesOpt = list(
                content = choice_formatter(ctype_id, 100)
              )
            )
          ),
          htmltools::div(
            class = "form-choice-text",
            shinyWidgets::pickerInput(
              inputId = ns("subsector_select"),
              label = htmltools::div(
                htmltools::tags$b("Subsector *"),
                htmltools::HTML("<p>12 general categories of the <a href='https://urbaninstitute.github.io/nccs-legacy/ntee/ntee-history.html'>National Taxonomy of Exempt Entities</a> (NTEE) code system</p>")
              ),
              choices = subsector,
              multiple = TRUE,
              options = list(`actions-box` = TRUE)
            )
          ),
          htmltools::div(
            class = "form-choice-text",
            shinyWidgets::pickerInput(
              inputId = ns("size_select"),
              label = htmltools::div(
                htmltools::tags$b("Asset Size *"),
                htmltools::p("Total assets from the IRS Business Master File grouped in five categories.")
              ),
              choices = list(
                "Under $100,000" = "1",
                "$100,000 - $499,999" = "2",
                "$500,000 - $999,999" = "3",
                "$1,000,000 - $4,999,999" = "4",
                "$5,000,000 - $9,999,999" = "5",
                "Above $10,000,000" = "6"
              ),
              multiple = TRUE,
              options = list(`actions-box` = TRUE)
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_geo", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Option 3: Geographic Scope",
        download_geo_para,
        htmltools::br(),
        bslib::layout_column_wrap(
          urban_virtualselect(ns, "region_select", "Optional - Select Region(s)", c("Northeast", "Midwest", "South", "West")),
          urban_virtualselect(ns, "geo_select", "Select State(s) *", state_choices),
          shiny::conditionalPanel(
            condition = "input.geo_select.length > 0",
            urban_virtualselect(
              ns,
              "county_select",
              label = "Optional - Select Specific County(s)",
              choices = unique(geo_df[["Census.County"]])
            ),
            ns = ns
          ),
          shiny::conditionalPanel(
            condition = "input.geo_select.length > 0",
            urban_virtualselect(
              ns,
              "cbsa_select",
              label = "Optional - Select Specific Metropolitan (> 50,000 people) and Micropolitan (10,000 – 50,000 people) Areas",
              choices = unique(geo_df[["Census.CBSA"]])
            ),
            ns = ns
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_time", "NEXT")
      ),
      bslib::accordion_panel(
        title = "Option 4: Date Range",
        download_date_para,
        htmltools::br(),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("start_year"),
              label = "From Tax Year *",
              choices = c(1989:2022),
              multiple = FALSE,
              options = list(`actions-box` = TRUE)
            )
          ),
          htmltools::div(
            class = "form-choice-header",
            shinyWidgets::pickerInput(
              inputId = ns("end_year"),
              label = "Through Tax Year *",
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
        title = "Option 5: Variables",
        download_fields_para,
        htmltools::br(),
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
              choices = var_choices_990,
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
          "A link to the requested data will be sent to your email address."
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
              label = "Email *",
              placeholder = "",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("organization"),
              label = "Organization *",
              placeholder = "",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("purpose"),
              label = "Title",
              placeholder = "Job Title",
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
          "If you need to make any changes, you can navigate back to the appropriate section using the drop-down menus above."
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
      bslib::accordion_panel_set(id = "accordion", value = "Option 1: Form Type")
    })
    observeEvent(input$next_type, {
      bslib::accordion_panel_set(id = "accordion", value = "Option 2: Organization, Subsector, and Size")
    })
    observeEvent(input$next_geo, {
      if (length(input$org_select) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please select at least one organization type",
          type = "error"
        )
      } else if (length(input$size_select) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please select at least one asset size",
          type = "error"
        )
      } else if (length(input$subsector_select) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please select at least one subsector",
          type = "error"
        )
      } else {
        bslib::accordion_panel_set(id = "accordion", value = "Option 3: Geographic Scope")
      }
    })
    observeEvent(input$next_time, {
      if (length(input$geo_select) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please select at least one state",
          type = "error"
        )
      } else {
        bslib::accordion_panel_set(id = "accordion", value = "Option 4: Date Range")
      }
    })
    observeEvent(input$next_data, {
      bslib::accordion_panel_set(id = "accordion", value = "Option 5: Variables")
    })
    observeEvent(input$next_user, {
      bslib::accordion_panel_set(id = "accordion", value = "Contact Information")
    })
    observeEvent(input$next_review, {
      if(nchar(input$email) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please enter an email address",
          type = "error"
        )
      } else if(nchar(input$organization) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please enter an organization",
          type = "error"
        )
      } else {
        bslib::accordion_panel_set(id = "accordion", value = "Review Your Request")
      }
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
    
    # Change variable selection based on form type
    observeEvent(input$form_select, {
      if (input$form_select == "990") {
        shiny::updateCheckboxGroupInput(
          session = session,
          inputId = "data_select",
          choices = var_choices_990,
          selected = var_choices_990
        )
      } else {
        shiny::updateCheckboxGroupInput(
          session = session,
          inputId = "data_select",
          choices = var_choices_990ez,
          selected = var_choices_990ez
        )
      }
    })
    
    # Button to select all variables
    observeEvent(input$all_data, {
      if (input$all_data & input$form_select == "990") {
        shiny::updateCheckboxGroupInput(
          session = session,
          inputId = "data_select",
          selected = var_choices_990
        )
      } else if (input$all_data & input$form_select == "990EZ") {
        shiny::updateCheckboxGroupInput(
          session = session,
          inputId = "data_select",
          selected = var_choices_990ez
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
    
    # Create the query
    
    
    
    shinyWidgets::useSweetAlert()
    observeEvent(input$start_data_download, {
      request <- query_builder_download(input)
      sendSweetAlert(
        session = session,
        title = "Success",
        text = "Your data request has been submitted successfully. A link to a .csv file containing your requested data and an accompanying data dictionary will be sent to your email within the next hour.",
        type = "success"
      )
      response <- httr::POST(
        url = "https://qf8i5d1vg2.execute-api.us-east-1.amazonaws.com/stg/data/",
        body = request,
        encode = "json",
        httr::add_headers(
          "Content-Type" = "application/json"
        )
      )
    })
 })
}