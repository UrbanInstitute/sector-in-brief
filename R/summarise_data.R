# Function to summarise data
summarise_data <- function(data, groupby_var, sum_var, query) {
  # Params
  geo_level <- query$geo_level
  # Create tables
  table_default <- data |>
    group_by(!!sym(groupby_var)) |>
    summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  table_ls <- list("default" = table_default)
  table_by_geo <- data |>
    dplyr::group_by(!!sym(groupby_var), !!sym(geo_level)) |>
    summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  table_ls[["by_geo"]] <- table_by_geo
  table_by_subsector <- data |>
    group_by(!!sym(groupby_var), Subsector) |>
    summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collect()
  table_ls[["by_subsector"]] <- table_by_subsector
  table_by_asset_size <- data |>
    dplyr::group_by(!!sym(groupby_var), `Asset Size`) |>
    dplyr::summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::mutate(
      "Asset Size" = case_when(
        `Asset Size` <= 1 ~ "Under $100,000",
        `Asset Size` == 2 ~ "$100,000 - $499,999",
        `Asset Size` == 3 ~ "$500,000 - $999,999",
        `Asset Size` == 4 ~ "$1 Million - $4.99 Million",
        `Asset Size` == 5 ~ "$5 Million - $9.99 Million",
        `Asset Size` == 6 ~ "Above $10 Million",
      )
    ) |>
    dplyr::collect()
  table_ls[["by_asset_size"]] <- table_by_asset_size
  return(table_ls)
}