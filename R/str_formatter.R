choice_formatter <- function(ls, width){
  str_formatter <- function(str, width){
    str <- stringr::str_wrap(str, width = width)
    str <- stringr::str_replace_all(str, "\\n", "<br>")
  }
  choices <- purrr::map_chr(names(ls), str_formatter, width = width)
  return(choices)
}