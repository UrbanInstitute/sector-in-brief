# Dashboard cutover handover

This file is a handover for the work needed in **this repo** (`sector-in-brief`) to consume the new parquet artifact produced by `../sector-in-brief-data`. Delete it once the cutover lands.

## Context

`../sector-in-brief-data` is the new producer of the parquet panels this dashboard reads. As of 2026-05-20 it has published a fresh sandbox vintage at:

```
s3://nccsdata/sector-in-brief-sandbox/v2026.05/
```

Contents (7 files):

- `number_nonprofits.parquet`
- `finances.parquet`
- `pf_grants.parquet`
- `daf.parquet` ← **shape changed in this vintage, see §"Substantive change" below**
- `nested_geographies.csv`
- `data_dictionary.parquet`
- `_manifest.json`

ADR `../nccs-contracts/decisions/0011-decouple-dashboard-from-committed-data.md` says the dashboard reads from S3, not from a committed `data/` directory. This dashboard currently still reads `data/*.parquet` locally (see `R/data_server_args.R` lines 14, 25, 36, 47, 58, 69, 80, 91, 102, 113, 124) — that's part of the cutover.

## Work to do (in order)

### 1. Rename three dimension columns to match the producer

Producer emits the cleaner names; dashboard still uses the old ones. 72 occurrences across `R/`. Run the grep yourself to see the full set:

```bash
grep -nE "Asset Size|Census CBSA|Tax Year" R/*.R
```

| Old (dashboard)   | New (producer)        | Why                                                                                                          |
| ----------------- | --------------------- | ------------------------------------------------------------------------------------------------------------ |
| `Asset Size`      | `Size`                | The band is computed from **expenses**, not assets. `Asset Size` was a misnomer.                              |
| `Census CBSA`     | `Metro/Micro Area`    | `Census CBSA` was a join-key name leaking into the UI. `Metro/Micro Area` is the OMB user-facing concept.    |
| `Tax Year`        | `Year`                | Producer emits `Year` everywhere. Same semantics (tax year as reported on the filing).                       |

Hotspots (not exhaustive — grep is the source of truth):

- `R/data_server_args.R` — central per-panel config; ~30 hits. **Start here.**
- `R/table_builder_proportion.R` lines 21+ — hardcoded `case_when` on `Asset Size`; rename and keep the band-to-label mapping.
- `R/data_pipeline.R` line 52 — `groupby_vars` list contains `"Asset Size"`.
- `R/data_ui.R` line 38 — UI label.
- `R/data_download_dashboard.R` lines 83, 152, 163 — download form labels.
- `R/caption_size.R`, `R/caption_geo.R`, `R/caption_year.R` — caption text.

UI labels (the bold headings users see) are a separate question from data columns — keep `Size` as the column name but you may want the **UI label** to remain something like "Organization Size" for clarity. Use judgment; the contract is column names, not button labels.

### 2. Substantive change: daf panel has `Number of Nonprofits` as a real column

Previously the DAF Proportion view ("% of nonprofits with DAFs") had to compute its denominator some other way. As of commit `853bfb5` in `../sector-in-brief-data`, `daf.parquet` includes:

- **`Number of Nonprofits`** (int32) — BMF active-window count per cell, same semantics as the `number_nonprofits` panel
- One row per **BMF-active cell**, not just cells with DAF filings (1,038,163 rows, up from ~6.8k)
- For cells with no DAF activity: `Has DAF = 0`, dollar metrics are `NA` (we do NOT fabricate $0)

`R/data_server_args.R` line 125 already references `"Number of Nonprofits"` in the DAF Proportion vars list — so the wiring may "just work" once the file is loaded. **Verify**: open the DAF Proportion view and confirm the denominator is the new column on `daf.parquet` (not joined from `number_nonprofits.parquet`). Look at `R/table_builder_proportion.R` — if it currently does a join to fetch the denominator, that logic can be deleted.

Also: `NA` dollar metrics for no-DAF-activity cells may surface as gaps in some plots. Decide per-view whether to filter to `Has DAF > 0` for dollar-metric views.

### 3. Point the loader at S3 (ADR 0011)

`R/dataloader.R` currently calls `arrow::read_parquet(path, ...)` where `path` is a relative `data/foo.parquet`. Per ADR 0011, the dashboard should read from S3 directly. Two options, pick one:

- **A. arrow S3 filesystem.** `arrow::s3_bucket("nccsdata")` and read by key. Pros: no local cache. Cons: every column-select roundtrips to S3 — may be slow for the Shiny page-spinner UX.
- **B. Download-once at app startup.** On `app.R` boot, `aws s3 sync s3://nccsdata/sector-in-brief/v{vintage}/ data/` (no profile needed at runtime if IAM is configured on the host). Pros: existing `read_parquet(path)` code unchanged. Cons: cold-start cost.

Recommend **B** for now — minimal churn. Sandbox prefix is `s3://nccsdata/sector-in-brief-sandbox/v2026.05/`; flip to prod once the producer publishes there.

The vintage string should come from config, not be hardcoded. Producer publishes `_manifest.json` alongside parquets — read its `vintage` field or list the prefix and pick the most recent `v*` directory.

### 4. Data dictionary

The dashboard currently links to `https://nccsdata.s3.us-east-1.amazonaws.com/dataexplorer/visuals/data_dictionary.xlsx` (old, in `R/visual_text.R` lines 19, 41, 81, 107). The new producer ships `data_dictionary.parquet` in each vintage with curated descriptions, source-table pointers, and `coverage_notes` (e.g., "1999 ~-50% legacy file is sparse"). Surface it in the dashboard — either rebuild the existing dictionary modal from the new parquet, or link out to a download URL. The `coverage_notes` field is the new bit worth surfacing prominently.

## Verification checklist

Before opening a PR:

- [ ] Grep `R/` for any remaining `Asset Size`, `Census CBSA`, `Tax Year` — should be zero in data-handling code (UI labels are case-by-case).
- [ ] All six panel views (Number of Nonprofits, Finances, PF Grants, DAF, DAF Proportion, Geo) render without "No Data Available".
- [ ] DAF Proportion view shows a sensible denominator (cell counts, not just DAF-filer counts).
- [ ] Year slider shows the correct range per panel:
  - `number_nonprofits`, `finances`: 1989–2024
  - `pf_grants`: 1989–2024
  - `daf`: 2021–2024
- [ ] Size filter shows expense-band labels (re-check `R/table_builder_proportion.R` case_when matches the producer's `derive_size` thresholds — see `../sector-in-brief-data/R/derive_dimensions.R`).
- [ ] Documented data gaps surface somewhere (1999 finances ~-50%, 2011-2016 pf_grants ~-50%, DAF coverage starts 2021).

## Useful pointers across repos

- Producer canonical output naming: `../sector-in-brief-data/CLAUDE.md` §"Output naming (authoritative)"
- Producer's data dictionary source: `../sector-in-brief-data/R/data_dictionary_curation.R`
- Producer's `derive_size`: `../sector-in-brief-data/R/derive_dimensions.R`
- Producer's resume memory: `/root/.claude/projects/-root-NCCS-sector-in-brief-data/memory/project-phase4-resume.md`
- ADR mandating cutover: `../nccs-contracts/decisions/0010-sector-in-brief-data-replaces-dataexplorer-data.md`
- ADR decoupling dashboard: `../nccs-contracts/decisions/0011-decouple-dashboard-from-committed-data.md`
- Output contract: `../nccs-contracts/contracts/sector-in-brief.yml`

## After this lands

Coordinate with the producer side:

1. Producer does a **prod** publish (`Rscript pipeline/run.R --prod` or `publish.yml` workflow) to `s3://nccsdata/sector-in-brief/v2026.05/` — gated on user instruction.
2. Dashboard PR merges, flipping its S3 prefix from `-sandbox/` to prod and bumping vintage.
3. Producer side archives `UrbanInstitute/nccs-dataexplorer-data` per ADR 0010.
