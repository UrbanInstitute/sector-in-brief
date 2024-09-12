# Single script for plotting functions

# Create multiple line plots
create_plots <- function(table_ls,
                         single_plot_func,
                         group_plot_func,
                         geo_level, 
                         subsector_level, 
                         asset_size_level, 
                         title, 
                         subtitle) {
  plot_ls <- list()
  # Blank Plot
  default_plot <- single_plot_func(table_ls[["default"]], title, subtitle)
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
    by_geo_plot <- group_plot_func(table_ls[["by_geo"]], geo_level, geo_title, subtitle)
    plot_ls[["by_geo"]] <- by_geo_plot
  } else {
    plot_ls[["by_geo"]] <- create_blank_plot("Select A Sub-Geographic Level From Above For Data By Geography")
  }
  if (subsector_level == "individual") {
    subsector_title <- paste(title, ", By Subsector")
    by_subsector_plot <- group_plot_func(table_ls[["by_subsector"]], "Subsector", subsector_title, subtitle)
    plot_ls[["by_subsector"]] <- by_subsector_plot
  } else {
    plot_ls[["by_subsector"]] <- create_blank_plot("Select A Individual Subsector From Above For Data By Subsector")
  }
  if (asset_size_level == "individual") {
    size_title <- paste(title, ", By Asset Size")
    by_asset_size_plot <- group_plot_func(table_ls[["by_asset_size"]], "Asset_Size", size_title, subtitle)
    plot_ls[["by_asset_size"]] <- by_asset_size_plot
  } else {
    plot_ls[["by_asset_size"]] <- create_blank_plot("Select A Individual Asset Size From Above For Data By Asset Size")
  }
  return(plot_ls)
}

create_single_facet_bar_plot <- function(table, title, subtitle) {
  p <- ggplot(table, aes(x = "Total", y = `Value`, fill = Metric)) +
    geom_col() +
    facet_wrap(~Metric) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::unit_format(unit = "m", scale = 1e-6)
    ) +
    labs(subtitle = subtitle, 
         x = "",
         title = title,
         y = "Number of Nonprofits (millions)") +
    theme_classic() +
    theme(
      text = element_text(family = "Lato"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 16, hjust = 0, margin = margin(b = 20)),
      axis.text = element_text(size = 12, color = "#000000"),
      axis.title.y = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 0.5, margin = margin(r = 10)),
      axis.line.y = element_blank(),
      axis.title.x = element_text(size = 12, margin = margin(t = 10), color = "#000000"),
      panel.grid.major.y = element_line(color = "#dcdcdc"),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      plot.caption = element_text(hjust = 0, size = 10, color = "grey50", margin = margin(t = 20)),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20),
      strip.background = element_blank(),
      strip.text=element_text(size=12, colour="black")
    )
  return(p)
}

create_group_facet_bar_plot <- function(table, grouping_var, title, subtitle) {
  p <- ggplot(table, aes(x = !!sym(var_rename_ls[[grouping_var]]), y = `Value`, fill = !!sym(var_rename_ls[[grouping_var]]))) +
    geom_col() +
    facet_wrap(~Metric) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::unit_format(unit = "m", scale = 1e-6)
    ) +
    labs(subtitle = subtitle, 
         x = var_rename_ls[[grouping_var]],
         title = title,
         y = "Number of Nonprofits (millions)") +
    theme_classic() +
    theme(
      text = element_text(family = "Lato"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 16, hjust = 0, margin = margin(b = 20)),
      axis.text = element_text(size = 12, color = "#000000"),
      axis.title.y = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 0.5, margin = margin(r = 10)),
      axis.line.y = element_blank(),
      axis.title.x = element_text(size = 12, margin = margin(t = 10), color = "#000000"),
      panel.grid.major.y = element_line(color = "#dcdcdc"),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      plot.caption = element_text(hjust = 0, size = 10, color = "grey50", margin = margin(t = 20)),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20),
      strip.background = element_blank(),
      strip.text=element_text(size=12, colour="black")
    )
  return(p)
}

create_single_line_plot <- function(table, title, subtitle) {
  p <- ggplot(table, aes(x = Year, y = `Number of Nonprofits`)) +
    geom_line(size = 1.5,
              linetype = 1,
              color = "#1696d2") +
    geom_point(size = 3, color = "#1696d2", fill = "white", shape = 21, stroke = 1.2) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::unit_format(unit = "m", scale = 1e-6)
    ) +
    labs(subtitle = subtitle, 
         x = "Fiscal Year",
         title = title,
         y = "Number of Nonprofits (millions)") +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    theme_classic() +
    theme(
      text = element_text(family = "Lato"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 16, hjust = 0, margin = margin(b = 20)),
      axis.text = element_text(size = 12, color = "#000000"),
      axis.title.y = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 0.5, margin = margin(r = 10)),
      axis.line.y = element_blank(),
      axis.title.x = element_text(size = 12, margin = margin(t = 10), color = "#000000"),
      panel.grid.major.y = element_line(color = "#dcdcdc"),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      plot.caption = element_text(hjust = 0, size = 10, color = "grey50", margin = margin(t = 20)),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
    )
  return(p)
}

create_group_line_plot <- function(table, grouping_var, title, subtitle) {
  p <- ggplot(table, aes(x = Year, y = `Number of Nonprofits`, colour = !!sym(var_rename_ls[[grouping_var]]))) +
    geom_line(size = 1.5,
              linetype = 1) +
    geom_point(size = 3, fill = "white", shape = 21, stroke = 1.2) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::unit_format(unit = "m", scale = 1e-6)
    ) +
    labs(subtitle = subtitle, 
         x = "Fiscal Year",
         title = title,
         y = "Number of Nonprofits (millions)") +
    scale_x_continuous(breaks = seq(1990, 2024, 4)) +
    theme_classic() +
    theme(
      text = element_text(family = "Lato"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 16, hjust = 0, margin = margin(b = 20)),
      axis.text = element_text(size = 12, color = "#000000"),
      axis.title.y = element_text(size = 12, angle = 90, vjust = 0.5, hjust = 0.5, margin = margin(r = 10)),
      axis.line.y = element_blank(),
      axis.title.x = element_text(size = 12, margin = margin(t = 10), color = "#000000"),
      panel.grid.major.y = element_line(color = "#dcdcdc"),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      plot.caption = element_text(hjust = 0, size = 10, color = "grey50", margin = margin(t = 20)),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
    )
  return(p)
}