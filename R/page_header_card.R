page_header_card <- function(header, subheader) {
  card <- htmltools::div(
    class = "var-title-card",
    htmltools::h2(header, class = "var-header"),
    htmltools::h3(subheader, class = "var-sub-header")
  )
  return(card)
}