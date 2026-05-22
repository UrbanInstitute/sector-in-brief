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

#' Build a filter section header (title + info-icon tooltip).
#'
#' Verbose explanations live in the tooltip so they don't stretch the
#' header. Used by every filter section in `data_ui()` inside the
#' panel's sidebar.
#'
#' Originally wrapped each header in `bslib::card_header` for the
#' pre-sidebar layout where each filter was its own card. Now uses a
#' plain styled div so the same component renders cleanly in the
#' sidebar context without nested card chrome.
#'
#' @param title Section title text.
#' @param tooltip_content Content shown when the user hovers the
#'   info icon — can be plain text, htmltools tags, or a tagList.
filter_card_header <- function(title, tooltip_content) {
  htmltools::div(
    class = "filter-header",
    htmltools::h6(title, style = "display:inline; margin-right:6px;"),
    bslib::tooltip(
      bsicons::bs_icon("info-circle"),
      tooltip_content,
      placement = "right"
    )
  )
}