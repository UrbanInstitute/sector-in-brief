# Welcome Page for sector in Brief
welcome <- bslib::nav_panel(
  title = "Welcome",
  htmltools::div(
    class = "welcome-banner",
    htmltools::div(
      class = "welcome-header",
     htmltools::h1(class = "text-3xl",
                   "Welcome to the National Center for Charitable Statistic's", 
                   htmltools::p(class = "text-3xl-cyan", "Sector In Brief")),
     htmltools::p(class = "leading-relaxed",
                   "A research tool for policymakers to visualize and download panel data 
                    derived directly from the IRS' Form 990.")
    )
  ),
  htmltools::div(
    class = "banner-light",
    htmltools::div(
      class = "flex-box--row",
      htmltools::div(
        class = "flex-box--column",
        htmltools::h1(class = "header--md",
                      "Visualize"),
        htmltools::p(class = "subheader",
                     htmltools::HTML("Visualize data on the <span style='color: #fdbf11'>
                     number of nonprofits</span>, <span style='color: #ec008b'>
                     nonprofit financials</span>,<span style='color: #55b748'>
                   private foundation grantmaking</span>, and 
                   <span style='color: #db2b27'>donor advised funds</span> extracted
                   directly from the Form 990."))
      ),
      htmltools::img(class = "img-box",
                     src = "ui-logo-rgb.png")
    )
  ),
  htmltools::div(
    class = "banner-light",
    htmltools::div(
      class = "flex-box--row",
      htmltools::div(
        class = "flex-box--column",
        htmltools::h1(class = "header--md",
                      "Download"),
        htmltools::p(class = "subheader",
                     "Assemble custom panel data sets from NCCS' archive of 
                      Form 990 data.")
      ),
      htmltools::img(class = "img-box",
                     src = "ui-logo-rgb.png")
    )
  )
)