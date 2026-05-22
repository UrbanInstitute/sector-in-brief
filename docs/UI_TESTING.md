# Manual UI Testing Checklist

A pre-release smoke test for the Sector-in-Brief dashboard. Designed
to be runnable in 15-25 minutes by anyone with the app in front of
them. Catches the classes of regressions that the automated test
suite (`tests/testthat/`) and the boot smoke test (`test-app_boot.R`)
can't see — visual layout, interactive plot behavior, cascading
filter UI, end-to-end download flows.

**Who runs this:** any analyst on the team. No programmatic setup —
you do not need R, RStudio, or the repo cloned locally. Just open the
staging URL in a browser.

**Staging URL:** <https://urban-main.shinyapps.io/nccs-sector-in-brief-staging/>

**Run before:** every release to production. Trigger is any PR
landing on `main` that touches `R/app.R`, the filter cards
(`R/data_ui.R`, `R/geo_filter_module.R`), the plot/table builders,
the Custom Panel Datasets module, or the data sync (`R/s3_sync.R`).

**Production runtime:** the dashboard deploys to an **Xlarge
shinyapps.io instance with 8 GB RAM**. Staging matches this so what
you see in staging is what production will see — keep that in mind
when judging "is this fast enough?".

Format: each row has a step you take and the expected outcome. If a
step's expected outcome doesn't happen, that's a bug — log it and
keep going (don't bail). Boxes are for tick-marking during the run.

---

## 1. Boot & branding (~1 min)

- [ ] App loads at the staging URL within ~3-5 seconds on a cold start (first hit of the day) or ~1-2 seconds on a warm start. shinyapps.io spins down idle instances, so the first hit after a quiet period pays the spin-up tax. Anything over ~10s on a cold start, or over ~3s on a warm one, is a regression worth flagging.
- [ ] No error banner or visible crash on load.
- [ ] Urban Institute logo + "| National Center for Charitable Statistics" appears in the navbar (or "| NCCS" if the window is narrow — resize to confirm both states render).
- [ ] No "Data may be stale" yellow banner across the top (unless you've intentionally broken S3 sync).
- [ ] Footer "We want your Feedback" link is present and points to the Qualtrics URL.

## 2. Welcome & About tabs (~2 min)

- [ ] **Welcome** tab is selected by default and renders:
  - Title + subtitle box
  - 5 intro paragraphs
  - Two "what's inside" sections (Visualizations + Downloads, each with an icon)
  - Credits block at the bottom
- [ ] Welcome-page **"Visualize"** internal link jumps to the Finances tab.
- [ ] Welcome-page **"Download"** internal link jumps to the Custom Panel Datasets tab.
- [ ] **About** tab renders without errors. Four accordion sections (Customization, Data Sources, Variations, FAQ) are present and collapsed by default.
- [ ] Expanding the Data Sources accordion shows the IRS-vs-NCCS reactable table cleanly (no overflow, columns readable).

## 3. Data Visualizations — happy path for one panel (~5 min)

Pick the **Numbers** panel for the canonical happy-path run.

- [ ] Click Data Visualizations → Numbers. Panel content appears within ~1s (lazy load; first activation pays the cost, subsequent ones are instant).
- [ ] Panel header reads "Number of Nonprofits" with a descriptive paragraph below it.
- [ ] Coverage notes accordion is collapsed by default. Expand it — bulleted list of documented data gaps appears.
- [ ] Five filter cards are present in this order: Organization Type, Subsector, Organization Size, Geographic Filters, Date Range. Each header has an info-icon tooltip on hover.
- [ ] Default selections match: Organization Type = "501(c)(3) Organizations" + "501(c)(4) - Social Welfare Organizations" + "Other Nonprofits"; all 12 subsectors checked; all 6 size bands checked; Geo = National; Date range = full 1989-present.
- [ ] **Without changing anything**, the Overall plot is already rendered (auto-rendered on tab activation). Plot is a smooth blue line trending upward over time, with caption text underneath listing the active filters.
- [ ] Click the "By Geography" sub-tab. Plot redraws as 4 colored lines (Northeast / Midwest / South / West) — confirming the National-→-4-regions rewrite.
- [ ] Hover any data point. A tooltip appears with bold labels and a comma-separated number.
- [ ] Click the **View Data** accordion under the plot. A reactable table appears. Sort by clicking a column header. Page through if more than 10 rows.
- [ ] Click **DOWNLOAD TABLE**. A CSV downloads with a sensible name (e.g. `by_geo.csv`). Open it; columns and rows match the on-screen table.

## 4. Filter behavior (~5 min)

### Organization Type tree

- [ ] Click the "501(c)(3) Organizations" parent node. All children (Public Charities, Private Foundations) become checked.
- [ ] Uncheck a single child. Parent shows partial-selected state.

### Subsector + Size

- [ ] Uncheck every subsector. Click UPDATE DATA. An inline message appears under the Subsector card ("Please select at least one subsector."). The plot does not change.
- [ ] Recheck one subsector. Uncheck every size band. Click UPDATE DATA. Message appears under the Size card; the subsector message is gone (only the active error shows per card).

### Geographic Filters (cascade behavior)

- [ ] Switch geo level to "Census Region". Region selectize appears (Northeast/South/Midwest/West). State/County/Metro selectizes are hidden.
- [ ] Switch to "Census State". Up to 5 states selectable (try a 6th — the selectize blocks it).
- [ ] Switch to "Census County". State + County selectizes appear. With state empty, click UPDATE DATA — message says "Please select at least one county." (The "select a state" path is dead because Shiny auto-preselects the first state.)
- [ ] Switch to "Metro/Micro Area". State auto-preselected; CBSA selectize available with maxItems=5.
- [ ] Verify state→county cascade: pick a different state, the County options refresh to that state's counties.
- [ ] Verify state→CBSA cascade: same flow, CBSA options refresh.

### Date Range

- [ ] Slider bounds match the panel's year coverage (Numbers: 1989-present; DAF panels: 2021-2023; PF: 1989-2023). Drag both handles together to a single year and confirm the plot redraws as a single bar/lollipop, not a line.

## 5. Per-panel quick checks (~3 min)

For each panel below, just confirm the Overall plot draws without errors and the caption text is present. **You do not need to exhaustively re-run filter tests.**

- [ ] **Numbers** — already covered in §3.
- [ ] **Finances → Assets** — dollar y-axis with "$" prefix in tooltip.
- [ ] **Finances → Revenues** — caption mentions "Other revenue sources" disclaimer.
- [ ] **Finances → Expenses** — caption mentions "Other expenses" disclaimer.
- [ ] **Finances → Benefits** — draws without error.
- [ ] **Private Foundation Grants** — change Organization Type to include "Private Foundations" — the plot should show a dashed line spanning 2016-2018 (NA gap) rather than a zero or a jump. Caption appends "The IRS has not released 990 PF tax records for tax years 2016 through 2018."
- [ ] **DAFs → Number of DAFs** — bar chart, not a line (single year per `data_server_args::time_series=FALSE`).
- [ ] **DAFs → DAF Contributions / DAF Grants / DAF Value** — same single-year bar style; dollar y-axis.
- [ ] **DAFs → DAF Proportion** — percentage y-axis ("Percentage" label, not "$").

## 6. Custom Panel Datasets (~3 min)

- [ ] Click Custom Panel Datasets. Page renders with the request form (multi-step accordion of "Form Type / Variables / Filters / Confirm" or similar).
- [ ] Fill out a minimal request: any form type, default vars, no special filters, your own test email. Submit.
- [ ] Confirmation modal appears stating the request has been received. (For local dev, the actual POST to the NCCS data-extract API may fail — that's fine; you're testing the UI flow, not the backend.)
- [ ] The "Download data dictionary" link on this page resolves to `www/data_dictionary.csv` and the file actually opens with readable column names (no `?` mojibake — the UTF-8 BOM in `publish_data_dictionary()` is what makes Excel render dashes correctly).

## 7. Error & validation paths (~2 min)

- [ ] **Inline validation**: clear every Subsector AND every Size checkbox simultaneously, click UPDATE DATA. **Both** messages appear (one under each card). The pre-fix bug only showed the last error.
- [ ] **Runtime error modal**: hard to provoke from staging without a code change. Skip unless a developer flags a specific case to test. If the modal does appear during normal use, that *is* a bug to log — title is "Something went wrong" with an expandable Technical detail section.
- [ ] **Schema contract**: not testable from the UI; this is a developer-only check enforced at app boot (see `test-validate_parquet_schemas.R`). Skip.

## 8. Cross-cutting visual checks (~2 min)

- [ ] Reactable rows alternate striped colors (light-gray bands).
- [ ] All filter card headers are aligned consistently (same height, same font weight).
- [ ] Plot caption text wraps at a reasonable width — no horizontal scroll bar at the bottom of any panel.
- [ ] Loading spinner appears (Urban-themed colored circles) when UPDATE DATA is mid-flight.
- [ ] The UPDATE DATA button is labeled "UPDATE DATA" idle and "VISUALIZING..." in-flight.

## 9. Known issues / not-yet-fixed

These are tracked separately and are **not** regressions to log:

- A `bslib` warning at boot ("Navigation containers expect ...") because `tags$head` is passed positionally to `page_navbar` in `R/app.R:29-31`. Cosmetic; queued for a fix.
- `R/caption_year.R` hardcodes "until tax year 2021" in caption text. Stale literal; queued for a fix that derives from the manifest.
- The Geographic Filters card has no "Reset" button next to its label, while some early UI sketches suggested one. Intentional (the geo_level radio acts as the reset).
- The PF panel's 2016-2018 NA handling shows a dashed line gap; this is by design (`table_builder_pf.R`).

## 10. Mobile (deferred)

The dashboard is not yet optimized for phone screens. A separate track will address:
- Filter cards stacking vertically below ~768px
- Navbar nav-menu collapsing into a hamburger
- Reactable horizontal scroll on narrow screens
- Touch-target sizing on radios/checkboxes

When that track lands, this section will be replaced with mobile-specific checks.

---

**When you find a bug:** write up the panel name, the exact filter combination, a screenshot if it's visual, and the section heading from this checklist that failed. Send to the dev team (GitHub issue if you have access; email or Slack otherwise).
