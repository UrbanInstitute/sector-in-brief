source("R/org_filters.R")

# Consolidate frontends

daf_frontend <- bslib::nav_panel(
  title = "Donor Advised Funds",
  div(
    br(),
    h2("Donor Advised Funds", class = "pageheader"),
    br(),
    h3("A donor advised fund (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time."),
    br()
  ),
  bslib::card(
    card_header("Step 1: Filters"),
    title = "",
    bslib::layout_columns(
      bslib::card(
        card_header("Organization Type"),
        org_filters$daf_org_filter,
        shiny::conditionalPanel(
          selectizeInput(
            "daf_other_orgs",
            width = "500px",
            label = "Other 501(c) Types",
            choices = org_type_choices,
          ),
          condition = "input.daf_org_level == 'Other Nonprofits'"
        )
      ),
      bslib::card(
        card_header("Geography"),
        radioButtons(
          "daf_geo_level",
          inline = FALSE,
          "Select Geographic Level",
          choices = list("Entire USA" = "all", 
                         "Region" = "census_region", 
                         "State" = "CENSUS_STATE_ABBR", 
                         "County" = "CENSUS_COUNTY_NAME", 
                         "Metro/Micro Area" = "CENSUS_CBSA_NAME")
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "daf_region_selector",
            label = "Select Region(s)",
            choices = c("Northeast", "South", "Midwest", "West"),
            multiple = TRUE
          ),
          condition = "input.daf_geo_level == 'census_region'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "daf_state_selector_multi",
            label = "Select State(s)",
            choices = state_choices,
            multiple = TRUE
          ),
          condition = "input.daf_geo_level == 'CENSUS_STATE_ABBR'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "daf_state_selector_single",
            label = "Select State",
            choices = state_choices,
            multiple = FALSE
          ),
          condition = "input.daf_geo_level == 'CENSUS_COUNTY_NAME' | input.daf_geo_level == 'CENSUS_CBSA_NAME'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "daf_county_selector",
            label = "Select Counties",
            choices = NULL,
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.daf_geo_level == 'CENSUS_COUNTY_NAME'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "daf_cbsa_selector",
            label = "Select Metro/Micro Area(s)",
            choices = NULL,
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.daf_geo_level == 'CENSUS_CBSA_NAME'"
        )
      ),
      bslib::card(
        bslib::card_header("Subsector"),
        shiny::radioButtons(
          inputId = "daf_subsector_level",
          label = NULL,
          inline = TRUE,
          choices = list(
            "All Subsectors" = "all", 
            "Individual Subsectors" = "individual"
          )
        ),
        shiny::conditionalPanel(
          selectizeInput(
            inputId = "daf_subsector_select",
            label = NULL,
            choices = list(
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
            ),
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.daf_subsector_level == 'individual'"
        )
      ),
      bslib::card(
        card_header("Asset Size"),
        shiny::radioButtons(
          inputId = "daf_size_level",
          label = NULL,
          inline = TRUE,
          choices = list(
            "All Asset Sizes" = "all", 
            "Individual Asset Sizes" = "individual"
          )
        ),
        shiny::conditionalPanel(
          selectizeInput(
            inputId = "daf_size_select",
            label = NULL,
            multiple = TRUE,
            options = list(maxItems = 5),
            choices = list(
              "Under $100,000" = 1,
              "$100,000 - $499,999" = 2,
              "$500,000 - $999,999" = 3,
              "$1 Million - $4.99 Million" = 4,
              "$5 Million - $9.99 Million" = 5,
              "Above $10 Million" = 6
            )
          ),
          condition = "input.daf_size_level == 'individual'"
        )
      )
    ),
    bslib::input_task_button(
      id = "process_daf_data",
      style = "border-radius: 0; font-size: 18px; color: #ffffff; margin: auto; background-color: #1696d2; border-color: #1696d2;",
      label = "RETRIEVE DATA",
      label_busy = "UPDATING PLOTS",
      type = "primary"
    )
  ),
  bslib::navset_card_tab(
    title =   "View Results",
    height = "100%",
    bslib::nav_panel(
      "Overall",
      layout_column_wrap(
        width = 1,
        bslib::card(
          bslib::card_body(plotOutput("daf_plot_overall")),
          bslib::card_body(plotOutput("plot_overall_num_daf")),
          daf_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("daf_table_overall")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Subsector",
      layout_column_wrap(
        width = 1,
        bslib::card(
          bslib::card_body(plotOutput("daf_plot_subsector")),
          bslib::card_body(plotOutput("plot_subsector_num_daf")),
          daf_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("daf_table_subsector")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Geography",
      layout_column_wrap(
        width = 1,
        bslib::card(
          bslib::card_body(plotOutput("daf_plot_geo")),
          bslib::card_body(plotOutput("plot_geo_num_daf")),
          daf_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("daf_table_geo")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Asset Size",
      layout_column_wrap(
        width = 1,
        bslib::card(
          bslib::card_body(plotOutput("daf_plot_size")),
          bslib::card_body(plotOutput("plot_size_num_daf")),
          daf_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("daf_table_size")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    )
  )
)

num_nonprofit_frontend <-   bslib::nav_panel(
  title = "Number",
  div(
    br(),
    h2("Total number of nonprofits", class = "pageheader"),
    br(),
    h3("The number of organizations that are registered with the Internal Revenue Service (IRS)."),
    br()
  ),
  bslib::card(
    card_header("Step 1: Filters"),
    title = "",
    bslib::layout_columns(
      bslib::card(
        card_header("Organization Type"),
        org_filters$nn_org_filter,
        shiny::conditionalPanel(
          selectizeInput(
            "other_orgs",
            width = "500px",
            label = "Other 501(c) Types",
            choices = org_type_choices,
          ),
          condition = "input.org_level == 'Other Nonprofits'"
        )
      ),
      bslib::card(
        card_header("Geography"),
        radioButtons(
          "geo_level",
          inline = FALSE,
          "Select Geographic Level",
          choices = list("Entire USA" = "all", 
                         "Region" = "census_region", 
                         "State" = "CENSUS_STATE_ABBR", 
                         "County" = "CENSUS_COUNTY_NAME", 
                         "Metro/Micro Area" = "CENSUS_CBSA_NAME")
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "region_selector",
            label = "Select Region(s)",
            choices = c("Northeast", "South", "Midwest", "West"),
            multiple = TRUE
          ),
          condition = "input.geo_level == 'census_region'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "state_selector_multi",
            label = "Select State(s)",
            choices = state_choices,
            multiple = TRUE
          ),
          condition = "input.geo_level == 'CENSUS_STATE_ABBR'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "state_selector_single",
            label = "Select State",
            choices = state_choices,
            multiple = FALSE
          ),
          condition = "input.geo_level == 'CENSUS_COUNTY_NAME' | input.geo_level == 'CENSUS_CBSA_NAME'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "county_selector",
            label = "Select Counties",
            choices = NULL,
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.geo_level == 'CENSUS_COUNTY_NAME'"
        ),
        shiny::conditionalPanel(
          selectizeInput(
            "cbsa_selector",
            label = "Select Metro/Micro Area(s)",
            choices = NULL,
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.geo_level == 'CENSUS_CBSA_NAME'"
        )
      ),
      bslib::card(
        bslib::card_header("Subsector"),
        shiny::radioButtons(
          inputId = "subsector_level",
          label = NULL,
          inline = TRUE,
          choices = list(
            "All Subsectors" = "all", 
            "Individual Subsectors" = "individual"
          )
        ),
        shiny::conditionalPanel(
          selectizeInput(
            inputId = "subsector_select",
            label = NULL,
            choices = list(
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
            ),
            multiple = TRUE,
            options = list(maxItems = 5)
          ),
          condition = "input.subsector_level == 'individual'"
        )
      ),
      bslib::card(
        card_header("Asset Size"),
        shiny::radioButtons(
          inputId = "size_level",
          label = NULL,
          inline = TRUE,
          choices = list(
            "All Asset Sizes" = "all", 
            "Individual Asset Sizes" = "individual"
          )
        ),
        shiny::conditionalPanel(
          selectizeInput(
            inputId = "size_select",
            label = NULL,
            multiple = TRUE,
            options = list(maxItems = 5),
            choices = list(
              "Under $100,000" = 1,
              "$100,000 - $499,999" = 2,
              "$500,000 - $999,999" = 3,
              "$1 Million - $4.99 Million" = 4,
              "$5 Million - $9.99 Million" = 5,
              "Above $10 Million" = 6
            )
          ),
          condition = "input.size_level == 'individual'"
        )
      ),
      bslib::card(
        card_header("Date Range"),
        sliderInput(
          "date_range",
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
    ),
    bslib::input_task_button(
      id = "process_num_nonprofit_data",
      style = "border-radius: 0; font-size: 18px; color: #ffffff; margin: auto; background-color: #1696d2; border-color: #1696d2;",
      label = "RETRIEVE DATA",
      label_busy = "UPDATING PLOTS",
      type = "primary"
    )
  ),
  bslib::navset_card_tab(
    title =   "View Results",
    height = "100%",
    bslib::nav_panel(
      "Overall",
      layout_column_wrap(
        width = NULL,
        heigh = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(shinycssloaders::withSpinner(plotOutput("num_nonprofit_plot_overall",
                                                                   height = "500px"))),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("num_nonprofit_table_overall")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Subsector",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(plotOutput("num_nonprofit_plot_subsector")),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("num_nonprofit_table_subsector")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Geography",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(plotOutput("num_nonprofit_plot_geo")),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("num_nonprofit_table_geo")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    ),
    bslib::nav_panel(
      "By Asset Size",
      layout_column_wrap(
        width = NULL,
        height = 650,
        style = htmltools::css(grid_template_columns = "3fr 1fr"),
        bslib::card(
          bslib::card_body(plotOutput("num_nonprofit_plot_size")),
          plot_footer
        ),
        bslib::card(
          bslib::card_body(reactable::reactableOutput("num_nonprofit_table_size")),
          bslib::card_body(
            downloadButton("downloadData", "DOWNLOAD", class = "btn-download", icon = NULL)
          )
        )
      )
    )
  )
)