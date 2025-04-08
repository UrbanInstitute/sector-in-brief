dataRequestUI <- function(id, geo_df) {
  ns <- NS(id)
  choices <- choice_builder("download")
  size <- names(choices$size)
  subsector <- choices$subsector
  bslib::card(
    bslib::card_title("Ready To Get Started?", class = "bg-light-gray"),
    urban_button(ns, "start_form", "REQUEST DATA"),
    bslib::accordion(
      id = ns("accordion"),
      open = FALSE,
      bslib::accordion_panel(
        title = accordion_title("Option 1: Form Type"),
        value = "Option 1: Form Type",
        htmltools::br(),
        htmltools::div(
          class = "bg-box__white",
          download_table
        ),
        htmltools::br(),
        htmltools::div(
          class = "btn-radio-urbn__lg",
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
        title = accordion_title("Option 2: Organization, Subsector, and Size"),
        value = "Option 2: Organization, Subsector, and Size",
        htmltools::br(),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("org_select"),
              label = htmltools::tagList(
                htmltools::h5("Organization Type*"),
                htmltools::p(
                  html_orgtype
                )
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
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("subsector_select"),
              label = htmltools::tagList(
                htmltools::tags$b("Subsector*"),
                htmltools::tagList(
                  htmltools::p("12 general categories of the",
                               htmltools::a(
                                 "National Taxonomy of Exempt Entities (NTEE)", 
                                 href = ntee_link
                               ),
                               "code system.")
                )
              ),
              choices = subsector,
              multiple = TRUE,
              options = list(`actions-box` = TRUE)
            )
          ),
          htmltools::div(
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("size_select"),
              label = htmltools::tagList(
                htmltools::tags$b("Asset Size *"),
                htmltools::p(
                  "Total assets from the IRS Business Master File grouped in five categories."
                )
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
        title = accordion_title("Option 3: Geographic Scope"),
        value = "Option 3: Geographic Scope",
        download_geo_para,
        htmltools::br(),
        bslib::layout_column_wrap(
          urban_virtualselect(ns, 
                              "region_select", 
                              htmltools::tags$b("Optional - Select Region(s)"), 
                              c("Northeast", "Midwest", "South", "West")),
          urban_virtualselect(ns, 
                              "geo_select",
                              htmltools::tags$b("Select State(s)*"),
                              state_choices),
          shiny::conditionalPanel(
            condition = "input.geo_select.length > 0",
            urban_virtualselect(
              ns,
              "county_select",
              label = htmltools::tags$b("Optional - Select County(s)"),
              choices = unique(geo_df[["Census.County"]])
            ),
            ns = ns
          ),
          shiny::conditionalPanel(
            condition = "input.geo_select.length > 0",
            urban_virtualselect(
              ns,
              "cbsa_select",
              label = htmltools::tags$b("Optional - Select Metro Areas(s)"),
              choices = unique(geo_df[["Census.CBSA"]])
            ),
            ns = ns
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_time", "NEXT")
      ),
      bslib::accordion_panel(
        title = accordion_title("Option 4: Date Range"),
        value = "Option 4: Date Range",
        download_date_para,
        htmltools::br(),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("start_year"),
              label = htmltools::tags$b("From Tax Year *"),
              choices = c(1989:2022),
              selected = 2012,
              multiple = FALSE,
              options = list(`actions-box` = TRUE)
            )
          ),
          htmltools::div(
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("end_year"),
              label = htmltools::tags$b("Through Tax Year *"),
              choices = c(1989:2022),
              selected = 2022,
              multiple = FALSE,
              options = list(`actions-box` = TRUE)
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_data", "NEXT")
      ),
      bslib::accordion_panel(
        title = accordion_title("Option 5: Variables"),
        value = "Option 5: Variables",
        download_fields_para,
        htmltools::br(),
        htmltools::br(),
        htmltools::div(
          class = "switch-urbn",
          bslib::input_switch(ns("all_data"), "All Data", TRUE)
        ),
        bslib::layout_column_wrap(
          htmltools::div(),
          htmltools::div(
            class = "urbn-checkbox",
            shiny::checkboxGroupInput(
              inputId = ns("data_select"),
              label = NULL,
              choices = var_choices_990,
              inline = FALSE,
              width = "100%"
            )
          ),
          htmltools::div()
        ),
        htmltools::br(),
        urban_button(ns, "next_user", "NEXT")
      ),
      bslib::accordion_panel(
        title = accordion_title("Contact Information"),
        value = "Contact Information",
        htmltools::p(
          "A link to the requested data will be sent to your email address."
        ),
        htmltools::br(),
          bslib::layout_column_wrap(
            width = 0.5,
            shiny::textInput(
              inputId = ns("first_name"),
              label = htmltools::tags$h5("First Name"),
              placeholder = "First Name",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("last_name"),
              label = htmltools::tags$h5("Last Name"),
              placeholder = "",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("email"),
              label = htmltools::tags$h5("Email *"),
              placeholder = "",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("organization"),
              label = htmltools::tags$h5("Organization *"),
              placeholder = "",
              value = ""
            ),
            shiny::textInput(
              inputId = ns("purpose"),
              label = htmltools::tags$h5("Title"),
              placeholder = "",
              value = ""
            )
          ),
        htmltools::br(),
        urban_button(ns, "next_review", "NEXT")
      ),
      bslib::accordion_panel(
        title = accordion_title("Review Your Request"),
        value = "Review Your Request",
        htmltools::p(
          "If you need to make any changes before submitting your request, 
          navigate back to the appropriate section using the drop-down menus above."
        ),
        htmltools::br(),
        bslib::layout_column_wrap(
          width = 1/3,
          htmltools::tagList(
            htmltools::h4("Form", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_form")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("Organization Type", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_org")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("Asset Size", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_size")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("Subsector(s)", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_subsector")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("State(s)", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_state")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("County(s)", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_county")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("Metro Area(s)", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_cbsa")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("Timeframe", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_timeframe")),
              class = "center-justify"
            )
          ),
          htmltools::tagList(
            htmltools::h4("Variables", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_variables")),
              class = "center-justify"
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
        shinyWidgets::updatePickerInput(
          session = session,
          inputId = "start_year",
          choices = c(1989:2022),
          selected = 1989
        )
        shinyWidgets::updatePickerInput(
          session = session,
          inputId = "end_year",
          choices = c(1989:2022),
          selected = 2022
        )
      } else {
        shiny::updateCheckboxGroupInput(
          session = session,
          inputId = "data_select",
          choices = var_choices_990ez,
          selected = var_choices_990ez
        )
        shinyWidgets::updatePickerInput(
          session = session,
          inputId = "start_year",
          choices = c(2012:2022),
          selected = 2012
        )
        shinyWidgets::updatePickerInput(
          session = session,
          inputId = "end_year",
          choices = c(2012:2022),
          selected = 2022
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
      size_translate_list <- list(
        "1" = "Under $100,000",
        "2" = "$100,000 - $499,999",
        "3" = "$500,000 - $999,999",
        "4" = "$1,000,000 - $4,999,999",
        "5" = "$5,000,000 - $9,999,999",
        "6" = "Above $10,000,000"
      )
      size_translate <- size_translate_list[input$size_select]
      paste(unlist(size_translate), collapse = ", ")
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
        var_length <- length(input$data_select)
        paste(var_length, "variables selected")
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
