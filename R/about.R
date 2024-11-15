about <- function() {
  about <- bslib::nav_panel(
    title = "About",
    about_title,
    htmltools::br(),
    customization,
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(title = htmltools::HTML("<b>Data Sources</b>"), data_sources)
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>Data Methodologies</b>"),
            bslib::accordion(
              open = FALSE,
              bslib::accordion_panel(
                title = htmltools::HTML("<b>Data Harmonization</b>"),
                "Data harmonization is the process of combining multiple data sets with inconsistent variable names and data types into a single, standardized data set. This allows for easier analysis and comparisons of the data."
              ),
              bslib::accordion_panel(
                title = htmltools::HTML("<b>Geocoding</b>"),
                "Geocoding is the process of converting address information into precise geographic coordinates. It first involves cleaning and standardizing addresses into a consistent format. Next, the addresses are passed through a geocoder that assigns each one a latitude, longitude, and other spatial references that can be mapped to Census geographic units such as tracts, blocks and zip codes."
              )
            )
          )
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>Notable Dataset Variations</b>"),
            htmltools::p(
              class = "subheader",
              "Since its establishment, NCCS has maintained a comprehensive database of nonprofit organizations based on Internal Revenue Service (IRS) data. Over time, both NCCS data collection protocols and IRS reporting requirements have evolved, leading to variations in dataset composition and year-over-year trends. Below are key methodological changes that explain notable variations in longitudinal analyses. Users should consider these methodological shifts when conducting trend analyses or drawing conclusions from year-over-year comparisons."
            ),
            bslib::accordion(
              open = FALSE,
              bslib::accordion_panel(
                title = htmltools::HTML("<b>1994-1995 Expansion of Coverage</b>"),
                "Prior to 1994, NCCS data collection was limited to nonprofit organizations exceeding specific revenue thresholds. Beginning in 1995, NCCS expanded its scope to include tax records from all IRS-filing nonprofit organizations, resulting in a substantial increase in our data archives’ coverage."
              ),
              bslib::accordion_panel(
                title = htmltools::HTML("<b>2008-2009 IRS Form Modernization</b>"),
                "In 2008 the IRS implemented significant modifications to the Form 990 and introduced the Form 990-EZ and 990N. These changes substantially expanded reporting requirements and compliance, leading to a marked increase in both the number of reporting organizations and available financial data between 2008 and 2009. Any sharp increases in nonprofit counts or financial metrics during this period should be interpreted within this context of expanded reporting requirements rather than actual sector growth."
              ),
              bslib::accordion_panel(
                title = htmltools::HTML("<b>2016-2018 Missing Data for Private Foundations</b>"),
                "The IRS has not released the Statistics of Income Extracts (SOI) for Form 990-PFs for tax years 2016, 2017 and 2018. Data points for private foundations during these years are connected with dotted lines to indicate their missingness."
              )
            )
          )
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>Frequently Asked Questions</b>"),
            bslib::accordion(
              open = FALSE,
              bslib::accordion_panel(
                title = htmltools::HTML("<b>Why can’t I visualize data for individual nonprofits?</b>"),
                "The Nonprofit Sector in Brief Explorer focuses on providing a sector-wide overview of the nonprofit sector. Our tool is designed for research on trends impacting the sector as a whole instead of the activities of individual organizations."
              ),
              bslib::accordion_panel(
                title = htmltools::HTML(
                  "<b>What is the difference between tax years and regular calendar years?</b>"
                ),
                "Tax years refer to the accounting period for which a tax record is filed. For example, it is not uncommon for nonprofits to file taxes for the year 2022 in 2024. This tax filing is assigned a calendar year of 2024 and a tax year of 2022 by NCCS to prevent confusion."
              ),
              bslib::accordion_panel(
                title = htmltools::HTML(
                  "<b>I want to download full panel sets from the Download Data page. Why do I have to use the Download Data feature to download full panel data sets?</b>"
                ),
                "NCCS’ panel data sets contain over 10 GB of data, thus delivering them directly through the dashboard would result in excessively large downloads. Recognizing that users want to see the raw data used to create visualizations on the Visualize Data page, the tool provides small, processed tables that can be quickly and easily downloaded, leaving larger data sets to the data download tool which uses the power of AWS cloud technologies to process large requests for full panel data."
              ),
              bslib::accordion_panel(
                title = htmltools::HTML(
                  "<b>I have some feedback on the dashboard, who should I contact?</b>"
                ),
                htmltools::HTML(
                  "Feedback can be submitted <a href='https://urban.co1.qualtrics.com/jfe/form/SV_2fRHTFJxNzD4GcS'>here</a>"
                )
              )
            )
          )
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>Project Credits</b>"),
            credits
          )
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>References</b>"),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Davis, C. & Lecy, J. (2023). <a href='https://urbaninstitute.github.io/nccs/datasets/census/'>Introducing the geocrosswalk Framework for Seamless Integration of Census Panels into Studies</a>."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Internal Revenue Service. (2024, October 24). <a href='https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf'>Exempt organizations business master file extract</a> (EO BMF). IRS.gov."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Internal Revenue Service. (2024, August 29). <a href='https://www.irs.gov/statistics/soi-tax-stats-purpose-and-function-of-statistics-of-income-soi-program'>SOI tax stats - purpose and function of statistics of income (SOI) program</a>. IRS.gov."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Internal Revenue Service. (2024, May 9). <a href='https://www.irs.gov/charities-non-profits/charitable-organizations/donor-advised-funds'>Donor advised funds</a>. IRS.gov."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Internal Revenue Service. (2023). <a href='https://www.irs.gov/charities-non-profits/charitable-organizations/private-foundations'>Private foundations</a>. IRS.gov."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Internal Revenue Service. (2023). <a href='https://www.irs.gov/pub/irs-pdf/f990.pdf'>Form 990: Return of organization exempt from income tax</a> [PDF]. IRS.gov."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "Urban Institute. (2020, August 31). <a href='https://urban-institute.medium.com/choosing-a-geocoder-for-the-urban-institute-86192f656c5f'>Choosing a geocoder for the Urban Institute</a>. Medium."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "U.S. Census Bureau. (2023, July 25). <a href='https://www.census.gov/programs-surveys/metro-micro/about.html'>About metropolitan and micropolitan statistical areas</a>."
              )
            ),
            htmltools::p(
              class = "subheader",
              htmltools::HTML(
                "U.S. Census Bureau. (n.d.). <a href='https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf'>United States Census Bureau regions and divisions with state FIPS codes</a>."
              )
            )
          )
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>Glossary</b>"),
            htmltools::p(class = "subheader", htmltools::HTML(
              sprintf(
                "<b>BMF</b> – IRS %s. A cumulative file updated monthly by the IRS containing the most recent information the IRS has for all tax-exempt organizations (IRS, 2024).",
                bmf_link
              )
            )),
            htmltools::p(class = "subheader", htmltools::HTML("<b>DAF</b> – Donor Advised Fund")),
            htmltools::p(
              class = "subheader",
              htmltools::HTML("<b>IRS</b> – Internal Revenue Service")
            ),
            htmltools::p(class = "subheader", htmltools::HTML(
              sprintf(
                "<b>NCCS</b> - The %s, a research and data resource of the Urban Institute.",
                nccs_full_link
              )
            )),
            htmltools::p(class = "subheader", htmltools::HTML(
              sprintf(
                "<b>NTEE</b> - %s system is used by the IRS and NCCS to classify nonprofit organizations.",
                ntee_link
              )
            )),
            htmltools::p(class = "subheader", htmltools::HTML(
              sprintf(
                "<b>SOI</b> - %s. The IRS SOI Program is responsible for publishing statistics compiled from tax returns (IRS, 2024).",
                soi_link
              )
            ))
          )
        )
      )
    ),
    htmltools::br(),
    htmltools::div(
      class = "banner-light",
      htmltools::div(
        class = "flex-box--column",
        bslib::accordion(
          open = FALSE,
          bslib::accordion_panel(
            title = htmltools::HTML("<b>Citing This Tool</b>"),
            htmltools::p(
              class = "subheader",
              "Urban Institute. (2024, Nov 15), Nonprofit Sector in Brief Data Explorer"
            )
          )
        )
      )
    ),
    htmltools::br()
  )
  return(about)
}