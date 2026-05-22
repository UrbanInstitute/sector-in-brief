#' Add the active size-band selections to a plot caption.
#'
#' Looks each integer size (1-6) up in `asset_size_ls` to map to its
#' human-readable dollar-range label.
#'
#' @param caption Running caption string.
#' @param size Active integer size selections.
#' @param asset_size_ls Map from integer to dollar-range label
#'   (defined in `R/data.R`).
#' @return Updated caption string.
caption_size <- function(caption, size, asset_size_ls) {
  sizes <- unlist(purrr::map(
    size,
    .f = function(x) {
      asset_size_ls[[x]]
    }
  ))
  caption <- paste(caption, "Size(s):", paste(sizes, collapse = ", "), "\n")
  return(caption)
}