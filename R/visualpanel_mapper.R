# Build the 13 lazy nav_panel shells (one per row of visualpanel_args).
# Called once at app boot. Per-panel content (heavy widgets, filter
# cards, plot UI) is mounted on demand by visualpanel_content() once
# the user activates a tab.

#' Build the named list of lazy panel shells used by `app()`.
#'
#' @param visualpanel_args The driver tibble — typically the
#'   top-level constant of the same name.
#' @return Named list keyed by panel title; each entry is a
#'   `bslib::nav_panel` containing a `uiOutput("panel_ui_<id>")` slot.
visualpanel_mapper <- function(visualpanel_args) {
  visualpanels <- purrr::pmap(visualpanel_args, visualpanel_builder)
  names(visualpanels) <- visualpanel_args[["title"]]
  return(visualpanels)
}
