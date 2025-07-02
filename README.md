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

* R version 2.10 or higher
* RStudio (optional, but recommended)

## Installation

1. Clone the repository with `git clone`
2. Install R packages

```r
renv::restore()
```
3. Run the app from the project root directory
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

The scripts are described in the order they are called.

* `app.R`: Main Shiny application file that initializes the app and defines the UI and server logic.
* `nav_panel-visuals.R`: Contains objects and functions used to create the layout for the visualization tabs.
* `text-visuals.R`: Contains the text and descriptions for the visualization tabs.
* `data_ui.R`: Contains the UI elements for the filters in the visuals tab.
* `options_nogeo.R`: Contains the UI elements for the filter options in the visuals tab.
* `geo_filter_module.R`: Contains the UI and server logic for the geographic filter module used in the visuals tab for geographic filtering.
* `urbn_ui_elements.R`: Contains custom UI elements and functions used throughout the application styled according to urban branding guidelines.

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