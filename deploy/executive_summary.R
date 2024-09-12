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
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Nonprofit Sector Overview</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1, h2 {
            color: #2c3e50;
        }
        ul {
            padding-left: 20px;
        }
    </style>
</head>
<body>
    <h1>Nonprofit Sector Overview</h1>

    <h2>Nonprofits</h2>
    <p>The Sector Summary tab provides insights on the number and size of nonprofits, including private foundations:</p>
    <ul>
        <li><strong>Total number of nonprofits</strong> - The number of organizations that are registered with the Internal Revenue Service (IRS).</li>
        <li><strong>Financial indicators for nonprofits</strong> (including private foundations, expressed in millions of real 2021 dollars):
            <ul>
                <li>Total revenues - The aggregate funds nonprofits receive from all sources.</li>
                <li>Total expenses - The aggregate money nonprofits pay to achieve their missions and operate their organizations.</li>
                <li>Total assets - The aggregate value of everything nonprofits own.</li>
            </ul>
        </li>
    </ul>
    <p>Data on the total number of nonprofits are displayed by fiscal year. Financial data are displayed by tax year.</p>

    <h2>Private Foundations</h2>
    <p>Private foundations are charitable organizations that typically receive most of their funding from a single source and primarily exist to make grants, rather than operate programs.</p>
    <p>The graphs provide information about these grants:</p>
    <ul>
        <li>Total number of private foundations</li>
        <li>Total number of grants</li>
        <li>Grant values (in real 2021 dollars):
            <ul>
                <li>Median grant size</li>
                <li>Total amount of grants paid</li>
            </ul>
        </li>
    </ul>
    <p>Data are displayed by tax year.</p>

    <h2>Sector Employment</h2>
    <p>The nonprofit sector is a major contributor to the US economy. The graphs show some of the sector's contributions, expressed in real 2021 dollars:</p>
    <ul>
        <li>Total benefits - The aggregate value of salaries, wages, benefits, and pension plan contributions nonprofits and private foundations pay to/on behalf of employees.</li>
        <li>Total payroll taxes - The estimated aggregate value of the taxes nonprofits and private foundations pay on employee earnings.</li>
    </ul>
    <p>Data are displayed by tax year.</p>

    <h2>Donor Advised Funds (DAF)</h2>
    <p>A donor advised fund (DAF) is a tool that allows individuals and organizations to contribute money and non-cash assets to a giving account, receive an immediate tax deduction, and recommend grants to nonprofits at a later time.</p>
    <p>The snapshots display data about DAFs:</p>
    <ul>
        <li>Percentage of organizations that maintain a DAF</li>
        <li>Total number of DAFs</li>
        <li>Financial indicators (in millions of real 2021 dollars):
            <ul>
                <li>Total DAF contributions</li>
                <li>Total DAF grants</li>
                <li>Total DAF value</li>
            </ul>
        </li>
    </ul>
    <p>Data are from tax year 2021.</p>
</body>
</html>
        "
      )
    )
    
  )
)