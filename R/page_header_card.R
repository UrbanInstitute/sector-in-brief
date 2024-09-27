page_header_card <- function(header, subheader) {
  card <- div(
    class = "var-title-card",
    h2(header, class = "var-header"),
    h3(subheader, class = "var-sub-header")
  )
  return(card)
}