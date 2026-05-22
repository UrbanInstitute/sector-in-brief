# Shared constants and reusable data objects loaded at package init:
#   - Link URLs to external resources (IRS, NCCS, Census, Qualtrics)
#   - `html_orgtype` — anchor tag reused in the org-type tooltip
#   - `navbar_title` — header img + branding for the page navbar
#   - `form_data` / `download_table` — IRS form-type comparison
#     reactable shown on the Custom Panel Datasets page
#   - `data_sources` / `data_source_table` — same shape, but for the
#     "Data Sources" accordion on the About page
#   - `irs.data.sets` / `nccs.data.sets` — strings reused in the
#     About page accordion content

library(reactable)

visual_link_page <- "Finances"
download_link_page <- "Custom Panel Datasets"

# URLs
ctype_desc_url <- "https://www.irs.gov/charities-non-profits/other-tax-exempt-organizations"
bmf_link <- "https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf"
ntee_link <- "https://www.irs.gov/pub/irs-tege/p4838.pdf"
soi_link <- "https://www.irs.gov/statistics/soi-tax-stats-annual-extract-of-tax-exempt-organization-financial-data"
tract_link <- "https://www2.census.gov/geo/pdfs/reference/GARM/Ch10GARM.pdf"
nccs_link <- "https://urbaninstitute.github.io/nccs/"
unified_bmf_link <- "https://urbaninstitute.github.io/nccs/datasets/bmf/"
core_link <- "https://lecy.github.io/nccs/datasets/core/"
daf_link <- "https://www.irs.gov/charities-non-profits/charitable-organizations/donor-advised-funds"
efile_link <- "https://lecy.github.io/nccs/datasets/efile/"
census_regions_link <- 'https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf'
census_crosswalks_link <- "https://urbaninstitute.github.io/nccs/datasets/census/"
geocoder_link <- "https://urban-institute.medium.com/choosing-a-geocoder-for-the-urban-institute-86192f656c5f"
qualtrics_link <- "https://urban.co1.qualtrics.com/jfe/form/SV_2fRHTFJxNzD4GcS"

# Reusable HTML Components
html_orgtype <- htmltools::a(
  "Section 501(c) of the Internal Revenue Code",
  href = ctype_desc_url
)

navbar_title <- htmltools::h4(
  htmltools::tags$img(src = "ui-logo-rgb-white.svg", height= "50px"),
  "National Center for Charitable Statistics"
)

form_data <- tibble::tribble(
  ~Option, ~Data_Source, ~Variable_Availability, ~Year_Availability,
  'Form 990 Filers [<a href="https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv">data dictionary link</a>]', "1,654,300 nonprofits", "All 547 paper-form variables", "2012-2022",
  'Form 990 + Form 990-EZ Filers [<a href="https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv">data dictionary link</a>]', "2,765,384 nonprofits", "236 variables in the EZ version, which also appear in the Form 990.", "1989-2022"
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

irs.data.sets <- "•	IRS Statistics Of Income extracts contain selected financial variables from both paper and electronic filings of the Form 990, Form 990-EZ, and Form 990-PF.<br>•	The IRS 990 series download page contains the full filing for each e-filed Form 990, Form 990-EZ, Form 990-PF, and Form 990-N."
nccs.data.sets <- "•	The NCCS Core Series contains processed panel data from the IRS’s Statistics of Income extracts for the Form 990, Form 990-EZ, and Form 990-PF.<br>•	The NCCS e-file catalog contains processed e-filed tax records for Form 990 and Form 990-EZ only."


data_sources <- tibble::tribble(
  ~Form, ~Filer, ~Data, ~NCCS_data,
  "990", "Nonprofits with gross receipts greater than $200,000, or
total assets greater than $500,000.", irs.data.sets, nccs.data.sets,
  "990-EZ", "Nonprofits with gross receipts less than or equal to $200,000, or
total assets less than or equal to $500,000 (these nonprofits can choose to file the full Form 990 instead).", irs.data.sets, nccs.data.sets,
  "990-PF", "Private foundations.", irs.data.sets, nccs.data.sets,
  "990-N", "Nonprofits with gross receipts less than or equal to $50,000 (these nonprofits can choose to file the full Form 990 instead).", irs.data.sets, "•	The NCCS 990-N ePostcard catalog contains data from Form 990-N (this dataset is not included in the dashboard because it has not been harmonized)."
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
      html = TRUE,
      style = JS("function(rowInfo, column, state) {
        const firstSorted = state.sorted[0]
        // Merge cells if unsorted or sorting by Data
        if (!firstSorted || firstSorted.id === 'Data') {
          const prevRow = state.pageRows[rowInfo.viewIndex - 1]
          if (prevRow && rowInfo.values['Data'] === prevRow['Data']) {
            return { visibility: 'hidden' }
          }
        }
      }")
    ),
    NCCS_data = colDef(
      name = "NCCS Data Set(s)",
      html = TRUE,
      style = JS("function(rowInfo, column, state) {
        const firstSorted = state.sorted[0]
        // Merge cells if unsorted or sorting by Data
        if (!firstSorted || firstSorted.id === 'NCCS_data') {
          const prevRow = state.pageRows[rowInfo.viewIndex - 1]
          if (prevRow && rowInfo.values['NCCS_data'] === prevRow['NCCS_data']) {
            return { visibility: 'hidden' }
          }
        }
      }")
    )
  ),
  striped = TRUE,
  highlight = TRUE,
  bordered = TRUE,
  resizable = TRUE,
  defaultPageSize = 10
)

