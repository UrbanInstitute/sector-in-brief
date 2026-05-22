# User-facing modal for unexpected server errors caught by the
# tryCatch in data_pipeline(). Validation errors are NOT shown here —
# those go inline under the offending filter card via
# render_validation_messages.R. This modal is only for thrown
# exceptions from arrow/dplyr/ggplot etc.

#' Build the "Something went wrong" modal for runtime errors.
#'
#' Raw error message is useful for support but ugly for end users, so
#' it's tucked into a collapsed `<details>` element.
#'
#' @param detail Raw error message string from `conditionMessage()`.
#' @return A `shiny::modalDialog`.
error_modal <- function(detail) {
  shiny::modalDialog(
    title = "Something went wrong",
    htmltools::p(
      "We hit an unexpected error rendering your selection. ",
      "Try adjusting the filters and clicking ", htmltools::strong("UPDATE DATA"),
      " again. If the problem persists, please report it via the feedback link in the About page."
    ),
    htmltools::tags$details(
      htmltools::tags$summary("Technical detail"),
      htmltools::tags$pre(detail)
    ),
    easyClose = TRUE,
    footer = shiny::modalButton("Dismiss")
  )
}

