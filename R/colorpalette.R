# Function to programmatically extend the Urban color palette

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

colorpalette <- function(num_colors, palette=urbnpalette){
  if (num_colors <= 8){
    return(palette)
  } else {
    colors <- grDevices::colorRampPalette(palette)(num_colors)
    return(colors)
  }
}
  
  