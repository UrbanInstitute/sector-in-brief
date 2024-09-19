# Single function to query organization types
orgtype_query <- function(data, org, other_orgs = NULL, orgvar = "Organization Type") {
  if (org == "501(c)(3) Public Charities"){
    data <- dplyr::filter(data, `Organization Type` == org)
  } else if (org == "501(c)(3) Private Foundations"){
    data <- dplyr::filter(data, `Organization Type` == org)
  } else if (org == "501(c)(4) Social Welfare Organizations") {
    data <- dplyr::filter(data, `Organization Type` == "501(c)(4)")
  } else if (org == "Other Nonprofits") {
    data <- dplyr::filter(data, `Organization Type` == other_orgs)
  }
  return(data)
}