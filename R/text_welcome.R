# Text on welcome page
library(usethis)

welcome_title <- htmltools::h2(
  "Nonprofit Sector-In-Brief Data Explorer",
  htmltools::h2(
    class = "h2-blue",
    "A Dashboard from the National Center for Charitable Statistics"
  )
)

welcome_subtitle <- htmltools::p(
  "Visualize and download public data on nonprofits from 1989 through the present"
)

welcome_para_1 <- htmltools::p(
  "Nonprofits across the country play a central role in civil society by
offering a broad range of programs and services that meet basic needs,
improve quality of life, and strengthen democracy."
)

welcome_para_2 <- htmltools::p(
  "Each year, nonprofits are required to complete the Internal Revenue
Service (IRS) 990 Tax Form and associated files, disclosing information
to ensure the sector remains transparent and accountable to the public.
IRS data provide rich information about the nonprofit sector but can be
challenging to access and understand."
)

welcome_para_3 <- htmltools::p(
  "Since 1996,   the Urban Institute's National Center for Charitable Statistics
  (NCCS) has processed and published comprehensive data on all tax-exempt 501(c)
  classifications and subsectors, including 501(c)(3) public charities and 
  private foundations and 501(c)(4) organizations, to advance research and 
  deepen understanding of nonprofits. Through its Nonprofit Sector in Brief 
  report series, NCCS shed light on the size and finances of nonprofits."
)
  

welcome_para_4 <- htmltools::p(
  "Now, the Nonprofit Sector-in-Brief Data Explorer aggregates more than three
  decades of NCCS data to illuminate trends in the nonprofit sector. The tool
  currently provides data up to 2021 and will be continuously updated with the most recent available data. View data and trends by organization type, subsector, asset size, geography, and time period to see a snapshot of the nonprofit sector as seen through IRS data."
)

welcome_para_5 <- htmltools::p(
  "There are two ways to explore NCCS data in this tool:"
)

welcome_visual_header <- shiny::actionLink(
  inputId = "visual_link",
  label = htmltools::h4(class = "actionlink", "Data Visualizations")
)

welcome_visual_para <-
  htmltools::p(
    "Access and export graphs and tables with the latest figures on nonprofit numbers, financials, private foundation grantmaking, and donor advised funds."
  )

welcome_download_header <- shiny::actionLink(
  inputId = "download_link",
  label = htmltools::h4(class = "actionlink", "Custom Panel Datasets")
)

welcome_download_para <- htmltools::p(
  "Assemble custom panel data sets for download from NCCS's archive of cleaned and harmonized Form 990 data (the NCCS Core) and Business Master Files."
)

credits <- htmltools::div(
  class = "flex-box__column",
  htmltools::h3("Project Credits"),
  htmltools::tagList(
    htmltools::p(
      class = "base",
      htmltools::tags$b("RESEARCH"), 
      " Thiyaghessan Poongundranar, Jesse Lecy, Hannah Martin and Laura Tomasko"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("DESIGN"), 
      " Thiyaghessan Poongundranar"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("DEVELOPMENT"), 
      " Thiyaghessan Poongundranar, Christina Prinvil and Erika Tyagi"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("EDITING"), 
      " Rachel Kenney and Zach VeShancey"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("TECHNICAL CONSULTATION"), 
      " Jessica Kelly, Sybil Mendonca, Silke Taylor, Alena Stern and Judah Axelrod"
    )
  )
)

about <- htmltools::div(
  class = "flex-box__column",
  htmltools::h3("About This Project"),
  htmltools::p(
    class = "base",
    "This project is funded by the National Center for Charitable Statistics (NCCS) at the Urban Institute. NCCS processes and publishes comprehensive nonprofit -sector data to advance research and deepen public understanding of charitable organizations."
  ),
  htmltools::p(
    class = "base",
    "The NCCS data contain standardized names, data types, and definitions for all variables across the different IRS Form 990s. NCCS data links tax records from every nonprofit filed from 1989 to 2022    in a single time-series panel, complete with geocoding to the Census tract and block levels for easy filtering."
  ),
  htmltools::p(
    class = "base",
    list(
      "For more information, see the ",
      htmltools::a(
        href = "https://nccs.urban.org",
        "NCCS homepage"
      ),
      "."
    )
  )
)

usethis::use_data(
  welcome_title,
  welcome_subtitle,
  welcome_para_1,
  welcome_para_2,
  welcome_para_3,
  welcome_para_4,
  welcome_para_5,
  welcome_visual_header,
  welcome_visual_para,
  welcome_download_header,
  welcome_download_para,
  credits,
  about,
  overwrite = TRUE,
  internal = TRUE
)