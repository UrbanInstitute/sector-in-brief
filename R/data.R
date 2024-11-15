# Internal data for dashboard
library(reactable)
library(usethis)

form_data <- tibble::tribble(
  ~Option, ~Data_Source, ~Variable_Availability, ~Year_Availability,
  '<a href="https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv">Form 990 Filers</a>', "1,654,300 Nonprofits", "All 547paper-form variables", "2012-2022",
  '<a href="https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv">Form 990 + Form 990-EZ Filers</a>', "2,765,384 nonprofits", "236 variables that are in the EZ version, which also appear in the Form 990", "1989-2022"
)

download_table <- reactable::reactable(
  form_data,
  theme = reactableTheme(
    borderColor = "#ddd",
    stripedColor = "#f6f8fa",
    highlightColor = "#f0f5f9",
    cellPadding = "12px"
  ),
  defaultColDef = reactable::colDef(
    align = "left",
    minWidth = 150,
    headerStyle = list(
      background = "#f5f5f5",
      fontWeight = "bold",
      borderBottom = "2px solid #ddd"
    )
  ),
  columns = list(
    Option = colDef(
      width = 150,
      name = "Form Type",
      html = TRUE
    ),
    Data_Source = reactable::colDef(
      width = 250,
      name = "Number of Nonprofits"
    ),
    Variable_Availability = colDef(
      width = 250,
      name = "Variables"
    ),
    Year_Availability = colDef(
      width = 150,
      name = "Years"
    )
  ),
  striped = TRUE,
  highlight = TRUE,
  bordered = TRUE,
  resizable = TRUE,
  defaultPageSize = 10
)

irs.data.sets <- "•	IRS Statistics Of Income Extracts contain selected financial variables from both paper and electronic filings of the Form 990, Form 990-EZ and Form 990-PF <br> •	The IRS 990 Series download page contains the full filing for each e-filed From 990, Form 990-EZ, Form 990-PF and Form 990-N"
nccs.data.sets <- "•	The NCCS Core  Series contains processed panel data from the IRS’ Statistics Of Income extracts for the Form 990, Form 990-EZ and Form 990-PF. <br> •	The NCCS Efile catalog contains processed e-filed tax records for Form 990 and Form 990-EZ only"


data_sources <- tibble::tribble(
  ~Form, ~Filer, ~Data, ~NCCS_data,
  "990", "Nonprofits with gross receipts greater than $200,000, or total assets greater than $500,000", irs.data.sets, nccs.data.sets,
  "990-EZ", "Nonprofits with gross receipts less than $200,000 and total assets less than $500,000", irs.data.sets, nccs.data.sets,
  "990-PF", "Private foundations and charitable trusts", irs.data.sets, nccs.data.sets,
  "990-N", "Nonprofits with gross receipts less than $50,000", irs.data.sets, "•	The NCCS 990-N ePostcard catalog contains data from Form 990N (this data sets is not included in the dashboard because it has not been harmonized)."
)

data_source_table <- reactable::reactable(
  data_sources,
  theme = reactableTheme(
    borderColor = "#ddd",
    stripedColor = "#f6f8fa",
    highlightColor = "#f0f5f9",
    cellPadding = "12px"
  ),
  defaultColDef = reactable::colDef(
    align = "left",
    minWidth = 150,
    headerStyle = list(
      background = "#f5f5f5",
      fontWeight = "bold",
      borderBottom = "2px solid #ddd"
    )
  ),
  columns = list(
    Form = colDef(
      name = "Form",
      html = TRUE
    ),
    Filer = reactable::colDef(
      name = "Who Must File?",
      html = TRUE
    ),
    Data = colDef(
      name = "IRS Data Set(s)",
      html = TRUE
    ),
    NCCS_data = colDef(
      name = "NCCS Data Set(s)",
      html = TRUE
    )
  ),
  striped = TRUE,
  highlight = TRUE,
  bordered = TRUE,
  resizable = TRUE,
  defaultPageSize = 10
)

usethis::use_data(
  download_table,
  data_source_table,
  internal = TRUE,
  overwrite = TRUE
)

