# Script Header
# Title: Dashboard Assets
# Description: This script contains assets used in the shiny dashboard, such
# as cards and filters
# Programmer: Thiyaghessan Poongundranar - tpoongundranar@urban.org
# Date Created: 2024-08-05
# Date Last Edited: 2024-08-05

# Footers
plot_footer <- bslib::card_footer(
  div(
    p(tags$b("Source"), ": IRS Business Master File"),
    p(tags$b("Notes"), ": Data on the total number of nonprofits are displayed by fiscal year, meaning January through December of a given calendar year. They come from the IRS’s Exempt Organization Business Master File."),
    p("Private foundations are charitable organizations that typically receive most of their funding from a single source (e.g. a donor, family, or corporation) and primarily exist to make grants, rather than operate programs. All private foundations are 501(c)(3) organizations, so selecting other 501(c) types will return no data.")
  )
)

daf_footer <- bslib::card_footer(
  div(
    p(tags$b("Source"), ": IRS E-filings for Tax Year 2021"),
    p(tags$b("Notes"), ": The tax year is the 12-month period beginning in a given calendar year that nonprofits use to calculate their annual financial statements. "),
    p("•	Percentage of organizations that maintain a DAF – The percentage of nonprofits that sponsor a DAF, meaning they hold and operate funds for donors."),
    p("•	Total number of DAFs – The aggregate number of DAF accounts that nonprofits sponsor. One DAF sponsor can hold multiple DAF accounts. "),
    p("o	Total DAF contributions – The aggregate value of the money that donors put into the DAFs that nonprofits sponsor."),
    p("o	Total DAF grants – The aggregate value of the money that DAF sponsors disburse at the recommendation of donors."),
    p("o	Total DAF value – The aggregate value of the money that nonprofits hold in the DAFs they sponsor.")
  )
)