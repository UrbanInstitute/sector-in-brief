# Script to load internal data for dashboard
# name page_section
library(reactable)
library(usethis)

welcome_title <- htmltools::h1(
  class = "text-3xl",
  "Welcome to the Nonprofit Sector-In-Brief Explorer",
  htmltools::p(
    class = "text-3xl-cyan",
    "A 990 Data Tool from the National Center for Charitable Statistics"
  )
)

welcome_subtitle <- htmltools::p(
  class = "leading-relaxed",
  "Visualize and download public data on nonprofits from 1989 through the present"
)

welcome_para_1 <- htmltools::p(
  class = "subheader",
  "Nonprofits—organizations provide societal benefits rather than distributing profits to private individuals—across the country play a central role in civil society. They offer a broad range of programs and services that meet basic needs, improve quality of life, and strengthen democracy.
Each year, nonprofits complete the Internal Revenue Service 990 Tax Form and associated files, disclosing information to ensure the sector remains transparent and accountable to the public."
)

welcome_para_2 <- htmltools::p(
  class = "subheader",
  "Urban Institute’s National Center for Charitable Statistics (NCCS) makes these large and difficult to navigate datasets accessible to illuminate broad trends in the nonprofit sector."
)

welcome_para_3 <- htmltools::p(
  class = "subheader",
  "The Nonprofit Sector-in-Brief Explorer allows users to see high-level nonprofit data trends over more than three decades, focus in on a specific time period, or drill down into specific communities or segments of the sector for localized insight."
)

welcome_visual_header <- htmltools::h1(class = "header--md", "Visualize")

welcome_visual_para <-
  htmltools::p(
    class = "subheader",
    htmltools::HTML(
      "Access and export graphs and tables of the latest trends in the number of nonprofits, nonprofit financials, private foundation grantmaking, and donor advised funds by organization type, subsector, geography, asset size, and time period using Urban’s NCCS data."
    )
  )

welcome_download_header <- htmltools::h1(class = "header--md", "Download")

welcome_download_para <- htmltools::p(
  class = "subheader",
  "Assemble custom panel data sets for download from NCCS's archive of cleaned and harmonized Form 990 data (the NCCS Core) and Business Master Files. Our data sets contain standardized names, data types, and definitions for all variables across the various iterations of the IRS Form 990. We have also linked tax records from every nonprofit filed between 1989 to 2022 in a single time-series panel, complete with geocoding to the Census tract and block levels for easy filtering."
)

download_title <- "Assemble Custom 990 Panel Data Sets"
download_subtitle <- "Urban’s National Center for Charitable Statistics (NCCS) is the only Internal Revenue Service (IRS) 990 data provider that has cleaned, processed, and published nonprofit tax returns going back to1989. This data download tool allows you to easily assemble panel data sets with data from tax filings made by nonprofits with over $50,000 in annual gross receipts in the United States since 1989, filtered by organization type, asset size, subsector and census geographic units."

download_formtype_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "NCCS cleans and harmonizes data from two versions of the Form 990: the full Form 990 and the reduced Form 990-EZ. Since 2012, nonprofits with assets less than $200,000 and gross receipts less than $500,000 have had the option to file the Form 990-EZ, which is a shortened version of the Form 990, and does not require a breakdown of every source of revenues and expenses incurred by a nonprofit."
    ),
    htmltools::p(
      "You can select one of two datasets: “Form 990 filers” or “Form 990 + 990-EZ filers."
    ),
    htmltools::HTML(
      "<ul>
          <li>If you select the Form 990 option, you will receive data from nonprofits that file the full Form 990. This version includes more variables, such as a statement of functional expenses, but fewer organizations. The panel is available from 2012 to 2022.</li>
          <li>If you select the Form 990 + Form 990-EZ option, you will receive data from nonprofits that file the full Form 990 or the Form 990-EZ. This dataset contains a larger number of organizations but fewer variables. This series is available from 1989 to 2022.</li>
       </ul>"
    )
  )

form_data <- tibble::tribble(
  ~Option, ~Data_Source, ~Variable_Availability, ~Year_Availability,
  "Form 990", "Only nonprofits that file the full 990", "All variables are available.", "1989-2022",
  "Form 990 + Form 990-EZ", "Nonprofits that file the full Form 990 or the Form 990-EZ", "Only variables that are in both versions of the form are available.", "2012-2022"
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
      width = 150
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

download_formtype_qn <- htmltools::div(
  class = "form-header",
  "Which form(s) are you interested in?"
)

download_orgtype_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "Filter your data set by organization type, subsector, and asset size."
    ),
    htmltools::p(
      "Organization type: Nonprofits can apply for exemption from federal income tax through Section 501c of the tax code. This Section defines different types of tax-exempt organizations according to their purpose and operations. We use this classification to create the organization type variable"
    ),
    htmltools::p(
      "Subsector: We use organizations’ National Taxonomy of Exempt Entities (NTEE) codes to assign nonprofits to subsectors, such as arts, education, health, and environment."
    ),
    htmltools::p(
      "Asset size: We have grouped organizations into five asset size brackets based on the total assets reported in the Form 990/Form 990-EZ."
    )
  )

download_geo_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "Filter your data set by geography."
    ),
    htmltools::p(
      "NCCS data are geocoded to the location of each nonprofit based on the addresses they submitted to the IRS. You can filter your selections by US Census region, state, county, metropolitan area, and micropolitan area."
    )
  )
download_geo_qn <- htmltools::div(class = "form-header", "What geography(ies) are you interested in?")
download_date_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "Filter your data set by tax years."
    ),
    htmltools::p(
      "Tax years are the 12-month period beginning in a given calendar year that nonprofits use to calculate their annual financial statements. The IRS is still in the process of releasing full tax records for tax year 2022, thus our 2022 data is incomplete and will be updated when this data becomes available from the IRS."
    )
  )

download_fields_para <- htmltools::div(
  class = "form-text",
  htmltools::p(" Choose the fields to include in your data set."),
  htmltools::p("By default, all data requests come with organizational information such as Employer Identification Number (EIN), Name, Address, Tax Year, Census geographies and FIPS codes. Choose which data you want in your file by adding groups of variables that correspond to Form 990 sections (revenue variables, expense variables, etc.). You can access the 2023 990 version here: https://www.irs.gov/pub/irs-pdf/f990.pdf ")
)

usethis::use_data(
  welcome_title,
  welcome_subtitle,
  welcome_para_1,
  welcome_para_2,
  welcome_para_3,
  welcome_visual_header,
  welcome_visual_para,
  welcome_download_header,
  welcome_download_para,
  download_title,
  download_subtitle,
  download_formtype_para,
  download_table,
  download_formtype_qn,
  download_orgtype_para,
  download_geo_para,
  download_geo_qn,
  download_date_para,
  download_fields_para,
  internal = TRUE,
  overwrite = TRUE
)

