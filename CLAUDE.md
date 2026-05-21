# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`sibApp` is the Sector-in-Brief Shiny dashboard for the Urban Institute's National Center for Charitable Statistics (NCCS). It is structured as an R package (see `DESCRIPTION`) but launched as a Shiny app. Dependencies are pinned via `renv` (`renv.lock`). Live deploy: https://nccs-urban.shinyapps.io/sector-in-brief/

## Common commands

Run from the repo root (an R session with `renv` activated by `.Rprofile`):

- Restore dependencies: `renv::restore()`
- Launch the app locally: `shiny::runApp(".")` — this is the authoritative path. The root `app.R` does `library(htmltools)`, `library(shinyWidgets)`, etc. before calling `app()`, which avoids the unqualified-namespace traps that `pkgload::load_all()` surfaces.
- For interactive iteration only: `pkgload::load_all()` then `app()`. Some bare-namespace calls in legacy files (e.g. `div(...)` instead of `htmltools::div(...)`) may fail this path until they are qualified.

## Data sync (ADR 0011)

`R/s3_sync.R` shells out to `aws s3 sync` at app startup to pull the parquet vintage from S3 into `data/`. No-op when the local `_manifest.json` already reports the target `VINTAGE`.

- Local dev with AWS SSO: set `SIB_AWS_PROFILE` in `.Renviron` (e.g. `SIB_AWS_PROFILE=thiya`)
- shinyapps.io / EC2: leave `SIB_AWS_PROFILE` unset; the default IAM credential chain is used
- Currently pointed at the sandbox prefix (`sector-in-brief-sandbox`). Flip `S3_PREFIX` to `sector-in-brief` once the producer publishes prod
- Bump `VINTAGE` when the producer publishes a new build

`R/s3_sync.R` also exports `publish_data_dictionary()` which writes `data/data_dictionary.parquet` to `www/data_dictionary.csv` (with a UTF-8 BOM for Excel) so the "Download data dictionary" links resolve.

## Architecture

One navbar Shiny app with thematic tabs: Welcome, About, Data Visualizations (Numbers / Finances / PF Grants / DAFs sub-tabs), Custom Panel Datasets. All files in `R/` are sourced as a flat namespace; functions are called by bare name.

- `R/app.R` — top-level UI + server. Calls `ensure_data_local()` + `publish_data_dictionary()` before assembling visualization panels.
- `R/visualpanel_args.R`, `R/visualpanel_builder.R`, `R/visualpanel_mapper.R` — driver tibble + builders for the 11 visualization panels.
- `R/data_ui.R`, `R/geo_filter_module.R`, `R/bslib_funcs.R` — filter cards (`filter_card_header` helper for tooltips on filter headers).
- `R/coverage_notes_card.R` — renders the producer's `coverage_notes` per panel as an inline accordion above the plots.
- `R/data_server.R`, `R/data_server_args.R`, `R/data_pipeline.R` — per-panel server pipeline (`format_input → validate_inputs → query_builder → filter_data → summarise_data → plots_build_all → render_outputs`).
- `R/dataloader.R` — wraps `arrow::read_parquet(..., col_select=cols)` and applies panel-specific filters (e.g. drops no-DAF cells from dollar-metric DAF views; clamps outliers on Number of DAFs / Total Assets).
- `R/query_builder.R`, `R/filter_data.R`, `R/summarise_data.R` — arrow-backed filtering and aggregation.
- `R/table_builder*.R`, `R/render_tables.R`, `R/render_outputs.R` — reactable + plot rendering dispatch.
- `R/plot_*.R`, `R/*_plot.R`, `R/plots_build_*.R` — ggplot2 + ggiraph plots. `plot_theme.R`, `colorpalette.R`, `scales.R` carry Urban Institute styling. `plots_build_single.R` short-circuits to `blank_plot()` for empty filter results.
- `R/text_about.R`, `R/visual_text.R`, `R/text_welcome.R`, `R/text_download.R`, `R/caption_*.R`, `R/tooltip_text.R` — copy/text content kept separate from logic.
- `R/data_download_dashboard.R`, `R/query_builder_download.R` — the "Custom Panel Datasets" download module (`dataRequestUI` / `dataRequestServer`).
- Internal package data: `R/sysdata.rda` (rebuilt by `usethis::use_data(..., internal=TRUE)` calls scattered in the `text_*.R` and `data.R` scripts when sourced).

## Data semantics

Producer ships these columns (cutover landed via PR #17, 2026-05):

- `Size` (1-6 expense band; 0 = BMF metadata but no CORE filing; **not** asset-based despite legacy naming)
- `Metro/Micro Area` (formerly `Census CBSA` — renamed for clarity; can be NA for rural counties)
- `Year` (tax year as reported on filing; formerly `Tax Year`)
- DAF panel covers every BMF-active cell (1M+ rows). Dollar metrics are NA for cells with no DAF activity; `dataloader.R` filters those out of dollar-metric DAF views, while DAF Proportion intentionally keeps them as the denominator.

Year ranges (from the current vintage):

| Panel | Years |
|---|---|
| Numbers | 1989-2026 |
| Finances / PF Grants | 1989-2023 (2024 is partial in the data) |
| DAFs | 2021-2023 (2020 has 0 holders, 2024 is partial) |

Geographic lookup is `data/nested_geographies.csv` — column names are spaces in the CSV but become dots after `read.csv()` (`Census.State`, `Census.County`, `Metro.Micro.Area`).

## Conventions

- File-per-function is the dominant pattern; filename usually matches the exported function name.
- Roxygen comments are inconsistent — match the surrounding file.
- Static assets (CSS, SVG, PNG, generated `data_dictionary.csv`) live in `www/` and are served by Shiny at `/`.
- Line endings: `.gitattributes` enforces LF.
- Namespace qualification is **inconsistent** in legacy files. The current direction is to qualify everything (`htmltools::div`, `shinyWidgets::create_tree`, etc.). Until that pass lands, `shiny::runApp(".")` is the safe execution path because the root `app.R` attaches the relevant packages.

## Related ADRs (in ../nccs-contracts/decisions/)

- **0010** — contracted producer for the dashboard's data
- **0011** — decouple dashboard from committed `data/*.parquet`; read from S3 instead. **Implemented**.

## Producer repo

Data is produced by `../sector-in-brief-data` (`UrbanInstitute/sector-in-brief-data`). When the columns or coverage notes need to change, the change starts there.
