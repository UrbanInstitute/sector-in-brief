# Single function to query organization types
orgtype_query <- function(data, org, other_orgs = NULL, orgvar = "Organization Type") {
  if (org == "501(c)(3) Public Charities"){
    data <- filter(data, !!sym(orgvar) == org)
  } else if (org == "501(c)(3) Private Foundations"){
    data <- filter(data, !!sym(orgvar) == org)
  } else if (org == "501(c)(4) Social Welfare Organizations") {
    data <- filter(data, !!sym(orgvar) == "501(c)(4)")
  } else if (org == "Other Nonprofits") {
    data <- filter(data, !!sym(orgvar) == other_orgs)
  }
  return(data)
}