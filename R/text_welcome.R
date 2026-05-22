# All static copy for the Welcome tab (R/welcome.R). Title,
# subtitle, intro paragraphs, the two "what's inside" sections, and
# the credits/about block at the bottom.

welcome_title <- htmltools::h2(
  "Nonprofit Sector In Brief Dashboard"
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
  "Each year, nonprofits are required to complete the Internal Revenue Service’s Form 990 and associated files, disclosing information to ensure the sector remains transparent and accountable to the public. IRS data provide rich information about the nonprofit sector but can be challenging to access and understand."
)

welcome_para_3 <- htmltools::p(
  "Since 1996, the Urban Institute's National Center for Charitable Statistics (NCCS) has processed and published comprehensive data on all tax-exempt 501(c) classifications and subsectors, including 501(c)(3) public charities and private foundations and 501(c)(4) organizations, to advance research and deepen understanding of nonprofits. Through its Nonprofit Sector in Brief report series, NCCS shed light on the size and finances of nonprofits."
)
  

welcome_para_4 <- htmltools::p(
  "Now, the Nonprofit Sector in Brief Dashboard aggregates more than three decades of NCCS data to illuminate trends in the nonprofit sector. The dashboard currently provides data up to 2021 and will be continuously updated with the most recent available data. View data and trends by organization type, subsector, size, geography, and time period to see a snapshot of the nonprofit sector as seen through IRS data."
)

welcome_para_5 <- htmltools::p(
  "There are two ways to explore NCCS data in this dashboard:"
)

welcome_visual_header <- shiny::actionLink(
  inputId = "visual_link",
  label = htmltools::h4(class = "actionlink", "Data Visualizations")
)

welcome_visual_para <-
  htmltools::p(
    "View and download charts and tables with the latest NCCS data on the number of nonprofits, nonprofit financials, private foundation grantmaking, and donor-advised funds."
  )

welcome_download_header <- shiny::actionLink(
  inputId = "download_link",
  label = htmltools::h4(class = "actionlink", "Custom Panel Datasets")
)

welcome_download_para <- htmltools::p(
  "Assemble custom panel datasets for download from NCCS's archive of cleaned and standardized Form 990 data (the NCCS Core) and Business Master Files."
)

credits <- htmltools::div(
  class = "flex-box__column",
  htmltools::h3("Project Credits"),
  htmltools::tagList(
    htmltools::p(
      class = "base",
      htmltools::tags$b("RESEARCH"), 
      " Thiyaghessan Poongundranar, Jesse Lecy, Hannah Martin, and Laura Tomasko"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("DESIGN"), 
      "Thiyaghessan Poongundranar, Laura Tomasko, Hannah Martin, Jesse Lecy, and Aleszu Bajak"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("DEVELOPMENT"), 
      " Thiyaghessan Poongundranar, Erika Tyagi, and Christina Prinvil"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("EDITING"), 
      " Rachel Kenney and Zach VeShancey"
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("TECHNICAL CONSULTATION"), 
      " Jessica Kelly, Sybil Mendonca, Silke Taylor, Alena Stern, and Judah Axelrod"
    )
  )
)

about <- htmltools::div(
  class = "flex-box__column",
  htmltools::h3("About This Project"),
  htmltools::p(
    class = "base",
    "This project is funded by the National Center for Charitable Statistics (NCCS) at the Urban Institute. NCCS processes and publishes comprehensive nonprofit sector data to advance research and deepen public understanding of charitable organizations."
  ),
  htmltools::HTML(
    '<p class="base">The NCCS data contain standardized names, data types, and definitions for all variables across the different IRS Form 990s. NCCS data links tax records from every nonprofit filed from 1989 to the present in a single time-series panel, complete with geocoding to the Census tract and block levels for easy filtering. For more information, see the NCCS <a href="https://nccs.urban.org">homepage</a>.</p>'
  ),
  htmltools::p(
    class = "base",
    htmltools::tags$b("Citing This Dashboard:"),
    "Nonprofit Sector In Brief Dashboard, Urban Institute, November 21, 2024, [https://urban-main.shinyapps.io/sector-in-brief/]."
  
  )
)

