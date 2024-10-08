# Welcome Page for sector in Brief
welcome <- bslib::nav_panel(
  title = "Welcome",
  htmltools::div(
    class = "welcome-banner",
    htmltools::div(
     class = "welcome-header",
     "Welcome to The National Center of Charitable Statistic's Research Data Tool.
      A research tool that allows you to both assemble and visualize panel data derived
     directly from the IRS' Form 990.",
    )
  ),
  htmltools::div(
    class = "banner-dark",
    htmltools::div(
      class = "welcome-header",
      htmltools::h2("Visualize Data"),
      htmltools::p("Explore data on the number of nonprofits, nonprofit financials,
                   private foundation grantmaking, and donor advised funds extracted
                   directly from the Form 990.")
    )
  ),
  htmltools::div(
    class = "banner-dark",
    htmltools::div(
      class = "welcome-header",
      htmltools::h2("Download Data"),
      htmltools::p("Explore data on the number of nonprofits, nonprofit financials,
                   private foundation grantmaking, and donor advised funds extracted
                   directly from the Form 990.")
    )
  )
)