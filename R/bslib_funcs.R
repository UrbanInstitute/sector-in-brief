# Wrapper functions for reusable bslib components, themed according to Urban Institute guidelines

#' @title Create an urban themed accordion panel
#' @param title character scalar. panel title
#' @param value character scalar. Panel value for internal reference
#' @param ... list of bslib components/content to include in the panel
urbn_accordion_panel <- function(title, value=title, ...) {
  bslib::accordion_panel(
    title = accordion_title(title),
    value = value,
    ...
  )
}