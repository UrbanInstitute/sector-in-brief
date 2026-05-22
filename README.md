# Nonprofit Sector In Brief Dashboard

This repository contains the code needed to create the [Nonprofit Sector In Brief Dashboard](https://nccs-urban.shinyapps.io/sector-in-brief/)
web application with R Shiny. 

# Overview

## Purpose

This dashboard makes data on nonprofits released by the IRS and processed by the
National Center for Charitable Statistics (NCCS) accessible to a wide audience. 
It provides visualizations and downloadable datasets that help users understand 
the nonprofit sector in the United States. The dashboard has 2 components:

1. **Visualizations**: Interactive charts and graphs that summarize key 
statistics about the nonprofit sector.
2. **Data Download**: A section where users can download custom curated 
datasets for further analysis.

## Target Audience

* **Visualizations**: Media, Research Analysts, Policymakers, and the General Public
* **Data Download**: Researchers, Data Scientists, and Developers

## Features

* Interactive visualizations of nonprofit sector statistics that can be filtered
and aggregated by organization type, geography, subsector and size.
  * Geographic units: Region, State, County, and Metro/Micro Area.
* Downloadable custom datasets of NCCS Core Files in CSV format using a 
serverless API architecture
* Responsive design that works on both desktop and mobile devices

## How it Works

The dashboard visualizes data using pre-processed parquet files created using 
NCCS's CORE, BMF and E-file datasets. The CORE and E-File data contains
financial metrics from tax years 1989 to 2021, while the BMF data contains
demographic information on nonprofits and has been geocoded to allow for
filtering and aggregation by region, state, county and metro/micro areas.

The download tab is a simple UI presenting a data request form that triggers 
AWS Athena via a serverless API. Once the request is processed, the user
receives an email containing the data and the associated data dictionary.

# Getting Started

## Prerequisites

* R version 4.0 or higher
* RStudio (optional, but recommended)

## Installation

1. Clone the repository with `git clone`
2. Install R packages

```r
renv::restore()
```

3. Configure AWS credentials so the app can sync the parquet data from
   `s3://nccsdata/sector-in-brief/` on startup (per ADR 0011 — the data
   is no longer committed). Locally with AWS SSO, set `SIB_AWS_PROFILE`
   in `.Renviron`; on shinyapps.io / EC2 the default IAM credential
   chain is used.

4. Run the app from the project root directory

```r
shiny::runApp()
```

# Application Structure

## Directory Layout

```
.
├── app.R                # Main Shiny application file
├── data                 # Directory for parquet files containing data used in visualization tabs
├── deploy               # Directory for deployment scripts and configuration files created with rsconnect
├── R                    # Directory for custom R functions and modules
├── www                  # Directory for static assets (CSS, JavaScript, images)
├── README.md            # This file
└── DESCRIPTION          # R package metadata file
```

## Scripts

The scripts in `R/` are sourced as a flat namespace by Shiny. Key files:

* `app.R` (root): entry point that calls `app()` from `R/app.R`.
* `R/app.R`: top-level UI + server. Triggers `ensure_data_local()` and `publish_data_dictionary()` at startup.
* `R/s3_sync.R`: shells out to `aws s3 sync` to pull the current vintage from S3 (no-op when the local manifest matches).
* `R/visualpanel_args.R`, `R/visualpanel_builder.R`, `R/visualpanel_mapper.R`: per-visualization-tab UI assembly.
* `R/data_ui.R`, `R/geo_filter_module.R`: filter cards (Organization Type, Subsector, Size, Date, Geography).
* `R/coverage_notes_card.R`: surfaces the producer's `coverage_notes` per panel as an inline accordion.
* `R/data_server.R`, `R/data_server_args.R`, `R/data_pipeline.R`: per-panel server pipeline.
* `R/dataloader.R`, `R/filter_data.R`, `R/query_builder.R`, `R/summarise_data.R`: arrow-backed querying.
* `R/table_builder*.R`, `R/render_tables.R`, `R/render_outputs.R`: reactable + plot dispatch.
* `R/plot_*.R`, `R/*_plot.R`, `R/plots_build_*.R`: ggplot2 + ggiraph chart construction.
* `R/text_about.R`, `R/visual_text.R`, `R/text_welcome.R`, `R/text_download.R`: copy/text content separated from logic.
* `R/data_download_dashboard.R`, `R/query_builder_download.R`: "Custom Panel Datasets" download module.

# Data

Visualization data lives in `data/` as parquet files
(`number_nonprofits.parquet`, `finances.parquet`, `pf_grants.parquet`,
`daf.parquet`) plus a curated dictionary (`data_dictionary.parquet`),
a manifest (`_manifest.json`), and a geography lookup
(`nested_geographies.csv`). The parquet files and manifest are
gitignored — the app pulls them from
`s3://nccsdata/sector-in-brief/v{VINTAGE}/` on startup via
`R/s3_sync.R` (see ADR 0011). Bump `VINTAGE` in `R/s3_sync.R` when the
producer (`sector-in-brief-data`) publishes a new build.

# Deployment

Two environments, both on the **urban-main** shinyapps.io account,
both on the **Xlarge instance (8 GB RAM)**:

| Env | URL | Trigger |
|---|---|---|
| **Staging** | <https://urban-main.shinyapps.io/nccs-sector-in-brief-staging/> | Auto on push to `main` (`deploy-staging.yml`) |
| **Production** | <https://urban-main.shinyapps.io/sector-in-brief/> | Auto on push to `prod` (`deploy-prod.yml`) |

There's a separate **legacy** prod URL at
<https://nccs-urban.shinyapps.io/sector-in-brief/> that remains the
publicly cited link until the migration to urban-main is announced.
Update external references and `R/text_welcome.R`'s citation when
that flip happens.

## Promotion model

1. PRs land on `main` → staging auto-redeploys.
2. Verify staging with `docs/UI_TESTING.md`.
3. Promote staging → prod with `git push origin main:prod` (or a PR
   from `main` into `prod`). The prod workflow fires and redeploys
   production.
4. Rollback: revert the `prod` branch to the previous commit, push,
   the workflow redeploys.

The `prod` branch *is* the answer to "what's in production right now?".

## Data + secrets

Data is **not** bundled into the deploy artifact — the runtime pulls
the pinned vintage from S3 at boot per `R/s3_sync.R` (ADR 0011). The
shinyapps.io app needs `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY`
set as per-app environment variables (in the shinyapps.io dashboard,
not the GitHub repo) so the default IAM credential chain can reach
the `nccsdata` bucket.

CI auth uses two repo Actions secrets shared by both workflows:
`SHINYAPPS_TOKEN`, `SHINYAPPS_SECRET`. Generate from the urban-main
shinyapps.io account: Tokens → Add Token.

Bump `VINTAGE` in `R/s3_sync.R` when the producer
(`sector-in-brief-data`) publishes a new build, then merge to `main`
to roll staging. Promote to prod once staging verification passes.

Deploy metadata is committed under
`deploy/rsconnect/shinyapps.io/<account>/`. The runtime `rsconnect/`
directory at the repo root is auto-generated and gitignored.

# License

MIT. See [LICENSE.md](LICENSE.md). Copyright Urban Institute, 2024-2026.

### Script Headers

Each script comes with a script header structured as follows:

```
#------------------------------------------------------------------------------
# File: <filename>
# Author: <author>
# Date Created: <date first created>
# Date Last Modified: <date last modified>
# Purpose: <brief description of the script's purpose>
# Usage: <how to use the script>
# Dependencies: <list of packages or other scripts required>
# Notes: <any additional notes or comments>
#------------------------------------------------------------------------------
```