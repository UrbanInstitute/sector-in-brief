library(usethis)

bmf_link <- "<a href='https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf'>IRS Business Master Files</a>"
ntee_link <- "<a href='https://www.irs.gov/pub/irs-tege/p4838.pdf'>National Taxonomy of Exempt Entities (NTEE)</a>"
soi_link <- "<a href='https://www.irs.gov/statistics/soi-tax-stats-annual-extract-of-tax-exempt-organization-financial-data'>Statistics of Income (SOI)</a>"
tract_link <- "<a href='https://www2.census.gov/geo/pdfs/reference/GARM/Ch10GARM.pdf'>Census tract and block</a>"
nccs_link <- "<a href='https://urbaninstitute.github.io/nccs/'>website</a>"
unified_bmf_link <- "<a href='https://urbaninstitute.github.io/nccs/datasets/bmf/'>here</a>"
core_link <- "<a href='https://lecy.github.io/nccs/datasets/core/'>NCCS' Core Series</a>"
nccs_full_link <- "<a href='https://urbaninstitute.github.io/nccs/'>National Center for Charitable Statistics (NCCS)</a>"
unified_bmf_full_link <- "<a href='https://urbaninstitute.github.io/nccs/datasets/bmf/'>Unified Business Master Files (BMF)</a>"
daf_link <- "<a href='https://www.irs.gov/charities-non-profits/charitable-organizations/donor-advised-funds'>Donor Advised Fund</a>"
efile_link <- "<a href='https://lecy.github.io/nccs/datasets/efile/'>NCCS' E-Filer Catalog</a>"

about_title <- htmltools::div(class = "welcome-banner",
                              htmltools::div(
                                class = "welcome-header",
                                htmltools::h1(
                                  class = "text-3xl",
                                  "About",
                                  htmltools::p(
                                    class = "text-3xl-cyan",
                                    "Learn more about the data behind the Nonprofit Sector in Brief Explorer."
                                  )
                                )
                              ))

customization <- htmltools::div(class = "banner-light",
                                htmltools::div(
                                  class = "flex-box--column",
                                  bslib::accordion(
                                    open = FALSE,
                                    bslib::accordion_panel(
                                      title = htmltools::HTML("<b>Customization</b>"),
                                      htmltools::p(
                                        class = "subheader",
                                        "There are several ways to customize data visualizations and create panel datasets."
                                      ),
                                      bslib::accordion(
                                        open = FALSE,
                                        bslib::accordion_panel(
                                          title = htmltools::HTML("<b>Organization Type</b>"),
                                          htmltools::HTML(
                                            sprintf(
                                              "Organization type categories are derived from the subsector codes reported in the %s.",
                                              bmf_link
                                            )
                                          )
                                        ),
                                        bslib::accordion_panel(title = htmltools::HTML("<b>Subsector</b>"), htmltools::HTML(
                                          sprintf(
                                            "Subsectors are derived from the general categories of the %s codes reported in the IRS %s.",
                                            ntee_link,
                                            bmf_link
                                          )
                                        )),
                                        bslib::accordion_panel(
                                          title = htmltools::HTML("<b>Tax Year</b>"),
                                          htmltools::HTML(
                                            "Tax years are derived from the tax period provided in the Form 990, 990-EZ or 990-PF."
                                          )
                                        ),
                                        bslib::accordion_panel(title = htmltools::HTML("<b>Asset Size</b>"), htmltools::HTML(
                                          sprintf(
                                            "Asset size categories are derived from the total assets reported in the %s.",
                                            bmf_link
                                          )
                                        )),
                                        bslib::accordion_panel(
                                          title = htmltools::HTML("<b>Geography</b>"),
                                          htmltools::HTML(
                                            sprintf(
                                              "Geographic options are derived by mapping the addresses associated with each nonprofit in the %s to a Census region, state, county, and metro areas. core-based-statistical area using the Urban Institute’s proprietary geocoder (Urban Institute, 2020).",
                                              bmf_link
                                            )
                                          ),
                                          htmltools::tags$ul(
                                            htmltools::tags$li(
                                              htmltools::HTML(
                                                "Census regions divide all 51 US States into 4 units – Northeast, Midwest, South and West (U.S. Census Bureau) A map can be found <a href='https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf'>here</a>."
                                              )
                                            ),
                                            htmltools::tags$li(
                                              "Census Core-based Statistical Areas (CBSAs) consist of metropolitan (urban area of at least 50,000 inhabitants) and micropolitan areas (urban area containing between 10,000 and 50,000 inhabitants) (U.S Census Bureau, 2023). In this dashboard, metropolitan and micropolitan areas are jointly referred to as “Metro Areas” for brevity."
                                            ),
                                            htmltools::tags$li(
                                              htmltools::HTML(
                                                "Each address is mapped across multiple Census units using NCCS’ <a href='https://urbaninstitute.github.io/nccs/datasets/census/'>Census Crosswalks</a> (Davis & Lecy, 2023)."
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ))

data_sources <-
  htmltools::div(
    htmltools::p(
      class = "subheader",
      "Urban Institute’s National Center for Charitable Statistics (NCCS) derives the data used in the Nonprofit Sector in Brief Data Explorer from the Internal Revenue Service (IRS). Nonprofits, as tax exempt organizations, are required to complete IRS 990 series of Tax Forms annually. The specific 990 form a nonprofit must file is determined by their organization type and gross receipts/total assets (IRS, 2024). The table below breaks down the reporting requirements for each type of Form 990 and the NCCS data sets associated with each form. "
    ),
    bslib::accordion(
      open = FALSE,
      bslib::accordion_panel(
        title = htmltools::HTML("<b>Data Sets</b>"),
        data_source_table,
        htmltools::br(),
        htmltools::p(class = "subheader", htmltools::HTML(
          sprintf(
            "The IRS releases both electronically filed (e-filed) versions of individual tax filings and a compilation of selected financial variables from Form 990s in a series of %s (IRS, 2024). To analyze IRS data across tax years, NCCS standardizes names, data types, and definitions because variable names and definitions are not consistent year-over-year. Next, NCCS links tax records from every nonprofit filed between 1989 to 2022 in a single time-series panel, complete with geocoding to the %s levels for easy filtering through a process called harmonization. For more information, visit the NCCS %s.",
            soi_link,
            tract_link,
            nccs_link
          )
        )),
        htmltools::p(
          class = "subheader",
          "Data for the Visualize Data and Download Data tabs come from the following data sources:"
        )
      )
    ),
    bslib::accordion(
      open = FALSE,
      bslib::accordion_panel(title = htmltools::HTML("<b>Numbers</b>"), htmltools::HTML(
        sprintf(
          "Data on the number of nonprofits is derived from NCCS’ Unified Business Master Files (BMF), a compilation of all BMFs released by the IRS. A detailed description of this file is provided %s.",
          unified_bmf_link
        )
      )),
      bslib::accordion_panel(
        title = htmltools::HTML("<b>Finances and Private Foundation Grantmaking</b>"),
        htmltools::HTML(
          sprintf(
            "Data on nonprofit financials and private foundation grantmaking are derived from %s, which comes from the IRS’ %s for Form 990, 990-EZ and 990-PF. Currently NCCS has harmonized data for the 990 and 990-EZ panels through 2021. The 990-PFs are partially harmonized and will be fully processed in 2025.",
            core_link,
            soi_link
          )
        )
      ),
      bslib::accordion_panel(
        title = htmltools::HTML("<b>Donor Advised Funds</b>"),
        htmltools::HTML(
          "Data on donor advised funds (DAFs) is derived from Schedules A and D of e-filed Form 990s for tax year 2021. DAF data is only available via electronic filings and a complete sample of all e-filed tax records is only available starting in tax year 2021, which was the first year the IRS mandated e-filing."
        )
      ),
      bslib::accordion_panel(
        title = htmltools::HTML("<b>Download Data</b>"),
        htmltools::HTML(
          sprintf(
            "Data for the download tool is derived from the harmonized %s, derived from the IRS’ %s for Form 990 and 990-EZ. While the 2021 tax records are complete, the IRS is still releasing 2022 data and therefore, the 2022 data represents only a partial sample of nonprofits. Form 990-PF data on private foundations is currently harmonized for the variables that appear on the Visualize Data page and will be fully processed for the Download Data page by 2025.",
            core_link,
            soi_link
          )
        )
      )
    )
  )

credits <- htmltools::div(
  class = "subheader",
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
  about_title,
  customization,
  data_sources,
  bmf_link,
  ntee_link,
  soi_link,
  tract_link,
  nccs_link,
  unified_bmf_link,
  core_link,
  credits,
  welcome_about,
  internal = TRUE,
  overwrite = TRUE
)