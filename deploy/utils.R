# Script Header
# Description: This script contains utility functions used in deployment of the 
# shiny app
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-08-05
# Date Last Edited: 2024-08-19

# Industry list
industry_list <- list(
  "ART" = "Arts, Culture, and Humanities", 
  "EDU" = "Education",
  "HEL" = "Health (minus Hospitals)",
  "HMS" = "Human Services",
  "IFA" = "International, Foreign Affairs" ,
  "PSB" = "Public, Societal Benefit",
  "REL" = "Religion Related",
  "MMB" = "Mutual/Membership Benefit",
  "UNI" = "Universities",
  "HOS" = "Hospitals",
  "all_groups" = "All Groups"
)

# Asset list
asset_list <- list(
  "0" = "All Sizes", 
  "1" = "Under $100,000",
  "2" = "$100,000 - $499,999",
  "3" = "$500,000 - $999,999",
  "4" = "$1 Million - $4.99 Million",
  "5" = "$5 Million - $9.99 Million",
  "6" = "Above $10 Million"
)

#' @title This function filters a parquet file based on filter inputs
#' @description It checks if each filter is not the "all" option before filtering
#' the parquet file
#' @param pq parquet file. Data set to filter
#' @param org_type character scalar. 501c type
#' @param state character scalar. State
#' @param industry_group character scalar. NTEE Major Group
#' @param geo_level character scalar. County, or cbsa level filtering
#' @param county_cbsa character scalar. County or CBSA unit level filtering
#' @param size integer. Asset size class
#' @param series character scalar. Type of data being queries for summary
#' @returns pq parquet object. Filtered parquet file.
filter_parquet <- function(pq,
                           org_type,
                           state,
                           industry_group,
                           geo_level,
                           county_cbsa,
                           size,
                           series) {
  if (org_type != "all_orgs") {
    pq <- pq |> dplyr::filter(CTYPE == org_type)
  }
  if (state != "all_states") {
    pq <- pq |> dplyr::filter(CENSUS_STATE_ABBR %in% state)
    if (geo_level == "county") {
      pq <- pq |> dplyr::filter(CENSUS_COUNTY_NAME == county_cbsa)
    } else if (geo_level == "cbsa") {
      pq <- pq |> dplyr::filter(CENSUS_CBSA_NAME == county_cbsa)
    }
  }
  if (industry_group != "all_groups") {
    pq <- pq |> dplyr::filter(NTEE_INDUSTRY_GROUP == industry_group)
  }
  if (size  > 0) {
    pq <- pq |> dplyr::filter(SIZE == as.integer(size))
  }
  if (series == "efile") {
    pq <- pq |>
      dplyr::summarise(
        TOTAL_NUM_DAFS = sum(NUM_DAFS, na.rm = TRUE),
        TOTAL_CONTRIBUTIONS = sum(TOTAL_CONTRIBUTIONS, na.rm = TRUE),
        TOTAL_GRANTS = sum(TOTAL_GRANTS, na.rm = TRUE),
        TOTAL_VALUE = sum(TOTAL_VALUE, na.rm = TRUE),
        TOTAL_HAVE_DAFS = sum(HAS_DAF, na.rm = TRUE),
        MEAN_DAF_PROPORTION = mean(DAF_PROPORTION, na.rm = TRUE)
      ) |>
      dplyr::collapse()
  } else {
    if (series == "fiscal") {
      pq <- pq |>
        dplyr::group_by(YEAR) |>
        dplyr::summarise(
          `Number of Nonprofits` = sum(num_nonprofit, na.rm = TRUE),
          `Total Assets` = sum(total_assets, na.rm = TRUE),
          `Total Revenues` = sum(total_revenues, na.rm = TRUE),
          `Total Expenses` = sum(total_expenses, na.rm = TRUE)
        ) |>
        dplyr::collapse()
    } else if (series == "pf") {
      pq <- pq |>
        dplyr::group_by(YEAR) |>
        dplyr::summarise(
          `Total Grants` = sum(TOTAL_GRANTS, na.rm = TRUE),
          `Median Grant Amount` = sum(MEDIAN_GRANT_AMT, na.rm = TRUE),
          `Number of Grants` = sum(NUM_GRANTS, na.rm = TRUE)
        ) |>
        dplyr::collapse()
    } else if (series == "labor") {
      pq <- pq |>
        dplyr::group_by(YEAR) |>
        dplyr::summarise(
          `Total Benefits` = sum(total_benefits, na.rm = TRUE),
          `Total Payroll Taxes` = sum(total_payroll, na.rm = TRUE)
        ) |>
        dplyr::collapse()
    }
  }
  return(pq)
}

#' @title This function creates the line graph used in the "Sector Summary" tab
#' @param data data frame. Data to plot
#' @param xvar character scalar. x-axis variable
#' @param yvar character scalar. y-axis variable
#' @param scale_unit character scalar. Unit of scale
#' @param scale_factor numeric scalar. Scale factor
#' @param color character scalar. Color of the line
#' @param xlab character scalar. x-axis label
#' @returns p ggplot object. Line graph
create_line_graph <- function(data,
                              xvar,
                              yvar,
                              scale_unit,
                              scale_factor,
                              color,
                              xlab,
                              missing_data = FALSE) {
  if (isTRUE(missing_data)) {
    data <- data |>
      dplyr::mutate({{yvar}} := ifelse(.data[[xvar]] %in% c(1993, 2016:2018), NA, .data[[yvar]])) |>
      dplyr::collect()
  }
  p <- ggplot(data, aes(x = .data[[xvar]], y = .data[[yvar]])) +
    geom_line(size = 1,
              linetype = 1,
              color = color) +
    geom_point(size = 2, color = color) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = 0.1),
      labels = scales::unit_format(unit = scale_unit, scale = scale_factor)
    ) +
    labs(y = "", x = xlab) +
    theme(axis.title.x = element_text(size = 14),
          axis.title.y = element_text(size = 14),)
  if (isTRUE(missing_data)) {
    p <- p +
      geom_line(
        data = filter(data, is.na(.data[[yvar]]) == FALSE),
        linetype = "dashed",
        color = color
      )
  }
  return(p)
}

create_header_statement <- function(org_type,
                                    state,
                                    industry_group,
                                    geo_level,
                                    county_cbsa,
                                    size){
  base_statement <- "Retrieving data for all 501(c) Organizations in The United States"
  if (org_type != "all_orgs") {
    base_statement <- gsub("501\\(c\\)", org_type, base_statement)
  } 
  if (state != "all_states") {
    base_statement <- gsub("The United States", usdata::abbr2state(state), base_statement)
    if (geo_level == "county") {
      base_statement <- paste(base_statement, ",", county_cbsa, "county")
    } else if (geo_level == "cbsa") {
      base_statement <- paste(base_statement, ",", county_cbsa, "metro area")
    }
  }
  if (industry_group != "all_groups") {
    base_statement <- paste(base_statement, "in the ", industry_list[[industry_group]], " industry group")
  }
  if (size > 0) {
    base_statement <- paste(base_statement, "with ", asset_list[[size]], " in assets")
  }
  return(base_statement)
}
