# Plotting

# Load data
data <- arrow::read_parquet("data/fiscal_metrics.parquet")

# Overall Trends
num_nonprofits <- data |>
  dplyr::group_by(YEAR) |>
  dplyr::summarise(
    `Number of Nonprofits` = sum(num_nonprofit, na.rm = TRUE),
  ) |>
  dplyr::collapse()
num_nonprofits_table <- DT::datatable(num_nonprofits, rownames = FALSE)
num_nonprofits_plot <- 
  ggplot2::ggplot(num_nonprofits, ggplot2::aes(x = YEAR, y = `Number of Nonprofits`)) +
  ggplot2::geom_line()

# Grouped by Subsector
num_nonprofits_subsector <- data |>
  dplyr::group_by(NTEE_INDUSTRY_GROUP, YEAR) |>
  dplyr::summarise(
    `Number of Nonprofits` = sum(num_nonprofit, na.rm = TRUE),
  ) |>
  dplyr::filter(
    NTEE_INDUSTRY_GROUP %in% c("HMS", "EDU", "ART", "PSB", "HEL")
  ) |>
  dplyr::collapse()
num_nonprofits_subsector_plot <- plotly::plot_ly(
  num_nonprofits_subsector,
  x = ~YEAR,
  y = ~`Number of Nonprofits`,
  color = ~NTEE_INDUSTRY_GROUP,
  type = "scatter",
  mode = "lines",
  name = "Number of Nonprofits"
)

num_nonprofits_subsector_table <- DT::datatable(num_nonprofits_subsector, rownames = FALSE)