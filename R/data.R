# Script to load internal data for dashboard
# name page_section

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
  internal = TRUE,
  overwrite = TRUE
)

