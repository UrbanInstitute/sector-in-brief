# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`sibApp` is the Sector-in-Brief Shiny dashboard for the Urban Institute's National Center for Charitable Statistics (NCCS). It is structured as an R package (see `DESCRIPTION`) but launched as a Shiny app. Dependencies are pinned via `renv` (`renv.lock`).

Deploys:
- Staging (auto on push to `main`): <https://urban-main.shinyapps.io/nccs-sector-in-brief-staging/>
- Prod new (auto on push to `prod`): <https://urban-main.shinyapps.io/sector-in-brief/>
- Prod legacy (no longer cited; kept live as a short-term fallback, slated for decommission): <https://nccs-urban.shinyapps.io/sector-in-brief/>

See `README.md` for the promotion model and `.github/workflows/deploy-{staging,prod}.yml` for the deploy automation.

## Common commands

Run from the repo root (an R session with `renv` activated by `.Rprofile`):

- Restore dependencies: `renv::restore()`
- Launch the app locally: `shiny::runApp(".")` — this is the authoritative path. The root `app.R` does `library(htmltools)`, `library(shinyWidgets)`, etc. before calling `app()`, which avoids the unqualified-namespace traps that `pkgload::load_all()` surfaces.
- For interactive iteration only: `pkgload::load_all()` then `app()`. Some bare-namespace calls in legacy files (e.g. `div(...)` instead of `htmltools::div(...)`) may fail this path until they are qualified.

## Data sync (ADR 0011)

`R/s3_sync.R` pulls the parquet vintage from S3 into `data/` at app startup via anonymous HTTPS (no AWS CLI, no credentials). The manifest is fetched first to enumerate files, then each file is downloaded. No-op when the local `_manifest.json` already reports the target `VINTAGE`.

- The bucket allows public `GetObject` on individual files but NOT anonymous `ListObjects` — that's why we drive enumeration from the manifest rather than using `aws s3 sync`. **No AWS credentials are needed** anywhere (locally, on shinyapps.io, or in CI). Important because institutional AWS accounts often rotate keys every 24 hours, which would break static-env-var setups.
- Reads from the prod prefix (`s3://nccsdata/sector-in-brief/v{VINTAGE}/`). The producer also publishes a `latest/` mirror, but the dashboard pins a specific `v*` tag so a new producer publish can't silently change shape — bump `VINTAGE` in a follow-up PR after testing the new build

`R/s3_sync.R` also exports `publish_data_dictionary()` which writes `data/data_dictionary.parquet` to `www/data_dictionary.csv` (with a UTF-8 BOM for Excel) so the "Download data dictionary" links resolve.

## Architecture

One navbar Shiny app with thematic tabs: Welcome, About, Data Visualizations (Numbers / Finances / PF Grants / DAFs sub-tabs), Custom Panel Datasets. All files in `R/` are sourced as a flat namespace; functions are called by bare name.

- `R/app.R` — top-level UI + server. Boot path: `ensure_data_local()` → `validate_parquet_schemas()` → `publish_data_dictionary()` → `resolve_visualpanel_year_ranges()` → `visualpanel_mapper()` → assemble `page_navbar` UI. URL bookmarking is enabled (`enableBookmarking = "url"`) so filter selections survive refresh and sharing.
- `R/visualpanel_args.R`, `R/visualpanel_builder.R`, `R/visualpanel_mapper.R`, `R/visualpanel_content.R` — driver tibble + builders for the 13 visualization panels. Panels are lazy: `visualpanel_builder` returns just a `uiOutput` placeholder; `visualpanel_content` mounts the heavy widgets on first tab activation.
- `R/data_ui.R`, `R/geo_filter_module.R`, `R/bslib_funcs.R` — filter sections inside the panel's `bslib::layout_sidebar`. Each section is wrapped in a `bslib::accordion_panel` (Date / Org Type / Geography open by default; Subsector + Size collapsed). `filter_card_header()` pairs a section title with a hover-info tooltip.
- `R/coverage_notes_card.R` — renders the producer's `coverage_notes` per panel as an inline accordion above the plots.
- `R/data_server.R`, `R/data_server_args.R`, `R/data_pipeline.R` — per-panel server pipeline (`format_input → validate_inputs → query_builder → filter_data → summarise_data → plots_build_all → render_outputs`). `data_server` also captures realized defaults on first mount (for the chip helper) and wires the Reset-filters observer.
- `R/filter_chip_labels.R`, `R/render_validation_messages.R` — active-filter chip text + inline validation rendering. Both pure-function tested.
- `R/dataloader.R` — wraps `arrow::read_parquet(..., col_select=cols)` and applies panel-specific filters (e.g. drops no-DAF cells from dollar-metric DAF views; clamps outliers on Number of DAFs / Total Assets).
- `R/query_builder.R`, `R/filter_data.R`, `R/summarise_data.R`, `R/query_cache.R` — arrow-backed filtering and aggregation. `query_cache` memoises the (filter+summarise) result on a digest of the query (50 MB max via `cachem::cache_disk`).
- `R/table_builder*.R`, `R/render_tables.R`, `R/render_outputs.R` — reactable + plot rendering dispatch.
- `R/plot_*.R`, `R/*_plot.R`, `R/plots_build_*.R` — ggplot2 + ggiraph plots. `plot_theme.R`, `colorpalette.R`, `scales.R` carry Urban Institute styling; `scales.R::y_scale_for(yvar)` is the per-metric y-axis factory (dollar / count / percent short-scale labels). Dispatch in `plots_build_single`: ≤3 unique years → bar plots (`multi_year_col_plot` or `group_col_plot`); ≥4 years → line plots. Empty results → `blank_plot()`.
- `R/expected_schema.R`, `R/validate_parquet_schemas.R` — schema contract validated at boot.
- `R/manifest_meta.R` — cached vintage + built_at_date read for the per-panel "Data through tax year X · vintage Y" indicator.
- `R/year_range.R` — manifest-driven year-range derivation for the date slider (auto-trims trailing partial-year publishes).
- `R/s3_sync.R` — anonymous-HTTPS fetch of the pinned vintage from S3 at boot.
- `R/text_about.R`, `R/visual_text.R`, `R/text_welcome.R`, `R/text_download.R`, `R/caption_*.R`, `R/tooltip_text.R` — copy/text content kept separate from logic.
- `R/data_download_dashboard.R`, `R/query_builder_download.R` — the "Custom Panel Datasets" download module (`dataRequestUI` / `dataRequestServer`).

## Data semantics

Producer ships these columns (cutover landed via PR #17, 2026-05):

- `Size` (1-6 expense band; 0 = BMF metadata but no CORE filing; **not** asset-based despite legacy naming)
- `Metro/Micro Area` (formerly `Census CBSA` — renamed for clarity; can be NA for rural counties)
- `County FIPS` / `CBSA Code` (v2026.07, ADR 0021) — the collision-proof identity keys the county + metro filters select on. Both **string**, leading zeros significant — never numeric-cast. `Census County` is now the canonical, de-duplicated name and is **NA for ambiguous/unresolved labels** (honest "unassigned" — e.g. a bare "Baltimore" that could be city or county). As of v2026.08 (ADR 0023) Connecticut is coordinate-resolved to its 9 post-2022 Census planning regions (GEOIDs 09110–09190), so CT rows now carry region names + FIPS + Metro/Micro instead of NA — coverage 99.9996% (2 off-grid orgs remain honestly NA). The dashboard filters by code, displays/groups by name (`R/geo_query.R`, `R/geo_filter_module.R`).
- `Year` (tax year as reported on filing; formerly `Tax Year`)
- DAF panel covers every BMF-active cell (1M+ rows). Dollar metrics are NA for cells with no DAF activity; `dataloader.R` filters those out of dollar-metric DAF views, while DAF Proportion intentionally keeps them as the denominator.

Year ranges (from the current vintage):

| Panel | Years |
|---|---|
| Numbers | 1989-2026 |
| Finances / PF Grants | 1989-2023 (2024 is partial in the data) |
| DAFs | 2021-2023 (2020 has 0 holders, 2024 is partial) |
| Government Grants / Program-Related Investments | 2021-2023 (e-file only; 2024 still arriving) |

Geographic lookup is `data/nested_geographies.csv`, loaded via `R/load_geo_df.R` (a data-derived allowlist of selectable geographies — NA-county rows dropped). Column names are spaces in the CSV but become dots after `read.csv()` (`Census.State`, `Census.County`, `County.FIPS`, `Metro.Micro.Area`, `CBSA.Code`, `Census.Region`). `load_geo_df()` forces `County.FIPS`/`CBSA.Code` to character (preserving leading zeros) and joins `CBSA.Type` from `data/cbsa_crosswalk.parquet` to drive the Metropolitan-vs-Micropolitan picker filter. The producer also publishes `county_fips_crosswalk.parquet` (carrying a `Resolution` flag) and `cbsa_crosswalk.parquet` (CBSA Type, CSA Code/Title) per ADR 0021.

## Conventions

- File-per-function is the dominant pattern; filename usually matches the exported function name.
- Roxygen style: file-level header explains the file's role; each exported function gets a one-line description + `@param` for non-obvious args. No `@title` boilerplate, no `@examples` (this is a Shiny app, not a package). Match the surrounding files for consistency — see PRs #36-#40 for the convention pass that established this.
- Static assets (CSS, SVG, PNG, generated `data_dictionary.csv`) live in `www/` and are served by Shiny at `/`.
- Custom CSS classes added during the UX refresh: `.panel-filter-sidebar`, `.filter-actions`, `.btn-reset`, `.filter-chip-row`, `.filter-chip`, `.filter-section`, `.filter-hint`, `.filter-header`, `.vintage-indicator`, `.validation-msg`.
- Line endings: `.gitattributes` enforces LF.
- Namespace qualification is **inconsistent** in legacy files. The current direction is to qualify everything (`htmltools::div`, `shinyWidgets::create_tree`, etc.). Until that pass lands, `shiny::runApp(".")` is the safe execution path because the root `app.R` attaches the relevant packages.

## Related ADRs (in ../nccs-contracts/decisions/)

- **0010** — contracted producer for the dashboard's data
- **0011** — decouple dashboard from committed `data/*.parquet`; read from S3 instead. **Implemented**.

## Producer repo

Data is produced by `../sector-in-brief-data` (`UrbanInstitute/sector-in-brief-data`). When the columns or coverage notes need to change, the change starts there.
