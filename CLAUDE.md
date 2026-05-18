# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`sibApp` is the Sector-in-Brief Shiny dashboard for the Urban Institute's National Center for Charitable Statistics (NCCS). It is structured as an R package (see `DESCRIPTION`) but launched as a Shiny app. Dependencies are pinned via `renv` (`renv.lock`). Live deploy: https://nccs-urban.shinyapps.io/sector-in-brief/

## Common commands

Run from the repo root (an R session with `renv` activated by `.Rprofile`):

- Restore dependencies: `renv::restore()`
- Launch the app locally: `shiny::runApp("app.R")` (or `app()` from `R/app.R` after `pkgload::load_all()`).
- Run tests (shinytest2 snapshot): `Rscript tests/testthat.R` or `shinytest2::test_app()` in an R session.
- Load all `R/*.R` for interactive iteration: `pkgload::load_all()`.
- Deploy: `rsconnect::deployApp()`. Tracked deploy metadata lives in `deploy/rsconnect/shinyapps.io/<account>/`.

## Architecture

The app is one navbar Shiny app with several thematic tabs (Welcome, About, Data Visualizations, Custom Panel Datasets). All ~70 files in `R/` are sourced as a flat namespace by `pkgload::load_all()` — there is no `library(sibApp)`; functions are called by bare name.

Layout after the 2026-05 refactor (40 commits on `iss14`):

- `R/app.R` — UI/server entry point. `R/nav_panel-visuals.R` builds the Data Visualizations panels.
- `R/data_server.R` + `R/data_server_args.R` + `R/data_pipeline.R` — per-panel server pipeline: `format_input → validate_inputs → query_builder → filter_data → summarise_data → plots_build_all → render_outputs`.
- `R/query_builder.R`, `R/build_filters.R`, `R/summarise_data.R` — Arrow-backed querying of parquet in `data/` (loaded once at startup).
- `R/geo_filter_module.R` + `R/geo_choices.R` — geographic nesting (state → CBSA → county) driven by `data/nested_geographies.csv`.
- `R/render_outputs.R` — table and plot rendering dispatch.
- `R/table_builder*.R` — `reactable` tables, variants per panel type.
- `R/plot_*.R`, `*_plot.R`, `plots_build_*.R` — ggplot2 + ggiraph plot construction. `plot_theme.R`, `colorpalette.R`, `scales.R` implement the Urban Institute style.
- `R/urbn_ui_elements.R` — consolidated wrappers for Urban-themed bslib/shinyWidgets controls (replaces the pre-refactor `urbn_*.R` per-control files).
- `R/text-visuals.R`, `R/caption_*.R`, `R/text_*.R`, `R/tooltip_text.R` — copy/text content kept separate from logic.
- `R/options_nogeo.R` — non-geographic filter options.
- `R/data_download_dashboard.R` + `R/query_builder_download.R` — the "Custom Panel Datasets" download module (`dataRequestUI` / `dataRequestServer`).
- Internal package data: `R/sysdata.rda`. User-facing data: `data/*.parquet` loaded at runtime via `arrow::read_parquet()`.

## Data

`data/` parquet files (`number_nonprofits.parquet`, `finances.parquet`, `pf_grants.parquet`, `daf.parquet`) are **gitignored** — they're synced manually from `s3://nccsdata/sector-in-brief/`. The app cannot start without them on disk. ADR 0011 plans to fetch them from S3 on app startup.

CSV lookups (`data/nested_geographies.csv`, `data/panel_dd.csv`) are tracked.

## Conventions

- File-per-function is the dominant pattern; filename usually matches the exported function name.
- Roxygen comments are used inconsistently — match the surrounding file.
- Static assets (CSS, SVG, PNG) live in `www/` and are wired in via `htmltools::includeCSS("www/sib_style.css")` in `R/app.R`.
- Line endings: `.gitattributes` enforces LF; local `core.autocrlf=input` is set.

## Related ADRs (in ../nccs-contracts/decisions/)

- **0009** — repo hygiene (executed 2026-05-18).
- **0010** — contracted producer for the dashboard's data (blocks 0011).
- **0011** — decouple dashboard from committed `data/*.parquet`; read from S3 instead.
- **0012** — architecture refactor (deferred; the 2026-05 refactor on `iss14` did much of Layer 1 already).
