#' @title pipeline for server side data processing
#' @param input list of input values
#' @param geo_filters list of geo filters
#' @param config list of output configuration parameters
#' @param geo_df data.frame. data set of nested geographies
#' @param output list of shiny outputs
#' @return list of shiny outputs
data_pipeline <- function(input,
                          geo_filters,
                          config,
                          data,
                          geo_df,
                          output) {
  inputs <- format_input(input = input, geo_filters = geo_filters, config)
  input_validation_msg <- validate_inputs(inputs)
  if (input_validation_msg != TRUE) {
    shiny::showModal(modal(input_validation_msg))
  }
  else {
    title <- plot_title(inputs)
    caption <- plot_caption(inputs)
    shiny::withProgress(min = 1, max = 5, {
      setProgress(1, message = "Filtering Data...")
      query <- query_builder(inputs, geo_df)
      filtered_data <- filter_data(data = data, filter_ls = query$filters)
      setProgress(2, message = "Creating Tables...")
      tables <- summarise_data(data = filtered_data, config, query = query)
      setProgress(3, message = "Creating Graphs...")
      plots <- plots_build_all(
        tables_ls = tables,
        groupby_vars = list(
          NULL,
          "Organization Type",
          query$geo_level,
          "Subsector",
          "Size"
        ),
        title = title,
        caption = caption,
        config
      )
      setProgress(4, message = "Displaying Results...")
      results <- list(plots = plots, tables = tables, output = output, query = query)
      setProgress(5, message = "Done!")
    })
  }
  return(results)
}

# Function to filter data
filter_data <- function(data, filter_ls){     
  fp <- purrr::map2(names(filter_ls), filter_ls, function(vars, vals) quo((!!(as.name(vars))) %in% !!vals))
  data <- dplyr::filter(data, !!!fp)
  data <- dplyr::compute(data)
  return(data)
}