# Internal data for dashboard
library(reactable)
library(usethis)

form_data <- tibble::tribble(
  ~Option, ~Data_Source, ~Variable_Availability, ~Year_Availability,
  '<a href="https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv">Form 990 Filers</a>', "1,654,300 Nonprofits with over $50,000 in annual gross receipts", "All 547paper-form variables are available.", "2012-2022",
  '<a href="https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv">Form 990 + Form 990-EZ Filers</a>', "2,765,384 nonprofits with over $50,000 annual gross receipts", "236 variables that are in the EZ version, which also appear in the Form 990.", "1989-2022"
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
      html = TRUE
    ),
    Data_Source = reactable::colDef(
      width = 250,
      name = "Data Source"
    ),
    Variable_Availability = colDef(
      width = 250,
      name = "Variable Availability"
    ),
    Year_Availability = colDef(
      width = 150,
      name = "Year Availability"
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
  internal = TRUE,
  overwrite = TRUE
)

