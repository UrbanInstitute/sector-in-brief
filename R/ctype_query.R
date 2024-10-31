#' @title Function to create ctype query
#' @param filter_ls list of filters
#' @param ctype_level1 first level of organization type
#' @param ctype_level2 second level of organization type
#' @return list of filters edited in place
ctype_query <- function(filter_ls, ctype_level1, ctype_level2){
  if ("501(c)(3)" %in% ctype_level1){
    filter_ls[["Organization Type"]] <- c(ctype_level1,
                                          "501(c)(3) Public Charities",
                                          "501(c)(3) Private Foundations")
  } else if ("501(c)(4) Social Welfare Organizations" %in% ctype_level1) {
    filter_ls[["Organization Type"]] <- c(ctype_level1, "501(c)(4)")
  } else if ("Other Nonprofits" %in% ctype_level1) {
    filter_ls[["Organization Type"]] <- c(ctype_level1, ctype_level2)
  } else {
    filter_ls[["Organization Type"]] <- ctype_level1
  }
  return(filter_ls)
}