number_of_nonprofits <-
  htmltools::div(
    class = "var-sub-header",
    htmltools::p("Understanding the number of nonprofit organizations registered with the IRS provides a sense of the overall size and growth of the nonprofit sector."),
    htmltools::p("Use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size.")
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
      htmltools::p("The financial state of nonprofits provides a sense of the resources available to serve communities, support the wellbeing of the workforce, and contribute to the tax base."),
      htmltools::p("Select which type of financial metric you would like to view, and then use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size.")
    )
  )

revenue_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The sum of all contributions, grants, program service revenues and investment income received by a nonprofit (total of lines 8 through 11 in Part I), is an important indicator of fiscal inflows tothe sector. It captures the trajectory of all monetary inflows, and when juxtaposed with total expenses, provides a measure of the sector’s fiscal health.")
)

assets_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The total assets of nonprofits provides a measure of the economic size and scale of the capital owned by a nonprofit. Total assets includes the sum of all cash, savings, investments, grants, accounts, loans, land, inventories and other assets that a nonprofit owns (total of column B of lines 1 through 15 of Part X),")
)

expenses_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Expenses show the spending that goes into operating nonprofit organizations in service of meeting their missions. Expenses are a combination of grants, benefits, salaries, fundraising fees, and other expenses from lines 13-17 in Part I of the Form 990.")
)

benefits_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Total benefits, calculated as the sum of salaries, wages, benefits, pension plan accruals and contributions, and 401(k) and 403(n) contributions nonprofits pay to/on behalf of employees, provide a measure of the overall spending on employees in the sector.")
)

payroll_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("An estimation of nonprofit payroll taxes on employee earnings provide a source of revenue to government and an estimate of the overall size of the nonprofit labor market."),
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
    htmltools::p("Trends in private foundation grantmaking provide a sense of funds available to public charities. Private foundations, an important source of funding to public charities, are charitable organizations that typically receive most of their funding from a single source, such as a donor, family, or corporation, and primarily exist to make grants, rather than operate programs (IRS, 2023). Grantmakers that receive funds from a variety of sources and make grants, such as community foundations, are incorporated as public charities and not counted in private foundation data."),
    htmltools::p("Note: The IRS has not released tax records for tax years 2016 – 2018, thus points from these years are represented with a dotted line to indicate their incompleteness."),
    htmltools::p("Use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size.")
  )
)

grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Total grants, calculated as the sum of gifts, grants and contributions issued by all private foundations, provide a measure of the overall trends in giving by private foundations.")
)

avg_grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p('The value of grants issued by the average private foundation (excludes community and corporate foundations), calculated by dividing total grants by the total number of private foundations, complements total grants by providing a measure of trends in giving by the average private foundation.')
)

daf_header <- htmltools::div(
  class = "var-title-card",
  htmltools::div(
    class = "var-header",
    "Donor Advised Funds"
  ),
  htmltools::div(
    class = "var-sub-header",
    htmltools::HTML("<p>A <a href='https://www.irs.gov/charities-non-profits/charitable-organizations/donor-advised-funds'>donor advised fund</a> (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time. Public charities, which are the only type of nonprofits that hold DAFs, can have as many individual DAF accounts as they want. This section summarizes key trends in the use of DAFs as a giving tool.</p>"),
    htmltools::p("Data begins in tax year 2021 because this is the first year complete records are available from Schedules A and D of e-filed Form 990s."),
    htmltools::p("Use filters to customize the graph by organization type, subsector, asset size, geography, or data range. Use the tabs to change the view from overall data to view by subsector, geography, or asset size.")
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
  htmltools::p("The cumulative value of the money held in DAFs measures the value of DAF funds in a given tax year, and consequently  indicates the funds available for giving in the future.")
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
  avg_grants_desc,
  daf_header,
  daf_number_desc,
  daf_contributions_desc,
  daf_value_desc,
  daf_grants_desc,
  daf_proportion_desc,
  overwrite = TRUE,
  internal = TRUE
)