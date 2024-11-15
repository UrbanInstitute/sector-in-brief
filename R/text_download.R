# Text for data download page
download_title <- "Create Custom 990 Panel Data Sets "
download_subtitle <- htmltools::div(
  htmltools::HTML(sprintf("<p>This data download tool allows you to easily assemble panel data sets as .csv files from the NCCS Core Data Series, containing selected variables from the IRS’ %s Extracts for Form 990 and 990-EZ. The Core series includes nonprofits with over $50,000 in annual gross receipts in the United States since 1989.</p>", soi_link)),
  htmltools::p(
    "Urban’s National Center for Charitable Statistics (NCCS) is the only nonprofit data repository that has cleaned, processed, and published nonprofit tax returns going back to 1989. Using Internal Revenue Service (IRS) data files, NCCS standardizes names, data types, and definitions for all variables across the various iterations of the IRS Form 990. NCCS data links tax records from every nonprofit filed between 1989 to 2022 in a single time-series panel, complete with geocoding to the Census tract and block levels for easy filtering. These features increase the fidelity of NCCS data sets, allowing for accurate mapping of records to census units at all levels of granularity."
  ),
  htmltools::p(
    "Request your customized panel data set and receive it by email. Required sections are denoted with an asterisk *"
  )
)

download_formtype_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "NCCS cleans and harmonizes data from two versions of the paper-filed IRS Form 990: the full Form 990 and the reduced shortened Form 990-EZ."
    ),
    htmltools::p(
      "You can select one of two datasets: “Form 990 Filers” or “Form 990 + 990-EZ Filers.”"
    )
  )

download_geo_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "NCCS data are geocoded to the location of each nonprofit based on the addresses submitted to the IRS in the Form 990."
    )
  )

download_date_para <-
  htmltools::div(
    class = "form-text",
    htmltools::p(
      "Tax years are the 12-month period beginning in a given calendar year that nonprofits use to calculate their annual financial statements. Note: If you select 2022 data, the dataset will be incomplete because the IRS is still in the process of releasing full tax records for tax year 2022."
    )
  )

download_fields_para <- htmltools::div(
  class = "form-text",
  htmltools::HTML("<p>Each variable comes from the individual parts of a Form 990. The 990-EZ consists of 5 parts and full Form 990 consists of 10 parts. To learn more about the variable choices, view the <a href='https://www.irs.gov/pub/irs-pdf/f990.pdf'>2023 Form 990</a> here</p>")
)

var_choices_990 <- list(
  "Program Service Accomplishments - Information on the major programs and services" = "03",
  "Required Schedules - Schedules required by the IRS" = "04",
  "Statements - Tax compliance statements reported to the IRS" = "05",
  "Governance - Information on the board of directors and governance structure" = "06",
  "Compensation - Compensation for key individuals reported to the IRS" = "07",
  "Revenue Statement - A breakdown of revenue sourced reported to the IRS" = "08",
  "Functional Expenses - An accounting of all expenses reported to the IRS." = "09",
  "Balance Sheet - An accounting of asssets and liabilities." = "10",
  "Public Charity Status - Information on the organization's public charity status" = "00",
  "Reporting - Information on how the nonprofit reports its financial statements" = "11"
)

var_choices_990ez <- list(
  "Program Service Accomplishments - Information on the major programs and services" = "03",
  "Required Schedules - Schedules required by the IRS" = "04",
  "Statements - Tax compliance statements reported to the IRS" = "05",
  "Governance - Information on the board of directors and governance structure" = "06",
  "Balance Sheet - An accounting of asssets and liabilities." = "10",
  "Public Charity Status - Information on the organization's public charity status" = "00"
)

usethis::use_data(
  download_title,
  download_subtitle,
  download_formtype_para,
  download_geo_para,
  download_date_para,
  var_choices_990,
  var_choices_990ez,
  internal = TRUE,
  overwrite = TRUE
)