# Text on welcome page
library(usethis)

welcome_title <- htmltools::h1(
  class = "text-3xl",
  "Welcome to the Nonprofit Sector-In-Brief Explorer",
  htmltools::p(
    class = "text-3xl-cyan",
    "A Form 990 Tool from the National Center for Charitable Statistics"
  )
)

welcome_subtitle <- htmltools::p(
  class = "leading-relaxed",
  "Visualize and download public data on nonprofits from 1989 through the present"
)

welcome_para_1 <- htmltools::p(
  class = "subheader",
  "Nonprofits across the country play a central role in civil society by offering a broad range of programs and services that meet basic needs, improve quality of life, and strengthen democracy."
)

welcome_para_2 <- htmltools::p(
  class = "subheader",
  "Each year, nonprofits with over $50,000 in annual gross receipts complete the Internal Revenue Service 990 Tax Form and associated files, disclosing information to ensure the sector remains transparent and accountable to the public."
)

welcome_para_3 <- htmltools::p(
  class = "subheader",
  "Urban Institute’s National Center for Charitable Statistics (NCCS) cleans, processes, and publishes these complex public datasets accessible to support nonprofit research that strengthens the public’s understanding of the field."
)

welcome_para_4 <- htmltools::p(
  class = "subheader",
  "Powered by NCCS data, the Nonprofit Sector in Brief Explorer illuminates trends in the nonprofit sector over more than three decades. Users can drill down on a specific type of nonprofit organization, time period, size, subsector, or geography for localized insight."
)

welcome_visual_header <- htmltools::h1(class = "header--md", "Visualize")

welcome_visual_para <-
  htmltools::p(
    class = "subheader",
    "Access and export graphs and tables with the latest figures on nonprofit numbers, financials, private foundation grantmaking, and donor advised funds."
  )

welcome_download_header <- htmltools::h1(class = "header--md", "Download")

welcome_download_para <- htmltools::p(
  class = "subheader",
  "Assemble custom panel data sets for download from NCCS's archive of cleaned and harmonized Form 990 data (the NCCS Core) and Business Master Files."
)

welcome_credits <- htmltools::div(
  class = "footer_text",
  htmltools::p(
    "The Nonprofit Sector in Brief Data Explorer makes public data on nonprofits from 1989 to the present available to visualize and download."  
  ),
  htmltools::p("Research - Jesse Lecy, Hannah Martin, Laura Tomasko"),
  htmltools::p("Development - Thiyaghessan Poongundranar"),
  htmltools::p("Design - Thiyaghessan Poongundranar")
)

welcome_about <- htmltools::div(
  class = "footer_text",
  htmltools::HTML(
    "<p>This project is funded by the National Center for Charitable Statistics (NCCS). The NCCS data used in this data explorer contains standardized names, data types, and definitions for all variables across the various iterations of the IRS Form 990. NCCS data links tax records from every nonprofit filed between 1989 to 2022 in a single time-series panel, complete with geocoding to the Census tract and block levels for easy filtering. For more information, see the <a href='https://nccs.urban.org/'>NCCS Website</a></p>"
  )
)

usethis::use_data(
  welcome_title,
  welcome_subtitle,
  welcome_para_1,
  welcome_para_2,
  welcome_para_3,
  welcome_para_4,
  welcome_visual_header,
  welcome_visual_para,
  welcome_download_header,
  welcome_download_para,
  welcome_credits,
  welcome_about,
  overwrite = TRUE,
  internal = TRUE
)