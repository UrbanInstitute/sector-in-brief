org_types <- org_type_choices
geo_data <- list(
  "Northeast" = c("New York", "Massachusetts"),
  "West" = c("California", "Washington")
)
subsectors <- list(
  "Arts, Culture, and Humanities" = "ART", 
  "Education (minus Universities)" = "EDU",
  "Health (minus Hospitals)" = "HEL",
  "Human Services" = "HMS",
  "International, Foreign Affairs" = "IFA",
  "Public, Societal Benefit" = "PSB",
  "Religion Related" = "REL",
  "Mutual/Membership Benefit" = "MMB",
  "Universities" = "UNI",
  "Hospitals" = "HOS"
)

# UI function for the module
dataRequestUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    
    h1("Data Request Form"),
    
    fluidRow(
      column(8,
             card(
               card_header("User Details"),
               card_body(
                 textInput(ns("name"), "Name", placeholder = "Firstname Lastname"),
                 textInput(ns("email"), "Email", placeholder = "firstname.lastname@gmail.com"),
                 textInput(ns("organization"), "Organization", placeholder = "Organization Name"),
                 textInput(ns("role"), "Role", placeholder = "Role in Organization")
               )
             ),
             card(
               card_header("Data Selection"),
               card_body(
                 # Step 1: Organization Type
                 selectizeInput(ns("org_type"), 
                                "1. Select Organization Type", 
                                 choices = c("Select" = "", org_types),
                                 multiple = TRUE),
                 
                 # Step 2: Geography
                 conditionalPanel(
                   condition = paste0("input['", ns("org_type"), "'] != ''"),
                   geo_filter_ui("dd_geo", state_choices)
                 ),
                 
                 # Step 3: Subsector
                 conditionalPanel(
                   condition = paste0("input['", ns("dd_geo"), "'] != ''"),
                   selectInput(ns("subsector"), "3. Select Subsector", choices = c("Select" = "", subsectors))
                 ),
                 
                 # Step 4: Asset Size
                 conditionalPanel(
                   condition = paste0("input['", ns("subsector"), "'] != ''"),
                   selectInput(ns("asset_size"), "4. Select Asset Size", choices = c("Select" = "", asset_sizes))
                 ),
                 
                 # Step 5: Date Range
                 conditionalPanel(
                   condition = paste0("input['", ns("asset_size"), "'] != ''"),
                   dateRangeInput(ns("date_range"), "5. Select Date Range")
                 ),
                 
                 # Step 6: Variables
                 conditionalPanel(
                   condition = paste0("input['", ns("asset_size"), "'] != ''"),
                   checkboxGroupInput(ns("variables"), "6. Select Variables",
                                      choices = c("Summary", "Revenues",
                                                  "Expenses", "Balance Sheet"),
                                      inline = TRUE)
                 ),
                 conditionalPanel(
                   condition = paste0("input['", ns("variables"), "'] != ''"),
                   checkboxGroupInput(ns("scope"), "7. Form Scope",
                                      choices = c("PC", "PZ"),
                                      inline = TRUE)
                 )
               )
             )
      ),
      column(4,
             card(
               card_header("Request Summary"),
               card_body(
                 textOutput(ns("user_name")),
                 textOutput(ns("user_email")),
                 textOutput(ns("user_organization")),
                 hr(),
                 textOutput(ns("selected_org_type")),
                 textOutput(ns("selected_geography")),
                 textOutput(ns("selected_subsector")),
                 textOutput(ns("selected_asset_size")),
                 textOutput(ns("selected_date_range")),
                 textOutput(ns("selected_variables")),
                 hr(),
                 textOutput(ns("file_size")),
                 actionButton(ns("submit"), "Submit Data Request", class = "btn-primary btn-block mt-4")
               )
             )
      )
    )
  )
}

# Server function for the module
dataRequestServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Update state choices based on selected region
    observeEvent(input$region, {
      if (input$region != "") {
        updateSelectInput(session, "state", 
                          choices = c("Select" = "", geo_data[[input$region]]))
      } else {
        updateSelectInput(session, "state", choices = c("Select" = ""))
      }
    })
    
    # Display request summary
    output$user_name <- renderText({ paste("Name:", input$name) })
    output$user_email <- renderText({ paste("Email:", input$email) })
    output$user_organization <- renderText({ paste("Organization:", input$organization) })
    output$user_role <- renderText({ paste("Role:", input$role) })
    output$selected_org_type <- renderText({ paste("Organization Type:", input$org_type) })
    output$selected_subsector <- renderText({ paste("Subsector:", input$subsector) })
    output$selected_asset_size <- renderText({ paste("Asset Size:", input$asset_size) })
    output$selected_date_range <- renderText({ 
      paste("Date Range:", paste(input$date_range, collapse = " to "))
    })
    output$selected_variables <- renderText({ 
      paste("Variables:", paste(input$variables, collapse = ", "))
    })
    
    # Placeholder for file size estimation
    output$file_size <- renderText({
      "Estimated file size: N/A"
    })
    
    # Handle submit button click
    observeEvent(input$submit, {
      # Here you would typically process the data request
      # For this example, we'll just show a notification
      showNotification("Data request submitted!", type = "message")
    })
  })
}