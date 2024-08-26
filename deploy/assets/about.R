page_about <- bslib::nav_panel(
  "About",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css")
  ),
  # Application title
  div(class = "title", "About"),
  div(
    class = "body",
    h2("What's In The Nonprofit Sector In Brief?"),
    br(),
    p(
      "The Sector In Brief summarizes key trends across 4 areas in the nonprofit
       sector."
    )
  ),
  div(
    h3("Sector Summary"),
    p(
      "The Sector Summary tab provides insights on the number and size of 
      nonprofits—excluding private foundations:"
    ),
    p(tags$ul(
      tags$li("Total number of nonprofits – The number of organizations that are 
      registered with the Internal Revenue Service (IRS)."),
      tags$li("Financial indicators for nonprofits—excluding private 
              foundations—expressed in millions of real (i.e., 
              inflation-adjusted) 2021 dollars. These data come from the annual 
              returns that nonprofits file with the IRS."),
      tags$ul(
        tags$li("Total revenues – The aggregate funds nonprofits receive from all sources."),
        tags$li("Total expenses – The aggregate money nonprofits pay to achieve their missions and operate their organizations."),
        tags$li("Total assets – The aggregate value of everything nonprofits own.")
      )
    )),
    p(
      "Data on the total number of nonprofits are displayed by fiscal year, 
      meaning January through December of a given calendar year. They come 
      from the IRS’s Exempt Organization Business Master File." 
    ),
    p(
      "Many nonprofits do not calculate their annual financial statements around
       the calendar year, so financial data are displayed by tax year, which is 
      the 12-month period beginning in a given calendar year that nonprofits 
      use to calculate their annual financial statements. These data come from 
      the annual returns that nonprofits file with the IRS."
    )
  ),
  div(
    h3("Private Foundations"),
    p("Private foundations are charitable organizations that typically receive 
      most of their funding from a single source (e.g. a donor, family, or 
      corporation) and primarily exist to make grants, rather than operate 
      programs. All private foundations are 501(c)(3) organizations, so 
      selecting other 501(c) types will return no data."),
    p("The graphs below provide information about these grants:"),
    p(tags$ul(
      tags$li("Total number of grants – The number of grants made by private 
      foundations."),
      tags$li("Total grant dollars – The aggregate amount of money private 
      foundations give away in grants."),
      tags$li("Grant values expressed in real (i.e., inflation-adjusted) 
              2021 dollars:"),
      tags$ul(
        tags$li("Median grant size – The median value of all grants that 
                private foundations reported making."),
        tags$li("o	Total amount of grants paid – The aggregate value of all 
                grants that private foundations reported making.")
      )
    )),
    p(
      "Data are displayed by tax year, which is the 12-month period beginning 
      in a given calendar year that private foundations use to calculate their 
      annual financial statements. These data come from the annual returns that 
      private foundations file with the IRS."
    )
  ),
  div(
    h3("Sector Employment"),
    p(
      "The nonprofit sector meets basic needs, strives to improves quality of 
      life, strengthens democracy, and more. It could not do this work without 
      the employees that power it. Because of the people power that is required 
      to fuel the sector, nonprofits and private foundations are major 
      contributors to the US economy."
    ),
    p(
      "The graphs below show some of the nonprofit sector’s contributions to the 
      economy, expressed in real (i.e., inflation-adjusted) 2021 dollars:"
    ),
    p(tags$ul(
      tags$li("Total benefits – The aggregate value of the salaries and wages, 
      benefits, pension plan accruals and contributions, and 401(k) and 403(b) 
      contributions nonprofits and private foundations pay to/on behalf of 
      employees."),
      tags$li("Total payroll taxes – The estimated aggregate value of the taxes 
      nonprofits and private foundations pay on employee earnings. See 
      Estimating Sector Size With Payroll Taxes for details about the 
      estimation process.")
    )),
    p(
      "Data are displayed by tax year, which is the 12-month period beginning in 
      a given calendar year that nonprofits use to calculate their annual 
      financial statements. These data come from the annual returns that 
      nonprofits file with the IRS."
    )
  ),
  div(
    h3("Donor Advised Funds (DAFs)"),
    p(
      "A donor advised fund (DAF) is a tool that allows individuals and 
      organizations to contribute money and non-cash assets to a giving account, 
      receive an immediate tax deduction, and recommend grants to nonprofits at 
      a later time."
    ),
    p(
      "The snapshots below display data about DAFs:"
    ),
    p(tags$ul(
      tags$li("Percentage of organizations that maintain a DAF – The percentage 
      of nonprofits that sponsor a DAF, meaning they hold and operate funds for 
      donors."),
      tags$li("Total number of DAFs – The aggregate number of DAF accounts that 
      nonprofits sponsor. One DAF sponsor can hold multiple DAF accounts."),
      tags$li("Financial indicators expressed in millions of real (i.e., 
              inflation-adjusted) 2021 dollars:"),
      tags$ul(
        tags$li("Total DAF contributions – The aggregate value of the money that 
                donors put into the DAFs that nonprofits sponsor."),
        tags$li("Total DAF grants – The aggregate value of the money that DAF 
                sponsors disburse at the recommendation of donors."),
        tags$li("Total DAF value – The aggregate value of the money that nonprofits 
                hold in the DAFs they sponsor.")
      )
    )),
    p(
      "Data are from tax year 2021, which is the 12-month period beginning in 
      2021 that nonprofits use to calculate their annual financial statements. 
      These data come from the annual returns that nonprofits file with the IRS."
    )
  )
)