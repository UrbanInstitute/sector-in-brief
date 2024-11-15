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
  htmltools::HTML("The National Center for Charitable Statistics (NCCS) at the Urban Institute processes and publishes comprehensive nonprofit sector data to advance research and deepen public understanding of charitable organizations. NCCS data encompasses the entire spectrum of tax-exempt organizations, which includes 501(c)3 public charities and private foundations, 501(c)4 organizations, and all the additional <a href='https://www.irs.gov/charities-non-profits/exempt-organization-types'>501(c) classifications and subsectors</a>.")
)

welcome_para_3 <- htmltools::p(
  class = "subheader",
  "The Nonprofit Sector in Brief Data Explorer aggregates NCCS data to illuminate sector-wide trends in nonprofits over more than three decades. It allows users to view data and trends by organization type, subsector, asset size, geography, and time period rather than by a specific organization. Looking across a range of organizations provides a snapshot into the state of the nonprofit sector as told through data released by the IRS."
)

welcome_para_4 <- htmltools::p(
  class = "subheader",
  "This data tool offers two ways to explore NCCS data for all nonprofits or for a customized subset of nonprofits:"
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
  overwrite = TRUE,
  internal = TRUE
)