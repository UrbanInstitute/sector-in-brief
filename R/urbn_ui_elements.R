#-------------------------------------------------------------------------------
# File: urbn_ui_elements.R
# Author: Thiyaghessan Poongundranar [tpoongundranar@urban.org]
# Date Created: 2024-06-01
# Date Last Edited: 2025-07-02
#
# Purpose: Create custom UI elements for the Nonprofit Sector In Brief dashboard
# themed with Urban Institute's branding.
#
# Usage: Used in conjunction with the .css style sheet to wrap UI elements with 
# Urban themed styling.
#
# Dependencies:
#  - htmltools
#  - shinyWidgets
#  - bslib
#  - shiny
#-------------------------------------------------------------------------------

# bslib theme that follows Urban Institute style guides
urbn_bstheme <- bslib::bs_theme(
  version = 5,
  preset = "bootstrap",
  bg = "#1696d2",
  fg = "#ffffff",
  primary = "#1696d2",
  secondary = "#fdbf11",
  success = "#55b748",
  info = "#5c5859",
  warning = "#ec008b",
  danger = "#db2b27",
  base_font = bslib::font_google("Lato"),
  font_scale = 1.5
)

#' @title Wrapper function for Urban themed bslib checkbox group input
#' 
#' @param ns The namespace of the shiny app
#' @param id The id of the checkbox group
#' @param label The label for the checkbox group
#' @param choices The choices for the checkbox group
#' @param ... Additional arguments passed to `shinyWidgets::virtualSelectInput`
#' 
#' @return A shiny checkbox group input wrapped in a div with Urban styling
urban_virtualselect <- function(ns, id, label, choices, ...){
  htmltools::div(
    class = "picker-urbn",
    shinyWidgets::virtualSelectInput(
      inputId = ns(id),
      label = label,
      choices = choices,
      showValueAsTags = TRUE,
      search = TRUE,
      multiple = TRUE,
      ...
    )
  )
}

#' @title Wrapper function for Urban themed shiny action button
#' 
#' @param ns The namespace of the shiny app
#' @param id The id of the button
#' @param label The label of the button
#' 
#' @return A shiny action button with Urban styling
urban_button <- function(ns, id, label) {
  shiny::actionButton(inputId = ns(id),
                      class = "btn-urban",
                      label = label)
}

#' @title Wrapper function for Urban themed shiny checkboxgroup 
#' 
#' @param ns The namespace of the shiny app
#' @param id The id of the checkboxgroup
#' @param choices The choices of the checkboxgroup
#' @param selected The selected choices of the checkboxgroup
#' @param ... Additional arguments passed to `shiny::checkboxGroupInput`
#' 
#' @return A html div tag containing a shiny checkboxgroup
urbn_checkboxgroup <- function(ns, id, choices, selected, ...){
  htmltools::div(
    class = "filter__text",
    shiny::checkboxGroupInput(
      inputId = ns(id),
      label = NULL,
      choices = choices,
      selected = selected,
      inline = FALSE,
      ...
    )
  )
}

#' @title Urban theming for shiny radiobuttons
#' 
#' @param ns The namespace of the shiny app
#' @param id The id of the radiobuttons
#' @param label The label of the radiobuttons
#' @param choices The choices of the radiobuttons
#' @param selected The selected choice of the radiobuttons
#' @param class The div class of the radiobutton
#' 
#' @return A shiny radiobuttons
urbn_radiobuttons <- function(ns, id, label, choices, selected, class){
  htmltools::div(
    class = class,
    shiny::radioButtons(
      inputId = ns(id),
      label = label,
      choices = choices,
      selected = selected,
      inline = FALSE
    )
  )
}

#' @title Wrapper function for Urban Themed R Shiny slider object
#' 
#' @param ns The namespace of the shiny app
#' @param id The id of the slider
#' @param start_year The start year of the slider
#' @param end_year The end year of the slider
#' 
#' @return A html div tag containing a shiny slider input with Urban styling
urbn_slider <- function(ns, id, start_year, end_year) {
  htmltools::div(
    class = "filter__text",
    shiny::sliderInput(
      inputId = ns(id),
      label = NULL,
      min = start_year,
      max = end_year,
      value = c(start_year, end_year),
      step = NULL,
      ticks = FALSE,
      sep = "",
      dragRange = TRUE,
      width = "100%"
    )
  )
}

#' @title Wrapper function for Urban themed bslib input task button
#'
#' @param ns The namespace of the shiny app
#' @param id The id of the button
#' @param label The label of the button
#' @param label_busy The label of the button when busy
#'
#' @return A urban styled bslib input task button
urbn_task_button <- function(ns, id, label, label_busy) {
  bslib::input_task_button(
    id = ns(id),
    class = "btn-urban",
    label = label,
    label_busy = label_busy,
    type = "primary"
  )
}

#' @title Wrapper function for Urban themed shinywidgets tree input 
#'
#' @param ns The namespace of the shiny app
#' @param id The id of the tree
#' @param choice_df data.frame. The data frame containing the choices for the tree
#' @param selected character vector. The selected choices of the treeinput.
#' @param ... Additional arguments passed to `shinyWidgets::treeInput`
#'
#' @return A html div tag containing an urban themed tree input
urbn_tree <- function(ns, id, choice_df, selected, ...){
  htmltools::div(
    class = "filter__text",
    shinyWidgets::treeInput(
      inputId = ns(id),
      label = NULL,
      choices = create_tree(choice_df),
      selected = selected,
      returnValue = "text",
      closeDepth = 0,
      ...
    )
  )
}