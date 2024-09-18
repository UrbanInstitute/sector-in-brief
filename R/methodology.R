page_methodology <- bslib::nav_panel(
  "Methodology",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css")
  ),
  # Application title
  div(class = "title", "Methodology"),
  div(
    h2("Data Sources"),
    br(),
    h3("Sector Summary"),
    p(
      "The data used in the Sector Summary is derived from the the IRS’s Exempt 
      Organization Business Master File and Annual extract of tax-exempt 
      organization financial data."
    )
  ),
  div(
    h3("Private Foundations"),
    p(
      "Data for private foundations is derived from the Annual extract of 
      tax-exempt organization financial data. The IRS has yet to release
      data for private foundations for fiscal years 2016-2019. Hence,
      the line graph is dotted for those missing years."
    )
  ),
  div(
    h3("Sector Employment"),
    p(
      "Data for benefits and payroll taxes are derived from the 
       IRS' Annual extract of tax-exempt organization financial data."
    )
  ),
  div(
    h3("Donor Advised Funds"),
    p(
      "Data for Donor Advised Funds are derived from IRS E-file data 
      for tax year 2021. This is because only e-file data for tax year 2021
      has complete coverage of the population of nonprofits."
    )
  ),
  div(
    h2("Variable Definitions")
  ),
  div(
    h3("Tax Year vs Filing Year"),
    p(
      "Filing Year - The year the tax return was filed."
    ),
    p("Tax Year - The accounting period for which the tax return is filed."),
    p("These are not always identical. For example, a nonprofit can file
       a tax return in 2022 (filing year) for 2021 (tax year).")
  ),
  div(
    h2("Methods Used"),
    br(),
    p("All variables are computed directly from their source files except for
       the following:")
  ),
  div(
    h3("Total Benefits"),
    p(
      "Total benefits – The aggregate value of the salaries and wages, benefits,
      pension plan accruals and contributions, and 401(k) and 403(b) 
      contributions nonprofits and private foundations pay to/on behalf of 
      employees"
    )
  ),
  div(
    h3("Payroll Taxes"),
    p(
      "Total payroll taxes – The estimated aggregate value of the taxes 
      nonprofits and private foundations pay on employee earnings. 
      See",
      a("Estimating Sector Size With Payroll Taxes", 
        href = "https://urbaninstitute.github.io/nccs/stories/payroll/")
      ,
      "for details about the estimation process."
    )
  )
)