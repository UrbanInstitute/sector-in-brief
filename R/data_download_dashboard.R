# Custom Panel Datasets module. This is the dashboard's "secondary"
# tab — instead of visualizing aggregated data, it lets users
# request a custom-cut row-level extract of 990 filings, delivered as
# a download link (and emailed as a durable receipt).
#
# Two halves:
#   - dataRequestUI()    — the multi-step form (form type, org/subsector,
#                           geography, dates, variables/format, contact,
#                           review)
#   - dataRequestServer()— validates the form, builds the request
#                           (query_builder_download.R), calls the
#                           modernized API (download_api_call.R) for a
#                           size estimate and then the export, and shows
#                           the download links (ADR 0008 / 0026)
#
# Delivery is pattern B (ADR 0026 §1): the API materializes the result to
# S3 and returns presigned + durable links; the bytes never flow through
# Shiny. Geography filters by collision-proof code (FIPS / CBSA code).
# The asset-size filter is intentionally gone — the API has no range
# filter for it (deferred), and dropping it removes the legacy
# `asset_select` wiring bug.
#
# Mounted as the last nav_panel by app.R.

# Last complete tax year offered by the download form. The API exposes no
# list-years endpoint, so this tracks the producer's CORE coverage
# (Finances/PF 1989-2023; 2024 is still partial — see CLAUDE.md "Data
# semantics"). Bump when the API's complete-year coverage advances.
DOWNLOAD_MAX_TAX_YEAR <- 2023L

# Latest "active" year offered in BMF (org-registry) mode. The BMF registry
# is kept current — unlike CORE's ~2-year filing lag — so its active_years
# range extends past DOWNLOAD_MAX_TAX_YEAR to the registry's current vintage.
# Bump as the registry advances.
BMF_MAX_ACTIVE_YEAR <- 2026L

# Earliest tax year per form code. 990-EZ data starts in 2012; everything
# else (incl. the 990+990-EZ union and 990-PF) goes back to 1989.
download_form_min_year <- function(form) {
  if (identical(form, "990ez")) 2012L else 1989L
}

#' Build the Custom Panel Datasets request UI.
#'
#' @param id Module id.
#' @param geo_df Nested geographies lookup (state → county/CBSA).
#' @return A `bslib::card` containing the multi-step form.
dataRequestUI <- function(id, geo_df) {
  ns <- shiny::NS(id)
  choices <- choice_builder("download")
  subsector <- choices$subsector
  bslib::card(
    bslib::card_title("Ready To Get Started?", class = "bg-light-gray"),
    urban_button(ns, "start_form", "REQUEST DATA"),
    # Query mode (ADR 0029): filing-level 990 data (CORE) vs the org-level
    # BMF registry incl. non-filers (no financials). Drives which steps and
    # columns show below; the server reshapes the form on change.
    htmltools::div(
      class = "btn-radio-urbn__lg download-source-toggle",
      shiny::radioButtons(
        inputId = ns("source_select"),
        label = download_source_label,
        choiceNames = list(download_source_corename, download_source_bmfname),
        choiceValues = c("core", "bmf"),
        selected = "core"
      )
    ),
    bslib::accordion(
      id = ns("accordion"),
      open = FALSE,
      bslib::accordion_panel(
        title = accordion_title("Option 1: Form Type"),
        value = "Option 1: Form Type",
        htmltools::br(),
        # Form type applies only to filing-level (CORE) data. The BMF
        # registry has no filing-form concept, so hide the picker and
        # explain why when that mode is selected.
        shiny::conditionalPanel(
          condition = "input.source_select != 'bmf'",
          ns = ns,
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
              choices = list(
                "Form 990"                 = "990",
                "Form 990-EZ"              = "990ez",
                "Form 990 + 990-EZ (combined)" = "990combined",
                "Form 990-PF"              = "990pf"
              ),
              selected = "990",
              inline = TRUE
            )
          )
        ),
        shiny::conditionalPanel(
          condition = "input.source_select == 'bmf'",
          ns = ns,
          htmltools::p(
            "Form type doesn't apply to the BMF registry — it lists every",
            "registered nonprofit regardless of which 990 (if any) they filed.",
            "Continue to the next section."
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_type", "NEXT")
      ),
      bslib::accordion_panel(
        title = accordion_title("Option 2: Organization and Subsector"),
        value = "Option 2: Organization and Subsector",
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
              choices = unique(geo_df[["Metro.Micro.Area"]])
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
        # CORE filters by tax (filing) year; BMF by registry-lifespan
        # overlap ("active during"). Different question, different copy.
        shiny::conditionalPanel(
          condition = "input.source_select != 'bmf'", ns = ns,
          download_date_para
        ),
        shiny::conditionalPanel(
          condition = "input.source_select == 'bmf'", ns = ns,
          download_active_para
        ),
        htmltools::br(),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("start_year"),
              label = htmltools::tags$b("From Tax Year *"),
              choices = c(1989:DOWNLOAD_MAX_TAX_YEAR),
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
              choices = c(1989:DOWNLOAD_MAX_TAX_YEAR),
              selected = DOWNLOAD_MAX_TAX_YEAR,
              multiple = FALSE,
              options = list(`actions-box` = TRUE)
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "next_data", "NEXT")
      ),
      bslib::accordion_panel(
        title = accordion_title("Option 5: Variables and Format"),
        value = "Option 5: Variables and Format",
        download_fields_para,
        htmltools::br(),
        htmltools::div(
          class = "switch-urbn",
          bslib::input_switch(ns("all_data"), "Select all variables", FALSE)
        ),
        bslib::layout_column_wrap(
          htmltools::div(
            class = "picker-urbn",
            shinyWidgets::pickerInput(
              inputId = ns("data_select"),
              label = htmltools::tags$b("Variables"),
              choices = download_column_choices(),
              selected = download_column_defaults(),
              multiple = TRUE,
              options = list(`actions-box` = TRUE,
                             `live-search` = TRUE,
                             `selected-text-format` = "count > 3")
            )
          ),
          htmltools::div(
            class = "btn-radio-urbn",
            shiny::radioButtons(
              inputId = ns("format_select"),
              label = htmltools::tags$b("File Format"),
              choices = list("CSV" = "csv", "Parquet" = "parquet"),
              selected = "csv",
              inline = TRUE
            )
          )
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
          ),
          htmltools::tagList(
            htmltools::h4("Format", class = "center-justify"),
            htmltools::div(
              shiny::textOutput(ns("selected_format")),
              class = "center-justify"
            )
          )
        ),
        htmltools::br(),
        urban_button(ns, "start_data_download", "SUBMIT REQUEST"),
        htmltools::br(),
        htmltools::br(),
        shiny::uiOutput(ns("download_result"))
      )
    )
  )
}

# Server function for the module
#' Server half of the Custom Panel Datasets module.
#'
#' Cascades state → county/CBSA choices, validates the form, builds the
#' request via `query_builder_download()`, calls the modernized API
#' (`download_api_call()`) for a size estimate and then the export, and
#' renders the download links (`download_link()`).
#'
#' @param id Module id (must match the UI half).
#' @param geo_df Nested geographies lookup.
dataRequestServer <- function(id, geo_df) {
  moduleServer(id, function(input, output, session) {
    cfg <- download_api_config()
    # Warn before committing to a large export (ADR 0026 §6). The size
    # distribution is bimodal — most queries are trivial, a long tail is
    # huge — so we warn only on the tail.
    WARN_BYTES <- 50 * 1024^2
    WARN_ROWS <- 250000L

    dl_result <- shiny::reactiveVal(NULL)
    req_full <- shiny::reactiveVal(NULL)

    # Update the open panel
    observeEvent(input$start_form, {
      bslib::accordion_panel_set(id = "accordion", value = "Option 1: Form Type")
    })
    observeEvent(input$next_type, {
      bslib::accordion_panel_set(id = "accordion", value = "Option 2: Organization and Subsector")
    })
    observeEvent(input$next_geo, {
      if (length(input$org_select) == 0){
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please select at least one organization type",
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
      bslib::accordion_panel_set(id = "accordion", value = "Option 5: Variables and Format")
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
          choices = unique(geo_df[["Metro.Micro.Area"]][geo_df[["Census.State"]] %in% input$geo_select])
        )
      }
    })

    current_source <- function() input$source_select %||% "core"

    # The year field is a tax-filing-year range in CORE mode and an "active
    # during" registry-lifespan range in BMF mode (ADR 0029). BMF has no
    # per-form floor and runs to the current registry vintage
    # (BMF_MAX_ACTIVE_YEAR, past CORE's ~2-year filing lag); CORE's floor is
    # form-driven (990-EZ starts 2012) and tops out at DOWNLOAD_MAX_TAX_YEAR.
    # BMF defaults to the single most-recent year (a current snapshot — the
    # "how many are active now" question); CORE defaults to its full span.
    refresh_year_range <- function() {
      bmf <- identical(current_source(), "bmf")
      years <- if (bmf) {
        1989:BMF_MAX_ACTIVE_YEAR
      } else {
        download_form_min_year(input$form_select):DOWNLOAD_MAX_TAX_YEAR
      }
      shinyWidgets::updatePickerInput(
        session = session, inputId = "start_year",
        label = if (bmf) "Active From Year *" else "From Tax Year *",
        choices = years, selected = if (bmf) max(years) else min(years)
      )
      shinyWidgets::updatePickerInput(
        session = session, inputId = "end_year",
        label = if (bmf) "Active Through Year *" else "Through Tax Year *",
        choices = years, selected = max(years)
      )
    }

    # Organization Type: only private foundations file a 990-PF, so the CORE
    # 990-PF picker is constrained to that single value. Every other CORE
    # form and all of BMF (which has no form concept) offers the full set.
    refresh_org_choices <- function() {
      if (identical(current_source(), "core") &&
          identical(input$form_select, "990pf")) {
        shinyWidgets::updatePickerInput(
          session = session, inputId = "org_select",
          choices = ctype_id["501(c)(3) - Private Foundations"],
          selected = "501(c)(3) Private Foundations"
        )
      } else {
        shinyWidgets::updatePickerInput(
          session = session, inputId = "org_select",
          choices = ctype_id
        )
      }
    }

    # Variable catalog is mode- and form-aware: BMF drops the Financials
    # block and tax_year (no filings) and adds the registry-lifespan cols;
    # CORE's Financials block changes with the form (990-PF Part I differs).
    refresh_variables <- function() {
      catalog <- download_column_catalog(input$form_select %||% "990",
                                         current_source())
      shinyWidgets::updatePickerInput(
        session = session, inputId = "data_select",
        choices = download_column_choices(catalog),
        selected = if (isTRUE(input$all_data)) {
          catalog$api_name
        } else {
          download_column_defaults(catalog)
        }
      )
    }

    # Switching query mode or form rebuilds the year range, org-type
    # choices, and variable catalog together.
    observeEvent(input$source_select, {
      refresh_year_range(); refresh_org_choices(); refresh_variables()
    })
    observeEvent(input$form_select, {
      refresh_year_range(); refresh_org_choices(); refresh_variables()
    })

    # "Select all variables" toggles between the full catalog and the
    # curated default set — for the current mode + form.
    observeEvent(input$all_data, {
      refresh_variables()
    })

    output$selected_form <- renderText({
      if (identical(current_source(), "bmf")) {
        "BMF registry (all registered nonprofits)"
      } else {
        input$form_select
      }
    })
    output$selected_org <- renderText({
      paste(input$org_select, collapse = ", ")
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
      paste(length(input$data_select), "variables selected")
    })
    output$selected_format <- renderText({
      toupper(input$format_select)
    })

    # Render the download links once an export completes (ADR 0026 §1/§3:
    # link, never bytes; plus the "we've also emailed this" receipt).
    output$download_result <- renderUI({
      res <- dl_result()
      if (is.null(res)) {
        return(NULL)
      }
      durable <- res$download_url %||% download_link(res$download_path, config = cfg)
      dict_url <- res$data_dictionary$url %||%
        download_link(res$download_path, kind = "dictionary", config = cfg)
      emailed <- !is.null(res$email) && identical(res$email$status, "sent")
      # Left-aligned card with its own class; `bg-box__white` is a
      # centring flexbox and squashes a multi-element block, so it is not
      # used here.
      htmltools::div(
        class = "download-ready",
        htmltools::h4("Your data is ready", class = "download-ready__title"),
        htmltools::p(
          class = "download-ready__meta",
          sprintf(
            "%s rows · %s · %s",
            format(res$row_count %||% 0, big.mark = ","),
            human_bytes(res$result$bytes),
            toupper(res$result$format %||% input$format_select)
          )
        ),
        htmltools::div(
          class = "download-ready__links",
          htmltools::a(
            "Download your data",
            href = durable, target = "_blank",
            class = "download-ready__btn"
          ),
          if (!is.null(dict_url)) {
            htmltools::a(
              "Download the data dictionary",
              href = dict_url, target = "_blank",
              class = "download-ready__link"
            )
          }
        ),
        if (emailed) {
          htmltools::p(
            class = "download-ready__emailed",
            htmltools::tags$em(
              sprintf("We've also emailed this link to %s.", res$email$to)
            )
          )
        }
      )
    })

    # Submit: size estimate -> warn-on-large -> export. The API runs the
    # query and materializes to S3; we only ever move the small JSON and
    # show the links it returns (pattern B).
    shinyWidgets::useSweetAlert()

    run_export <- function(payload) {
      shiny::showModal(shiny::modalDialog(
        htmltools::p("Preparing your export… this can take a moment for large requests."),
        title = "Working", footer = NULL, easyClose = FALSE
      ))
      res <- download_api_call(payload, cfg)
      shiny::removeModal()
      if (!isTRUE(res$ok)) {
        sendSweetAlert(
          session = session,
          title = "Something went wrong",
          text = res$error %||% "The export could not be completed.",
          type = "error"
        )
        return(invisible(NULL))
      }
      dl_result(res)
    }

    observeEvent(input$start_data_download, {
      if (length(input$data_select) == 0) {
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "Please select at least one variable",
          type = "error"
        )
        return()
      }
      # Guard the year range: the pickers don't constrain each other, and an
      # inverted range would otherwise build a descending tax_years list.
      if (as.integer(input$start_year) > as.integer(input$end_year)) {
        sendSweetAlert(
          session = session,
          title = "Error",
          text = "\"From Tax Year\" must be on or before \"Through Tax Year\".",
          type = "error"
        )
        return()
      }
      dl_result(NULL)
      full_payload <- query_builder_download(input, geo_df, estimate = FALSE)
      req_full(full_payload)

      shiny::showModal(shiny::modalDialog(
        htmltools::p("Estimating the size of your export…"),
        title = "Working", footer = NULL, easyClose = FALSE
      ))
      est <- download_api_call(
        query_builder_download(input, geo_df, estimate = TRUE), cfg
      )
      shiny::removeModal()

      if (!isTRUE(est$ok)) {
        sendSweetAlert(
          session = session,
          title = "Something went wrong",
          text = est$error %||% "Could not estimate the export size.",
          type = "error"
        )
        return()
      }

      rows <- est$row_count %||% 0
      bytes <- est$estimated_bytes %||% 0
      if (bytes > WARN_BYTES || rows > WARN_ROWS) {
        shinyWidgets::confirmSweetAlert(
          session = session,
          inputId = "confirm_large",
          title = "Large export",
          text = sprintf(
            "This export is about %s rows (~%s). Large downloads can take longer to prepare. Continue?",
            format(rows, big.mark = ","), human_bytes(bytes)
          ),
          type = "warning",
          btn_labels = c("Cancel", "Download anyway")
        )
      } else {
        run_export(full_payload)
      }
    })

    observeEvent(input$confirm_large, {
      if (isTRUE(input$confirm_large)) {
        run_export(req_full())
      }
    })
 })
}
