#' Add the Organization Type predicate to a query filter list.
#'
#' Resolves the user-facing label (e.g. "501(c)(3) Public Charities")
#' through `ctype_id` to the parquet's stored value(s) for that type.
#'
#' @param filter_ls In-progress filter list from `query_builder()`.
#' @param ctype Active selection from the org-type radio.
#' @return `filter_ls` with the "Organization Type" entry added.
ctype_query <- function(filter_ls, ctype){
  filter_ls[["Organization Type"]] <- ctype_id[ctype] |> unlist()
  return(filter_ls)
}