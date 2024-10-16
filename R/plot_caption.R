#' @title Function to format plot caption
#' @description This function formats the caption for the plot based on the inputs provided by the user
#' @param inputs A list of inputs provided by the user, formatted
#' 
plot_caption <- function(inputs) {
  # Params needed for caption
  caption <- ""
  ctype_level1 <- inputs$ctype_level1
  geo_level <- inputs$geo_level
  region <- inputs$geo_region
  state_single <- inputs$geo_state_single
  state_mult <- inputs$geo_state_mult
  county <- inputs$geo_county
  cbsa <- inputs$geo_cbsa
  subsector <- inputs$subsector
  size <- inputs$size
  agg_var <- inputs$agg_var
  year_var <- inputs$year_var
  
  caption <- caption_geo(
    caption,
    geo_level = geo_level,
    region = region,
    state_single = state_single,
    state_mult = state_mult,
    county = county,
    cbsa = cbsa
  )
  caption <- paste(caption, "Subsector(s):", paste(subsector, collapse = ", "), "\n")
  caption <- caption_size(caption, size, asset_size_ls)
  # Private Foundation notes
  caption <- caption_pf(caption, ctype_level1)
  # DAF Notes
  caption <- caption_daf(caption, agg_var)
  # Year Notes
  caption <- caption_year(caption, year_var)
  return(caption)
}