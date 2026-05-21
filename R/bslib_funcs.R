# Wrapper functions for reusable bslib components, themed according to Urban Institute guidelines

#' @title Create an urban themed accordion panel
#' @param title character scalar. panel title
#' @param value character scalar. Panel value for internal reference
#' @param ... list of bslib components/content to include in the panel
#' @return bslib accordion panel
urbn_accordion_panel <- function(title, ...) {
  bslib::accordion_panel(
    title = accordion_title(title),
    value = title,
    ...
  )
}

#' Card header for a filter card: title with a hover-info tooltip,
#' so verbose descriptions don't stretch the header.
filter_card_header <- function(title, tooltip_content) {
  bslib::card_header(
    htmltools::div(
      class = "filter-header",
      htmltools::h6(title, style = "display:inline; margin-right:6px;"),
      bslib::tooltip(
        bsicons::bs_icon("info-circle"),
        tooltip_content,
        placement = "right"
      )
    )
  )
}