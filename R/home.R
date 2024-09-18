page_home <- bslib::nav_panel(
  "Home",
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sib_style.css"),
    tags$style(
      HTML(
        "
        h2 {
          font-size: 2em;
          color: black;
          text-decoration: underline;
          text-underline-offset: 16px;
        }
        p {
          font-size: 1.0em;
          color: black;
        }
        "
      )
    )

  ),
  # Application title
  div(class = "title", "Nonprofit Sector In Brief"),
  div(
    class = "body",
    h2("Explore Nonprofit Data in the United States"),
    br(),
    p(
      "The National Center for Charitable Statistics (NCCS) has relaunched
        its Sector-In-Brief Report as a data tool that allows users to explore
        nonprofit tax data released by the IRS."
    )
  ),
  bslib::layout_columns(
    bslib::card(
      min_height = "400px",
      bslib::card_header(div(class = "header", "Sector Summary")),
      bsicons::bs_icon("graph-up-arrow", size = "8em", class = "rounded mx-auto d-block"),
      bslib::card_body(
        div(
          class = "body",
          "Explore yearly trends in the number of nonprofits, total
               revenues, total expenses, and total assets."
        ),
        shiny::actionButton("to_sector", label = "Sector Summary", style =
                              "color: #000000; background-color: #1696d2; border-color: #1696d2")
      )
    ),
    bslib::card(
      min_height = "400px",
      bslib::card_header(div(class = "header", "Private Foundations")),
      bsicons::bs_icon("buildings-fill", size = "8em", class = "rounded mx-auto d-block"),
      bslib::card_body(
        div(class = "body", "Explore yearly trends in the number and amount of
            grants from Private Foundations."),
        shiny::actionButton("to_pf", label = "Private Foundations", style =
                              "color: #000000; background-color: #1696d2; border-color: #1696d2")
      )
    ),
    bslib::card(
      min_height = "400px",
      bslib::card_header(div(class = "header", "Employment")),
      bsicons::bs_icon("tools", size = "8em", class = "rounded mx-auto d-block"),
      bslib::card_body(
        div(
          class = "body",
          "Explore yearly trends in benefits and payroll tax amounts for all
               nonprofits."
        ),
        shiny::actionButton("to_emp", label = "Employment", style = "color: #000000; background-color: #1696d2; border-color: #1696d2")
      )
    ),
    bslib::card(
      min_height = "400px",
      bslib::card_header(div(class = "header", "Donor Advised Funds (DAFs)")),
      bsicons::bs_icon("cash-stack", size = "8em", class = "rounded mx-auto d-block"),
      bslib::card_body(
        div(
          class = "body",
          "A summary of Donor Advised Fund (DAF) activity from e-file tax returns
          for the 2021 accounting period"
        ),
        shiny::actionButton("to_daf", label = "DAFs", style = "color: #000000; background-color: #1696d2; border-color: #1696d2")
      )
    )
  )
)