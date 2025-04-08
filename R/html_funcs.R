# Wrapper functions for reusable html components

#' @title Wrapper function for html used in title box
#' @param title character scalar. Title text
#' @param subtitle character scalar. Subtitle text
#' @return html string for a title box
title_box <- function(title, subtitle) {
  htmltools::div(class = "bg-box__dot",
                 htmltools::div(
                   class = "box-title",
                   htmltools::h2(title),
                   htmltools::p(
                     subtitle
                   )
                 ))
}

#' @title Create a white flexbox
#' @description
#' A flexible layout module with a white background
#' @param ... list of html elements to include in flexbox
white_flexbox <- function(...){
  htmltools::div(
    class = "bg-box__white",
    htmltools::div(
      class = "flex-box__column",
      ...
    )
  )
}