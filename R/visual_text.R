number_of_nonprofits <-
  htmltools::div(
    class = "var-sub-header",
    htmltools::p("Understanding the number of nonprofit organizations that are registered with the IRS provides a sense of the overall size of the nonprofit sector."),
    htmltools::p("Toggle the visualization options using the “Overall,” “By Subsector,” “By Geography,” and “By Asset Size” tabs on the top right of the visual panel for this metric."),
    htmltools::HTML(
      "<ul>
          <li>Overall: This view shows you one line containing data for all nonprofits in the filters you selected.</li>
          <li>By Subsector: This view shows you separate lines for each subsector.</li>
          <li>By Geography: This view shows you separate lines for each Census region.</li>
          <li>By Asset Size: This view shows you separate lines for each Asset Size.</li>
       </ul>"
    ),
    htmltools::p("Scroll below the chart to further customize the graphs by filtering the data that gets visualized. Once you are satisfied with your selections, click the “Visualize Data” button.")
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
      htmltools::p("This section visualizes selected fiscal metrics from the nonprofit sector to provide an overview of the sector’s fiscal dynamics."),
      htmltools::p("Select a specific metric with the buttons below and toggle the visualization options using the “Overall,” “By Subsector,” “By Geography,” and “By Asset Size” tabs on the top right of the visual panel for each metric."),
      htmltools::HTML(
        "<ul>
          <li>Overall: This view shows you one line containing data for all nonprofits in the filters you selected.</li>
          <li>By Subsector: This view shows you separate lines for each subsector.</li>
          <li>By Geography: This view shows you separate lines for each Census region.</li>
          <li>By Asset Size: This view shows you separate lines for each Asset Size.</li>
       </ul>"
      ),
      htmltools::p("Scroll below the chart to further customize the graphs by filtering the data that gets visualized. Once you are satisfied with your selections, click the “Visualize Data” button.")
    )
  )

revenue_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The sum of all contributions, grants, program service revenues, investment income etc. received by a nonprofit (total of lines 8 through 11 in Part I), is an important indicator of fiscal inflows tothe sector. It captures the trajectory of all monetary inflows, and when juxtaposed with total expenses, provides a measure of the sector’s fiscal health.")
)

assets_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The total assets, calculated as the sum of all cash, savings, investments, grants, accounts, loans, land, inventories etc. that a nonprofit owns (total of column B of lines 1 through 15 of Part X), provides a measure of the size and scale of the sector by aggregating the economic value of all forms of capital owned by a nonprofit.")
)

expenses_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The sum of all  grants, benefits, salaries, fundraising fees etc. nonprofits pay out (total of lines 13-17 in Part I), is an important indicator of the fiscal dynamics within the sector. It captures the trajectory of all monetary outflows and when combined with revenues, provides a measure of the sector’s fiscal health.")
)

benefits_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Total benefits, calculated as the sum of salaries, wages, benefits, pension plan accruals and contributions, and 401(k) and 403(n) contributions nonprofits pay to/on behalf of employees, provide a measure of the overall spending on employees in the sector.")
)

payroll_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Total payroll taxes, an estimate of the aggregate value of the taxes nonprofits and private foundations pay on employee earnings, provide a measure of human resource expenditures in the sector and consequently, a measure of the overall size of the labor market in the nonprofit sector. Since the Bureau of Labor Statistics (BLS) does not disaggregate employment figures by geography, subsector, organization type and asset sizes, payroll taxes provide a proxy measure of the size of the labor market at a more granular level."),
  htmltools::p("See Estimating Sector Size With Payroll Taxes for details about the estimation process.")
)

pf_header <- htmltools::div(
  class = "var-title-card",
  htmltools::div(
    class = "var-header",
    "Private Foundation Grantmaking"
  ),
  htmltools::div(
    class = "var-sub-header",
    htmltools::p("Private foundations are charitable organizations that typically receive most of their funding from a single source (e.g., a donor, family, or corporation) and primarily exist to make grants, rather than operate programs. This section visualizes selected grant making metrics from private foundations, excluding community and corporate foundations, to summarize key trends in private foundation giving. The IRS has not released tax records for tax years 2016 – 2018, thus points from these years are represented with a dotted line to indicate their incompleteness."),
    htmltools::p("Select a specific metric with the buttons below and toggle the visualization options using the “Overall,” “By Subsector,” “By Geography,” and “By Asset Size” tabs on the top right of the visual panel for each metric."),
    htmltools::HTML(
      "<ul>
          <li>Overall: This view shows you one line containing data for all nonprofits in the filters you selected.</li>
          <li>By Subsector: This view shows you separate lines for each subsector.</li>
          <li>By Geography: This view shows you separate lines for each Census region.</li>
          <li>By Asset Size: This view shows you separate lines for each Asset Size.</li>
       </ul>"
    ),
    htmltools::p("Scroll below the chart to further customize the graphs by filtering the data that gets visualized. Once you are satisfied with your selections, click the “Visualize Data” button.")
  )
)

grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("Total grants, calculated as the sum of gifts, grants and contributions issued by all private foundations(excludes community and corporate foundations), provide a measure of the overall trends in giving by private foundations.")
)

avg_grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The value of grants issued by the average private foundation (excludes community and corporate foundations), calculated by dividing total grants by the total number of private foundations, complements total grants by providing a measure of trends in giving by the average private foundation.")
)

daf_header <- htmltools::div(
  class = "var-title-card",
  htmltools::div(
    class = "var-header",
    "Donor Advised Funds"
  ),
  htmltools::div(
    class = "var-sub-header",
    htmltools::p("A donor advised fund (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time. This section visualizes various metrics on DAF activity across the nonprofit sector to summarize key trends in DAF usage."),
    htmltools::p("Select a specific metric with the buttons below and toggle the visualization options using the “Overall,” “By Subsector,” “By Geography,” and “By Asset Size” tabs on the top right of the visual panel for each metric."),
    htmltools::HTML(
      "<ul>
          <li>Overall: This view shows you one bar containing data for all nonprofits in the filters you selected.</li>
          <li>By Subsector: This view shows you separate bars for each subsector.</li>
          <li>By Geography: This view shows you separate bars for each Census region.</li>
          <li>By Asset Size: This view shows you separate bars for each Asset Size.</li>
       </ul>"
    ),
    htmltools::p("Scroll below the chart to further customize the graphs by filtering the data that gets visualized. Once you are satisfied with your selections, click the “Visualize Data” button.")
  )
)

daf_number_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The aggregate number of DAF accounts that nonprofits sponsor, provides a measure of growth in DAF usage in the sector and consequently their popularity as a tool for giving. Since one DAF sponsor can hold multiple DAF accounts, this metric is not indicative of how DAFs are distributed across the sector.")
)

daf_contributions_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The aggregate value of the money that donors put into the donor advised funds (DAFs) that nonprofits sponsor in a given tax year, provide a measure of the size, and consequently the scale of utilization of DAFs as a tool for donors in the nonprofit sector.")
)

daf_value_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The cumulative value of the money that nonprofits hold in the DAFs they sponsor measures the value of funds held in DAFs during a given tax year, and consequently an indicates the funds available for giving in the future.")
)

daf_grants_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The aggregate value of the grants made during the year from all DAFs, provides a measure of overall charitable giving that occurs via DAFs.")
)

daf_proportion_desc <- htmltools::div(
  class = "var-sub-header",
  htmltools::p("The percentage of nonprofits that sponsor a DAF, meaning they hold and operate funds for donors, provides a measure of DAF sponsorship rates in the nonprofit sector and correspondingly its distribution across the sector.")
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