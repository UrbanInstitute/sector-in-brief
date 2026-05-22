# Standard panel header: <h2> title plus a paragraph of descriptive
# copy. Used at the top of each visualization panel (via
# visualpanel_content) and on the Custom Panel Datasets download page.

#' Build a panel header (title + subtitle).
#'
#' @param header Title text.
#' @param subheader Descriptive content (can be plain text, htmltools
#'   tags, or a tagList).
#' @return A `htmltools::tagList`.
page_header_card <- function(header, subheader) {
  card <- htmltools::tagList(
    htmltools::h2(header),
    subheader
  )
  return(card)
}