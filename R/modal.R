# User-facing modal for unexpected server errors. The detail string is
# the raw R error message — useful for support, ugly for end users — so
# it's tucked into a collapsed details element.
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

