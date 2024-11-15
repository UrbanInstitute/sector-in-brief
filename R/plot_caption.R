#' @title Function to format plot caption
#' @description This function formats the caption for the plot based on the inputs provided by the user
#' @param inputs A list of inputs provided by the user, formatted
#' 
plot_caption <- function(inputs) {
  # Params needed for caption
  caption <- ""
  ctype <- inputs$ctype
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
  caption <- paste(caption, "Organization Type(s):", paste(ctype, collapse = ", "), "\n")
  caption <- paste(caption, "Subsector(s):", paste(subsector, collapse = ", "), "\n")
  caption <- caption_size(caption, size, asset_size_ls)
  # Private Foundation notes
  caption <- caption_pf(caption, ctype)
  # DAF Notes
  caption <- caption_daf(caption, agg_var)
  # Finance Notes
  caption <- caption_finance(caption, agg_var)
  # Year Notes
  caption <- caption_year(caption, year_var)
  caption <- paste(
    caption,
    "\n",
    "•	All data is derived directly from IRS tax records and are thus subject to changes in IRS reporting requirements. Fluctuations in observed Year-Over-Year values are likely due to changes in these requirements.",
    "\n",
    "•	The graphs only include data until 2021 because the IRS has only partially released tax records for tax year 2022."
  )
  return(caption)
}