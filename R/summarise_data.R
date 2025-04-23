# Function to summarise data
summarise_data <- function(data, groupby_var, sum_var, query) {
  # Params
  geo_level <- query$geo_level
  org_type <- query[["filters"]][["Organization Type"]]
  groupby_ls <- list("default" = NULL,
                     "by_ctype" = "Organization Type",
                     "by_geo" = geo_level,
                     "by_subsector" = "Subsector",
                     "by_asset_size" = "Size")
  # Create tables
  is_pf <- FALSE
  if (length(org_type) == 1){
    if (org_type == "501(c)(3) Private Foundations" &
        groupby_var == "Tax Year"){
      is_pf <- TRUE
    }
  }
  if (sum_var == "Proportion with DAFs") {
    table_ls <- purrr::map(
      groupby_ls,
      purrr::possibly(table_builder_proportion, otherwise = blank_table()),
      data = data,
      groupby_var = groupby_var,
      sum_var = "Has DAF",
      sum_var_2 = "Number of Nonprofits",
      proportion_var = sum_var
    )
  } else {
    table_ls <- purrr::map(
      groupby_ls,
      purrr::possibly(table_builder, otherwise = blank_table()),
      data = data,
      groupby_var = groupby_var,
      sum_var = sum_var,
      is_pf = is_pf
    )
  }
  return(table_ls)
}