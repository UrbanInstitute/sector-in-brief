# Create multiple plots
create_plots <- function(table_ls,
                         single_plot_func,
                         group_plot_func,
                         geo_level, 
                         subsector_level, 
                         asset_size_level, 
                         title, 
                         subtitle,
                         yvar) {
  plot_ls <- list()
  # Blank Plot
  default_plot <- single_plot_func(table_ls[["default"]], title, subtitle, yvar)
  plot_ls[["default"]] <- default_plot
  if (geo_level != "all") {
    if (geo_level == "census_region"){
      geo_title <- paste(title, ", By Census Region")
    } else if (geo_level == "CENSUS_STATE_ABBR") {
      geo_title <- paste(title, ", By State")
    } else if (geo_level == "CENSUS_COUNTY_NAME") {
      geo_title <- paste(title, ", By County")
    } else if (geo_level == "CENSUS_CBSA_NAME") {
      geo_title <- paste(title, ", By CBSA")
    }
    by_geo_plot <- group_plot_func(table_ls[["by_geo"]], geo_level, geo_title, subtitle, yvar)
    plot_ls[["by_geo"]] <- by_geo_plot
  } else {
    plot_ls[["by_geo"]] <- create_blank_plot("Select A Sub-Geographic Level From Above For Data By Geography")
  }
  if (subsector_level == "individual") {
    subsector_title <- paste(title, ", By Subsector")
    by_subsector_plot <- group_plot_func(table_ls[["by_subsector"]], "Subsector", subsector_title, subtitle, yvar)
    plot_ls[["by_subsector"]] <- by_subsector_plot
  } else {
    plot_ls[["by_subsector"]] <- create_blank_plot("Select A Individual Subsector From Above For Data By Subsector")
  }
  if (asset_size_level == "individual") {
    size_title <- paste(title, ", By Asset Size")
    by_asset_size_plot <- group_plot_func(table_ls[["by_asset_size"]], "Asset_Size", size_title, subtitle, yvar)
    plot_ls[["by_asset_size"]] <- by_asset_size_plot
  } else {
    plot_ls[["by_asset_size"]] <- create_blank_plot("Select A Individual Asset Size From Above For Data By Asset Size")
  }
  return(plot_ls)
}