# Function to summarise data
summarise_data <- function(data, groupby_var, sum_var, geo_level, subsector_level, asset_size_level) {
  table_default <- data |>
    group_by(!!sym(groupby_var)) |>
    summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
    dplyr::collapse()
  table_ls <- list("default" = table_default)
  if (geo_level != "all") {
    table_by_geo <- data |>
      dplyr::group_by(!!sym(groupby_var), !!sym(geo_level)) |>
      summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
      dplyr::rename_with(~var_rename_ls[[geo_level]], !!sym(geo_level)) |>
      dplyr::collapse()
    table_ls[["by_geo"]] <- table_by_geo
  }
  if (subsector_level != "all") {
    table_by_subsector <- data |>
      group_by(!!sym(groupby_var), Subsector) |>
      summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
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
      group_by(!!sym(groupby_var), Asset_Size) |>
      summarise(!!sum_var := sum(!!sym(sum_var), na.rm = TRUE)) |>
      dplyr::rename_with(~var_rename_ls[["Asset_Size"]], Asset_Size) |>
      dplyr::collapse()
    table_ls[["by_asset_size"]] <- table_by_asset_size
  }
  return(table_ls)
}