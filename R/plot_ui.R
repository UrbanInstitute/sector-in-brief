#-------------------------------------------------------------------------------
# File: plot_ui.R
# Author: Thiyaghessan Poongundranar [tpoongundranar@urban.org]
# Date created: 2024-06-01
# Date last edited: 2025-07-02
#
# Purpose: Create the layout of the navigation panels containing the plots. Does
# not include the plots themselves which are created in a separate script.
#
# Usage: Sourced by app during startup, plot_ui() creates the navigation panels 
# for each disaggregation of the data. The panel for each plot and its associated
# table are created with plotpanel_builder() and iterated over with 
# plotpanel_mapper() using the arguments from plotpanel_args.
#
# Dependencies:
# - tibble
# - bslib
# - purrr
# - ggiraph
# - shinycssloaders
# - reactable
# - R/urbn_ui_elements.R
#-------------------------------------------------------------------------------

# IDs for each plot
plotpanel_args <-
  tibble::tribble(
    ~title, ~plot_id, ~table_id, ~download_id, ~table_title_id,
    "Overall", "plot_overall", "table_overall", "dl_overall", "table_overall_title",
    "By Organization Type", "plot_ctype", "table_ctype", "dl_ctype", "table_ctype_title",
    "By Subsector", "plot_subsector", "table_subsector", "dl_subsector", "table_subsector_title",
    "By Geography", "plot_geo", "table_geo", "dl_geo", "table_geo_title",
    "By Size", "plot_size", "table_size", "dl_size", "table_size_title",
  )

#' @title Create the navigation panels for each disaggregation of the data
#' 
#' @description This function uses the plotpanel_mapper to create navigation panels
#' for each disaggregation of the data, such as overall, by organization type,
#' by subsector, by geography, and by size.
#' 
#' @param id The namespace ID for the plot panels
#' 
#' @return A bslib:navset_card_underline object containing the plot panels for 
#' each disaggregation
plot_ui <- function(id) {
  plotpanels <- plotpanel_mapper(plotpanel_args, id)
  bslib::navset_card_underline(
    title =   "Visualize Your Results",
    height = "100%",
    plotpanels[["Overall"]],
    plotpanels[["By Organization Type"]],
    plotpanels[["By Subsector"]],
    plotpanels[["By Geography"]],
    plotpanels[["By Size"]]
  )
}

#' @title Construct the plot panel for each metric being visualized
#' 
#' @description This function builds a navigation panel for each metric being visualized,
#' including a plot output area and a table output area with a download button.
#' 
#' @param id The namespace ID for the plot panel
#' @param plotpanel_args A tibble containing the arguments for the plot panel
#' 
#' @return A bslib:nav_panel object containing the plot and table outputs
plotpanel_mapper <- function(plotpanel_args, id){
  plotpanels <- purrr::pmap(plotpanel_args, plotpanel_builder, id = id)
  names(plotpanels) <- plotpanel_args[["title"]]
  return(plotpanels)
}

#' @title Create a plot panel with a plot and a table
#' 
#' @description This function builds a plot panel with a ggiraph plot output,
#' a reactable table output, and a download button for the table. The plot output
#' uses a spinner before rendering for a better UI experience.
#' 
#' @param id The namespace ID for the plot panel
#' @param title The title of the plot panel
#' @param plot_id The ID for the ggiraph plot output
#' @param table_id The ID for the reactable table output
#' @param download_id The ID for the download button
#' @param table_title_id The ID for the table title output
#' 
#' @return A bslib:nav_panel object containing the plot and table outputs
plotpanel_builder <- function(id,
                              title,
                              plot_id,
                              table_id,
                              download_id,
                              table_title_id) {
  bslib::nav_panel(
    title = title,
    layout_column_wrap(
      width = 1,
      heights_equal = "row",
      bslib::card(bslib::card_body(
        shinycssloaders::withSpinner(ggiraph::girafeOutput(NS(id, plot_id), width = "100%"), type = 1)
      )),
      bslib::accordion(
        bslib::accordion_panel(
          title = accordion_title("View Data"),
          value = "view_table",
          id = "reactable",
          table_contents(id, table_id, download_id, table_title_id)
        ),
        open = FALSE
      )
    )
  )
}

#' @title Create the contents of the table output area
#' 
#' @description This function creates the HTML structure for the table output area,
#' including the table header, the reactable output, and the download button.
#' 
#' @param id The namespace ID for the table output area
#' @param table_id The ID for the reactable table output
#' @param download_id The ID for the download button
#' @param table_title_id The ID for the table title output
#' 
#' @return A list of HTML tags containing the table header, reactable output, 
#' and download button
table_contents <- function(id, table_id, download_id, table_title_id) {
  htmltools::tagList(
    urbn_tbl_hdr(id, table_title_id),
    reactable::reactableOutput(NS(id, table_id)),
    htmltools::br(),
    urbn_download_button(id, download_id, "DOWNLOAD TABLE")
  )
}
