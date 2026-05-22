# Wrap long choice labels to a max width with `<br>` line breaks, so
# checkboxGroupInput / urbn_tree options don't blow out their card
# width.

#' Wrap the names of a named list to a max width.
#'
#' @param ls Named list whose names are the labels to wrap.
#' @param width Max characters per line before inserting `<br>`.
#' @return Character vector of wrapped names.
choice_formatter <- function(ls, width) {
  str_formatter <- function(str, width){
    str <- stringr::str_wrap(str, width = width)
    str <- stringr::str_replace_all(str, "\\n", "<br>")
  }
  choices <- purrr::map_chr(names(ls), str_formatter, width = width)
  return(choices)
}