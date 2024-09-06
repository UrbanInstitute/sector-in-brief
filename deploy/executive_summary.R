########################
# Programmer: Thiyaghessan tpoongundranar@urban.org
# Date created: 2024-09-04
# Date of last revision: 2024-09-04
# Description: This script contains the executive summary for the sector in brief
########################

exec_summary <- bslib::nav_panel(
  "Executive Summary",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css"),
    tags$style(
      HTML(
        "
        h2 {
          font-size: 2em;
          color: black;
          text-decoration: underline;
          text-underline-offset: 8px;
        }
        "
      )
    )
    
  ),
  div(
    class = "title",
    "Nonprofit Sector In Brief"
  ),
  div(
    class = "body",
    h2("Highlights"),
    br(),
    p("The number of nonprofits has increased by 1.5% from 2019 to 2020."),
    p("Total revenues have increased by 3.5% from 2019 to 2020."),
    p("Total expenses have increased by 2.5% from 2019 to 2020."),
    p("Total assets have increased by 4.5% from 2019 to 2020.")
  ),
  div(
    h2("Number of Organizations"),
    br(),
    h3("All Nonprofits (Including Private Foundations)"),
    num_nonprofits_plot,
    p(
      "The number of nonprofits has increased from 1989 - 2024"
    ),
    h3("Public Charities"),
    num_nonprofits_plot,
    p(
      "Public Charities have displayed the strongest growth"
    ),
    h4("By Subsector"),
    div(
      bslib::card(
        "plot",
        num_nonprofits_subsector_plot
      )
    ),
    div(
      actionButton(
        "update_plot",
        "Explore Data",
        style = "margin-top: 32px; margin-left: 32px; color: cyan;"
      ),
    )
  )
)