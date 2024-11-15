table_builder_geo <- function(table, groupby_var, groupby_var_2, sum_var, is_pf){
  if (is_pf == TRUE){
    table <- table_builder_pf(table, groupby_var, sum_var)
  }
  return(table)
}