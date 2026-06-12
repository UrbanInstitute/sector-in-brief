# Title + subtitle copy for the Custom Panel Datasets tab. The form
# itself lives in R/data_download_dashboard.R::dataRequestUI().
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

# Query-mode (ADR 0029) chooser copy. CORE = filing-level 990 data; BMF =
# the org-level IRS Business Master File registry (incl. non-filers), with
# no financials. Rich (HTML) radio labels so the trade-off is legible.
bmf_link <- "https://nccs.urban.org/nccs/datasets/bmf/"
download_source_label <- htmltools::tags$b("What kind of data do you want? *")
# Card content: a bold title (.ds-title) + a normal-weight description
# (.ds-desc), styled by .download-source-toggle in www/sib_style.css. Copy is
# kept tight so the two cards read at a glance.
download_source_corename <- htmltools::HTML(paste0(
  '<span class="ds-title">990 filings</span>',
  '<span class="ds-desc">Financial and operational data reported by ',
  'organizations that filed a Form 990, 990-EZ, or 990-PF.</span>'
))
download_source_bmfname <- htmltools::HTML(paste0(
  '<span class="ds-title">BMF registry</span>',
  '<span class="ds-desc">Every registered nonprofit, including those that ',
  'have never filed a 990 &mdash; kept current through 2026. Names and ',
  'demographics (location, subsector, organization type), but ',
  '<b>no financials</b>. <a href="', bmf_link,
  '" target="_blank" rel="noopener">Learn more about the BMF</a>.</span>'
))
# BMF date step: active_years is a lifespan-overlap filter, NOT a tax year.
# The registry is current (through 2026) — unlike CORE's ~2-year filing lag —
# which is the point of BMF for "how many are active now" questions.
download_active_para <- htmltools::p(
  "Select the period during which an organization was active in the IRS ",
  "registry, which is current through 2026. This returns organizations active ",
  "at any point in the range (based on their first and last year in the ",
  "Business Master File); for a current snapshot, choose the most recent year. ",
  "It is not a tax-filing year, and the registry carries no financial data."
)

download_fields_para <- htmltools::p(
  "Choose the variables (columns) to include in your extract, grouped by",
  "identification, classification, geography, and finances. Every record",
  "includes the organization's EIN. To learn more about the underlying",
  "fields, view the ",
  htmltools::a(href = "https://www.irs.gov/pub/irs-pdf/f990.pdf", "Form 990 and Form 990-EZ"),
  ". The selectable columns are defined by the dashboard's column catalog",
  "(R/download_columns.R)."
)

