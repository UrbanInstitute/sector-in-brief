# Text for data download page
download_title <- "Create Custom 990 Panel Data Sets "
download_subtitle <- htmltools::div(
    htmltools::tagList(
    htmltools::p(
      "This feature allows you to easily assemble panel datasets as .csv files from the National Center for Charitable Statistics (NCCS) Core Data Series, which contains selected variables from the IRS's ",
      htmltools::a(href = soi_link, "Statistics of Income extracts"),
      " for Forms 990 and 990-EZ. The Core Series includes nonprofits with over $50,000 in annual gross receipts in the United States since 1989."
    ),
    htmltools::p(
      "NCCS is the only nonprofit data repository that has cleaned, processed, and published nonprofit tax returns going back to 1989. Using IRS data files, NCCS standardizes names, data types, and definitions for all variables across the various iterations of IRS Form 990. NCCS data link available tax records from every nonprofit filed since 1989 in a single time-series panel, complete with geocoding (mapping each tax record to a latitude and longitude) to the census tract and block levels for easy filtering. These features allow for accurate mapping of NCCS data to all levels of geography."
    ),
    htmltools::p(
      "Request your customized panel dataset and receive it by email. Required sections are denoted with an asterisk (*)."
    )
  )
)

download_geo_para <- htmltools::p(
      "Each nonprofit is geocoded (mapped to a latitude and longitude) based on 
      the addresses submitted to the IRS in Forms 990."
    )

download_date_para <- htmltools::p(
      "Tax years are the periods nonprofits use to calculate their financial statements. They span January to December like a typical calendar year but lag calendar years by two years, on average. Note: If you select 2022 data, the dataset will be incomplete because the IRS is still releasing full tax records for that year."
    )

download_fields_para <- htmltools::p(
  "Each variable comes from the individual parts of a Form 990. Form 990-EZ has 5 parts and the full Form 990 has 10. To learn more about the variable choices, view the ",
  htmltools::a(href = "https://www.irs.gov/pub/irs-pdf/f990.pdf", "2023 Form 990 and Form 990-EZ:")
)

var_choices_990 <- list(
  "Program Service Accomplishments: Information on the major programs and services" = "03",
  "Required Schedules: Schedules required by the IRS" = "04",
  "Statements: Tax-compliance statements reported to the IRS" = "05",
  "Governance: Information on the board of directors and governance structure" = "06",
  "Compensation: Compensation for key individuals reported to the IRS" = "07",
  "Revenue Statement: A breakdown of revenue sourced reported to the IRS" = "08",
  "Functional Expenses: An accounting of all expenses reported to the IRS." = "09",
  "Balance Sheet: An accounting of asssets and liabilities." = "10",
  "Public Charity Status: Information on the organization's public charity status" = "00",
  "Reporting: Information on how the nonprofit reports its financial statements" = "12",
  "Lobbying: information on lobbying activities" = "04",
  "Reconciliation: Reconciliation of net assets" = "11"
)

var_choices_990ez <- list(
  "Program Service Accomplishments: Information on the major programs and services" = "03",
  "Required Schedules: Schedules required by the IRS" = "04",
  "Statements: Tax compliance statements reported to the IRS" = "05",
  "Governance: Information on the board of directors and governance structure" = "06",
  "Balance Sheet: An accounting of asssets and liabilities." = "10",
  "Public Charity Status: Information on the organization's public charity status" = "00"
)

usethis::use_data(
  download_title,
  download_subtitle,
  download_geo_para,
  download_date_para,
  var_choices_990,
  var_choices_990ez,
  internal = TRUE,
  overwrite = TRUE
)