# Per-panel descriptive copy for the 13 visualization panels (intro
# paragraphs shown above the filters via `visualpanel_content()`).
# Each variable here is referenced by name in `visualpanel_args`'s
# `panel_desc` column:
#   number_of_nonprofits, assets_desc, revenue_desc, expenses_desc,
#   benefits_desc, gov_grants_desc, grants_desc, pri_desc, daf_*_desc,
#   daf_proportion_desc
number_of_nonprofits <- htmltools::tagList(
  htmltools::p(
    "Understanding the number of nonprofit organizations registered with the IRS provides a sense of the overall size and growth of the sector. NCCS data encompass all tax-exempt ",
    htmltools::a(href = "https://www.irs.gov/charities-non-profits/exempt-organization-types", "501(c) classifications and subsectors,"),
    "including 501(c)(3) public charities and private foundations and 501(c)(4) organizations."
  ),
  
  htmltools::p(
    "The chart below shows the number of organizations for the nonprofit sector overall. Select the nonprofit sizes, geographies, and date range you're interested in to create a custom chart. Use the tabs above the chart to view your selections broken out by organization type, subsector, geography, or size."
  ),
  
  htmltools::p(
    class = "base",
    htmltools::tags$b("Data Source:"),
    "NCCS's ",
    htmltools::a(href = "https://urbaninstitute.github.io/nccs/datasets/bmf/", "Unified Business Master File,"),
    "which contains data processed from IRS Business Master Files for calendar years 1989 through 2024. This includes all nonprofits, even those with gross receipts less than or equal to $50,000.",
    htmltools::a(href = "data_dictionary.csv", "Download data dictionary.")
  )
)

finance_header <-
  htmltools::tagList(
    htmltools::h2("Finances"),
    htmltools::p(
      "The financial state of nonprofits reflects the resources available to nonprofits for meeting their missions. NCCS data encompass all tax-exempt ",
      htmltools::a(href = "https://www.irs.gov/charities-non-profits/exempt-organization-types", "501(c) classifications and subsectors,"),
      "including 501(c)3 public charities and private foundations and 501(c)4 organizations."
    ),
    htmltools::p(
      "Select a financial metric to view, and then use filters to customize the graph by organization type, subsector, size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or size."
    ),
    htmltools::p(
      class = "base",
      htmltools::tags$b("Data Source:"),
      "The Assets, Revenues, Expenses, and Benefits panels use ",
      htmltools::a(href = "https://lecy.github.io/nccs/datasets/core/", "NCCS's Core Series,"),
      "which contains data processed from the IRS's ",
      htmltools::a(href = "https://www.irs.gov/statistics/soi-tax-stats-annual-extract-of-tax-exempt-organization-financial-data", "Statistics of Income (SOI) extracts"),
      "for Forms 990, 990-EZ and 990-PF for tax years 1989 through 2023. The Government Grants panel uses NCCS's e-file data instead (see that panel for its source). These data do not include 990-N filers and thus exclude small nonprofits with gross receipts less than or equal to $50,000. More information can be found in the About page.",
      htmltools::a(href = "data_dictionary.csv", "Download data dictionary.")
    )
  )

revenue_desc <- htmltools::p(
  "An important indicator of fiscal inflows, revenue captures the sum of all contributions, grants, program service revenues, investment income, and other sources of revenue (see chart notes) found on lines 8 through 11 in Part I of Form 990."
)

assets_desc <- htmltools::p(
  "A nonprofit’s total assets include the sum of all cash, savings, investments, grants, accounts, loans, land, inventories, and other assets (see chart notes) that a nonprofit owns (total of column B of lines 1 through 15 of Part X of Form 990)."
)

expenses_desc <- htmltools::p(
  "Expenses show the spending that goes into operating nonprofit organizations in service of meeting their missions. Expenses are a combination of grants, benefits, salaries, fundraising fees, and other expenses (see chart notes) from lines 13 through 17 in Part I of Form 990."
)

benefits_desc <- htmltools::p(
  "Total benefits are the sum of salaries, wages, benefits, pension plan accruals and contributions, and the 401(k) and 403(b) contributions nonprofits pay to and on behalf of employees. It provides a measure of overall spending on nonprofit-sector employees."
)

# NOTE: the Data Source line below is an interim draft written from the
# producer's data dictionary (efile Phase 0, Form 990 Part VIII line 1e).
# Replace with the canonical NCCS e-file dataset citation when available.
gov_grants_desc <- htmltools::tagList(
  htmltools::p(
    "Government grants capture the dollar value of grants and contributions that nonprofits receive from government sources, reported on line 1e of Part VIII of Form 990. They reflect the role of public funding in supporting the nonprofit sector."
  ),
  htmltools::p(
    "Only organizations that file the full Form 990 report this figure; 990-EZ and 990-PF filers do not carry line 1e, and most filers report no government grants in a given year. Coverage begins in tax year 2021, the first year of full nonprofit 990 e-file records from the IRS."
  ),
  htmltools::p(
    class = "base",
    htmltools::tags$b("Data Source:"),
    "NCCS's e-file data, processed from line 1e of Part VIII of e-filed IRS Form 990 for tax years 2021 through 2023.",
    htmltools::a(href = "data_dictionary.csv", "Download data dictionary.")
  )
)

# Tab-level header shown above BOTH Private Foundation pills (Grants and
# Program-Related Investments). It must carry only facts shared by both
# panels — each panel's own data source and coverage caveats live in its
# `*_desc` (the two draw on different datasets and year ranges).
pf_header <- htmltools::tagList(
  htmltools::h2("Private Foundation Grantmaking"),
  htmltools::tagList(
    htmltools::p(
      "Private foundations, which are typically funded by an individual donor or family, are one of several sources of private funding available to public charities. This section summarizes how private foundations deploy their resources — through the grants they make and through program-related investments."
    ),
    htmltools::p(
      "Other foundations that receive funds from various sources and make grants, such as community foundations, are incorporated as public charities and not counted in private foundation data."
    ),
    htmltools::p(
      "Select a metric below, then use the filters to customize the chart by organization type, subsector, size, geography, or date range. Use the tabs above the chart to view your selections broken out by subsector, geography, or size."
    )
  )
)

grants_desc <- htmltools::tagList(
  htmltools::p(
    "Private foundation grants represent the dollar value of the grants these nonprofits allocate, calculated as the sum of gifts, grants, and contributions issued. It captures overall giving trends among private foundations."
  ),
  htmltools::p(
    "The IRS has not released tax records for tax years 2016 through 2018. Missing data points from these years are represented with a dotted line."
  ),
  htmltools::p(
    class = "base",
    htmltools::tags$b("Data Source:"),
    "NCCS's Core Series, which contains data processed from the IRS's Statistics of Income Extracts for Form 990-PF for tax years 1989 through 2023.",
    htmltools::a(href = "data_dictionary.csv", "Download data dictionary.")
  )
)

# NOTE: the Data Source line below is an interim draft written from the
# producer's data dictionary (efile Phase 0, Form 990-PF Part IX-B).
# Replace with the canonical NCCS e-file dataset citation when available.
pri_desc <- htmltools::tagList(
  htmltools::p(
    "Program-related investments (PRIs) are investments private foundations make primarily to advance their charitable mission rather than to generate income — for example, low-interest loans to nonprofits or equity stakes in mission-aligned enterprises. This metric sums the total PRIs reported by private foundations on Part IX-B of Form 990-PF."
  ),
  htmltools::p(
    "Only 990-PF filers report this figure, and most foundations report no PRIs in a given year. Coverage begins in tax year 2021, the first year of full nonprofit 990 e-file records from the IRS."
  ),
  htmltools::p(
    class = "base",
    htmltools::tags$b("Data Source:"),
    "NCCS's e-file data, processed from Part IX-B of e-filed IRS Form 990-PF for tax years 2021 through 2023.",
    htmltools::a(href = "data_dictionary.csv", "Download data dictionary.")
  )
)

daf_header <- htmltools::tagList(
  htmltools::h2("Donor-Advised Funds"),
  htmltools::p(
    "A ",
    htmltools::a(href = "https://www.irs.gov/charities-non-profits/charitable-organizations/donor-advised-funds", "donor-advised fund"),
    " (DAF) is a tool that allows individuals and organizations to contribute money and noncash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time. Public charities, which are the only type of nonprofits that hold DAFs, can have as many individual DAF accounts as they want. This section summarizes key trends in the use of DAFs as a giving tool."
  ),
  htmltools::p(
    "Data begin in tax year 2021 because this is the first year that full nonprofit 990 e-file records are available from the IRS."
  ),
  htmltools::p(
    "The chart below shows DAF data for all private foundations. Select the nonprofit sizes, geographies, and date range you're interested in to create a custom chart. Use the tabs above the chart to view your selections broken out by subsector, geography, or size."
  ),
  htmltools::p(
    class = "base",
    htmltools::tags$b("Data Source:"),
    htmltools::a(href = "https://lecy.github.io/nccs/datasets/efile/", "NCCS' E-Filer Catalog,"),
    "which contains data processed from Schedule D for e-filed IRS Form 990 in tax year 2021. This panel does not include 990-N data and thus excludes small nonprofits with gross receipts less than or equal to $50,000. ",
    htmltools::a(href = "data_dictionary.csv", "Download data dictionary.")
  )
)

daf_number_desc <-
  htmltools::p(
    "The aggregate number of DAF accounts that nonprofits sponsor reflects trends in DAF usage. One public charity can sponsor many accounts."
  )

daf_contributions_desc <-
  htmltools::p(
    "The aggregate value of the money that donors put into DAFs in a given tax year measures the size and scale of donors’ usage of DAFs."
  )

daf_value_desc <-
  htmltools::p(
    "The cumulative value of the money held in DAFs captures the value of DAF funds in a given tax year, indicating the funds available for future giving."
  )

daf_grants_desc <-
  htmltools::p(
    "The aggregate value of the grants made during the year from all DAFs measures overall charitable giving through DAFs."
  )

daf_proportion_desc <- htmltools::p(
  "Percentage of nonprofits that sponsor DAFs, defined as holding and operating DAF accounts, captures the prevalence of DAFs among public charities."
)

