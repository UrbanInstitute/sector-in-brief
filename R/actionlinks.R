actionlink_tbl <- tibble::tribble(
  ~inputId, ~label, ~style,
  "org_reset", "Reset", "float: right;",
  "geo_reset", "Reset", "float: right;",
  "subsector_reset", "Reset", "float: right;",
  "size_reset", "Reset", "float: right;",
  "date_reset", "Reset", "float: right;"
)

actionlinks <- purrr::pmap(actionlink_tbl, function(inputId, label, style) {
  shiny::actionLink(inputId, label, style = style)
})

names(actionlinks) <- actionlink_tbl$inputId
