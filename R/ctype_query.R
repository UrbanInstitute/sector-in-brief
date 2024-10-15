#' @title Function to create ctype query
#' @param filter_ls list of filters
#' @param ctype_level1 first level of organization type
#' @param ctype_level2 second level of organization type
#' @return list of filters edited in place
ctype_query <- function(filter_ls, ctype_level1, ctype_level2){
  if (ctype_level1 == "501(c)(3)"){
    filter_ls[["Organization Type"]] <- c("501(c)(3) Public Charities",
                                          "501(c)(3) Private Foundations")
  } else if (ctype_level1 == "501(c)(4) Social Welfare Organizations") {
    filter_ls[["Organization Type"]] <- "501(c)(4)"
  } else if (ctype_level1 == "Other Nonprofits") {
    filter_ls[["Organization Type"]] <- ctype_level2
  }
  return(filter_ls)
}