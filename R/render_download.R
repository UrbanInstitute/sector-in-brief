# Build per-table download handlers so the user can grab a CSV of any
# of the five summary views directly from the panel. Wired into the
# dl_* output slots by render_outputs().

#' Wrap a list of tibbles in per-table CSV download handlers.
#'
#' @param tables Named list of 5 tibbles from `summarise_data()`.
#' @return Named list of `shiny::downloadHandler` outputs; each file
#'   is named after its breakdown key (default.csv, by_ctype.csv, ...).
render_download <- function(tables) {
  purrr::imap(
    tables,
    .f = function(table, name) {
      downloadHandler(
        filename = paste0(name, ".csv"),
        content = function(file) {
          write.csv(table, file)
        }
      )
    }
  )
}
