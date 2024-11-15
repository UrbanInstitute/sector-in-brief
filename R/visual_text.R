number_of_nonprofits <-
  htmltools::div(
    class = "var-sub-header",
    htmltools::p("Understanding the number of nonprofit organizations registered with the IRS provides a sense of the overall size and growth of the nonprofit sector. National Center for Charitable Statistics (NCCS) data encompasses the entire spectrum of tax-exempt organizations, which includes 501(c)3 public charities and private foundations, 501(c)4 organizations, and all the additional 501(c) classifications and subsectors."),
    htmltools::p("Use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size."),
    htmltools::div(
      class = "var-caption",
      htmltools::HTML(sprintf("<p>Data Source: NCCS’ %s, which contains data processed from IRS BMF for calendar years 1989-2024. This includes all nonprofits, even those with gross receipts less than or equal to $50,000.</p>", unified_bmf_full_link))
    )
  )

finance_header <-
  htmltools::div(
    class = "var-title-card",
    htmltools::div(
      class = "var-header",
      "Finances"
    ),
    htmltools::div(
      class = "var-sub-header",
      htmltools::p("The financial state of nonprofits provides a sense of the resources available to meet their missions. NCCS data encompasses the entire spectrum of tax-exempt organizations, which includes 501(c)3 public charities and private foundations, 501(c)4 organizations, and all the additional 501(c) classifications and subsectors."),
      htmltools::div(
        class = "var-caption",
        htmltools::p("Select which type of financial metric you would like to view, and then use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size."),
        htmltools::HTML(sprintf("<p>Data Source: %s, which contains data processed from the IRS’ %s Extracts for Form 990, 990-EZ and 990-PF for tax years 1989-2021. This panel does not include 990-N data and thus excludes small nonprofits with gross receipts less than or equal to $50,000. More information can be found in the About page.</p>", core_link, soi_link))
      )
    )
  )

revenue_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("An important indicator of fiscal inflows, revenue captures the sum of all contributions, grants, program service revenues, investment income, and other sources of revenue (see graph notes) found on lines 8 through 11 in Part I of the Form 990.")
)

assets_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Expenses show the spending that goes into operating nonprofit organizations in service of meeting their missions. Expenses are a combination of grants, benefits, salaries, fundraising fees, and other expenses (see graph notes) from lines 13-17 in Part I of the Form 990.")
)

expenses_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Expenses show the spending that goes into operating nonprofit organizations in service of meeting their missions. Expenses are a combination of grants, benefits, salaries, fundraising fees, and other expenses (see graph notes) from lines 13-17 in Part I of the Form 990.")
)

benefits_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Total benefits, calculated as the sum of salaries, wages, benefits, pension plan accruals and contributions, and 401(k) and 403(n) contributions nonprofits pay to/on behalf of employees, provides a measure of the overall spending on employees in the sector.")
)

payroll_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("An estimation of nonprofit payroll taxes on employee earnings provide a source of revenue to government and an estimate of the overall size of the nonprofit labor market. The estimate excludes smaller nonprofits, organizations exempt from annual filing requirements, and undercounts private foundations' payroll taxes. Due to these exclusions, this estimate understates the nonprofit sector's total labor market contribution."),
  htmltools::HTML("<p>See <a href='https://urbaninstitute.github.io/nccs/stories/payroll/'>Estimating Sector Size With Payroll Taxes</a> for details about the estimation process.</p>")
)

pf_header <- htmltools::div(
  class = "var-title-card",
  htmltools::div(
    class = "var-header",
    "Private Foundation Grantmaking"
  ),
  htmltools::div(
    class = "var-sub-header",
    htmltools::p("Trends in grantmaking by private foundations, one of several sources of private funding available to public charities, provide a sense of the grantmaking resources available from one type of private, institutional funder. Private foundations are typically funded by a single source, such as an individual donor or family. Other grantmakers that receive funds from a variety of sources and make grants, such as community foundations, are incorporated as public charities and not counted in private foundation data."),
    htmltools::p("The IRS has not released tax records for tax years 2016 – 2018, thus points from these years are represented with a dotted line to indicate their incompleteness."),
    htmltools::p("Use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size."),
    htmltools::p("Data Source: NCCS’ Core Series, which contains data processed from the IRS’ Statistics of Income Extracts for Form 990-PF for tax years 1989-2021.")
  )
)

grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The dollar value of grants allocated by private foundations, calculated as the sum of gifts, grants and contributions issued by all private foundations, provides a measure of the overall trends in giving by private foundations.")
)

daf_header <- htmltools::div(
  class = "var-title-card",
  htmltools::div(
    class = "var-header",
    "Donor Advised Funds"
  ),
  htmltools::div(
    class = "var-sub-header",
    htmltools::HTML(sprintf("<p>A %s (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time (IRS, 2024). Public charities, which are the only type of nonprofits that hold DAFs, can have as many individual DAF accounts as they want (IRS, 2024). This section summarizes key trends in the use of DAFs as a giving tool.</p>", daf_link)),
    htmltools::p("Data begins in tax year 2021 because this is the first year that full nonprofit 990 e-file records are available from the IRS."),
    htmltools::p("Use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size."),
    htmltools::HTML(sprintf("<p>Data Source: %s, which contains data processed from Schedule D for e-filed IRS Form 990 in tax year 2021. This panel does not include 990-N data and thus excludes small nonprofits with gross receipts less than or equal to $50,000.</p>", efile_link))
  )
)

daf_number_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The aggregate number of DAF accounts that nonprofits sponsor provides a measure of growth in DAF usage and their popularity as a tool for giving. One public charity can sponsor many accounts.")
)

daf_contributions_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The aggregate value of the money that donors put into DAFs in a given tax year provide a measure of the size and scale of DAF utilization by donors.")
)

daf_value_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The cumulative value of the money held in DAFs measures the value of DAF funds in a given tax year, and consequently indicates the funds available for giving in the future.")
)

daf_grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The aggregate value of the grants made during the year from all DAFs provides a measure of overall charitable giving through DAFs.")
)

daf_proportion_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The percentage of nonprofits that sponsor  DAFs, defined as holding and operating DAF accounts, provides a measure of the prevalence of DAFs among public charities.")
)

usethis::use_data(
  number_of_nonprofits,
  finance_header,
  revenue_desc,
  expenses_desc,
  benefits_desc,
  payroll_desc,
  pf_header,
  grants_desc,
  daf_header,
  daf_number_desc,
  daf_contributions_desc,
  daf_value_desc,
  daf_grants_desc,
  daf_proportion_desc,
  overwrite = TRUE,
  internal = TRUE
)