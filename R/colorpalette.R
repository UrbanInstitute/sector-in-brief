# Urban Institute brand colours plus a programmatic extension. Used
# by every grouped plot (group_col_plot.R, group_line_plot.R) to fill
# / colour series. ≤8 groups take the first N brand colours; >8 falls
# back to a colourRampPalette interpolation across the same anchors.

urbnpalette <- c(
  "#1696d2",
  "#d2d2d2",
  "#000000",
  "#fdbf11",
  "#ec008b",
  "#55b748",
  "#5c5859",
  "#db2b27"
)

#' Get N brand-aligned colours for a grouped plot.
#'
#' @param num_colors Number of distinct colours needed.
#' @param palette Anchor palette (default: Urban brand, 8 colours).
#' @return Character vector of length `num_colors`.
colorpalette <- function(num_colors, palette = urbnpalette) {
  if (num_colors <= length(palette)) {
    return(palette[seq_len(num_colors)])
  } else {
    colors <- grDevices::colorRampPalette(palette)(num_colors)
    return(colors)
  }
}
  
  