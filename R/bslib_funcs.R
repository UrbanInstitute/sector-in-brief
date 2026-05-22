# Reusable bslib wrappers for Urban-themed UI primitives. Currently
# two: an accordion panel that styles the title via accordion_title(),
# and a card header that pairs a filter title with a hover-info
# tooltip (so verbose explanations don't stretch the card header).

#' Build an Urban-themed accordion panel.
#'
#' @param title Title shown on the panel header.
#' @param ... Forwarded to `bslib::accordion_panel` as body content.
#' @return A `bslib::accordion_panel`.
urbn_accordion_panel <- function(title, ...) {
  bslib::accordion_panel(
    title = accordion_title(title),
    value = title,
    ...
  )
}

#' Build a filter card header (title + info-icon tooltip).
#'
#' Verbose explanations live in the tooltip so they don't stretch the
#' card header. Used by every filter card in `data_ui()`.
#'
#' @param title Card title text.
#' @param tooltip_content Content shown when the user hovers the
#'   info icon — can be plain text, htmltools tags, or a tagList.
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