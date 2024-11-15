#' @title Function to create ctype query
#' @param filter_ls list of filters
#' @param ctype character scalar. 501(c) type.
#' @return list of filters edited in place
ctype_query <- function(filter_ls, ctype){
  filter_ls[["Organization Type"]] <- ctype_id[ctype] |> unlist()
  return(filter_ls)
}