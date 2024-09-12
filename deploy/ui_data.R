# Test data wrangling script for the number of nonprofits
# Decide on which ones to filter on and then filter

# Data Wrangling Functions
orgtype_query <- function(data, org, other_orgs = NULL) {
  if (org == "501(c)(3) Public Charities"){
    data <- filter(data, Organization_Type == org)
  } else if (org == "501(c)(3) Private Foundations"){
    data <- filter(data, Organization_Type == org)
  } else if (org == "501(c)(4) Social Welfare Organizations") {
    data <- filter(data, Organization_Type == "501(c)(4)")
  } else if (org == "Other Nonprofits") {
    data <- filter(data, Organization_Type == other_orgs)
  }
  return(data)
}

geo_query <- function(data, geo_level, region, state_single, state_mult, county, cbsa) {
  if (geo_level == "census_region") {
    data <- filter(data, census_region %in% region)
  } else if (geo_level == "CENSUS_STATE_ABBR") {
    data <- filter(data, CENSUS_STATE_ABBR %in% state_mult)
  } else if (geo_level == "CENSUS_COUNTY_NAME") {
    data <- filter(data, CENSUS_STATE_ABBR %in% state_single)
    data <- filter(data, CENSUS_COUNTY_NAME %in% county)
  } else if (geo_level == "CENSUS_CBSA_NAME") {
    data <- filter(data, CENSUS_CBSA_NAME %in% cbsa)
  }
  return(data)
}

subsector_query <- function(data, subsector) {
  data <- filter(data, Subsector %in% subsector)
  return(data)
}

filter_asset_size <- function(data, asset_size){
  data <- filter(data, Asset_Size %in% asset_size)
  return(data)
}

filter_data <- function(data,
                        org_level = "All Nonprofits",
                        other_orgs = NULL,
                        geo_level = "all",
                        region = NULL,
                        state_single = NULL,
                        state_mult = NULL,
                        county = NULL,
                        cbsa = NULL,
                        subsector_level = "all",
                        subsectors = NULL,
                        asset_size_level = "all",
                        asset_sizes = NULL,
                        year_start,
                        year_end) {
  if (org_level != "All Nonprofits") {
    data <- orgtype_query(data, org_level, other_orgs)
  }
  if (geo_level != "all"){
    data <- geo_query(data, geo_level, region, state_single, state_mult, county, cbsa)
  }
  if (subsector_level != "all") {
    data <- subsector_query(data, subsectors)
  }
  if (asset_size_level != "all") {
    data <- filter_asset_size(data, asset_sizes)
  }
  if (year_start != 1989) {
    data <- filter(data, Year >= year_start)
  }
  if (year_end != 2024) {
    data <- filter(data, Year <= year_end)
  }
  return(data)
}

summarise_data <- function(data, geo_level, subsector_level, asset_size_level) {
  table_default <- data |>
    group_by(Year) |>
    summarise(Number_Of_Nonprofits = sum(num_nonprofit, na.rm = TRUE)) |>
    dplyr::collapse()
  table_ls <- list("default" = table_default)
  if (geo_level != "all") {
    table_by_geo <- data |>
      dplyr::group_by(Year, !!sym(geo_level)) |>
      summarise(Number_Of_Nonprofits = sum(num_nonprofit, na.rm = TRUE)) |>
      dplyr::collapse()
    table_ls[["by_geo"]] <- table_by_geo
  }
  if (subsector_level != "all") {
    table_by_subsector <- data |>
      group_by(Year, Subsector) |>
      summarise(Number_Of_Nonprofits = sum(num_nonprofit)) |>
      dplyr::collapse()
    table_ls[["by_subsector"]] <- table_by_subsector
  }
  if (asset_size_level != "all") {
    table_by_asset_size <- data |>
      dplyr::mutate(Asset_Size = case_when(
        Asset_Size == 1 ~ "Under $100,000",
        Asset_Size == 2 ~ "$100,000 - $499,999",
        Asset_Size == 3 ~ "$500,000 - $999,999",
        Asset_Size == 4 ~ "$1 Million - $4.99 Million",
        Asset_Size == 5 ~ "$5 Million - $9.99 Million",
        Asset_Size == 6 ~ "Above $10 Million",
      )) |>
      group_by(Year, Asset_Size) |>
      summarise(Number_Of_Nonprofits = sum(num_nonprofit)) |>
      dplyr::collapse()
    table_ls[["by_asset_size"]] <- table_by_asset_size
  }
  return(table_ls)
}

create_plots <- function(table_ls, geo_level, subsector_level, asset_size_level, title, subtitle) {
  plot_ls <- list()
  # Blank Plot
  default_plot <- create_single_plot(table_ls[["default"]], title, subtitle)
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
    by_geo_plot <- create_group_plot(table_ls[["by_geo"]], geo_level, geo_title, subtitle)
    plot_ls[["by_geo"]] <- by_geo_plot
  } else {
    plot_ls[["by_geo"]] <- create_blank_plot("Select A Sub-Geographic Level From Above For Data By Geography")
  }
  if (subsector_level == "individual") {
    subsector_title <- paste(title, ", By Subsector")
    by_subsector_plot <- create_group_plot(table_ls[["by_subsector"]], "Subsector", subsector_title, subtitle)
    plot_ls[["by_subsector"]] <- by_subsector_plot
  } else {
    plot_ls[["by_subsector"]] <- create_blank_plot("Select A Individual Subsector From Above For Data By Subsector")
  }
  if (asset_size_level == "individual") {
    size_title <- paste(title, ", By Asset Size")
    by_asset_size_plot <- create_group_plot(table_ls[["by_asset_size"]], "Asset_Size", size_title, subtitle)
    plot_ls[["by_asset_size"]] <- by_asset_size_plot
  } else {
    plot_ls[["by_asset_size"]] <- create_blank_plot("Select A Individual Asset Size From Above For Data By Asset Size")
  }
  return(plot_ls)
}



# Plotting Functions
create_single_plot <- function(table, title, subtitle) {
  p <- ggplot(table, aes(x = Year, y = Number_Of_Nonprofits)) +
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

create_group_plot <- function(table, grouping_var, title, subtitle) {
  p <- ggplot(table, aes(x = Year, y = Number_Of_Nonprofits, colour = !!sym(grouping_var))) +
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

create_blank_plot <- function(title) {
  p <- ggplot() +
    labs(title = title) +
    theme_classic() +
    theme(
      text = element_text(family = "Lato"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
    )
  return(p)
}