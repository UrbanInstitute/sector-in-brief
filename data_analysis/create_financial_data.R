create_financial_data <- function(financial_var, bmf_cols, core, pf, bmf, destfolder){
  core_subset <- core |>
    dplyr::select(
      EIN2,
      !!rlang::sym(financial_var),
      `Asset Size`,
      `Tax Year`
    ) |>
    dplyr::collapse()
  
  pf_subset <- pf |>
    dplyr::select(
      EIN2,
      !!rlang::sym(financial_var),
      `Tax Year`,
      `Asset Size`
    ) |>
    dplyr::collapse()
  
  full <- purrr::list_rbind(list(core_subset, pf_subset))
  
  bmf_merge <- bmf |>
    dplyr::select(
      dplyr::all_of(
        bmf_cols
      )
    ) |>
    dplyr::collapse()
  
  full <- full |>
    tidylog::left_join(
      bmf_merge,
      by = "EIN2"
    ) |>
    dplyr::distinct() |>
    dplyr::group_by(
      Subsector,
      `Tax Year`,
      `Organization Type`,
      `Asset Size`,
      `Census Region`,
      `Census State`,
      `Census County`,
      `Census CBSA`
    ) |>
    dplyr::summarise(
      !!rlang::sym(financial_var) := sum(!!rlang::sym(financial_var), na.rm = TRUE)
    ) |>
    dplyr::collapse()
  
  destfile <- gsub(" ", "_", financial_var)
  dest <- paste0(destfolder, destfile, ".parquet")
  arrow::write_parquet(full, dest)
  message(
    sprintf("Finished saving data for %s", financial_var)
  )
  return(full)
  
}