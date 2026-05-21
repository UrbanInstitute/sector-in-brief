#' @title Function to add selected asset sizes to plot caption
#' @param caption A character string containing the plot caption
#' @param size A character vector of selected asset sizes
#' @param asset_size_ls A list of asset sizes
#' @return A character string with the plot caption edited in place
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